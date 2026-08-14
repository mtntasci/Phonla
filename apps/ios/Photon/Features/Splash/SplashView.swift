//
//  SplashView.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import SwiftUI

/// Minimalist pure-white splash screen showing brand identity and initiating session check.
public struct SplashView: View {
    @Environment(NavigationState.self) private var navigationState
    @State private var authService = AuthService.shared
    @State private var isAnimating: Bool = false
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: PhotonSpacing.xxl) {
            Spacer()
            
            // Brand Logo & Title
            VStack(spacing: PhotonSpacing.md) {
                Image(systemName: "camera.filters")
                    .font(.system(size: 56, weight: .light))
                    .foregroundColor(PhotonColors.textPrimary)
                    .scaleEffect(isAnimating ? 1.0 : 0.9)
                    .opacity(isAnimating ? 1.0 : 0.0)
                
                Text("PHOTON")
                    .font(PhotonTypography.hero)
                    .tracking(6)
                    .foregroundColor(PhotonColors.textPrimary)
                    .opacity(isAnimating ? 1.0 : 0.0)
                
                Text("Light • Cinematic • Monochrome")
                    .font(PhotonTypography.bodyMedium)
                    .foregroundColor(PhotonColors.textSecondary)
                    .opacity(isAnimating ? 0.8 : 0.0)
            }
            
            Spacer()
            
            // Subtle loading indicator during initial session verification
            ProgressView()
                .tint(PhotonColors.textPrimary)
                .scaleEffect(0.9)
                .opacity(isAnimating ? 1.0 : 0.0)
                .padding(.bottom, PhotonSpacing.xxxl)
        }
        .photonBackground()
        .task {
            withAnimation(.easeOut(duration: 0.5)) {
                isAnimating = true
            }
            
            // Verify session and transition accordingly
            let session = await authService.checkCurrentSession()
            if session != nil {
                navigationState.navigateToHome()
            } else {
                navigationState.navigateToAuth()
            }
        }
    }
}

#Preview {
    SplashView()
        .environment(NavigationState())
}
