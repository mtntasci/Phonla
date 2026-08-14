package com.alafteknoloji.photon.core.navigation

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import com.alafteknoloji.photon.models.LoadedPhoto

sealed class Screen {
    data object Splash : Screen()
    data object Auth : Screen()
    data object Home : Screen()
    data class Editor(val photo: LoadedPhoto) : Screen()
    data object Settings : Screen()
    data object Membership : Screen()
}

/**
 * Observable navigation coordinator managing root screen transitions and modals.
 * 100% Parity with iOS NavigationState.swift.
 */
class NavigationState {
    var currentScreen by mutableStateOf<Screen>(Screen.Splash)
        private set

    var isMembershipPresented by mutableStateOf(false)
        private set

    fun navigateToSplash() {
        currentScreen = Screen.Splash
    }

    fun navigateToAuth() {
        currentScreen = Screen.Auth
    }

    fun navigateToHome() {
        currentScreen = Screen.Home
    }

    fun navigateToEditor(photo: LoadedPhoto) {
        currentScreen = Screen.Editor(photo)
    }

    fun navigateToSettings() {
        currentScreen = Screen.Settings
    }

    fun presentMembership() {
        isMembershipPresented = true
    }

    fun dismissMembership() {
        isMembershipPresented = false
    }
}
