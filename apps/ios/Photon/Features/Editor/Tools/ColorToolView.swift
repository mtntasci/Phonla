//
//  ColorToolView.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import SwiftUI

/// Compact sub-tool icon bar for Color adjustments (Temperature, Tint, Saturation, Vibrance).
public struct ColorToolView: View {
    @Bindable var viewModel: EditorViewModel
    
    public init(viewModel: EditorViewModel) {
        self.viewModel = viewModel
    }
    
    private func isSubToolModified(_ tool: ColorSubTool) -> Bool {
        switch tool {
        case .temperature: return abs(viewModel.editState.temperature - 6500.0) > 1.0
        case .tint: return abs(viewModel.editState.tint) > 0.001
        case .saturation: return abs(viewModel.editState.saturation - 1.0) > 0.001
        case .vibrance: return abs(viewModel.editState.vibrance) > 0.001
        }
    }
    
    public var body: some View {
        HStack(spacing: PhotonSpacing.xs) {
            ForEach(ColorSubTool.allCases) { tool in
                let isSelected = viewModel.selectedColorSubTool == tool
                let modified = isSubToolModified(tool)
                
                Button {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.82)) {
                        viewModel.selectedColorSubTool = tool
                    }
                } label: {
                    HStack(spacing: 5) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: tool.systemIcon)
                                .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
                            
                            if modified {
                                Circle()
                                    .fill(PhotonColors.accent)
                                    .frame(width: 5, height: 5)
                                    .offset(x: 3, y: -2)
                            }
                        }
                        
                        Text(tool.rawValue)
                            .font(.system(size: 12, weight: isSelected ? .semibold : .medium))
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(isSelected ? PhotonColors.textPrimary : PhotonColors.surfaceSecondary)
                    .foregroundColor(isSelected ? PhotonColors.textInverted : PhotonColors.textPrimary)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .strokeBorder(isSelected ? Color.clear : (modified ? PhotonColors.accent.opacity(0.4) : PhotonColors.border.opacity(0.4)), lineWidth: 0.8)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, PhotonSpacing.xs)
        .padding(.vertical, 4)
    }
}

