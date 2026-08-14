//
//  SettingsView.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import SwiftUI

/// Minimalist pure-white Settings screen displaying account status, app info, and privacy commitments.
public struct SettingsView: View {
    @Environment(NavigationState.self) private var navigationState
    @State private var authService = AuthService.shared
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header
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
                
                Text("Ayarlar")
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
                    // Account Session Card
                    if let session = authService.currentSession {
                        VStack(alignment: .leading, spacing: PhotonSpacing.md) {
                            Text("Oturum")
                                .font(PhotonTypography.caption)
                                .foregroundColor(PhotonColors.textTertiary)
                            
                            HStack(spacing: PhotonSpacing.md) {
                                // User Avatar / Monogram
                                ZStack {
                                    Circle()
                                        .fill(PhotonColors.surfaceSecondary)
                                        .frame(width: 48, height: 48)
                                    
                                    if let photoURL = session.photoURL {
                                        AsyncImage(url: photoURL) { phase in
                                            if let image = phase.image {
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 48, height: 48)
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
                                }
                                
                                Spacer()
                                
                                PhotonButton("Çıkış Yap", variant: .outline, size: .small, isFullWidth: false) {
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
                    
                    // Privacy Info Card
                    VStack(alignment: .leading, spacing: PhotonSpacing.sm) {
                        HStack(spacing: PhotonSpacing.sm) {
                            Image(systemName: "lock.shield")
                                .font(.system(size: 20))
                                .foregroundColor(PhotonColors.textPrimary)
                            
                            Text("Gizlilik & Donanım Hızlandırma")
                                .font(PhotonTypography.titleMedium)
                                .foregroundColor(PhotonColors.textPrimary)
                        }
                        
                        Text("Tüm fotoğraf düzenleme ve render işlemleri doğrudan iPhone'unuzun Metal GPU donanımında gerçekleştirilir. Fotoğraflarınız hiçbir sunucuya yüklenmez.")
                            .font(PhotonTypography.bodyMedium)
                            .foregroundColor(PhotonColors.textSecondary)
                    }
                    .padding(PhotonSpacing.lg)
                    .photonCard(backgroundColor: PhotonColors.surfaceSecondary, hasBorder: false)
                    
                    // App Information List
                    VStack(spacing: 0) {
                        infoRow(label: "Uygulama", value: "Photon")
                        Divider().foregroundColor(PhotonColors.divider)
                        infoRow(label: "Bundle ID", value: "com.alafteknoloji.photon")
                        Divider().foregroundColor(PhotonColors.divider)
                        infoRow(label: "Sürüm", value: "1.0.0 (MVP)")
                        Divider().foregroundColor(PhotonColors.divider)
                        infoRow(label: "Render Motoru", value: "Core Image & Metal")
                    }
                    .padding(.horizontal, PhotonSpacing.md)
                    .photonCard()
                }
                .padding(PhotonSpacing.lg)
            }
        }
        .photonBackground()
    }
    
    @ViewBuilder
    private func fallbackAvatar(for session: UserSession) -> some View {
        if let initial = session.displayName?.prefix(1).uppercased(), !initial.isEmpty {
            Text(initial)
                .font(PhotonTypography.headline)
                .foregroundColor(PhotonColors.textPrimary)
        } else {
            Image(systemName: "person.fill")
                .font(.system(size: 20))
                .foregroundColor(PhotonColors.textSecondary)
        }
    }
    
    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(PhotonTypography.bodyMedium)
                .foregroundColor(PhotonColors.textSecondary)
            Spacer()
            Text(value)
                .font(PhotonTypography.bodyMedium.weight(.medium))
                .foregroundColor(PhotonColors.textPrimary)
        }
        .padding(.vertical, PhotonSpacing.md)
    }
}

#Preview {
    SettingsView()
        .environment(NavigationState())
}
