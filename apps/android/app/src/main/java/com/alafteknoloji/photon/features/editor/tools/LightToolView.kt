package com.alafteknoloji.photon.features.editor.tools

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import com.alafteknoloji.photon.core.designsystem.PhotonSpacing
import com.alafteknoloji.photon.core.designsystem.components.PhotonSlider
import com.alafteknoloji.photon.features.editor.EditorViewModel
import java.util.Locale
import kotlin.math.roundToInt

@Composable
fun LightToolView(
    viewModel: EditorViewModel,
    modifier: Modifier = Modifier
) {
    val scrollState = rememberScrollState()
    val state = viewModel.editState

    Column(
        modifier = modifier
            .verticalScroll(scrollState)
            .padding(horizontal = PhotonSpacing.md, vertical = PhotonSpacing.xs),
        verticalArrangement = Arrangement.spacedBy(PhotonSpacing.sm)
    ) {
        // Pozlama
        PhotonSlider(
            title = "Pozlama",
            value = state.exposure,
            onValueChange = { newVal ->
                viewModel.updateState { it.copy(exposure = newVal) }
            },
            valueRange = -2.0f..2.0f,
            defaultValue = 0.0f,
            formattedValue = if (state.exposure >= 0) {
                String.format(Locale.US, "+%.2f EV", state.exposure)
            } else {
                String.format(Locale.US, "%.2f EV", state.exposure)
            }
        )

        // Parlaklık
        PhotonSlider(
            title = "Parlaklık",
            value = state.brightness,
            onValueChange = { newVal ->
                viewModel.updateState { it.copy(brightness = newVal) }
            },
            valueRange = -1.0f..1.0f,
            defaultValue = 0.0f,
            formattedValue = run {
                val percent = (state.brightness * 100).roundToInt()
                if (percent >= 0) "+$percent%" else "$percent%"
            }
        )

        // Kontrast
        PhotonSlider(
            title = "Kontrast",
            value = state.contrast,
            onValueChange = { newVal ->
                viewModel.updateState { it.copy(contrast = newVal) }
            },
            valueRange = 0.5f..1.5f,
            defaultValue = 1.0f,
            formattedValue = run {
                val percent = ((state.contrast - 1.0f) * 100).roundToInt()
                if (percent >= 0) "+$percent%" else "$percent%"
            }
        )

        // Parlak Alanlar
        PhotonSlider(
            title = "Parlak Alanlar",
            value = state.highlights,
            onValueChange = { newVal ->
                viewModel.updateState { it.copy(highlights = newVal) }
            },
            valueRange = -1.0f..1.0f,
            defaultValue = 0.0f,
            formattedValue = run {
                val percent = (state.highlights * 100).roundToInt()
                if (percent >= 0) "+$percent%" else "$percent%"
            }
        )

        // Gölgeler
        PhotonSlider(
            title = "Gölgeler",
            value = state.shadows,
            onValueChange = { newVal ->
                viewModel.updateState { it.copy(shadows = newVal) }
            },
            valueRange = -1.0f..1.0f,
            defaultValue = 0.0f,
            formattedValue = run {
                val percent = (state.shadows * 100).roundToInt()
                if (percent >= 0) "+$percent%" else "$percent%"
            }
        )
    }
}
