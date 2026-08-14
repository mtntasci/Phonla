//
//  SplashView.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import SwiftUI

/// Minimalist pure-white splash screen featuring the official Photon logo and session verification.
public struct SplashView: View {
    @Environment(NavigationState.self) private var navigationState
    @State private var authService = AuthService.shared
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: PhotonSpacing.md) {
            Spacer()
            
            // Official Photon App Logo
            Image("PhotonLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 96, height: 96)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
            
            Text("Photon")
                .font(PhotonTypography.bodyMedium)
                .foregroundColor(PhotonColors.textSecondary)
                .padding(.top, PhotonSpacing.xs)
            
            Spacer()
        }
        .photonBackground()
        .task {
            // Verify session and transition smoothly
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
