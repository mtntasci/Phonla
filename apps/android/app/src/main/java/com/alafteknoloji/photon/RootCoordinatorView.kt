package com.alafteknoloji.photon

import androidx.compose.animation.Crossfade
import androidx.compose.animation.core.tween
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import com.alafteknoloji.photon.core.designsystem.PhotonColors
import com.alafteknoloji.photon.core.designsystem.PhotonTheme
import com.alafteknoloji.photon.core.navigation.Screen
import com.alafteknoloji.photon.features.auth.AuthScreen
import com.alafteknoloji.photon.features.editor.EditorScreen
import com.alafteknoloji.photon.features.home.HomeScreen
import com.alafteknoloji.photon.features.settings.SettingsScreen
import com.alafteknoloji.photon.features.splash.SplashScreen
import com.alafteknoloji.photon.services.ServiceContainer

/**
 * Root coordinator observing NavigationState and rendering the active screen flow with smooth crossfade.
 * 100% Parity with iOS RootCoordinatorView.swift.
 */
@Composable
fun RootCoordinatorView(serviceContainer: ServiceContainer) {
    val navigationState = serviceContainer.navigationState

    PhotonTheme {
        Surface(
            modifier = Modifier.fillMaxSize(),
            color = PhotonColors.background
        ) {
            Crossfade(
                targetState = navigationState.currentScreen,
                animationSpec = tween(250),
                label = "ScreenTransition"
            ) { screen ->
                when (screen) {
                    is Screen.Splash -> SplashScreen(
                        authService = serviceContainer.authService,
                        navigationState = navigationState
                    )
                    is Screen.Auth -> AuthScreen(
                        authService = serviceContainer.authService,
                        navigationState = navigationState
                    )
                    is Screen.Home -> HomeScreen(
                        authService = serviceContainer.authService,
                        photoLibraryService = serviceContainer.photoLibraryService,
                        navigationState = navigationState
                    )
                    is Screen.Editor -> EditorScreen(
                        photo = screen.photo,
                        imageProcessingService = serviceContainer.imageProcessingService,
                        photoLibraryService = serviceContainer.photoLibraryService,
                        navigationState = navigationState
                    )
                    is Screen.Settings -> SettingsScreen(
                        authService = serviceContainer.authService,
                        navigationState = navigationState
                    )
                    is Screen.Membership -> SettingsScreen(
                        authService = serviceContainer.authService,
                        navigationState = navigationState
                    )
                }
            }
        }
    }
}
