package com.alafteknoloji.photon.services

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.ColorMatrix
import android.graphics.ColorMatrixColorFilter
import android.graphics.Paint
import com.alafteknoloji.photon.models.CinematicPreset
import com.alafteknoloji.photon.models.MonoPreset
import com.alafteknoloji.photon.models.PhotoEditState
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlin.math.pow

/**
 * Deterministic image processing service for Android.
 * Features 60 FPS hardware-accelerated ColorMatrix pipeline for live preview
 * and non-destructive full-resolution bitmap rendering matching iOS Core Image pipeline.
 * 100% Parity with iOS ImageProcessingService.swift.
 */
class ImageProcessingService {

    /**
     * Builds a composited 4x5 ColorMatrix reflecting all PhotoEditState adjustments.
     */
    fun buildColorMatrix(state: PhotoEditState): ColorMatrix {
        val result = ColorMatrix()

        // 1. Exposure (2^EV linear multiplier)
        if (state.exposure != 0.0f) {
            val expFactor = 2.0.pow(state.exposure.toDouble()).toFloat()
            val expMatrix = ColorMatrix(
                floatArrayOf(
                    expFactor, 0f, 0f, 0f, 0f,
                    0f, expFactor, 0f, 0f, 0f,
                    0f, 0f, expFactor, 0f, 0f,
                    0f, 0f, 0f, 1f, 0f
                )
            )
            result.postConcat(expMatrix)
        }

        // 2. Brightness & Contrast
        val effectiveSat = if (state.isMonoActive) 0.0f else state.saturation
        if (state.brightness != 0.0f || state.contrast != 1.0f || effectiveSat != 1.0f) {
            val brightnessOffset = state.brightness * 60f
            val scale = state.contrast
            val translate = (-0.5f * scale + 0.5f) * 255f + brightnessOffset

            val bcMatrix = ColorMatrix(
                floatArrayOf(
                    scale, 0f, 0f, 0f, translate,
                    0f, scale, 0f, 0f, translate,
                    0f, 0f, scale, 0f, translate,
                    0f, 0f, 0f, 1f, 0f
                )
            )
            result.postConcat(bcMatrix)

            if (effectiveSat != 1.0f) {
                val satMatrix = ColorMatrix()
                satMatrix.setSaturation(effectiveSat)
                result.postConcat(satMatrix)
            }
        }

        // 3. White Balance: Temperature & Tint
        if ((state.temperature != 6500.0f || state.tint != 0.0f) && !state.isMonoActive) {
            val tempDiff = (state.temperature - 6500.0f) / 3500.0f
            val rScale = 1.0f + (tempDiff * 0.15f)
            val bScale = 1.0f - (tempDiff * 0.15f)
            val tintScale = 1.0f + (state.tint * 0.002f)

            val tempMatrix = ColorMatrix(
                floatArrayOf(
                    rScale, 0f, 0f, 0f, 0f,
                    0f, tintScale, 0f, 0f, 0f,
                    0f, 0f, bScale, 0f, 0f,
                    0f, 0f, 0f, 1f, 0f
                )
            )
            result.postConcat(tempMatrix)
        }

        // 4. Cinematic Looks (Phase 6)
        if (state.selectedLookId != null && state.selectedLookId != "original" && !state.isMonoActive) {
            val lookMatrix = getCinematicColorMatrix(state.selectedLookId, state.lookIntensity)
            result.postConcat(lookMatrix)
        }

        // 5. Professional Monochrome Engine (Phase 7)
        if (state.isMonoActive) {
            val monoMatrix = getMonochromeColorMatrix(state)
            result.postConcat(monoMatrix)
        }

        return result
    }

    private fun getCinematicColorMatrix(lookId: String, intensity: Float): ColorMatrix {
        val matrix = when (lookId) {
            "cinema" -> ColorMatrix( // Teal & Orange split grading
                floatArrayOf(
                    1.15f, 0.00f, -0.05f, 0f, 10f,
                    -0.02f, 1.05f, 0.02f, 0f, 3f,
                    -0.08f, 0.05f, 1.15f, 0f, 15f,
                    0f, 0f, 0f, 1f, 0f
                )
            )
            "warm" -> ColorMatrix( // Golden Amber
                floatArrayOf(
                    1.20f, 0.05f, 0.00f, 0f, 8f,
                    0.00f, 1.10f, 0.00f, 0f, 4f,
                    0.00f, 0.00f, 0.85f, 0f, -8f,
                    0f, 0f, 0f, 1f, 0f
                )
            )
            "cold" -> ColorMatrix( // Nordic Blue
                floatArrayOf(
                    0.90f, 0.00f, 0.00f, 0f, -6f,
                    0.00f, 0.98f, 0.02f, 0f, 0f,
                    0.05f, 0.05f, 1.25f, 0f, 12f,
                    0f, 0f, 0f, 1f, 0f
                )
            )
            "teal" -> ColorMatrix( // Deep Turquoise
                floatArrayOf(
                    0.90f, 0.05f, 0.00f, 0f, -5f,
                    0.00f, 1.10f, 0.05f, 0f, 8f,
                    0.05f, 0.10f, 1.20f, 0f, 18f,
                    0f, 0f, 0f, 1f, 0f
                )
            )
            "fade" -> ColorMatrix( // Matte Film Lifted Blacks
                floatArrayOf(
                    0.92f, 0.00f, 0.00f, 0f, 20f,
                    0.00f, 0.92f, 0.00f, 0f, 20f,
                    0.00f, 0.00f, 0.92f, 0f, 20f,
                    0f, 0f, 0f, 1f, 0f
                )
            )
            "night" -> ColorMatrix( // Urban Midnight
                floatArrayOf(
                    1.05f, 0.00f, 0.00f, 0f, -12f,
                    0.00f, 1.05f, 0.05f, 0f, -6f,
                    0.05f, 0.05f, 1.30f, 0f, 10f,
                    0f, 0f, 0f, 1f, 0f
                )
            )
            "forest" -> ColorMatrix( // Emerald Greens
                floatArrayOf(
                    0.92f, 0.08f, 0.00f, 0f, 2f,
                    0.05f, 1.20f, 0.00f, 0f, 6f,
                    0.00f, 0.05f, 0.95f, 0f, -5f,
                    0f, 0f, 0f, 1f, 0f
                )
            )
            "urban" -> ColorMatrix( // High Contrast Metropol
                floatArrayOf(
                    1.20f, 0.00f, 0.00f, 0f, -8f,
                    0.00f, 1.20f, 0.00f, 0f, -8f,
                    0.00f, 0.00f, 1.20f, 0f, -8f,
                    0f, 0f, 0f, 1f, 0f
                )
            )
            else -> ColorMatrix()
        }

        return matrix
    }

    private fun getMonochromeColorMatrix(state: PhotoEditState): ColorMatrix {
        val presetId = state.selectedMonoPresetId ?: "mono_natural"
        val preset = MonoPreset.allPresets.firstOrNull { it.id == presetId } ?: MonoPreset.allPresets[0]

        val rw = preset.redWeight
        val gw = preset.greenWeight
        val bw = preset.blueWeight
        val bias = preset.brightnessOffset * 255f

        val scale = preset.contrastMultiplier
        val translate = (-0.5f * scale + 0.5f) * 255f + bias

        // RGB channel luminance mapping
        return ColorMatrix(
            floatArrayOf(
                rw * scale, gw * scale, bw * scale, 0f, translate,
                rw * scale, gw * scale, bw * scale, 0f, translate,
                rw * scale, gw * scale, bw * scale, 0f, translate,
                0f, 0f, 0f, 1f, 0f
            )
        )
    }

    /**
     * Executes full-resolution non-destructive rendering of the source bitmap.
     */
    suspend fun renderFullResolution(
        sourceBitmap: Bitmap,
        state: PhotoEditState
    ): Bitmap = withContext(Dispatchers.Default) {
        val matrix = buildColorMatrix(state)
        val filter = ColorMatrixColorFilter(matrix)

        val output = Bitmap.createBitmap(
            sourceBitmap.width,
            sourceBitmap.height,
            Bitmap.Config.ARGB_8888
        )

        val canvas = Canvas(output)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG or Paint.FILTER_BITMAP_FLAG).apply {
            colorFilter = filter
        }

        canvas.drawBitmap(sourceBitmap, 0f, 0f, paint)
        output
    }
}
