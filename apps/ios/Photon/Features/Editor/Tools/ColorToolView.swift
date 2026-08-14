//
//  ColorToolView.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import SwiftUI

/// Adjustment panel for Color tools: Temperature, Tint, Saturation, Vibrance.
public struct ColorToolView: View {
    @Bindable var viewModel: EditorViewModel
    
    public init(viewModel: EditorViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: PhotonSpacing.sm) {
                // Temperature
                PhotonSlider(
                    title: "Sıcaklık (Temperature)",
                    value: Binding(
                        get: { viewModel.editState.temperature },
                        set: { newVal in
                            viewModel.updateStateDirectly { $0.temperature = newVal }
                        }
                    ),
                    range: 2000.0...10000.0,
                    defaultValue: 6500.0,
                    step: 50.0,
                    valueFormatter: { val in
                        let diff = Int(val - 6500.0)
                        if diff == 0 {
                            return "6500K (Nötr)"
                        } else if diff > 0 {
                            return "+\(diff)K (\(Int(val))K)"
                        } else {
                            return "\(diff)K (\(Int(val))K)"
                        }
                    },
                    onEditingEnded: {
                        viewModel.recordHistorySnapshot()
                    }
                )
                
                // Tint
                PhotonSlider(
                    title: "Renk Tonu (Tint)",
                    value: Binding(
                        get: { viewModel.editState.tint },
                        set: { newVal in
                            viewModel.updateStateDirectly { $0.tint = newVal }
                        }
                    ),
                    range: -100.0...100.0,
                    defaultValue: 0.0,
                    step: 1.0,
                    valueFormatter: { val in
                        let ival = Int(val)
                        return ival >= 0 ? "+\(ival)" : "\(ival)"
                    },
                    onEditingEnded: {
                        viewModel.recordHistorySnapshot()
                    }
                )
                
                // Saturation
                PhotonSlider(
                    title: "Doygunluk (Saturation)",
                    value: Binding(
                        get: { viewModel.editState.saturation },
                        set: { newVal in
                            viewModel.updateStateDirectly { $0.saturation = newVal }
                        }
                    ),
                    range: 0.0...2.0,
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
                
                // Vibrance
                PhotonSlider(
                    title: "Canlılık (Vibrance)",
                    value: Binding(
                        get: { viewModel.editState.vibrance },
                        set: { newVal in
                            viewModel.updateStateDirectly { $0.vibrance = newVal }
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
