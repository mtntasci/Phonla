//
//  AuthPlaceholderView.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import SwiftUI

/// Placeholder screen for Authentication (Phase 2).
public struct AuthPlaceholderView: View {
    @Environment(NavigationState.self) private var navigationState
    
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: PhotonSpacing.xxl) {
            // Header
            VStack(alignment: .leading, spacing: PhotonSpacing.xs) {
                Text("Giriş Yap")
                    .font(PhotonTypography.titleLarge)
                    .foregroundColor(PhotonColors.textPrimary)
                
                Text("Fotoğraflarınızı cihazınızda düzenleyin ve kaydedin.")
                    .font(PhotonTypography.bodyMedium)
                    .foregroundColor(PhotonColors.textSecondary)
            }
            .padding(.top, PhotonSpacing.xxl)
            
            Spacer()
            
            // Placeholder Auth Action Buttons
            VStack(spacing: PhotonSpacing.md) {
                PhotonButton("Apple ile Giriş Yap", systemImage: "apple.logo", variant: .primary) {
                    navigationState.navigateToHome()
                }
                
                PhotonButton("Google ile Devam Et", systemImage: "globe", variant: .outline) {
                    navigationState.navigateToHome()
                }
                
                PhotonButton("Facebook ile Devam Et", systemImage: "f.circle", variant: .outline) {
                    navigationState.navigateToHome()
                }
                
                PhotonButton("Atla / Doğrudan Başla", variant: .ghost) {
                    navigationState.navigateToHome()
                }
            }
            .padding(.bottom, PhotonSpacing.xxl)
        }
        .padding(.horizontal, PhotonSpacing.xl)
        .photonBackground()
    }
}

#Preview {
    AuthPlaceholderView()
        .environment(NavigationState())
}
