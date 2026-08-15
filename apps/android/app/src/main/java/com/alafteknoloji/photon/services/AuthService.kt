package com.alafteknoloji.photon.services

import android.content.Context
import android.content.SharedPreferences
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import com.alafteknoloji.photon.models.UserSession
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.FirebaseUser
import com.google.firebase.auth.OAuthProvider
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.tasks.await
import kotlinx.coroutines.withContext

enum class AuthProvider(val title: String) {
    Apple("Apple"),
    Google("Google"),
    Guest("Misafir")
}

/**
 * Production authentication service backed by Firebase Auth on Android.
 * 100% Parity with iOS AuthService.swift.
 */
class AuthService(private val context: Context) {
    private val auth: FirebaseAuth by lazy { FirebaseAuth.getInstance() }
    private val prefs: SharedPreferences by lazy {
        context.getSharedPreferences("photon_user_prefs", Context.MODE_PRIVATE)
    }

    var currentSession by mutableStateOf<UserSession?>(null)
        private set

    var isLoading by mutableStateOf(false)
        private set

    var lastError by mutableStateOf<String?>(null)
        private set

    val isAuthenticated: Boolean
        get() = currentSession != null

    init {
        syncFirebaseCurrentUser()
    }

    fun syncFirebaseCurrentUser() {
        val user = auth.currentUser
        if (user != null) {
            val storedPhone = prefs.getString("photon_user_phone_${user.uid}", null)
            val resolvedPhone = user.phoneNumber ?: storedPhone

            currentSession = UserSession(
                uid = user.uid,
                email = user.email,
                displayName = user.displayName ?: (user.email?.substringBefore("@")?.replaceFirstChar { it.uppercase() } ?: "Photonla Üyesi"),
                photoUrl = user.photoUrl?.toString(),
                phoneNumber = resolvedPhone,
                providerId = resolveProviderName(user),
                isAnonymous = user.isAnonymous
            )
        } else {
            currentSession = null
        }
    }

    suspend fun checkCurrentSession(): UserSession? = withContext(Dispatchers.IO) {
        val user = auth.currentUser
        if (user != null) {
            syncFirebaseCurrentUser()
            currentSession
        } else {
            currentSession = null
            null
        }
    }

    suspend fun signInWithGoogle(idToken: String): Result<UserSession> = withContext(Dispatchers.IO) {
        isLoading = true
        lastError = null
        try {
            val credential = com.google.firebase.auth.GoogleAuthProvider.getCredential(idToken, null)
            val authResult = auth.signInWithCredential(credential).await()
            val user = authResult.user ?: throw IllegalStateException("Firebase kullanıcısı alınamadı")
            syncFirebaseCurrentUser()
            isLoading = false
            Result.success(currentSession!!)
        } catch (e: Exception) {
            isLoading = false
            lastError = e.localizedMessage ?: "Google ile giriş yapılırken hata oluştu"
            Result.failure(e)
        }
    }

    suspend fun signInWithApple(activity: android.app.Activity): Result<UserSession> = withContext(Dispatchers.IO) {
        isLoading = true
        lastError = null
        try {
            val provider = OAuthProvider.newBuilder("apple.com").build()
            val authResult = auth.startActivityForSignInWithProvider(activity, provider).await()
            val user = authResult.user ?: throw IllegalStateException("Apple kullanıcısı alınamadı")
            syncFirebaseCurrentUser()
            isLoading = false
            Result.success(currentSession!!)
        } catch (e: Exception) {
            isLoading = false
            val msg = e.localizedMessage ?: "Apple ile giriş yapılamadı"
            lastError = msg
            Result.failure(e)
        }
    }

    suspend fun signInAnonymously(): Result<UserSession> = withContext(Dispatchers.IO) {
        isLoading = true
        lastError = null
        try {
            val authResult = auth.signInAnonymously().await()
            val user = authResult.user ?: throw IllegalStateException("Firebase kullanıcısı alınamadı")
            syncFirebaseCurrentUser()
            isLoading = false
            Result.success(currentSession!!)
        } catch (e: Exception) {
            isLoading = false
            lastError = e.localizedMessage ?: "Giriş yapılamadı"
            Result.failure(e)
        }
    }

    fun savePhoneNumber(phoneNumber: String) {
        val uid = currentSession?.uid ?: return
        prefs.edit().putString("photon_user_phone_$uid", phoneNumber).apply()
        currentSession = currentSession?.copy(phoneNumber = phoneNumber)
    }

    suspend fun signOut() = withContext(Dispatchers.IO) {
        try {
            auth.signOut()
            currentSession = null
            lastError = null
        } catch (e: Exception) {
            lastError = e.localizedMessage
        }
    }

    private fun resolveProviderName(user: FirebaseUser): String {
        val provider = user.providerData.firstOrNull { it.providerId != "firebase" }?.providerId
        return when (provider) {
            "apple.com" -> "Apple"
            "google.com" -> "Google"
            "facebook.com" -> "Facebook"
            else -> if (user.isAnonymous) "Misafir" else "Firebase"
        }
    }
}
