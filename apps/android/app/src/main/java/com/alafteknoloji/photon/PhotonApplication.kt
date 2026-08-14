package com.alafteknoloji.photon

import android.app.Application
import com.google.firebase.FirebaseApp

class PhotonApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        FirebaseApp.initializeApp(this)
    }
}
