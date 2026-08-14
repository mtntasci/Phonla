package com.alafteknoloji.photon.core.designsystem.components

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.unit.dp
import com.alafteknoloji.photon.core.designsystem.PhotonColors
import com.alafteknoloji.photon.core.designsystem.PhotonCornerRadius
import com.alafteknoloji.photon.core.designsystem.PhotonSpacing
import com.alafteknoloji.photon.core.designsystem.PhotonTypography

enum class PhotonButtonVariant {
    Primary,
    Secondary,
    Ghost,
    Destructive
}

enum class PhotonButtonSize {
    Small,
    Medium,
    Large
}

@Composable
fun PhotonButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    variant: PhotonButtonVariant = PhotonButtonVariant.Primary,
    size: PhotonButtonSize = PhotonButtonSize.Medium,
    isFullWidth: Boolean = false,
    isLoading: Boolean = false,
    enabled: Boolean = true,
    leadingIcon: ImageVector? = null
) {
    val height = when (size) {
        PhotonButtonSize.Small -> 36.dp
        PhotonButtonSize.Medium -> 48.dp
        PhotonButtonSize.Large -> 56.dp
    }

    val contentPadding = when (size) {
        PhotonButtonSize.Small -> PaddingValues(horizontal = PhotonSpacing.md, vertical = PhotonSpacing.xs)
        PhotonButtonSize.Medium -> PaddingValues(horizontal = PhotonSpacing.lg, vertical = PhotonSpacing.sm)
        PhotonButtonSize.Large -> PaddingValues(horizontal = PhotonSpacing.xl, vertical = PhotonSpacing.md)
    }

    val cornerRadius = when (size) {
        PhotonButtonSize.Small -> PhotonCornerRadius.full
        PhotonButtonSize.Medium -> PhotonCornerRadius.md
        PhotonButtonSize.Large -> PhotonCornerRadius.lg
    }

    val containerColor = when (variant) {
        PhotonButtonVariant.Primary -> PhotonColors.accent
        PhotonButtonVariant.Secondary -> PhotonColors.surfaceSecondary
        PhotonButtonVariant.Ghost -> Color.Transparent
        PhotonButtonVariant.Destructive -> PhotonColors.error.copy(alpha = 0.1f)
    }

    val contentColor = when (variant) {
        PhotonButtonVariant.Primary -> PhotonColors.textInverted
        PhotonButtonVariant.Secondary -> PhotonColors.textPrimary
        PhotonButtonVariant.Ghost -> PhotonColors.textPrimary
        PhotonButtonVariant.Destructive -> PhotonColors.error
    }

    val border = when (variant) {
        PhotonButtonVariant.Secondary -> BorderStroke(1.dp, PhotonColors.border)
        PhotonButtonVariant.Destructive -> BorderStroke(1.dp, PhotonColors.error.copy(alpha = 0.3f))
        else -> null
    }

    Button(
        onClick = onClick,
        enabled = enabled && !isLoading,
        shape = RoundedCornerShape(cornerRadius),
        colors = ButtonDefaults.buttonColors(
            containerColor = containerColor,
            contentColor = contentColor,
            disabledContainerColor = containerColor.copy(alpha = 0.4f),
            disabledContentColor = contentColor.copy(alpha = 0.4f)
        ),
        border = border,
        contentPadding = contentPadding,
        modifier = modifier
            .height(height)
            .then(if (isFullWidth) Modifier.fillMaxWidth() else Modifier)
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(PhotonSpacing.sm)
        ) {
            if (isLoading) {
                CircularProgressIndicator(
                    modifier = Modifier.size(16.dp),
                    strokeWidth = 2.dp,
                    color = contentColor
                )
            } else if (leadingIcon != null) {
                Icon(
                    imageVector = leadingIcon,
                    contentDescription = null,
                    modifier = Modifier.size(18.dp)
                )
            }
            Text(
                text = text,
                style = PhotonTypography.button
            )
        }
    }
}
