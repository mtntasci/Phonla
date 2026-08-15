package com.alafteknoloji.photon.features.splash

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.alafteknoloji.photon.core.designsystem.PhotonColors
import com.alafteknoloji.photon.core.designsystem.PhotonSpacing
import com.alafteknoloji.photon.core.designsystem.PhotonTypography
import com.alafteknoloji.photon.core.designsystem.components.PhotonLogoMark
import com.alafteknoloji.photon.core.navigation.NavigationState
import com.alafteknoloji.photon.services.AuthService
import kotlinx.coroutines.delay

/**
 * Minimalist Splash Screen with clean vector logo animation and session verification.
 * 100% Parity with iOS SplashView.swift.
 */
@Composable
fun SplashScreen(
    authService: AuthService,
    navigationState: NavigationState
) {
    var isVisible by remember { mutableStateOf(false) }

    LaunchedEffect(Unit) {
        isVisible = true
        val session = authService.checkCurrentSession()
        delay(1200)
        if (session != null) {
            navigationState.navigateToHome()
        } else {
            navigationState.navigateToAuth()
        }
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(PhotonColors.background),
        contentAlignment = Alignment.Center
    ) {
        AnimatedVisibility(
            visible = isVisible,
            enter = fadeIn(animationSpec = tween(700))
        ) {
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.spacedBy(PhotonSpacing.md)
            ) {
                PhotonLogoMark(
                    size = 76.dp,
                    color = PhotonColors.textPrimary
                )

                Text(
                    text = "PHONLA",
                    style = PhotonTypography.hero.copy(
                        letterSpacing = 4.sp,
                        color = PhotonColors.textPrimary
                    )
                )
            }
        }
    }
}
