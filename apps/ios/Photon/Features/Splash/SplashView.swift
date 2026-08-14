//
//  SplashView.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import SwiftUI

/// Minimalist pure-white splash screen with transparent Photon brandmark and Firebase session verification.
public struct SplashView: View {
    @Environment(NavigationState.self) private var navigationState
    @State private var authService = AuthService.shared
    @State private var opacity: Double = 0.0
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: PhotonSpacing.md) {
            Spacer()
            
            // Transparent Photon Vector Brandmark
            PhotonLogoMark(size: 76, color: PhotonColors.textPrimary)
            
            Text("PHOTON")
                .font(PhotonTypography.titleMedium)
                .tracking(5)
                .foregroundColor(PhotonColors.textPrimary)
                .padding(.top, PhotonSpacing.xs)
            
            Spacer()
        }
        .opacity(opacity)
        .photonBackground()
        .task {
            withAnimation(.easeIn(duration: 0.3)) {
                opacity = 1.0
            }
            
            // Allow splash to be visible for a smooth 1.0s brand moment while initializing
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            // Verify real Firebase Auth session
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
