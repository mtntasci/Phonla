//
//  CinematicToolView.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import SwiftUI

/// Compact horizontal preset strip for Phase 6 Cinematic Looks.
public struct CinematicToolView: View {
    @Bindable var viewModel: EditorViewModel
    
    public init(viewModel: EditorViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
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
                        HStack(spacing: 5) {
                            Image(systemName: preset.systemIcon)
                                .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                                .foregroundColor(isSelected ? PhotonColors.textInverted : preset.accentTint)
                            
                            Text(preset.name)
                                .font(.system(size: 12, weight: isSelected ? .semibold : .medium))
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 11)
                        .padding(.vertical, 7)
                        .background(isSelected ? PhotonColors.textPrimary : PhotonColors.surfaceSecondary)
                        .foregroundColor(isSelected ? PhotonColors.textInverted : PhotonColors.textPrimary)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .strokeBorder(isSelected ? Color.clear : PhotonColors.border.opacity(0.4), lineWidth: 0.8)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, PhotonSpacing.xs)
            .padding(.vertical, 4)
        }
    }
}

