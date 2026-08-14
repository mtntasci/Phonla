//
//  AuthView.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import SwiftUI

/// Minimalist, pure-white authentication screen with Apple, Google, and Facebook sign-in options.
public struct AuthView: View {
    @Environment(NavigationState.self) private var navigationState
    @State private var authService = AuthService.shared
    @State private var errorMessage: String?
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Top / Center Branding Area
            VStack(spacing: PhotonSpacing.lg) {
                ZStack {
                    RoundedRectangle(cornerRadius: PhotonCornerRadius.xl, style: .continuous)
                        .fill(PhotonColors.surfaceSecondary)
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "camera.filters")
                        .font(.system(size: 36, weight: .light))
                        .foregroundColor(PhotonColors.textPrimary)
                }
                
                VStack(spacing: PhotonSpacing.xs) {
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
                    isLoading: authService.isLoading
                ) {
                    performSignIn(provider: .apple)
                }
                
                // Google Sign In
                PhotonButton(
                    "Google ile Devam Et",
                    systemImage: "globe",
                    variant: .outline,
                    isLoading: authService.isLoading
                ) {
                    performSignIn(provider: .google)
                }
                
                // Facebook Sign In
                PhotonButton(
                    "Facebook ile Devam Et",
                    systemImage: "f.circle",
                    variant: .outline,
                    isLoading: authService.isLoading
                ) {
                    performSignIn(provider: .facebook)
                }
                
                Text("Giriş yaparak fotoğraflarınızı cihazınızda güvenle işleyebilirsiniz.")
                    .font(PhotonTypography.caption)
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
