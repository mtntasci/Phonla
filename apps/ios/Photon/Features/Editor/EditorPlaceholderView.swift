//
//  EditorPlaceholderView.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import SwiftUI

/// Placeholder UI for Photon Editor (Phase 4-8 foundations).
public struct EditorPlaceholderView: View {
    @Environment(NavigationState.self) private var navigationState
    @State private var selectedTab: String = "Light"
    
    private let toolTabs = ["Light", "Color", "Cinematic", "Mono"]
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // Top Toolbar
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
                
                Text("Editör")
                    .font(PhotonTypography.headline)
                    .foregroundColor(PhotonColors.textPrimary)
                
                Spacer()
                
                PhotonButton("Kaydet", variant: .primary, size: .small, isFullWidth: false) {
                    // Export trigger placeholder
                }
            }
            .padding(.horizontal, PhotonSpacing.lg)
            .padding(.vertical, PhotonSpacing.sm)
            
            Divider()
                .foregroundColor(PhotonColors.divider)
            
            // Photo Preview Placeholder Area
            ZStack {
                Color(hex: "#FAFAFA")
                
                VStack(spacing: PhotonSpacing.md) {
                    Image(systemName: "photo")
                        .font(.system(size: 48, weight: .ultraLight))
                        .foregroundColor(PhotonColors.textTertiary)
                    
                    Text("Önizleme Tuvali (Preview Canvas)")
                        .font(PhotonTypography.bodyMedium)
                        .foregroundColor(PhotonColors.textSecondary)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: PhotonCornerRadius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: PhotonCornerRadius.md, style: .continuous)
                    .strokeBorder(PhotonColors.border, lineWidth: 1)
            )
            .padding(PhotonSpacing.md)
            
            // Bottom Tool Category Tabs
            VStack(spacing: PhotonSpacing.md) {
                Divider()
                    .foregroundColor(PhotonColors.divider)
                
                HStack(spacing: PhotonSpacing.sm) {
                    ForEach(toolTabs, id: \.self) { tab in
                        Button {
                            selectedTab = tab
                        } label: {
                            Text(tab)
                                .font(PhotonTypography.bodyMedium.weight(selectedTab == tab ? .semibold : .regular))
                                .foregroundColor(selectedTab == tab ? PhotonColors.textPrimary : PhotonColors.textSecondary)
                                .padding(.horizontal, PhotonSpacing.lg)
                                .padding(.vertical, PhotonSpacing.sm)
                                .background(selectedTab == tab ? PhotonColors.surfaceSecondary : Color.clear)
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(.horizontal, PhotonSpacing.md)
                .padding(.bottom, PhotonSpacing.lg)
            }
            .background(PhotonColors.surfacePrimary)
        }
        .photonBackground()
    }
}

#Preview {
    EditorPlaceholderView()
        .environment(NavigationState())
}
