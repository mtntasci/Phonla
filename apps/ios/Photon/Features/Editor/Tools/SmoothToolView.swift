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
            // MARK: - Manuel Subtool Button with Upward Brush Size Menu
            Menu {
                Section("Fırça Boyutu") {
                    ForEach(HealingBrushPreset.allCases) { preset in
                        Button {
                            withAnimation(.spring(response: 0.22, dampingFraction: 0.8)) {
                                viewModel.selectedBrushPreset = preset
                            }
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                        } label: {
                            HStack {
                                Text(preset.rawValue)
                                if viewModel.selectedBrushPreset == preset {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "bandage.fill")
                        .font(.system(size: 12, weight: .semibold))
                    
                    Text("Manuel")
                        .font(.system(size: 12, weight: .bold))
                    
                    Text("(\(viewModel.selectedBrushPreset.rawValue))")
                        .font(.system(size: 11, weight: .medium))
                        .opacity(0.85)
                    
                    Image(systemName: "chevron.up")
                        .font(.system(size: 9, weight: .bold))
                        .opacity(0.75)
                    
                    if healedSpotsCount > 0 {
                        Circle()
                            .fill(PhotonColors.accent)
                            .frame(width: 5, height: 5)
                    }
                }
                .padding(.horizontal, 13)
                .padding(.vertical, 7)
                .background(PhotonColors.textPrimary)
                .foregroundColor(PhotonColors.textInverted)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            
            // MARK: - Bul & Temizle Button (AI Face & Spot Scanner)
            Button {
                viewModel.runAutoFindAndCleanBlemishes()
            } label: {
                HStack(spacing: 5) {
                    if viewModel.isScanningBlemishes {
                        ProgressView()
                            .scaleEffect(0.65)
                            .tint(PhotonColors.textInverted)
                        Text("Taranıyor...")
                            .font(.system(size: 11, weight: .bold))
                    } else {
                        Image(systemName: "sparkle.magnifyingglass")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color.cyan)
                        
                        Text("Bul & Temizle")
                            .font(.system(size: 12, weight: .bold))
                    }
                }
                .padding(.horizontal, 13)
                .padding(.vertical, 7)
                .background(
                    viewModel.isScanningBlemishes
                    ? PhotonColors.textPrimary
                    : PhotonColors.surfaceSecondary
                )
                .foregroundColor(
                    viewModel.isScanningBlemishes
                    ? PhotonColors.textInverted
                    : PhotonColors.textPrimary
                )
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .strokeBorder(Color.cyan.opacity(0.45), lineWidth: 1.0)
                )
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isScanningBlemishes)
            
            Spacer()
        }
        .padding(.horizontal, PhotonSpacing.xs)
        .padding(.vertical, 4)
    }
}
