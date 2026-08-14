package com.alafteknoloji.photon.features.editor.tools

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Block
import androidx.compose.material.icons.filled.Movie
import androidx.compose.material3.Divider
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.alafteknoloji.photon.core.designsystem.PhotonColors
import com.alafteknoloji.photon.core.designsystem.PhotonCornerRadius
import com.alafteknoloji.photon.core.designsystem.PhotonSpacing
import com.alafteknoloji.photon.core.designsystem.PhotonTypography
import com.alafteknoloji.photon.core.designsystem.components.PhotonSlider
import com.alafteknoloji.photon.features.editor.EditorViewModel
import com.alafteknoloji.photon.models.CinematicPreset
import kotlin.math.roundToInt

@Composable
fun CinematicToolView(
    viewModel: EditorViewModel,
    modifier: Modifier = Modifier
) {
    val scrollState = rememberScrollState()
    val state = viewModel.editState
    val isLookActive = state.selectedLookId != null && state.selectedLookId != "original"

    Column(
        modifier = modifier.padding(vertical = PhotonSpacing.xs),
        verticalArrangement = Arrangement.spacedBy(PhotonSpacing.sm)
    ) {
        // Horizontal Presets Strip
        Row(
            modifier = Modifier
                .horizontalScroll(scrollState)
                .padding(horizontal = PhotonSpacing.md),
            horizontalArrangement = Arrangement.spacedBy(PhotonSpacing.sm)
        ) {
            CinematicPreset.allPresets.forEach { preset ->
                val isSelected = (state.selectedLookId == preset.id) ||
                        (state.selectedLookId == null && preset.id == "original")

                Column(
                    modifier = Modifier
                        .width(68.dp)
                        .clickable {
                            viewModel.applyPresetUpdate {
                                if (preset.id == "original") {
                                    it.copy(selectedLookId = null)
                                } else {
                                    it.copy(
                                        selectedLookId = preset.id,
                                        isMonoActive = false // disable mono if cinematic chosen
                                    )
                                }
                            }
                        },
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.spacedBy(PhotonSpacing.xs)
                ) {
                    Box(
                        modifier = Modifier
                            .size(56.dp)
                            .clip(RoundedCornerShape(PhotonCornerRadius.md))
                            .background(
                                if (isSelected) PhotonColors.textPrimary else PhotonColors.surfaceSecondary
                            ),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            imageVector = if (preset.id == "original") Icons.Default.Block else Icons.Default.Movie,
                            contentDescription = preset.name,
                            tint = if (isSelected) PhotonColors.textInverted else preset.accentTint,
                            modifier = Modifier.size(24.dp)
                        )
                    }

                    Text(
                        text = preset.name,
                        style = PhotonTypography.caption.copy(
                            fontWeight = if (isSelected) FontWeight.SemiBold else FontWeight.Normal,
                            color = if (isSelected) PhotonColors.textPrimary else PhotonColors.textSecondary
                        ),
                        textAlign = TextAlign.Center
                    )
                }
            }
        }

        // Intensity Slider
        if (isLookActive) {
            Divider(
                color = PhotonColors.divider,
                modifier = Modifier.padding(horizontal = PhotonSpacing.md)
            )

            Box(modifier = Modifier.padding(horizontal = PhotonSpacing.md)) {
                PhotonSlider(
                    title = "Yoğunluk",
                    value = state.lookIntensity,
                    onValueChange = { newVal ->
                        viewModel.updateState { it.copy(lookIntensity = newVal) }
                    },
                    valueRange = 0.0f..1.0f,
                    defaultValue = 1.0f,
                    formattedValue = "${(state.lookIntensity * 100).roundToInt()}%"
                )
            }
        }
    }
}
