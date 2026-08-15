//
//  SettingsView.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import SwiftUI
import UserNotifications
import Photos

/// Profile and Settings screen managing user profile data, runtime permissions,
/// membership tiers, privacy commitments, Easter Egg, and real account deletion.
public struct SettingsView: View {
    @Environment(NavigationState.self) private var navigationState
    @Environment(\.scenePhase) private var scenePhase
    @State private var authService = AuthService.shared
    @State private var subscriptionService = SubscriptionService.shared
    @State private var consentManager = ConsentManager.shared
    
    // Runtime Permission States
    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined
    @State private var photoLibraryStatus: PHAuthorizationStatus = .notDetermined
    
    // Membership Sheet State
    @State private var showMembershipSheet: Bool = false
    
    // Easter Egg State (3 quick taps on Privacy card)
    @State private var privacyTapCount: Int = 0
    @State private var lastPrivacyTapTime: Date = .distantPast
    @State private var showEasterEgg: Bool = false
    @State private var easterEggDismissTask: Task<Void, Never>?
    
    // Account Deletion States
    @State private var showDeleteConfirmation: Bool = false
    @State private var isDeletingAccount: Bool = false
    @State private var deleteErrorMessage: String?
    @State private var showDeleteErrorAlert: Bool = false
    
    public init() {}
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // MARK: - Header
                headerView
                
                Divider()
                    .foregroundColor(PhotonColors.divider)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: PhotonSpacing.xl) {
                        // MARK: - 1. Profile Section
                        if let session = authService.currentSession {
                            profileSection(session: session)
                        }
                        
                        // MARK: - 2. Permissions Section
                        permissionsSection
                        
                        // MARK: - 3. Membership Section
                        membershipSection
                        
                        // MARK: - 4. Privacy & Hardware Acceleration Card (with 3-Tap Easter Egg)
                        privacyCard
                        
                        // MARK: - 5. Delete Account Section
                        deleteAccountSection
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
                checkAllPermissions()
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    checkAllPermissions()
                }
            }
            .confirmationDialog(
                "Hesabınızı Silmek İstediğinize Emin Misiniz?",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Hesabımı Kalıcı Olarak Sil", role: .destructive) {
                    performAccountDeletion()
                }
                Button("Vazgeç", role: .cancel) {}
            } message: {
                Text("Bu işlem Firebase üzerindeki hesabınızı ve tüm yerel oturum verilerinizi kalıcı olarak silecektir. Bu işlem geri alınamaz.")
            }
            .alert("Hesap Silme Hatası", isPresented: $showDeleteErrorAlert) {
                Button("Tamam", role: .cancel) {}
            } message: {
                Text(deleteErrorMessage ?? "Hesap silinirken bir hata oluştu.")
            }
            
            // MARK: - Easter Egg Floating Banner
            if showEasterEgg {
                easterEggBanner
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(100)
            }
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
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
    }
    
    // MARK: - 1. Profile Section (Photo, Name, Email, Provider & Sign Out)
    
    private func profileSection(session: UserSession) -> some View {
        VStack(alignment: .leading, spacing: PhotonSpacing.md) {
            HStack(spacing: PhotonSpacing.md) {
                ZStack {
                    Circle()
                        .fill(PhotonColors.surfaceSecondary)
                        .frame(width: 60, height: 60)
                    
                    if let photoURL = session.photoURL {
                        AsyncImage(url: photoURL) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
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
                    Text(session.displayName ?? "Photonla Kullanıcısı")
                        .font(PhotonTypography.headline)
                        .foregroundColor(PhotonColors.textPrimary)
                        .lineLimit(1)
                    
                    if let email = session.email {
                        Text(email)
                            .font(PhotonTypography.caption)
                            .foregroundColor(PhotonColors.textSecondary)
                            .lineLimit(1)
                    }
                    
                    if let provider = session.providerId {
                        HStack(spacing: 4) {
                            Image(systemName: providerSystemIcon(for: provider))
                                .font(.system(size: 11))
                            Text("\(provider) ile Bağlı")
                                .font(PhotonTypography.caption.weight(.medium))
                        }
                        .foregroundColor(PhotonColors.textTertiary)
                        .padding(.top, 2)
                    }
                }
                
                Spacer()
            }
            
            Divider().foregroundColor(PhotonColors.divider)
            
            // Sign Out Button inside Profile
            PhotonButton("Çıkış Yap", variant: .outline, size: .small, isFullWidth: true) {
                Task {
                    try? await authService.signOut()
                    navigationState.navigateToAuth()
                }
            }
        }
        .padding(PhotonSpacing.lg)
        .photonCard()
    }
    
    // MARK: - 2. Permissions Section (Notifications, Photos Add-Only & Ad Privacy)
    
    private var permissionsSection: some View {
        VStack(alignment: .leading, spacing: PhotonSpacing.sm) {
            Text("İzinler & Gizlilik")
                .font(PhotonTypography.caption)
                .foregroundColor(PhotonColors.textTertiary)
                .padding(.horizontal, PhotonSpacing.xs)
            
            VStack(spacing: 0) {
                // 1. Bildirimler
                notificationPermissionRow
                
                Divider().foregroundColor(PhotonColors.divider)
                
                // 2. Fotoğraflara Kaydetme (Lowest Privilege: Add Only)
                photoLibraryPermissionRow
                
                Divider().foregroundColor(PhotonColors.divider)
                
                // 3. Reklam Gizliliği (Google UMP Privacy Options Form & Consent Revocation)
                adPrivacyRow
            }
            .padding(.horizontal, PhotonSpacing.md)
            .photonCard()
        }
    }
    
    private var adPrivacyRow: some View {
        HStack {
            Image(systemName: "hand.raised.square.fill")
                .font(.system(size: 16))
                .foregroundColor(PhotonColors.textPrimary)
                .frame(width: 28)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Reklam Gizliliği")
                    .font(PhotonTypography.bodyMedium)
                    .foregroundColor(PhotonColors.textPrimary)
                
                Text("Gizlilik tercihleri ve rıza yönetimi")
                    .font(PhotonTypography.caption)
                    .foregroundColor(PhotonColors.textTertiary)
            }
            
            Spacer()
            
            Button {
                consentManager.presentPrivacyOptionsForm { error in
                    if let error = error {
                        print("[SettingsView] Privacy options error: \(error.localizedDescription)")
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(consentManager.isPrivacyOptionsRequired ? "Düzenle" : "Tercihler")
                        .font(PhotonTypography.caption.weight(.semibold))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .bold))
                }
                .foregroundColor(PhotonColors.textPrimary)
                .padding(.horizontal, PhotonSpacing.sm)
                .padding(.vertical, 6)
                .background(PhotonColors.surfaceSecondary)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .strokeBorder(PhotonColors.border, lineWidth: 0.8)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, PhotonSpacing.md)
    }
    
    private var notificationPermissionRow: some View {
        HStack {
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 16))
                .foregroundColor(PhotonColors.textPrimary)
                .frame(width: 28)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Bildirimler")
                    .font(PhotonTypography.bodyMedium)
                    .foregroundColor(PhotonColors.textPrimary)
                
                Text("Güncellemeler ve yenilikler")
                    .font(PhotonTypography.caption)
                    .foregroundColor(PhotonColors.textTertiary)
            }
            
            Spacer()
            
            if notificationStatus == .authorized || notificationStatus == .provisional {
                permissionStatusBadge(title: "İzin Verildi", isGranted: true)
            } else if notificationStatus == .denied {
                openSettingsButton
            } else {
                Button {
                    requestNotificationPermission()
                } label: {
                    Text("İzin İste")
                        .font(PhotonTypography.caption.weight(.semibold))
                        .foregroundColor(PhotonColors.textInverted)
                        .padding(.horizontal, PhotonSpacing.sm)
                        .padding(.vertical, 6)
                        .background(PhotonColors.textPrimary)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, PhotonSpacing.md)
    }
    
    private var photoLibraryPermissionRow: some View {
        HStack {
            Image(systemName: "photo.stack.fill")
                .font(.system(size: 16))
                .foregroundColor(PhotonColors.textPrimary)
                .frame(width: 28)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Fotoğraflara Kaydetme")
                    .font(PhotonTypography.bodyMedium)
                    .foregroundColor(PhotonColors.textPrimary)
                
                Text("Düzenlenen fotoğrafları galeriye ekleme")
                    .font(PhotonTypography.caption)
                    .foregroundColor(PhotonColors.textTertiary)
            }
            
            Spacer()
            
            if photoLibraryStatus == .authorized || photoLibraryStatus == .limited {
                permissionStatusBadge(title: "İzin Verildi", isGranted: true)
            } else if photoLibraryStatus == .denied || photoLibraryStatus == .restricted {
                openSettingsButton
            } else {
                Button {
                    requestPhotoLibraryPermission()
                } label: {
                    Text("İzin İste")
                        .font(PhotonTypography.caption.weight(.semibold))
                        .foregroundColor(PhotonColors.textInverted)
                        .padding(.horizontal, PhotonSpacing.sm)
                        .padding(.vertical, 6)
                        .background(PhotonColors.textPrimary)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, PhotonSpacing.md)
    }
    
    private func permissionStatusBadge(title: String, isGranted: Bool) -> some View {
        HStack(spacing: 5) {
            Circle()
                .fill(isGranted ? PhotonColors.success : PhotonColors.error)
                .frame(width: 6, height: 6)
            Text(title)
                .font(PhotonTypography.caption.weight(.medium))
                .foregroundColor(isGranted ? PhotonColors.success : PhotonColors.textSecondary)
        }
        .padding(.horizontal, PhotonSpacing.xs)
        .padding(.vertical, 4)
    }
    
    private var openSettingsButton: some View {
        Button {
            if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        } label: {
            HStack(spacing: 4) {
                Text("Ayarları Aç")
                    .font(PhotonTypography.caption.weight(.semibold))
                Image(systemName: "arrow.up.forward.app")
                    .font(.system(size: 11))
            }
            .foregroundColor(PhotonColors.textPrimary)
            .padding(.horizontal, PhotonSpacing.sm)
            .padding(.vertical, 6)
            .background(PhotonColors.surfaceSecondary)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(PhotonColors.border, lineWidth: 0.8)
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - 3. Membership Section
    
    private var membershipSection: some View {
        VStack(alignment: .leading, spacing: PhotonSpacing.sm) {
            Text("Üyelik")
                .font(PhotonTypography.caption)
                .foregroundColor(PhotonColors.textTertiary)
                .padding(.horizontal, PhotonSpacing.xs)
            
            Button {
                showMembershipSheet = true
            } label: {
                HStack {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 16))
                        .foregroundColor(subscriptionService.isProUser ? Color.yellow : PhotonColors.textPrimary)
                        .frame(width: 28)
                    
                    Text("Photonla Pro & Planlar")
                        .font(PhotonTypography.bodyMedium)
                        .foregroundColor(PhotonColors.textPrimary)
                    
                    Spacer()
                    
                    if subscriptionService.isProUser {
                        HStack(spacing: 4) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 11))
                            Text("Pro")
                                .font(PhotonTypography.caption.weight(.bold))
                        }
                        .foregroundColor(PhotonColors.textInverted)
                        .padding(.horizontal, PhotonSpacing.sm)
                        .padding(.vertical, 3)
                        .background(Color.black)
                        .clipShape(Capsule())
                    } else {
                        Text("Standart")
                            .font(PhotonTypography.caption.weight(.medium))
                            .foregroundColor(PhotonColors.textSecondary)
                    }
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(PhotonColors.textTertiary)
                }
                .padding(.horizontal, PhotonSpacing.md)
                .padding(.vertical, PhotonSpacing.md)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .photonCard()
        }
    }
    
    // MARK: - 4. Privacy & Hardware Acceleration Card (with 3-Tap Easter Egg)
    
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
    
    // MARK: - 5. Delete Account Section (Real Firebase Auth Account Deletion)
    
    private var deleteAccountSection: some View {
        VStack(alignment: .leading, spacing: PhotonSpacing.xs) {
            Button {
                showDeleteConfirmation = true
            } label: {
                HStack(spacing: PhotonSpacing.sm) {
                    if isDeletingAccount {
                        ProgressView()
                            .tint(PhotonColors.error)
                            .frame(width: 20, height: 20)
                    } else {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 15))
                            .foregroundColor(PhotonColors.error)
                    }
                    
                    Text("Hesabımı Sil")
                        .font(PhotonTypography.bodyMedium.weight(.semibold))
                        .foregroundColor(PhotonColors.error)
                    
                    Spacer()
                }
                .padding(.horizontal, PhotonSpacing.md)
                .padding(.vertical, PhotonSpacing.md)
                .background(PhotonColors.error.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: PhotonCornerRadius.md, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: PhotonCornerRadius.md, style: .continuous)
                        .strokeBorder(PhotonColors.error.opacity(0.2), lineWidth: 0.8)
                )
            }
            .buttonStyle(.plain)
            .disabled(isDeletingAccount)
            
            Text("Hesabınızı sildiğinizde kimlik bilgileriniz ve oturumunuz kalıcı olarak kaldırılır.")
                .font(PhotonTypography.caption)
                .foregroundColor(PhotonColors.textTertiary)
                .padding(.horizontal, PhotonSpacing.xs)
        }
    }
    
    private func performAccountDeletion() {
        isDeletingAccount = true
        Task {
            do {
                try await authService.deleteAccount()
                isDeletingAccount = false
                navigationState.navigateToAuth()
            } catch {
                isDeletingAccount = false
                deleteErrorMessage = error.localizedDescription
                showDeleteErrorAlert = true
            }
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
    
    // MARK: - Permission Handlers & Checkers
    
    private func checkAllPermissions() {
        checkNotificationStatus()
        checkPhotoLibraryStatus()
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
    
    private func checkPhotoLibraryStatus() {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        self.photoLibraryStatus = status
    }
    
    private func requestPhotoLibraryPermission() {
        Task {
            let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
            await MainActor.run {
                self.photoLibraryStatus = status
            }
        }
    }
    
    // MARK: - Helpers
    
    private func providerSystemIcon(for provider: String) -> String {
        switch provider.lowercased() {
        case "apple": return "apple.logo"
        case "google": return "globe"
        case "facebook": return "f.circle"
        case "e-posta", "email", "password": return "envelope.fill"
        default: return "person.crop.circle"
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

