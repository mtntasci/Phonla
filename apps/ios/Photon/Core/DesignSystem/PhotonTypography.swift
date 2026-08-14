//
//  PhotonTypography.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import SwiftUI

/// Typography scale and font helpers for Photon.
public enum PhotonTypography {
    /// Hero brand display text (32 pt, Bold, tracking: -0.5)
    public static let hero = Font.system(size: 32, weight: .bold, design: .default)
    
    /// Large screen titles (24 pt, Semibold, tracking: -0.3)
    public static let titleLarge = Font.system(size: 24, weight: .semibold, design: .default)
    
    /// Section and card headers (18 pt, Semibold)
    public static let titleMedium = Font.system(size: 18, weight: .semibold, design: .default)
    
    /// Subtitles and emphasized body (16 pt, Medium)
    public static let headline = Font.system(size: 16, weight: .medium, design: .default)
    
    /// Primary body text (15 pt, Regular)
    public static let bodyLarge = Font.system(size: 15, weight: .regular, design: .default)
    
    /// Secondary body and description text (13 pt, Regular)
    public static let bodyMedium = Font.system(size: 13, weight: .regular, design: .default)
    
    /// Captions and fine print (11 pt, Regular)
    public static let caption = Font.system(size: 11, weight: .regular, design: .default)
    
    /// Primary button label (15 pt, Semibold)
    public static let button = Font.system(size: 15, weight: .semibold, design: .default)
    
    /// Monospaced technical values (sliders, values) (12 pt, Medium, Monospaced)
    public static let valueMono = Font.system(size: 12, weight: .medium, design: .monospaced)
}
