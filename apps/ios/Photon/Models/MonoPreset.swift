//
//  MonoPreset.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import SwiftUI

/// Definition of a professional monochrome preset with distinct RGB luminance channel weights and tonal characteristics.
public struct MonoPreset: Identifiable, Equatable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let subtitle: String
    public let systemIcon: String
    
    // Channel mixing weights
    public let redWeight: Float
    public let greenWeight: Float
    public let blueWeight: Float
    
    // Tone adjustments
    public let contrastMultiplier: Float
    public let brightnessOffset: Float
    public let highlightRecovery: Float
    public let shadowLift: Float
    
    public init(
        id: String,
        name: String,
        subtitle: String,
        systemIcon: String,
        redWeight: Float,
        greenWeight: Float,
        blueWeight: Float,
        contrastMultiplier: Float = 1.0,
        brightnessOffset: Float = 0.0,
        highlightRecovery: Float = 0.0,
        shadowLift: Float = 0.0
    ) {
        self.id = id
        self.name = name
        self.subtitle = subtitle
        self.systemIcon = systemIcon
        self.redWeight = redWeight
        self.greenWeight = greenWeight
        self.blueWeight = blueWeight
        self.contrastMultiplier = contrastMultiplier
        self.brightnessOffset = brightnessOffset
        self.highlightRecovery = highlightRecovery
        self.shadowLift = shadowLift
    }
    
    /// Default collection of Phase 7 professional monochrome presets.
    public static let allPresets: [MonoPreset] = [
        MonoPreset(
            id: "mono_natural",
            name: "Natural",
            subtitle: "Dengeli Doğal Gri Ton",
            systemIcon: "circle.lefthalf.filled",
            redWeight: 0.299,
            greenWeight: 0.587,
            blueWeight: 0.114,
            contrastMultiplier: 1.0
        ),
        MonoPreset(
            id: "mono_portrait",
            name: "Portrait",
            subtitle: "Pürüzsüz Ten & Yumuşak Ton",
            systemIcon: "person.crop.circle.fill",
            redWeight: 0.600,
            greenWeight: 0.300,
            blueWeight: 0.100,
            contrastMultiplier: 1.05,
            brightnessOffset: 0.04
        ),
        MonoPreset(
            id: "mono_high_contrast",
            name: "High Contrast",
            subtitle: "Derin Siyahlar & Gümüş",
            systemIcon: "circle.circle.fill",
            redWeight: 0.350,
            greenWeight: 0.550,
            blueWeight: 0.100,
            contrastMultiplier: 1.35,
            brightnessOffset: -0.02
        ),
        MonoPreset(
            id: "mono_soft",
            name: "Soft",
            subtitle: "İpeksi Düşük Kontrast",
            systemIcon: "cloud.fill",
            redWeight: 0.333,
            greenWeight: 0.333,
            blueWeight: 0.334,
            contrastMultiplier: 0.85,
            brightnessOffset: 0.05,
            shadowLift: 0.15
        ),
        MonoPreset(
            id: "mono_street",
            name: "Street",
            subtitle: "Sert Sokak & Doku",
            systemIcon: "road.lanes",
            redWeight: 0.400,
            greenWeight: 0.450,
            blueWeight: 0.150,
            contrastMultiplier: 1.20,
            shadowLift: -0.10
        ),
        MonoPreset(
            id: "mono_dramatic",
            name: "Dramatic",
            subtitle: "Kırmızı Filtre Gökyüzü",
            systemIcon: "bolt.circle.fill",
            redWeight: 0.780,
            greenWeight: 0.180,
            blueWeight: 0.040,
            contrastMultiplier: 1.40,
            brightnessOffset: -0.04
        )
    ]
}
