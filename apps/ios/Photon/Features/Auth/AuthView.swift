//
//  AuthView.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import SwiftUI
import AuthenticationServices

/// Minimalist, pure-white authentication screen with transparent branding and Firebase Auth providers.
public struct AuthView: View {
    @Environment(NavigationState.self) private var navigationState
    @State private var authService = AuthService.shared
    @State private var errorMessage: String?
    @State private var showEmailLoginSheet: Bool = false
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Top / Center Branding Area
            VStack(spacing: PhotonSpacing.lg) {
                PhotonLogoMark(size: 72, color: PhotonColors.textPrimary)
                
                VStack(spacing: PhotonSpacing.xxs) {
                    Text("PHOTONLA")
                        .font(PhotonTypography.titleLarge)
                        .tracking(4)
                        .foregroundColor(PhotonColors.textPrimary)
                    
                    Text("Işık, Sinematik Renk & Siyah-Beyaz")
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
                
                // Sign in with Apple (Native Primary)
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
                
                // Email Sign In (Test User & Review Login)
                PhotonButton(
                    "E-posta ile Giriş Yap",
                    systemImage: "envelope.fill",
                    variant: .secondary,
                    size: .large,
                    isLoading: false
                ) {
                    showEmailLoginSheet = true
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
        .sheet(isPresented: $showEmailLoginSheet) {
            EmailLoginSheet {
                navigationState.navigateToHome()
            }
        }
    }
    
    private func performSignIn(provider: AuthProvider) {
        errorMessage = nil
        Task {
            do {
                _ = try await authService.signIn(with: provider)
                navigationState.navigateToHome()
            } catch AuthError.cancelled {
                // User cancelled Apple or Google sign in sheet; remain on AuthView quietly
            } catch {
                let nsError = error as NSError
                if nsError.domain == ASAuthorizationError.errorDomain &&
                    nsError.code == ASAuthorizationError.canceled.rawValue {
                    // User cancelled Apple authorization
                } else {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    AuthView()
        .environment(NavigationState())
}
