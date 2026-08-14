package com.alafteknoloji.photon.models

import androidx.compose.ui.graphics.Color

/**
 * Definition of a cinematic color grading look / preset.
 * 100% Parity with iOS CinematicPreset.swift.
 */
data class CinematicPreset(
    val id: String,
    val name: String,
    val subtitle: String,
    val accentTint: Color = Color.White
) {
    companion object {
        val allPresets = listOf(
            CinematicPreset(
                id = "original",
                name = "Orijinal",
                subtitle = "Doğal Renkler",
                accentTint = Color.Gray
            ),
            CinematicPreset(
                id = "cinema",
                name = "Sinema",
                subtitle = "Teal & Orange Sinema",
                accentTint = Color(0xFFE08A46)
            ),
            CinematicPreset(
                id = "warm",
                name = "Sıcak",
                subtitle = "Altın Saat Sıcaklığı",
                accentTint = Color(0xFFE5A93C)
            ),
            CinematicPreset(
                id = "cold",
                name = "Soğuk",
                subtitle = "Kuzey Mavi Tonları",
                accentTint = Color(0xFF5B92E5)
            ),
            CinematicPreset(
                id = "teal",
                name = "Turkuaz",
                subtitle = "Turkuaz & Cyan Gölge",
                accentTint = Color(0xFF2FA4A9)
            ),
            CinematicPreset(
                id = "fade",
                name = "Soluk",
                subtitle = "Matte Film Kontrastı",
                accentTint = Color(0xFF9C9288)
            ),
            CinematicPreset(
                id = "night",
                name = "Gece",
                subtitle = "Gece Şehri Atmosferi",
                accentTint = Color(0xFF3B4A7A)
            ),
            CinematicPreset(
                id = "forest",
                name = "Orman",
                subtitle = "Zümrüt Yeşil & Toprak",
                accentTint = Color(0xFF3D8249)
            ),
            CinematicPreset(
                id = "urban",
                name = "Şehir",
                subtitle = "Sert Sokak & Doku",
                accentTint = Color(0xFF7A7E85)
            )
        )
    }
}
