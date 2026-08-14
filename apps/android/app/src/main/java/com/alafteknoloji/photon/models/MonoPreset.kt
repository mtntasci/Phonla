package com.alafteknoloji.photon.models

/**
 * Definition of a professional monochrome preset with distinct RGB luminance channel weights.
 * 100% Parity with iOS MonoPreset.swift.
 */
data class MonoPreset(
    val id: String,
    val name: String,
    val subtitle: String,
    val redWeight: Float,
    val greenWeight: Float,
    val blueWeight: Float,
    val contrastMultiplier: Float = 1.0f,
    val brightnessOffset: Float = 0.0f,
    val highlightRecovery: Float = 0.0f,
    val shadowLift: Float = 0.0f
) {
    companion object {
        val allPresets = listOf(
            MonoPreset(
                id = "mono_natural",
                name = "Doğal",
                subtitle = "Dengeli Doğal Gri Ton",
                redWeight = 0.299f,
                greenWeight = 0.587f,
                blueWeight = 0.114f,
                contrastMultiplier = 1.0f
            ),
            MonoPreset(
                id = "mono_portrait",
                name = "Portre",
                subtitle = "Pürüzsüz Ten & Yumuşak Ton",
                redWeight = 0.600f,
                greenWeight = 0.300f,
                blueWeight = 0.100f,
                contrastMultiplier = 1.05f,
                brightnessOffset = 0.04f
            ),
            MonoPreset(
                id = "mono_high_contrast",
                name = "Yüksek Kontrast",
                subtitle = "Derin Siyahlar & Gümüş",
                redWeight = 0.350f,
                greenWeight = 0.550f,
                blueWeight = 0.100f,
                contrastMultiplier = 1.35f,
                brightnessOffset = -0.02f
            ),
            MonoPreset(
                id = "mono_soft",
                name = "Yumuşak",
                subtitle = "İpeksi Düşük Kontrast",
                redWeight = 0.333f,
                greenWeight = 0.333f,
                blueWeight = 0.334f,
                contrastMultiplier = 0.85f,
                brightnessOffset = 0.05f,
                shadowLift = 0.15f
            ),
            MonoPreset(
                id = "mono_street",
                name = "Sokak",
                subtitle = "Sert Sokak & Doku",
                redWeight = 0.400f,
                greenWeight = 0.450f,
                blueWeight = 0.150f,
                contrastMultiplier = 1.20f,
                shadowLift = -0.10f
            ),
            MonoPreset(
                id = "mono_dramatic",
                name = "Dramatik",
                subtitle = "Kırmızı Filtre Gökyüzü",
                redWeight = 0.780f,
                greenWeight = 0.180f,
                blueWeight = 0.040f,
                contrastMultiplier = 1.40f,
                brightnessOffset = -0.04f
            )
        )
    }
}
