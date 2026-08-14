//
//  LightToolView.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import SwiftUI

/// Adjustment panel for Light tools: Exposure, Brightness, Contrast, Highlights, Shadows.
public struct LightToolView: View {
    @Bindable var viewModel: EditorViewModel
    
    public init(viewModel: EditorViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: PhotonSpacing.sm) {
                // Exposure -> Pozlama
                PhotonSlider(
                    title: "Pozlama",
                    value: Binding(
                        get: { viewModel.editState.exposure },
                        set: { newVal in
                            viewModel.updateStateDirectly { $0.exposure = newVal }
                        }
                    ),
                    range: -2.0...2.0,
                    defaultValue: 0.0,
                    step: 0.05,
                    valueFormatter: { val in
                        val >= 0 ? String(format: "+%.2f EV", val) : String(format: "%.2f EV", val)
                    },
                    onEditingEnded: {
                        viewModel.recordHistorySnapshot()
                    }
                )
                
                // Brightness -> Parlaklık
                PhotonSlider(
                    title: "Parlaklık",
                    value: Binding(
                        get: { viewModel.editState.brightness },
                        set: { newVal in
                            viewModel.updateStateDirectly { $0.brightness = newVal }
                        }
                    ),
                    range: -1.0...1.0,
                    defaultValue: 0.0,
                    step: 0.02,
                    valueFormatter: { val in
                        let percent = Int(val * 100)
                        return percent >= 0 ? "+\(percent)%" : "\(percent)%"
                    },
                    onEditingEnded: {
                        viewModel.recordHistorySnapshot()
                    }
                )
                
                // Contrast -> Kontrast
                PhotonSlider(
                    title: "Kontrast",
                    value: Binding(
                        get: { viewModel.editState.contrast },
                        set: { newVal in
                            viewModel.updateStateDirectly { $0.contrast = newVal }
                        }
                    ),
                    range: 0.5...1.5,
                    defaultValue: 1.0,
                    step: 0.02,
                    valueFormatter: { val in
                        let percent = Int((val - 1.0) * 100)
                        return percent >= 0 ? "+\(percent)%" : "\(percent)%"
                    },
                    onEditingEnded: {
                        viewModel.recordHistorySnapshot()
                    }
                )
                
                // Highlights -> Parlak Alanlar
                PhotonSlider(
                    title: "Parlak Alanlar",
                    value: Binding(
                        get: { viewModel.editState.highlights },
                        set: { newVal in
                            viewModel.updateStateDirectly { $0.highlights = newVal }
                        }
                    ),
                    range: -1.0...1.0,
                    defaultValue: 0.0,
                    step: 0.02,
                    valueFormatter: { val in
                        let percent = Int(val * 100)
                        return percent >= 0 ? "+\(percent)%" : "\(percent)%"
                    },
                    onEditingEnded: {
                        viewModel.recordHistorySnapshot()
                    }
                )
                
                // Shadows -> Gölgeler
                PhotonSlider(
                    title: "Gölgeler",
                    value: Binding(
                        get: { viewModel.editState.shadows },
                        set: { newVal in
                            viewModel.updateStateDirectly { $0.shadows = newVal }
                        }
                    ),
                    range: -1.0...1.0,
                    defaultValue: 0.0,
                    step: 0.02,
                    valueFormatter: { val in
                        let percent = Int(val * 100)
                        return percent >= 0 ? "+\(percent)%" : "\(percent)%"
                    },
                    onEditingEnded: {
                        viewModel.recordHistorySnapshot()
                    }
                )
            }
            .padding(.vertical, PhotonSpacing.xs)
        }
    }
}
