//
//  SmoothToolView.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import SwiftUI

/// Compact sub-tool bar for Skin Smoothing (Cilt) tool.
public struct SmoothToolView: View {
    @Bindable var viewModel: EditorViewModel
    
    public init(viewModel: EditorViewModel) {
        self.viewModel = viewModel
    }
    
    private var isModified: Bool {
        viewModel.editState.skinSmoothing > 0.001
    }
    
    public var body: some View {
        HStack(spacing: PhotonSpacing.sm) {
            // Main Smoothing Subtool Active Button
            HStack(spacing: 5) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 15, weight: .semibold))
                    
                    if isModified {
                        Circle()
                            .fill(PhotonColors.accent)
                            .frame(width: 5, height: 5)
                            .offset(x: 3, y: -2)
                    }
                }
                
                Text("Pürüzsüzlük")
                    .font(.system(size: 12, weight: .semibold))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(PhotonColors.textPrimary)
            .foregroundColor(PhotonColors.textInverted)
            .clipShape(Capsule())
            
            // Detected Faces Tag / Status
            HStack(spacing: 4) {
                Image(systemName: "face.smiling")
                    .font(.system(size: 12))
                
                if viewModel.isDetectingFaces {
                    Text("Yüzler taranıyor...")
                        .font(.system(size: 11, weight: .medium))
                } else if viewModel.detectedFaces.isEmpty {
                    Text("Yüz tespit edilmedi")
                        .font(.system(size: 11, weight: .medium))
                } else {
                    Text("\(viewModel.detectedFaces.count) Yüz (Odaklandı)")
                        .font(.system(size: 11, weight: .medium))
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(PhotonColors.surfaceSecondary)
            .foregroundColor(PhotonColors.textSecondary)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(PhotonColors.border.opacity(0.4), lineWidth: 0.8)
            )
            
            Spacer()
        }
        .padding(.horizontal, PhotonSpacing.xs)
        .padding(.vertical, 4)
    }
}

