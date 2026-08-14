package com.alafteknoloji.photon.services

import android.content.Context
import com.alafteknoloji.photon.core.navigation.NavigationState

/**
 * Dependency injection container managing singleton services across Photon.
 * 100% Parity with iOS ServiceContainer.swift.
 */
class ServiceContainer(context: Context) {
    val authService: AuthService = AuthService(context)
    val imageProcessingService: ImageProcessingService = ImageProcessingService()
    val photoLibraryService: PhotoLibraryService = PhotoLibraryService(context)
    val navigationState: NavigationState = NavigationState()

    companion object {
        @Volatile
        private var INSTANCE: ServiceContainer? = null

        fun getInstance(context: Context): ServiceContainer {
            return INSTANCE ?: synchronized(this) {
                INSTANCE ?: ServiceContainer(context.applicationContext).also { INSTANCE = it }
            }
        }
    }
}
