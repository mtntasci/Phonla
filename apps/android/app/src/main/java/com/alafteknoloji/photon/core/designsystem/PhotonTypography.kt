package com.alafteknoloji.photon.core.designsystem

import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp

/**
 * Typography scale and font styles for Photon.
 * 100% Parity with iOS PhotonTypography.swift.
 */
object PhotonTypography {
    val hero = TextStyle(
        fontSize = 32.sp,
        fontWeight = FontWeight.Bold,
        letterSpacing = (-0.5).sp
    )

    val titleLarge = TextStyle(
        fontSize = 24.sp,
        fontWeight = FontWeight.SemiBold,
        letterSpacing = (-0.3).sp
    )

    val titleMedium = TextStyle(
        fontSize = 18.sp,
        fontWeight = FontWeight.SemiBold
    )

    val headline = TextStyle(
        fontSize = 16.sp,
        fontWeight = FontWeight.Medium
    )

    val bodyLarge = TextStyle(
        fontSize = 15.sp,
        fontWeight = FontWeight.Normal
    )

    val bodyMedium = TextStyle(
        fontSize = 13.sp,
        fontWeight = FontWeight.Normal
    )

    val caption = TextStyle(
        fontSize = 11.sp,
        fontWeight = FontWeight.Normal
    )

    val button = TextStyle(
        fontSize = 15.sp,
        fontWeight = FontWeight.SemiBold
    )

    val valueMono = TextStyle(
        fontSize = 12.sp,
        fontWeight = FontWeight.Medium,
        fontFamily = FontFamily.Monospace
    )
}
