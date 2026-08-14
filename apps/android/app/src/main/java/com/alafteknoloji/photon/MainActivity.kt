package com.alafteknoloji.photon

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import com.alafteknoloji.photon.services.ServiceContainer

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        val serviceContainer = ServiceContainer.getInstance(this)

        setContent {
            RootCoordinatorView(serviceContainer = serviceContainer)
        }
    }
}
