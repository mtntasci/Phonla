package com.alafteknoloji.photon.models

/**
 * Central, deterministic state model representing all adjustments.
 * 100% Parity with iOS PhotoEditState.swift.
 */
data class PhotoEditState(
    // Light Adjustments
    val exposure: Float = 0.0f,       // -2.0 ... 2.0 EV
    val brightness: Float = 0.0f,     // -1.0 ... 1.0
    val contrast: Float = 1.0f,       // 0.5 ... 1.5
    val highlights: Float = 0.0f,     // -1.0 ... 1.0
    val shadows: Float = 0.0f,        // -1.0 ... 1.0

    // Color Adjustments
    val temperature: Float = 6500.0f, // 2000K ... 10000K
    val tint: Float = 0.0f,           // -100.0 ... 100.0
    val saturation: Float = 1.0f,     // 0.0 ... 2.0
    val vibrance: Float = 0.0f,       // -1.0 ... 1.0

    // Cinematic Looks
    val selectedLookId: String? = null,
    val lookIntensity: Float = 1.0f,  // 0.0 ... 1.0

    // Monochrome Engine
    val isMonoActive: Boolean = false,
    val selectedMonoPresetId: String? = null,
    val monoIntensity: Float = 1.0f   // 0.0 ... 1.0
) {
    companion object {
        val identity = PhotoEditState()
    }

    val isEdited: Boolean
        get() = this != identity
}
