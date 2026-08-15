//
//  MonoToolView.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import SwiftUI

/// Compact horizontal preset strip for Phase 7 Professional Monochrome Engine.
public struct MonoToolView: View {
    @Bindable var viewModel: EditorViewModel
    
    public init(viewModel: EditorViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: PhotonSpacing.xs) {
                // Original / Color Toggle Option
                Button {
                    viewModel.applyPresetUpdate {
                        viewModel.editState.isMonoActive = false
                    }
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "slash.circle")
                            .font(.system(size: 13, weight: !viewModel.editState.isMonoActive ? .semibold : .regular))
                            .foregroundColor(!viewModel.editState.isMonoActive ? PhotonColors.textInverted : PhotonColors.textSecondary)
                        
                        Text("Renkli")
                            .font(.system(size: 12, weight: !viewModel.editState.isMonoActive ? .semibold : .medium))
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 11)
                    .padding(.vertical, 7)
                    .background(!viewModel.editState.isMonoActive ? PhotonColors.textPrimary : PhotonColors.surfaceSecondary)
                    .foregroundColor(!viewModel.editState.isMonoActive ? PhotonColors.textInverted : PhotonColors.textPrimary)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .strokeBorder(!viewModel.editState.isMonoActive ? Color.clear : PhotonColors.border.opacity(0.4), lineWidth: 0.8)
                    )
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
                        HStack(spacing: 5) {
                            Image(systemName: preset.systemIcon)
                                .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                                .foregroundColor(isSelected ? PhotonColors.textInverted : PhotonColors.textPrimary)
                            
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

