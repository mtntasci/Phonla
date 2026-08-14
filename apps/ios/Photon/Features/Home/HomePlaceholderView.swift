//
//  HomePlaceholderView.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import SwiftUI

/// Minimalist pure-white Home screen with primary CTA to pick photo and enter editor.
public struct HomePlaceholderView: View {
    @Environment(NavigationState.self) private var navigationState
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // Minimal Navigation Header
            HStack {
                Text("PHOTON")
                    .font(PhotonTypography.titleMedium)
                    .tracking(2)
                    .foregroundColor(PhotonColors.textPrimary)
                
                Spacer()
                
                Button {
                    navigationState.navigateToSettings()
                } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(PhotonColors.textPrimary)
                        .frame(width: 40, height: 40)
                        .background(PhotonColors.surfaceSecondary)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, PhotonSpacing.xl)
            .padding(.vertical, PhotonSpacing.md)
            
            Spacer()
            
            // Center Hero / CTA Area
            VStack(spacing: PhotonSpacing.xl) {
                // Subtle Icon Container
                ZStack {
                    RoundedRectangle(cornerRadius: PhotonCornerRadius.xl, style: .continuous)
                        .fill(PhotonColors.surfaceSecondary)
                        .frame(width: 96, height: 96)
                    
                    Image(systemName: "photo.badge.plus")
                        .font(.system(size: 38, weight: .light))
                        .foregroundColor(PhotonColors.textPrimary)
                }
                
                VStack(spacing: PhotonSpacing.xs) {
                    Text("Işık & Sinematik Görünüm")
                        .font(PhotonTypography.titleLarge)
                        .foregroundColor(PhotonColors.textPrimary)
                    
                    Text("Düzenlemek için galerinizden bir fotoğraf seçin.")
                        .font(PhotonTypography.bodyMedium)
                        .foregroundColor(PhotonColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                
                // Primary CTA: Fotoğraf Yükle
                PhotonButton("Fotoğraf Yükle", systemImage: "plus", variant: .primary, size: .large) {
                    navigationState.navigateToEditor()
                }
                .padding(.horizontal, PhotonSpacing.xl)
                .padding(.top, PhotonSpacing.md)
            }
            .padding(.horizontal, PhotonSpacing.lg)
            
            Spacer()
            
            // Footer Info
            Text("Fotoğraflarınız yalnızca bu cihazda işlenir.")
                .font(PhotonTypography.caption)
                .foregroundColor(PhotonColors.textTertiary)
                .padding(.bottom, PhotonSpacing.xl)
        }
        .photonBackground()
    }
}

#Preview {
    HomePlaceholderView()
        .environment(NavigationState())
}
