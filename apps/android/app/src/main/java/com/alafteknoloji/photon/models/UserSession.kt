package com.alafteknoloji.photon.models

import android.graphics.Bitmap
import android.net.Uri

/**
 * Model representing the authenticated user's session in Photon.
 * 100% Parity with iOS UserSession.swift.
 */
data class UserSession(
    val uid: String,
    val email: String? = null,
    val displayName: String = "Phonla Üyesi",
    val photoUrl: String? = null,
    val phoneNumber: String? = null,
    val providerId: String = "Firebase",
    val isAnonymous: Boolean = false
)

/**
 * In-memory container for a loaded photo in the Photon Editor.
 * 100% Parity with iOS LoadedPhoto.swift.
 */
data class LoadedPhoto(
    val sourceUri: Uri? = null,
    val originalBitmap: Bitmap,
    val previewBitmap: Bitmap,
    val width: Int = originalBitmap.width,
    val height: Int = originalBitmap.height,
    val filename: String = "photon_photo.jpg"
)
