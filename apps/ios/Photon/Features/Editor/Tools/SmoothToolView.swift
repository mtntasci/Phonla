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
    
    private var isSmoothingModified: Bool {
        viewModel.editState.skinSmoothing > 0.001
    }
    
    private var healedSpotsCount: Int {
        viewModel.editState.healedSpots.count
    }
    
    public var body: some View {
        HStack(spacing: PhotonSpacing.sm) {
            // Subtool Segments: Pürüzsüzlük vs Leke Silme
            ForEach(PortraitSubTool.allCases) { subTool in
                let isSelected = viewModel.selectedPortraitSubTool == subTool
                let isSubModified = subTool == .smoothing ? isSmoothingModified : healedSpotsCount > 0
                
                Button {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.8)) {
                        viewModel.selectedPortraitSubTool = subTool
                    }
                } label: {
                    HStack(spacing: 5) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: subTool.systemIcon)
                                .font(.system(size: 13, weight: .semibold))
                            
                            if isSubModified {
                                Circle()
                                    .fill(PhotonColors.accent)
                                    .frame(width: 5, height: 5)
                                    .offset(x: 3, y: -2)
                            }
                        }
                        
                        Text(subTool.rawValue)
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .padding(.horizontal, 11)
                    .padding(.vertical, 7)
                    .background(isSelected ? PhotonColors.textPrimary : PhotonColors.surfaceSecondary)
                    .foregroundColor(isSelected ? PhotonColors.textInverted : PhotonColors.textSecondary)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .strokeBorder(isSelected ? Color.clear : PhotonColors.border.opacity(0.4), lineWidth: 0.8)
                    )
                }
                .buttonStyle(.plain)
            }
            
            // Sub-mode Contextual Actions / Status Tags
            if viewModel.selectedPortraitSubTool == .smoothing {
                // Detected Faces Tag
                HStack(spacing: 4) {
                    Image(systemName: "face.smiling")
                        .font(.system(size: 11))
                    
                    if viewModel.isDetectingFaces {
                        Text("Taranıyor...")
                            .font(.system(size: 11, weight: .medium))
                    } else if viewModel.detectedFaces.isEmpty {
                        Text("Yüz algılanmadı")
                            .font(.system(size: 11, weight: .medium))
                    } else {
                        Text("\(viewModel.detectedFaces.count) Yüz")
                            .font(.system(size: 11, weight: .medium))
                    }
                }
                .padding(.horizontal, 9)
                .padding(.vertical, 6)
                .background(PhotonColors.surfaceSecondary.opacity(0.8))
                .foregroundColor(PhotonColors.textSecondary)
                .clipShape(Capsule())
            } else {
                // Spot Healing Controls (Select size to arm brush)
                HStack(spacing: PhotonSpacing.xs) {
                    // Brush Size Selector Chips
                    HStack(spacing: 4) {
                        ForEach(HealingBrushPreset.allCases) { preset in
                            let isPresetArmed = viewModel.armedBrushPreset == preset
                            Button {
                                withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                                    if viewModel.armedBrushPreset == preset {
                                        viewModel.armedBrushPreset = nil
                                    } else {
                                        viewModel.armedBrushPreset = preset
                                    }
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(isPresetArmed ? PhotonColors.textInverted : PhotonColors.textSecondary)
                                        .frame(width: preset.iconSize * 0.45, height: preset.iconSize * 0.45)
                                    
                                    Text(preset.rawValue)
                                        .font(.system(size: 11, weight: isPresetArmed ? .bold : .medium))
                                }
                                .padding(.horizontal, 9)
                                .padding(.vertical, 6)
                                .background(isPresetArmed ? PhotonColors.textPrimary : PhotonColors.surfaceSecondary)
                                .foregroundColor(isPresetArmed ? PhotonColors.textInverted : PhotonColors.textSecondary)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .strokeBorder(isPresetArmed ? PhotonColors.accent.opacity(0.8) : PhotonColors.border.opacity(0.4), lineWidth: isPresetArmed ? 1.2 : 0.8)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                    // Status Hint Tag
                    HStack(spacing: 4) {
                        if let armed = viewModel.armedBrushPreset {
                            Circle()
                                .fill(PhotonColors.accent)
                                .frame(width: 5, height: 5)
                            Text("Lekeye dokunun")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(PhotonColors.textPrimary)
                        } else {
                            Text("Boyut seçin")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(PhotonColors.textTertiary)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(PhotonColors.surfaceSecondary.opacity(0.6))
                    .clipShape(Capsule())
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, PhotonSpacing.xs)
        .padding(.vertical, 4)
    }
}
