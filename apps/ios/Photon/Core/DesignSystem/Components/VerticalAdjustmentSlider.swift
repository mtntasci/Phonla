//
//  VerticalAdjustmentSlider.swift
//  Photon
//
//  Created by Metin TASCI on 15.08.2026.
//

import SwiftUI
import UIKit

/// Sleek, translucent vertical adjustment slider positioned on the right side of the photo preview.
/// Supports smooth vertical dragging, dynamic live value pill, center/default indicator, and double-tap reset.
public struct VerticalAdjustmentSlider: View {
    let systemIcon: String
    let title: String
    @Binding var value: Float
    let range: ClosedRange<Float>
    let defaultValue: Float
    let step: Float?
    let valueFormatter: (Float) -> String
    let onEditingEnded: (() -> Void)?
    
    @State private var isDragging: Bool = false
    @State private var dragStartY: CGFloat = 0
    @State private var dragStartValue: Float = 0
    
    private let sliderHeight: CGFloat = 190
    private let sliderWidth: CGFloat = 34
    private let thumbSize: CGFloat = 26
    
    public init(
        systemIcon: String,
        title: String,
        value: Binding<Float>,
        range: ClosedRange<Float>,
        defaultValue: Float = 0.0,
        step: Float? = nil,
        valueFormatter: @escaping (Float) -> String = { String(format: "%.2f", $0) },
        onEditingEnded: (() -> Void)? = nil
    ) {
        self.systemIcon = systemIcon
        self.title = title
        self._value = value
        self.range = range
        self.defaultValue = defaultValue
        self.step = step
        self.valueFormatter = valueFormatter
        self.onEditingEnded = onEditingEnded
    }
    
    private var isModified: Bool {
        abs(value - defaultValue) > 0.001
    }
    
    /// Normalized position [0, 1] where 0 is bottom (min) and 1 is top (max)
    private var normalizedProgress: CGFloat {
        let span = range.upperBound - range.lowerBound
        guard span > 0 else { return 0.5 }
        let clamped = min(max(value, range.lowerBound), range.upperBound)
        return CGFloat((clamped - range.lowerBound) / span)
    }
    
    /// Normalized default position [0, 1]
    private var normalizedDefault: CGFloat {
        let span = range.upperBound - range.lowerBound
        guard span > 0 else { return 0.5 }
        let clamped = min(max(defaultValue, range.lowerBound), range.upperBound)
        return CGFloat((clamped - range.lowerBound) / span)
    }
    
    public var body: some View {
        HStack(spacing: PhotonSpacing.xs) {
            // MARK: - Floating Dynamic Value Badge (Shows to the left of the slider)
            HStack(spacing: 4) {
                Image(systemName: systemIcon)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(isModified ? PhotonColors.accent : PhotonColors.textSecondary)
                
                Text(valueFormatter(value))
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(PhotonColors.textPrimary)
                    .contentTransition(.numericText())
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Capsule()
                            .strokeBorder(isModified ? PhotonColors.accent.opacity(0.4) : PhotonColors.border.opacity(0.5), lineWidth: 0.8)
                    )
                    .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 2)
            )
            .animation(.spring(response: 0.25, dampingFraction: 0.85), value: value)
            .onTapGesture(count: 2) {
                resetToDefault()
            }
            
            // MARK: - Vertical Glass Slider Track
            GeometryReader { geometry in
                let availableTravel = sliderHeight - thumbSize
                let thumbY = (1.0 - normalizedProgress) * availableTravel
                let defaultY = (1.0 - normalizedDefault) * availableTravel + (thumbSize / 2)
                
                ZStack(alignment: .top) {
                    // Glass Background Capsule
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Capsule()
                                .fill(PhotonColors.surfacePrimary.opacity(0.45))
                        )
                        .overlay(
                            Capsule()
                                .strokeBorder(PhotonColors.border.opacity(0.6), lineWidth: 0.6)
                        )
                        .shadow(color: Color.black.opacity(0.18), radius: 8, x: 0, y: 3)
                    
                    // Center / Default Tick Line
                    Rectangle()
                        .fill(PhotonColors.textTertiary.opacity(0.5))
                        .frame(width: 14, height: 1.5)
                        .position(x: sliderWidth / 2, y: defaultY)
                    
                    // Active Range Fill Line
                    let fillTop = min(thumbY + (thumbSize / 2), defaultY)
                    let fillBottom = max(thumbY + (thumbSize / 2), defaultY)
                    let fillHeight = max(fillBottom - fillTop, 0)
                    
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(isModified ? PhotonColors.accent : PhotonColors.textTertiary)
                        .frame(width: 3, height: fillHeight)
                        .position(x: sliderWidth / 2, y: fillTop + (fillHeight / 2))
                    
                    // Thumb Knob
                    Circle()
                        .fill(PhotonColors.textPrimary)
                        .frame(width: thumbSize, height: thumbSize)
                        .overlay(
                            Circle()
                                .strokeBorder(isModified ? PhotonColors.accent : PhotonColors.border, lineWidth: 1.5)
                        )
                        .overlay(
                            Image(systemName: systemIcon)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(PhotonColors.textInverted)
                        )
                        .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 2)
                        .offset(y: thumbY)
                        .animation(isDragging ? nil : .spring(response: 0.28, dampingFraction: 0.8), value: normalizedProgress)
                }
                .frame(width: sliderWidth, height: sliderHeight)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { gesture in
                            if !isDragging {
                                isDragging = true
                                dragStartY = gesture.location.y
                                dragStartValue = value
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            }
                            
                            // Dragging UP decreases Y, which means INCREASING value
                            let currentY = min(max(gesture.location.y, thumbSize / 2), sliderHeight - (thumbSize / 2))
                            let progress = 1.0 - ((currentY - (thumbSize / 2)) / availableTravel)
                            let span = range.upperBound - range.lowerBound
                            var calculatedValue = range.lowerBound + Float(progress) * span
                            
                            if let step = step, step > 0 {
                                calculatedValue = (calculatedValue / step).rounded() * step
                            }
                            
                            let finalValue = min(max(calculatedValue, range.lowerBound), range.upperBound)
                            if abs(finalValue - value) > 0.0001 {
                                value = finalValue
                            }
                        }
                        .onEnded { _ in
                            isDragging = false
                            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                            onEditingEnded?()
                        }
                )
                .simultaneousGesture(
                    TapGesture(count: 2)
                        .onEnded {
                            resetToDefault()
                        }
                )
            }
            .frame(width: sliderWidth, height: sliderHeight)
        }
    }
    
    private func resetToDefault() {
        guard isModified else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        withAnimation(.spring(response: 0.28, dampingFraction: 0.8)) {
            value = defaultValue
        }
        onEditingEnded?()
    }
}
