//
//  CinematicToolView.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import SwiftUI

/// Preset selection panel and intensity control for Phase 6 Cinematic Looks.
public struct CinematicToolView: View {
    @Bindable var viewModel: EditorViewModel
    
    public init(viewModel: EditorViewModel) {
        self.viewModel = viewModel
    }
    
    private var isLookActive: Bool {
        if let lookId = viewModel.editState.selectedLookId, lookId != "original" {
            return true
        }
        return false
    }
    
    public var body: some View {
        VStack(spacing: PhotonSpacing.xs) {
            // Horizontal Presets Strip
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: PhotonSpacing.xs) {
                    ForEach(CinematicPreset.allPresets) { preset in
                        let isSelected = (viewModel.editState.selectedLookId == preset.id) ||
                            (viewModel.editState.selectedLookId == nil && preset.id == "original")
                        
                        Button {
                            viewModel.applyPresetUpdate {
                                if preset.id == "original" {
                                    viewModel.editState.selectedLookId = nil
                                } else {
                                    viewModel.editState.selectedLookId = preset.id
                                    // Turn off mono if cinematic look is chosen to maintain visual integrity
                                    viewModel.editState.isMonoActive = false
                                }
                            }
                        } label: {
                            VStack(spacing: PhotonSpacing.xxs) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: PhotonCornerRadius.sm, style: .continuous)
                                        .fill(isSelected ? PhotonColors.textPrimary : PhotonColors.surfaceSecondary)
                                        .frame(width: 46, height: 46)
                                    
                                    Image(systemName: preset.systemIcon)
                                        .font(.system(size: 19, weight: .regular))
                                        .foregroundColor(isSelected ? PhotonColors.textInverted : preset.accentTint)
                                }
                                
                                Text(preset.name)
                                    .font(PhotonTypography.caption.weight(isSelected ? .semibold : .regular))
                                    .foregroundColor(isSelected ? PhotonColors.textPrimary : PhotonColors.textSecondary)
                                    .lineLimit(1)
                            }
                            .frame(width: 58)
                            .padding(.vertical, PhotonSpacing.xxs)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, PhotonSpacing.md)
                .padding(.vertical, PhotonSpacing.xxs)
            }
            
            // Intensity Slider when a cinematic look is active
            if isLookActive {
                PhotonSlider(
                    title: "Yoğunluk",
                    value: Binding(
                        get: { viewModel.editState.lookIntensity },
                        set: { newVal in
                            viewModel.updateStateDirectly { $0.lookIntensity = newVal }
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
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .padding(.vertical, PhotonSpacing.xs)
    }
}
