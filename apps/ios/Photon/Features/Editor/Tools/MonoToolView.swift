//
//  MonoToolView.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import SwiftUI

/// Preset selection panel and intensity control for Phase 7 Professional Monochrome Engine.
public struct MonoToolView: View {
    @Bindable var viewModel: EditorViewModel
    
    public init(viewModel: EditorViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: PhotonSpacing.sm) {
            // Horizontal Mono Presets Strip
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: PhotonSpacing.sm) {
                    // Original / Color Toggle Option
                    Button {
                        viewModel.applyPresetUpdate {
                            viewModel.editState.isMonoActive = false
                        }
                    } label: {
                        VStack(spacing: PhotonSpacing.xs) {
                            ZStack {
                                RoundedRectangle(cornerRadius: PhotonCornerRadius.md, style: .continuous)
                                    .fill(!viewModel.editState.isMonoActive ? PhotonColors.textPrimary : PhotonColors.surfaceSecondary)
                                    .frame(width: 56, height: 56)
                                
                                Image(systemName: "slash.circle")
                                    .font(.system(size: 22, weight: .regular))
                                    .foregroundColor(!viewModel.editState.isMonoActive ? PhotonColors.textInverted : PhotonColors.textSecondary)
                            }
                            
                            Text("Renkli")
                                .font(PhotonTypography.caption.weight(!viewModel.editState.isMonoActive ? .semibold : .regular))
                                .foregroundColor(!viewModel.editState.isMonoActive ? PhotonColors.textPrimary : PhotonColors.textSecondary)
                        }
                        .frame(width: 68)
                        .padding(.vertical, PhotonSpacing.xxs)
                    }
                    .buttonStyle(.plain)
                    
                    // Mono Presets
                    ForEach(MonoPreset.allPresets) { preset in
                        let isSelected = viewModel.editState.isMonoActive &&
                            (viewModel.editState.selectedMonoPresetId == preset.id ||
                             (viewModel.editState.selectedMonoPresetId == nil && preset.id == "mono_natural"))
                        
                        Button {
                            viewModel.applyPresetUpdate {
                                viewModel.editState.isMonoActive = true
                                viewModel.editState.selectedMonoPresetId = preset.id
                                // Turn off cinematic look when mono is enabled
                                viewModel.editState.selectedLookId = nil
                            }
                        } label: {
                            VStack(spacing: PhotonSpacing.xs) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: PhotonCornerRadius.md, style: .continuous)
                                        .fill(isSelected ? PhotonColors.textPrimary : PhotonColors.surfaceSecondary)
                                        .frame(width: 56, height: 56)
                                    
                                    Image(systemName: preset.systemIcon)
                                        .font(.system(size: 22, weight: .regular))
                                        .foregroundColor(isSelected ? PhotonColors.textInverted : PhotonColors.textPrimary)
                                }
                                
                                Text(preset.name)
                                    .font(PhotonTypography.caption.weight(isSelected ? .semibold : .regular))
                                    .foregroundColor(isSelected ? PhotonColors.textPrimary : PhotonColors.textSecondary)
                            }
                            .frame(width: 68)
                            .padding(.vertical, PhotonSpacing.xxs)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, PhotonSpacing.md)
                .padding(.vertical, PhotonSpacing.xxs)
            }
            
            // Mono Intensity Slider when Monochrome is active
            if viewModel.editState.isMonoActive {
                Divider()
                    .foregroundColor(PhotonColors.divider)
                    .padding(.horizontal, PhotonSpacing.md)
                
                PhotonSlider(
                    title: "Yoğunluk",
                    value: Binding(
                        get: { viewModel.editState.monoIntensity },
                        set: { newVal in
                            viewModel.updateStateDirectly { $0.monoIntensity = newVal }
                        }
                    ),
                    range: 0.0...1.0,
                    defaultValue: 1.0,
                    step: 0.02,
                    valueFormatter: { val in
                        "\(Int(val * 100))%"
                    },
                    onEditingEnded: {
                        viewModel.recordHistorySnapshot()
                    }
                )
            }
        }
        .padding(.vertical, PhotonSpacing.xs)
    }
}
