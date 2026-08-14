//
//  View+DesignSystem.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import SwiftUI

extension View {
    /// Applies Photon's standard pure white background.
    public func photonBackground() -> some View {
        self
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(PhotonColors.background)
    }
    
    /// Applies Photon's minimalist card style with optional border.
    public func photonCard(
        backgroundColor: Color = PhotonColors.surfacePrimary,
        cornerRadius: CGFloat = PhotonCornerRadius.md,
        hasBorder: Bool = true
    ) -> some View {
        self
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(hasBorder ? PhotonColors.border : Color.clear, lineWidth: 1)
            )
    }
    
    /// Subtle divider line for Photon lists and tool panels.
    public func photonDivider() -> some View {
        Rectangle()
            .fill(PhotonColors.divider)
            .frame(height: 1)
    }
}
