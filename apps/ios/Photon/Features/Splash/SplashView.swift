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
            
            // Temporary manual entry CTA for phase 1 validation
            VStack(spacing: PhotonSpacing.md) {
                PhotonButton("Devam Et", systemImage: "arrow.right", variant: .primary) {
                    navigationState.navigateToAuth()
                }
            }
            .padding(.horizontal, PhotonSpacing.xxl)
            .padding(.bottom, PhotonSpacing.xxxl)
        }
        .photonBackground()
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    SplashView()
        .environment(NavigationState())
}
