package com.alafteknoloji.photon.core.designsystem

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable

private val LightColorScheme = lightColorScheme(
    primary = PhotonColors.accent,
    onPrimary = PhotonColors.textInverted,
    background = PhotonColors.background,
    onBackground = PhotonColors.textPrimary,
    surface = PhotonColors.surfacePrimary,
    onSurface = PhotonColors.textPrimary,
    surfaceVariant = PhotonColors.surfaceSecondary,
    onSurfaceVariant = PhotonColors.textSecondary,
    outline = PhotonColors.border,
    error = PhotonColors.error
)

@Composable
fun PhotonTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit
) {
    MaterialTheme(
        colorScheme = LightColorScheme,
        content = content
    )
}
