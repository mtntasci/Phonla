//
//  SmoothToolView.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import SwiftUI

/// Adjustment panel for Portrait & Skin Smoothing tool.
public struct SmoothToolView: View {
    @Bindable var viewModel: EditorViewModel
    
    public init(viewModel: EditorViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: PhotonSpacing.sm) {
            Spacer(minLength: 0)
            
            // Main Portrait Skin Smoothing Slider (0 - 100)
            PhotonSlider(
                title: "Yumuşat",
                value: Binding(
                    get: { viewModel.editState.skinSmoothing },
                    set: { newVal in
                        viewModel.updateStateDirectly { $0.skinSmoothing = newVal }
                    }
                ),
                range: 0.0...100.0,
                defaultValue: 0.0,
                step: 1.0,
                valueFormatter: { val in
                    "\(Int(val))"
                },
                onEditingEnded: {
                    viewModel.recordHistorySnapshot()
                }
            )
            
            Spacer(minLength: 0)
        }
        .padding(.vertical, PhotonSpacing.xxs)
    }
}
