//
//  SmoothToolView.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import SwiftUI

/// Compact sub-tool bar for Portrait & Skin Smoothing (Cilt) tool.
public struct SmoothToolView: View {
    @Bindable var viewModel: EditorViewModel
    
    public init(viewModel: EditorViewModel) {
        self.viewModel = viewModel
    }
    
    private var healedSpotsCount: Int {
        viewModel.editState.healedSpots.count
    }
    
    public var body: some View {
        HStack(spacing: PhotonSpacing.sm) {
            // Primary Leke Silme Button (Cilt main tool)
            Button {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.8)) {
                    viewModel.selectedPortraitSubTool = .healing
                }
            } label: {
                HStack(spacing: 5) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "bandage.fill")
                            .font(.system(size: 13, weight: .semibold))
                        
                        if healedSpotsCount > 0 {
                            Circle()
                                .fill(PhotonColors.accent)
                                .frame(width: 5, height: 5)
                                .offset(x: 3, y: -2)
                        }
                    }
                    
                    Text("Leke Silme")
                        .font(.system(size: 12, weight: .semibold))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(PhotonColors.textPrimary)
                .foregroundColor(PhotonColors.textInverted)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            
            // Brush Size Chips
            HStack(spacing: 4) {
                ForEach(HealingBrushPreset.allCases) { preset in
                    let isPresetSelected = viewModel.selectedBrushPreset == preset
                    Button {
                        withAnimation(.spring(response: 0.22, dampingFraction: 0.8)) {
                            viewModel.selectedBrushPreset = preset
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(isPresetSelected ? PhotonColors.textInverted : PhotonColors.textSecondary)
                                .frame(width: preset.iconSize * 0.45, height: preset.iconSize * 0.45)
                            
                            Text(preset.rawValue)
                                .font(.system(size: 11, weight: isPresetSelected ? .bold : .medium))
                        }
                        .padding(.horizontal, 9)
                        .padding(.vertical, 6)
                        .background(isPresetSelected ? PhotonColors.textPrimary : PhotonColors.surfaceSecondary)
                        .foregroundColor(isPresetSelected ? PhotonColors.textInverted : PhotonColors.textSecondary)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            
            // Spot Healing Info Tag
            if healedSpotsCount > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 11))
                        .foregroundColor(PhotonColors.accent)
                    Text("\(healedSpotsCount) Leke")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(PhotonColors.textSecondary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(PhotonColors.surfaceSecondary.opacity(0.8))
                .clipShape(Capsule())
            }
            
            Spacer()
        }
        .padding(.horizontal, PhotonSpacing.xs)
        .padding(.vertical, 4)
    }
}
