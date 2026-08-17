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
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: PhotonSpacing.sm) {
                // MARK: - Sub-tool Switcher (Pürüzsüzlük vs Leke Silme)
                HStack(spacing: 3) {
                    ForEach(PortraitSubTool.allCases) { subTool in
                        let isSelected = viewModel.selectedPortraitSubTool == subTool
                        Button {
                            withAnimation(.spring(response: 0.26, dampingFraction: 0.82)) {
                                viewModel.selectedPortraitSubTool = subTool
                            }
                        } label: {
                            HStack(spacing: 5) {
                                Image(systemName: subTool.systemIcon)
                                    .font(.system(size: 11, weight: .semibold))
                                
                                Text(subTool.rawValue)
                                    .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                                
                                if subTool == .healing && healedSpotsCount > 0 {
                                    Circle()
                                        .fill(PhotonColors.accent)
                                        .frame(width: 5, height: 5)
                                }
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(isSelected ? PhotonColors.textPrimary : PhotonColors.surfaceSecondary)
                            .foregroundColor(isSelected ? PhotonColors.textInverted : PhotonColors.textSecondary)
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                Divider()
                    .frame(height: 18)
                    .foregroundColor(PhotonColors.divider)
                
                // MARK: - Sihirbaz (Wizard) Mode Controls
                if viewModel.selectedPortraitSubTool == .smoothing {
                    // 1. Primary "Sihirbaz" Action Button (Triggers animated scan & mask overlay)
                    Button {
                        viewModel.runWizardRetouch()
                    } label: {
                        HStack(spacing: 6) {
                            if viewModel.isWizardScanning {
                                ProgressView()
                                    .scaleEffect(0.65)
                                    .tint(PhotonColors.textInverted)
                                Text("Taranıyor...")
                                    .font(.system(size: 11, weight: .bold))
                            } else {
                                Image(systemName: "wand.and.stars")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(viewModel.isWizardActive ? PhotonColors.textInverted : Color.cyan)
                                Text("Sihirbaz")
                                    .font(.system(size: 11, weight: .bold))
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            viewModel.isWizardActive || viewModel.isWizardScanning
                            ? PhotonColors.textPrimary
                            : PhotonColors.surfaceSecondary
                        )
                        .foregroundColor(
                            viewModel.isWizardActive || viewModel.isWizardScanning
                            ? PhotonColors.textInverted
                            : PhotonColors.textPrimary
                        )
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .strokeBorder(Color.cyan.opacity(0.5), lineWidth: 1.0)
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.isWizardScanning)
                    
                    // 2. Doğal vs İpeksi Mode Presets (Visible & active for user refinement)
                    HStack(spacing: 4) {
                        ForEach(WizardRetouchMode.allCases) { mode in
                            let isCurrent = (viewModel.isWizardActive || viewModel.editState.skinSmoothing > 0) && viewModel.selectedWizardMode == mode
                            Button {
                                if viewModel.isWizardActive {
                                    viewModel.selectWizardMode(mode)
                                } else {
                                    viewModel.runWizardRetouch(mode: mode)
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: mode.systemIcon)
                                        .font(.system(size: 10, weight: .semibold))
                                    Text(mode.rawValue)
                                        .font(.system(size: 11, weight: isCurrent ? .bold : .medium))
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(isCurrent ? PhotonColors.textPrimary : PhotonColors.surfaceSecondary)
                                .foregroundColor(isCurrent ? PhotonColors.textInverted : PhotonColors.textSecondary)
                                .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                    // 3. "Uygula" (Apply & Dismiss Mask) Button when mask is visible
                    if viewModel.isShowingSkinMaskOverlay {
                        Button {
                            viewModel.applyWizardAndDismissMask()
                        } label: {
                            HStack(spacing: 5) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 11, weight: .bold))
                                Text("Uygula")
                                    .font(.system(size: 11, weight: .bold))
                            }
                            .padding(.horizontal, 11)
                            .padding(.vertical, 6)
                            .background(Color(red: 0.12, green: 0.58, blue: 0.35))
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                        }
                        .buttonStyle(.plain)
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    // 4. Face Detection Badge
                    if !viewModel.detectedFaces.isEmpty {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 5, height: 5)
                            Text("\(viewModel.detectedFaces.count) Yüz Algılandı")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(PhotonColors.textSecondary)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(PhotonColors.surfaceSecondary.opacity(0.6))
                        .clipShape(Capsule())
                    }
                } else {
                    // MARK: - Spot Healing Sub-tools
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
                }
            }
            .padding(.horizontal, PhotonSpacing.xs)
            .padding(.vertical, 4)
        }
    }
}
