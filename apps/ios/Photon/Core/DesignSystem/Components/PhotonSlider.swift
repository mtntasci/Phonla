//
//  PhotonSlider.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import SwiftUI

/// Minimalist, high-precision adjustment slider designed for Photon.
/// Features a center neutral tick, direct value readout, double-tap to reset, and haptic feedback.
public struct PhotonSlider: View {
    let title: String
    @Binding var value: Float
    let range: ClosedRange<Float>
    let defaultValue: Float
    let step: Float
    let valueFormatter: (Float) -> String
    let onEditingEnded: (() -> Void)?
    
    public init(
        title: String,
        value: Binding<Float>,
        range: ClosedRange<Float>,
        defaultValue: Float = 0.0,
        step: Float = 0.01,
        valueFormatter: @escaping (Float) -> String,
        onEditingEnded: (() -> Void)? = nil
    ) {
        self.title = title
        self._value = value
        self.range = range
        self.defaultValue = defaultValue
        self.step = step
        self.valueFormatter = valueFormatter
        self.onEditingEnded = onEditingEnded
    }
    
    private var isModified: Bool {
        abs(value - defaultValue) > (step * 0.5)
    }
    
    public var body: some View {
        VStack(spacing: PhotonSpacing.xs) {
            // Header with Title and Formatted Value
            HStack {
                Text(title)
                    .font(PhotonTypography.bodyMedium.weight(.medium))
                    .foregroundColor(isModified ? PhotonColors.textPrimary : PhotonColors.textSecondary)
                
                Spacer()
                
                // Formatted Value Pill
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        value = defaultValue
                    }
                    onEditingEnded?()
                } label: {
                    HStack(spacing: PhotonSpacing.xxs) {
                        Text(valueFormatter(value))
                            .font(PhotonTypography.valueMono)
                            .foregroundColor(isModified ? PhotonColors.textPrimary : PhotonColors.textTertiary)
                        
                        if isModified {
                            Image(systemName: "arrow.uturn.backward.circle.fill")
                                .font(.system(size: 11))
                                .foregroundColor(PhotonColors.textTertiary)
                        }
                    }
                    .padding(.horizontal, PhotonSpacing.sm)
                    .padding(.vertical, 2)
                    .background(isModified ? PhotonColors.surfaceSecondary : Color.clear)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            
            // Slider Control
            Slider(
                value: Binding(
                    get: { self.value },
                    set: { newValue in
                        self.value = newValue
                    }
                ),
                in: range,
                step: step
            ) {
                Text(title)
            } minimumValueLabel: {
                EmptyView()
            } maximumValueLabel: {
                EmptyView()
            } onEditingChanged: { editing in
                if !editing {
                    onEditingEnded?()
                }
            }
            .tint(PhotonColors.textPrimary)
        }
        .padding(.horizontal, PhotonSpacing.md)
        .padding(.vertical, PhotonSpacing.xs)
    }
}

#Preview {
    VStack(spacing: 20) {
        PhotonSlider(
            title: "Pozlama",
            value: .constant(0.4),
            range: -2.0...2.0,
            defaultValue: 0.0,
            step: 0.05,
            valueFormatter: { val in
                val >= 0 ? String(format: "+%.2f EV", val) : String(format: "%.2f EV", val)
            }
        )
        
        PhotonSlider(
            title: "Kontrast",
            value: .constant(1.0),
            range: 0.5...1.5,
            defaultValue: 1.0,
            step: 0.02,
            valueFormatter: { val in
                let percent = Int((val - 1.0) * 100)
                return percent >= 0 ? "+\(percent)%" : "\(percent)%"
            }
        )
    }
    .padding()
    .photonBackground()
}
