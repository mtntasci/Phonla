package com.alafteknoloji.photon.core.designsystem.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.sin

/**
 * Elegant, transparent vector brandmark for Photon.
 * 100% Parity with iOS PhotonLogoMark.swift.
 */
@Composable
fun PhotonLogoMark(
    size: Dp = 32.dp,
    color: Color = Color.White,
    modifier: Modifier = Modifier
) {
    Canvas(modifier = modifier.size(size)) {
        val center = Offset(size.toPx() / 2f, size.toPx() / 2f)
        val radius = minOf(size.toPx(), size.toPx()) / 2f
        val strokeWidth = radius * 0.12f

        // Outer optical ring
        drawCircle(
            color = color,
            radius = radius - strokeWidth / 2f,
            center = center,
            style = Stroke(width = strokeWidth)
        )

        // 6-blade minimalist aperture rays
        val bladeCount = 6
        val innerRadius = radius * 0.36f
        val rayLength = radius * 0.78f

        for (i in 0 until bladeCount) {
            val angle = (i * (2.0 * PI / bladeCount) - (PI / 6.0)).toFloat()
            val tangentAngle = (angle + (PI / 3.2)).toFloat()

            val startX = center.x + cos(angle) * innerRadius
            val startY = center.y + sin(angle) * innerRadius
            val endX = startX + cos(tangentAngle) * (rayLength - innerRadius)
            val endY = startY + sin(tangentAngle) * (rayLength - innerRadius)

            drawLine(
                color = color,
                start = Offset(startX, startY),
                end = Offset(endX, endY),
                strokeWidth = strokeWidth * 0.9f,
                cap = StrokeCap.Round
            )
        }

        // Central photon light core point
        val coreRadius = radius * 0.14f
        drawCircle(
            color = color,
            radius = coreRadius,
            center = center
        )
    }
}
