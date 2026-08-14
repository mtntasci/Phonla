//
//  PhotoEditState.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import Foundation

/// Central, serializable, and deterministic state model representing all adjustments.
public struct PhotoEditState: Equatable, Codable, Sendable {
    // MARK: - Light Adjustments
    /// Exposure adjustment in EV stops (-2.0 ... 2.0, neutral: 0.0)
    public var exposure: Float = 0.0
    
    /// Brightness adjustment (-1.0 ... 1.0, neutral: 0.0)
    public var brightness: Float = 0.0
    
    /// Contrast adjustment (0.5 ... 1.5, neutral: 1.0)
    public var contrast: Float = 1.0
    
    /// Highlights adjustment (-1.0 ... 1.0, neutral: 0.0)
    public var highlights: Float = 0.0
    
    /// Shadows adjustment (-1.0 ... 1.0, neutral: 0.0)
    public var shadows: Float = 0.0
    
    // MARK: - Color Adjustments
    /// White Balance Color Temperature in Kelvin (2000K ... 10000K, neutral: 6500K)
    public var temperature: Float = 6500.0
    
    /// Color Tint (-100.0 ... 100.0, neutral: 0.0)
    public var tint: Float = 0.0
    
    /// Color Saturation (0.0 ... 2.0, neutral: 1.0)
    public var saturation: Float = 1.0
    
    /// Color Vibrance (-1.0 ... 1.0, neutral: 0.0)
    public var vibrance: Float = 0.0
    
    // MARK: - Cinematic Looks (Preset / LUT)
    /// Selected cinematic look identifier (e.g. "teal_orange", "kodak_gold", "cinestill")
    public var selectedLookId: String? = nil
    
    /// Intensity of cinematic look blending (0.0 ... 1.0, default: 1.0)
    public var lookIntensity: Float = 1.0
    
    // MARK: - Monochrome Engine
    /// Flag indicating whether monochrome mode is active
    public var isMonoActive: Bool = false
    
    /// Selected mono preset identifier (e.g. "high_contrast", "noir", "soft_bw")
    public var selectedMonoPresetId: String? = nil
    
    /// Monochrome intensity blending (0.0 ... 1.0, default: 1.0)
    public var monoIntensity: Float = 1.0
    
    // MARK: - Portrait & Skin Smoothing
    /// Skin smoothing intensity (0.0 ... 100.0, neutral: 0.0)
    public var skinSmoothing: Float = 0.0
    
    // MARK: - Helpers & Identity
    
    public init() {}
    
    /// Baseline identity state (unmodified image)
    public static let identity = PhotoEditState()
    
    /// Returns true if any adjustment has diverged from default values.
    public var isEdited: Bool {
        self != Self.identity
    }
    
    /// Resets all values to the default unmodified state.
    public mutating func reset() {
        self = Self.identity
    }
}
