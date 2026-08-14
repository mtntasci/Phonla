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
import kotlin.math.roundToInt

@Composable
fun ColorToolView(
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
        // Sıcaklık
        PhotonSlider(
            title = "Sıcaklık",
            value = state.temperature,
            onValueChange = { newVal ->
                viewModel.updateState { it.copy(temperature = newVal) }
            },
            valueRange = 2000.0f..10000.0f,
            defaultValue = 6500.0f,
            formattedValue = run {
                val diff = (state.temperature - 6500.0f).roundToInt()
                when {
                    diff == 0 -> "6500K (Nötr)"
                    diff > 0 -> "+${diff}K (${state.temperature.roundToInt()}K)"
                    else -> "${diff}K (${state.temperature.roundToInt()}K)"
                }
            }
        )

        // Renk Tonu
        PhotonSlider(
            title = "Renk Tonu",
            value = state.tint,
            onValueChange = { newVal ->
                viewModel.updateState { it.copy(tint = newVal) }
            },
            valueRange = -100.0f..100.0f,
            defaultValue = 0.0f,
            formattedValue = run {
                val ival = state.tint.roundToInt()
                if (ival >= 0) "+$ival" else "$ival"
            }
        )

        // Doygunluk
        PhotonSlider(
            title = "Doygunluk",
            value = state.saturation,
            onValueChange = { newVal ->
                viewModel.updateState { it.copy(saturation = newVal) }
            },
            valueRange = 0.0f..2.0f,
            defaultValue = 1.0f,
            formattedValue = run {
                val percent = ((state.saturation - 1.0f) * 100).roundToInt()
                if (percent >= 0) "+$percent%" else "$percent%"
            }
        )

        // Canlılık
        PhotonSlider(
            title = "Canlılık",
            value = state.vibrance,
            onValueChange = { newVal ->
                viewModel.updateState { it.copy(vibrance = newVal) }
            },
            valueRange = -1.0f..1.0f,
            defaultValue = 0.0f,
            formattedValue = run {
                val percent = (state.vibrance * 100).roundToInt()
                if (percent >= 0) "+$percent%" else "$percent%"
            }
        )
    }
}
