//
//  CinematicPreset.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import SwiftUI

/// Definition of a cinematic color grading look / preset.
public struct CinematicPreset: Identifiable, Equatable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let subtitle: String
    public let systemIcon: String
    public let accentTint: Color
    
    public init(
        id: String,
        name: String,
        subtitle: String,
        systemIcon: String,
        accentTint: Color = Color.primary
    ) {
        self.id = id
        self.name = name
        self.subtitle = subtitle
        self.systemIcon = systemIcon
        self.accentTint = accentTint
    }
    
    /// Default collection of Phase 6 cinematic presets.
    public static let allPresets: [CinematicPreset] = [
        CinematicPreset(
            id: "original",
            name: "Orijinal",
            subtitle: "Doğal Renkler",
            systemIcon: "slash.circle",
            accentTint: Color.gray
        ),
        CinematicPreset(
            id: "cinema",
            name: "Sinema",
            subtitle: "Teal & Orange Sinema",
            systemIcon: "film",
            accentTint: Color(hex: "#E08A46")
        ),
        CinematicPreset(
            id: "warm",
            name: "Sıcak",
            subtitle: "Altın Saat Sıcaklığı",
            systemIcon: "sun.horizon.fill",
            accentTint: Color(hex: "#E5A93C")
        ),
        CinematicPreset(
            id: "cold",
            name: "Soğuk",
            subtitle: "Kuzey Mavi Tonları",
            systemIcon: "snowflake",
            accentTint: Color(hex: "#5B92E5")
        ),
        CinematicPreset(
            id: "teal",
            name: "Turkuaz",
            subtitle: "Turkuaz & Cyan Gölge",
            systemIcon: "drop.fill",
            accentTint: Color(hex: "#2FA4A9")
        ),
        CinematicPreset(
            id: "fade",
            name: "Soluk",
            subtitle: "Matte Film Kontrastı",
            systemIcon: "smoke.fill",
            accentTint: Color(hex: "#9C9288")
        ),
        CinematicPreset(
            id: "night",
            name: "Gece",
            subtitle: "Gece Şehri Atmosferi",
            systemIcon: "moon.stars.fill",
            accentTint: Color(hex: "#3B4A7A")
        ),
        CinematicPreset(
            id: "forest",
            name: "Orman",
            subtitle: "Zümrüt Yeşil & Toprak",
            systemIcon: "leaf.fill",
            accentTint: Color(hex: "#3D8249")
        ),
        CinematicPreset(
            id: "urban",
            name: "Şehir",
            subtitle: "Sert Sokak & Doku",
            systemIcon: "building.2.fill",
            accentTint: Color(hex: "#7A7E85")
        )
    ]
}
