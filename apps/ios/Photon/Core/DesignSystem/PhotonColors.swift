//
//  PhotonColors.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import SwiftUI

/// Pure white / Light-mode focused color palette for Photon.
public enum PhotonColors {
    // MARK: - Backgrounds & Surfaces
    /// Pure white primary background (#FFFFFF)
    public static let background = Color(hex: "#FFFFFF")
    
    /// Pure white primary card / surface (#FFFFFF)
    public static let surfacePrimary = Color(hex: "#FFFFFF")
    
    /// Subtle light gray secondary surface for containers and pills (#F5F5F7)
    public static let surfaceSecondary = Color(hex: "#F5F5F7")
    
    /// Ultra-light tertiary surface for subtle highlights (#FAFAFA)
    public static let surfaceTertiary = Color(hex: "#FAFAFA")
    
    // MARK: - Text & Content
    /// Deep charcoal/black primary text (#111111)
    public static let textPrimary = Color(hex: "#111111")
    
    /// Neutral dark gray secondary text (#6E6E73)
    public static let textSecondary = Color(hex: "#6E6E73")
    
    /// Subtle light gray tertiary text (#8E8E93)
    public static let textTertiary = Color(hex: "#8E8E93")
    
    /// Inverted pure white text for solid dark buttons (#FFFFFF)
    public static let textInverted = Color(hex: "#FFFFFF")
    
    // MARK: - Borders & Dividers
    /// Clean, minimalist border line (#E5E5EA)
    public static let border = Color(hex: "#E5E5EA")
    
    /// Ultra-subtle separator / divider (#EFEFF4)
    public static let divider = Color(hex: "#EFEFF4")
    
    // MARK: - Brand & Accents
    /// Monochrome black accent (#111111)
    public static let accent = Color(hex: "#111111")
    
    /// Active / Interactive state tint (#111111)
    public static let tintActive = Color(hex: "#111111")
    
    /// Standard destructive / error red (#FF3B30)
    public static let error = Color(hex: "#FF3B30")
    
    /// Standard success green (#34C759)
    public static let success = Color(hex: "#34C759")
}
