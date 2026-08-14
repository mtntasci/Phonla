package com.alafteknoloji.photon.core.designsystem.components

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.RotateLeft
import androidx.compose.material3.Icon
import androidx.compose.material3.Slider
import androidx.compose.material3.SliderDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.alafteknoloji.photon.core.designsystem.PhotonColors
import com.alafteknoloji.photon.core.designsystem.PhotonSpacing
import com.alafteknoloji.photon.core.designsystem.PhotonTypography
import kotlin.math.abs

@Composable
fun PhotonSlider(
    title: String,
    value: Float,
    onValueChange: (Float) -> Unit,
    valueRange: ClosedFloatingPointRange<Float>,
    defaultValue: Float = 0f,
    formattedValue: String,
    modifier: Modifier = Modifier
) {
    val isModified = abs(value - defaultValue) > 0.001f

    Column(
        modifier = modifier.fillMaxWidth(),
        verticalArrangement = Arrangement.spacedBy(PhotonSpacing.xxs)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = title,
                style = PhotonTypography.bodyMedium,
                color = PhotonColors.textPrimary
            )

            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(PhotonSpacing.xs)
            ) {
                Text(
                    text = formattedValue,
                    style = PhotonTypography.valueMono,
                    color = if (isModified) PhotonColors.textPrimary else PhotonColors.textSecondary
                )

                AnimatedVisibility(
                    visible = isModified,
                    enter = fadeIn(),
                    exit = fadeOut()
                ) {
                    Icon(
                        imageVector = Icons.Default.RotateLeft,
                        contentDescription = "Sıfırla",
                        tint = PhotonColors.textSecondary,
                        modifier = Modifier
                            .size(16.dp)
                            .clickable { onValueChange(defaultValue) }
                    )
                }
            }
        }

        Slider(
            value = value,
            onValueChange = onValueChange,
            valueRange = valueRange,
            colors = SliderDefaults.colors(
                thumbColor = PhotonColors.textPrimary,
                activeTrackColor = PhotonColors.textPrimary,
                inactiveTrackColor = PhotonColors.border
            ),
            modifier = Modifier.fillMaxWidth()
        )
    }
}
