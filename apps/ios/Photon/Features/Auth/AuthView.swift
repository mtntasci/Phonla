//
//  AuthView.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import SwiftUI

/// Minimalist, pure-white authentication screen with Apple and Google sign-in options.
public struct AuthView: View {
    @Environment(NavigationState.self) private var navigationState
    @State private var authService = AuthService.shared
    @State private var errorMessage: String?
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Top / Center Branding Area
            VStack(spacing: PhotonSpacing.md) {
                Image("PhotonLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 84, height: 84)
                    .clipShape(RoundedRectangle(cornerRadius: 19, style: .continuous))
                    .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
                
                VStack(spacing: PhotonSpacing.xxs) {
                    Text("PHOTON")
                        .font(PhotonTypography.titleLarge)
                        .tracking(4)
                        .foregroundColor(PhotonColors.textPrimary)
                    
                    Text("Işık, Sinematik Renk & Mono")
                        .font(PhotonTypography.bodyMedium)
                        .foregroundColor(PhotonColors.textSecondary)
                }
            }
            .padding(.horizontal, PhotonSpacing.xl)
            
            Spacer()
            
            // Bottom Action Area
            VStack(spacing: PhotonSpacing.md) {
                if let errorMessage {
                    Text(errorMessage)
                        .font(PhotonTypography.caption)
                        .foregroundColor(PhotonColors.error)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, PhotonSpacing.md)
                }
                
                // Sign in with Apple (Primary)
                PhotonButton(
                    "Apple ile Giriş Yap",
                    systemImage: "apple.logo",
                    variant: .primary,
                    size: .large,
                    isLoading: authService.isLoading
                ) {
                    performSignIn(provider: .apple)
                }
                
                // Google Sign In
                PhotonButton(
                    "Google ile Devam Et",
                    systemImage: "globe",
                    variant: .outline,
                    size: .large,
                    isLoading: authService.isLoading
                ) {
                    performSignIn(provider: .google)
                }
                
                // Privacy Footnote
                HStack(spacing: PhotonSpacing.xxs) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 11))
                    Text("Giriş yaparak fotoğraflarınızı cihazınızda güvenle işleyebilirsiniz.")
                        .font(PhotonTypography.caption)
                }
                .foregroundColor(PhotonColors.textTertiary)
                .multilineTextAlignment(.center)
                .padding(.top, PhotonSpacing.xs)
            }
            .padding(.horizontal, PhotonSpacing.xl)
            .padding(.bottom, PhotonSpacing.xxxl)
        }
        .photonBackground()
    }
    
    private func performSignIn(provider: AuthProvider) {
        errorMessage = nil
        Task {
            do {
                _ = try await authService.signIn(with: provider)
                navigationState.navigateToHome()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    AuthView()
        .environment(NavigationState())
}
