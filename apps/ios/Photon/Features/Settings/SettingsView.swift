//
//  SettingsView.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import SwiftUI
import UserNotifications

/// Profile and Settings screen managing user profile data, notification permissions,
/// membership tiers, privacy commitments, and the special dedicated Easter Egg.
public struct SettingsView: View {
    @Environment(NavigationState.self) private var navigationState
    @State private var authService = AuthService.shared
    
    // Phone Number Editing State
    @State private var phoneNumberText: String = ""
    @State private var isEditingPhone: Bool = false
    @State private var phoneSavedFeedback: Bool = false
    
    // Notification Permission State
    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined
    
    // Membership Sheet State
    @State private var showMembershipSheet: Bool = false
    
    // Easter Egg State (3 quick taps on Privacy card)
    @State private var privacyTapCount: Int = 0
    @State private var lastPrivacyTapTime: Date = .distantPast
    @State private var showEasterEgg: Bool = false
    @State private var easterEggDismissTask: Task<Void, Never>?
    
    public init() {}
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // MARK: - Header
                HStack {
                    Button {
                        navigationState.navigateToHome()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(PhotonColors.textPrimary)
                            .frame(width: 36, height: 36)
                            .background(PhotonColors.surfaceSecondary)
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("Profil & Ayarlar")
                        .font(PhotonTypography.headline)
                        .foregroundColor(PhotonColors.textPrimary)
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 36, height: 36)
                }
                .padding(.horizontal, PhotonSpacing.lg)
                .padding(.vertical, PhotonSpacing.sm)
                
                Divider()
                    .foregroundColor(PhotonColors.divider)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: PhotonSpacing.xl) {
                        // MARK: - Profile Card
                        if let session = authService.currentSession {
                            profileCard(session: session)
                        }
                        
                        // MARK: - Settings Group
                        VStack(alignment: .leading, spacing: PhotonSpacing.sm) {
                            Text("Ayarlar")
                                .font(PhotonTypography.caption)
                                .foregroundColor(PhotonColors.textTertiary)
                                .padding(.horizontal, PhotonSpacing.xs)
                            
                            VStack(spacing: 0) {
                                // 1. Notifications
                                notificationRow
                                
                                Divider().foregroundColor(PhotonColors.divider)
                                
                                // 2. Memberships
                                Button {
                                    showMembershipSheet = true
                                } label: {
                                    HStack {
                                        Image(systemName: "crown.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(PhotonColors.textPrimary)
                                            .frame(width: 28)
                                        
                                        Text("Üyelikler")
                                            .font(PhotonTypography.bodyMedium)
                                            .foregroundColor(PhotonColors.textPrimary)
                                        
                                        Spacer()
                                        
                                        Text("Free")
                                            .font(PhotonTypography.caption)
                                            .foregroundColor(PhotonColors.textSecondary)
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(PhotonColors.textTertiary)
                                    }
                                    .padding(.vertical, PhotonSpacing.md)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, PhotonSpacing.md)
                            .photonCard()
                        }
                        
                        // MARK: - Privacy & Hardware Acceleration Card (with 3-Tap Easter Egg)
                        privacyCard
                    }
                    .padding(PhotonSpacing.lg)
                    .padding(.bottom, PhotonSpacing.xxxl)
                }
            }
            .photonBackground()
            .sheet(isPresented: $showMembershipSheet) {
                MembershipView()
            }
            .onAppear {
                initializeProfileState()
                checkNotificationStatus()
            }
            
            // MARK: - Easter Egg Floating Banner
            if showEasterEgg {
                easterEggBanner
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(100)
            }
        }
    }
    
    // MARK: - Profile Card View
    
    private func profileCard(session: UserSession) -> some View {
        VStack(alignment: .leading, spacing: PhotonSpacing.md) {
            // User Avatar & Name
            HStack(spacing: PhotonSpacing.md) {
                ZStack {
                    Circle()
                        .fill(PhotonColors.surfaceSecondary)
                        .frame(width: 56, height: 56)
                    
                    if let photoURL = session.photoURL {
                        AsyncImage(url: photoURL) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 56, height: 56)
                                    .clipShape(Circle())
                            } else {
                                fallbackAvatar(for: session)
                            }
                        }
                    } else {
                        fallbackAvatar(for: session)
                    }
                }
                
                VStack(alignment: .leading, spacing: PhotonSpacing.xxs) {
                    Text(session.displayName ?? "Photon Kullanıcısı")
                        .font(PhotonTypography.headline)
                        .foregroundColor(PhotonColors.textPrimary)
                    
                    if let email = session.email {
                        Text(email)
                            .font(PhotonTypography.caption)
                            .foregroundColor(PhotonColors.textSecondary)
                    }
                    
                    if let provider = session.providerId {
                        HStack(spacing: 4) {
                            Image(systemName: provider == "Apple" ? "apple.logo" : "globe")
                                .font(.system(size: 10))
                            Text("\(provider) ile Bağlı")
                                .font(PhotonTypography.caption)
                        }
                        .foregroundColor(PhotonColors.textTertiary)
                    }
                }
                
                Spacer()
            }
            
            Divider().foregroundColor(PhotonColors.divider)
            
            // Phone Number Field (Optional & Editable)
            VStack(alignment: .leading, spacing: PhotonSpacing.xs) {
                Text("Telefon Numarası (Opsiyonel)")
                    .font(PhotonTypography.caption)
                    .foregroundColor(PhotonColors.textTertiary)
                
                HStack(spacing: PhotonSpacing.sm) {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 13))
                        .foregroundColor(PhotonColors.textSecondary)
                    
                    TextField("Telefon numaranızı girin", text: $phoneNumberText)
                        .font(PhotonTypography.bodyMedium)
                        .keyboardType(.phonePad)
                        .foregroundColor(PhotonColors.textPrimary)
                    
                    if phoneNumberText != (session.phoneNumber ?? "") {
                        Button {
                            authService.savePhoneNumber(phoneNumberText)
                            withAnimation {
                                phoneSavedFeedback = true
                            }
                            Task {
                                try? await Task.sleep(nanoseconds: 2_000_000_000)
                                withAnimation {
                                    phoneSavedFeedback = false
                                }
                            }
                        } label: {
                            Text("Kaydet")
                                .font(PhotonTypography.caption.weight(.semibold))
                                .foregroundColor(PhotonColors.textInverted)
                                .padding(.horizontal, PhotonSpacing.sm)
                                .padding(.vertical, 6)
                                .background(PhotonColors.textPrimary)
                                .clipShape(Capsule())
                        }
                    } else if phoneSavedFeedback {
                        Text("Kaydedildi")
                            .font(PhotonTypography.caption.weight(.semibold))
                            .foregroundColor(PhotonColors.success)
                    }
                }
                .padding(.vertical, PhotonSpacing.xs)
                .padding(.horizontal, PhotonSpacing.sm)
                .background(PhotonColors.surfaceSecondary)
                .clipShape(RoundedRectangle(cornerRadius: PhotonCornerRadius.md, style: .continuous))
            }
            
            Divider().foregroundColor(PhotonColors.divider)
            
            // Sign Out Button
            HStack {
                Spacer()
                PhotonButton("Çıkış Yap", variant: .outline, size: .small, isFullWidth: true) {
                    Task {
                        try? await authService.signOut()
                        navigationState.navigateToAuth()
                    }
                }
            }
        }
        .padding(PhotonSpacing.lg)
        .photonCard()
    }
    
    // MARK: - Notifications Row
    
    private var notificationRow: some View {
        HStack {
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 16))
                .foregroundColor(PhotonColors.textPrimary)
                .frame(width: 28)
            
            Text("Bildirim İzni")
                .font(PhotonTypography.bodyMedium)
                .foregroundColor(PhotonColors.textPrimary)
            
            Spacer()
            
            if notificationStatus == .authorized || notificationStatus == .provisional {
                HStack(spacing: 4) {
                    Circle()
                        .fill(PhotonColors.success)
                        .frame(width: 6, height: 6)
                    Text("İzin Verildi")
                        .font(PhotonTypography.caption.weight(.medium))
                        .foregroundColor(PhotonColors.success)
                }
            } else {
                Button {
                    requestNotificationPermission()
                } label: {
                    Text(notificationStatus == .denied ? "İzin Verilmedi" : "İzin İste")
                        .font(PhotonTypography.caption.weight(.medium))
                        .foregroundColor(PhotonColors.textSecondary)
                        .padding(.horizontal, PhotonSpacing.sm)
                        .padding(.vertical, 4)
                        .background(PhotonColors.surfaceSecondary)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.vertical, PhotonSpacing.md)
    }
    
    // MARK: - Privacy & Hardware Acceleration Card
    
    private var privacyCard: some View {
        VStack(alignment: .leading, spacing: PhotonSpacing.md) {
            HStack(spacing: PhotonSpacing.sm) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 20))
                    .foregroundColor(PhotonColors.textPrimary)
                
                Text("Gizlilik & Donanım Hızlandırma")
                    .font(PhotonTypography.titleMedium)
                    .foregroundColor(PhotonColors.textPrimary)
            }
            
            VStack(alignment: .leading, spacing: PhotonSpacing.xs) {
                privacyPoint(text: "Fotoğraflar doğrudan cihaz üzerinde işlenir")
                privacyPoint(text: "Fotoğraflar hiçbir sunucuya yüklenmez")
                privacyPoint(text: "Apple Metal donanım hızlandırmalı GPU görüntü motoru kullanılır")
            }
        }
        .padding(PhotonSpacing.lg)
        .photonCard(backgroundColor: PhotonColors.surfaceSecondary, hasBorder: false)
        .contentShape(Rectangle())
        .onTapGesture {
            handlePrivacyCardTap()
        }
    }
    
    private func privacyPoint(text: String) -> some View {
        HStack(alignment: .top, spacing: PhotonSpacing.xs) {
            Text("•")
                .foregroundColor(PhotonColors.textPrimary)
            Text(text)
                .font(PhotonTypography.bodyMedium)
                .foregroundColor(PhotonColors.textSecondary)
        }
    }
    
    // MARK: - Easter Egg Floating Banner
    
    private var easterEggBanner: some View {
        HStack(spacing: PhotonSpacing.sm) {
            Text("❤️")
                .font(.system(size: 22))
            
            Text("Bu uygulama Gurbet için Metin tarafından aşkla yapıldı ❤️")
                .font(PhotonTypography.bodyMedium.weight(.semibold))
                .foregroundColor(PhotonColors.textInverted)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(PhotonSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: PhotonCornerRadius.lg, style: .continuous)
                .fill(Color.black.opacity(0.92))
                .shadow(color: Color.black.opacity(0.35), radius: 16, x: 0, y: 6)
        )
        .padding(.horizontal, PhotonSpacing.lg)
        .padding(.bottom, PhotonSpacing.xl)
    }
    
    // MARK: - Easter Egg Action (3 Taps within 1.5s)
    
    private func handlePrivacyCardTap() {
        let now = Date()
        if now.timeIntervalSince(lastPrivacyTapTime) < 1.5 {
            privacyTapCount += 1
        } else {
            privacyTapCount = 1
        }
        lastPrivacyTapTime = now
        
        if privacyTapCount >= 3 {
            privacyTapCount = 0
            triggerEasterEgg()
        }
    }
    
    private func triggerEasterEgg() {
        easterEggDismissTask?.cancel()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            showEasterEgg = true
        }
        
        easterEggDismissTask = Task {
            try? await Task.sleep(nanoseconds: 10_000_000_000)
            guard !Task.isCancelled else { return }
            withAnimation(.easeInOut(duration: 0.3)) {
                showEasterEgg = false
            }
        }
    }
    
    // MARK: - State Initializers & Helpers
    
    private func initializeProfileState() {
        if let session = authService.currentSession {
            phoneNumberText = session.phoneNumber ?? ""
        }
    }
    
    private func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            Task { @MainActor in
                self.notificationStatus = settings.authorizationStatus
            }
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            Task { @MainActor in
                checkNotificationStatus()
            }
        }
    }
    
    @ViewBuilder
    private func fallbackAvatar(for session: UserSession) -> some View {
        if let initial = session.displayName?.prefix(1).uppercased(), !initial.isEmpty {
            Text(initial)
                .font(PhotonTypography.headline)
                .foregroundColor(PhotonColors.textPrimary)
        } else {
            Image(systemName: "person.fill")
                .font(.system(size: 24))
                .foregroundColor(PhotonColors.textSecondary)
        }
    }
}

#Preview {
    SettingsView()
        .environment(NavigationState())
}
