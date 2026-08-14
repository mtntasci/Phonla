//
//  SettingsPlaceholderView.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import SwiftUI

/// Minimalist pure-white Settings screen displaying app and privacy information.
public struct SettingsPlaceholderView: View {
    @Environment(NavigationState.self) private var navigationState
    
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
                    // Privacy Info Card
                    VStack(alignment: .leading, spacing: PhotonSpacing.sm) {
                        HStack(spacing: PhotonSpacing.sm) {
                            Image(systemName: "lock.shield")
                                .font(.system(size: 20))
                                .foregroundColor(PhotonColors.textPrimary)
                            
                            Text("Gizlilik Odaklı İşleme")
                                .font(PhotonTypography.titleMedium)
                                .foregroundColor(PhotonColors.textPrimary)
                        }
                        
                        Text("Tüm fotoğraf düzenleme işlemleri doğrudan iPhone'unuzun donanımında gerçekleştirilir. Görselleriniz hiçbir sunucuya yüklenmez.")
                            .font(PhotonTypography.bodyMedium)
                            .foregroundColor(PhotonColors.textSecondary)
                    }
                    .padding(PhotonSpacing.lg)
                    .photonCard(backgroundColor: PhotonColors.surfaceSecondary, hasBorder: false)
                    
                    // App Information List
                    VStack(spacing: 0) {
                        infoRow(label: "Uygulama", value: "Photon")
                        Divider().foregroundColor(PhotonColors.divider)
                        infoRow(label: "Bundle ID", value: "com.alafteknoloji.Photon")
                        Divider().foregroundColor(PhotonColors.divider)
                        infoRow(label: "Sürüm", value: "1.0.0 (MVP)")
                        Divider().foregroundColor(PhotonColors.divider)
                        infoRow(label: "Motor", value: "Core Image & Metal")
                    }
                    .padding(.horizontal, PhotonSpacing.md)
                    .photonCard()
                }
                .padding(PhotonSpacing.lg)
            }
        }
        .photonBackground()
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
    SettingsPlaceholderView()
        .environment(NavigationState())
}
