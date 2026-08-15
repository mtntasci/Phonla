package com.alafteknoloji.photon.features.auth

import android.app.Activity
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.credentials.CredentialManager
import androidx.credentials.GetCredentialRequest
import androidx.credentials.exceptions.GetCredentialCancellationException
import com.alafteknoloji.photon.core.designsystem.PhotonColors
import com.alafteknoloji.photon.core.designsystem.PhotonSpacing
import com.alafteknoloji.photon.core.designsystem.PhotonTypography
import com.alafteknoloji.photon.core.designsystem.components.PhotonButton
import com.alafteknoloji.photon.core.designsystem.components.PhotonButtonSize
import com.alafteknoloji.photon.core.designsystem.components.PhotonButtonVariant
import com.alafteknoloji.photon.core.designsystem.components.PhotonLogoMark
import com.alafteknoloji.photon.core.navigation.NavigationState
import com.alafteknoloji.photon.services.AuthService
import com.google.android.libraries.identity.googleid.GetGoogleIdOption
import com.google.android.libraries.identity.googleid.GoogleIdTokenCredential
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import kotlinx.coroutines.withTimeoutOrNull

/**
 * Minimalist, pure-white authentication screen with transparent branding and Firebase Auth providers.
 * 100% Parity with iOS AuthView.swift.
 */
@Composable
fun AuthScreen(
    authService: AuthService,
    navigationState: NavigationState
) {
    val context = LocalContext.current
    val activity = context as? Activity
    val scope = rememberCoroutineScope()
    var errorMessage by remember { mutableStateOf<String?>(null) }
    var isGoogleLoading by remember { mutableStateOf(false) }
    var isAppleLoading by remember { mutableStateOf(false) }

    fun handleGoogleSignIn() {
        if (activity == null) return
        errorMessage = null
        isGoogleLoading = true

        scope.launch {
            try {
                val credentialManager = CredentialManager.create(context)
                val googleIdOption = GetGoogleIdOption.Builder()
                    .setFilterByAuthorizedAccounts(false)
                    .setServerClientId("799654898432-lq7ur1fkf2jsi6hne99ehl24jk4kg1qo.apps.googleusercontent.com")
                    .setAutoSelectEnabled(false)
                    .build()

                val request = GetCredentialRequest.Builder()
                    .addCredentialOption(googleIdOption)
                    .build()

                val result = credentialManager.getCredential(
                    request = request,
                    context = activity
                )

                val credential = result.credential
                if (credential is androidx.credentials.CustomCredential &&
                    credential.type == GoogleIdTokenCredential.TYPE_GOOGLE_ID_TOKEN_CREDENTIAL
                ) {
                    val googleIdTokenCredential = GoogleIdTokenCredential.createFrom(credential.data)
                    val authResult = authService.signInWithGoogle(googleIdTokenCredential.idToken)
                    if (authResult.isSuccess) {
                        withContext(Dispatchers.Main) { navigationState.navigateToHome() }
                    } else {
                        errorMessage = authResult.exceptionOrNull()?.localizedMessage ?: "Google ile giriş yapılamadı"
                    }
                } else {
                    errorMessage = "Geçerli bir Google hesabı bulunamadı"
                }
            } catch (e: GetCredentialCancellationException) {
                // User cancelled quietly
            } catch (e: Exception) {
                errorMessage = e.localizedMessage ?: "Giriş başarısız oldu"
            } finally {
                isGoogleLoading = false
            }
        }
    }

    fun handleAppleSignIn() {
        if (activity == null) return
        errorMessage = null
        isAppleLoading = true

        scope.launch {
            try {
                val result = authService.signInWithApple(activity)
                if (result.isSuccess) {
                    withContext(Dispatchers.Main) { navigationState.navigateToHome() }
                } else {
                    errorMessage = result.exceptionOrNull()?.localizedMessage ?: "Apple ile giriş yapılamadı"
                }
            } catch (e: Exception) {
                errorMessage = e.localizedMessage ?: "Apple ile giriş yapılamadı"
            } finally {
                isAppleLoading = false
            }
        }
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(PhotonColors.background)
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = PhotonSpacing.xl)
                .padding(bottom = PhotonSpacing.xxxl),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Spacer(modifier = Modifier.weight(1f))

            // Top / Center Branding Area
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.spacedBy(PhotonSpacing.lg)
            ) {
                PhotonLogoMark(
                    size = 72.dp,
                    color = PhotonColors.textPrimary
                )

                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.spacedBy(PhotonSpacing.xxs)
                ) {
                    Text(
                        text = "PHONLA",
                        style = PhotonTypography.titleLarge.copy(
                            letterSpacing = 4.sp,
                            color = PhotonColors.textPrimary
                        )
                    )

                    Text(
                        text = "Işık, Sinematik Renk & Siyah-Beyaz",
                        style = PhotonTypography.bodyMedium,
                        color = PhotonColors.textSecondary
                    )
                }
            }

            Spacer(modifier = Modifier.weight(1f))

            // Bottom Action Area
            Column(
                modifier = Modifier.fillMaxWidth(),
                verticalArrangement = Arrangement.spacedBy(PhotonSpacing.md),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                if (errorMessage != null) {
                    Text(
                        text = errorMessage!!,
                        style = PhotonTypography.caption,
                        color = PhotonColors.error,
                        textAlign = TextAlign.Center,
                        modifier = Modifier.padding(horizontal = PhotonSpacing.md)
                    )
                }

                // Google Sign In (Primary on Android)
                PhotonButton(
                    text = "Google ile Devam Et",
                    onClick = { handleGoogleSignIn() },
                    variant = PhotonButtonVariant.Primary,
                    size = PhotonButtonSize.Large,
                    isFullWidth = true,
                    isLoading = isGoogleLoading
                )

                // Apple Sign In
                PhotonButton(
                    text = "Apple ile Giriş Yap",
                    onClick = { handleAppleSignIn() },
                    variant = PhotonButtonVariant.Secondary,
                    size = PhotonButtonSize.Large,
                    isFullWidth = true,
                    isLoading = isAppleLoading
                )

                // Privacy Footnote
                Row(
                    horizontalArrangement = Arrangement.spacedBy(PhotonSpacing.xxs),
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = Modifier.padding(top = PhotonSpacing.xs)
                ) {
                    Icon(
                        imageVector = Icons.Default.Lock,
                        contentDescription = null,
                        tint = PhotonColors.textTertiary,
                        modifier = Modifier.size(12.dp)
                    )
                    Text(
                        text = "Giriş yaparak fotoğraflarınızı cihazınızda güvenle işleyebilirsiniz.",
                        style = PhotonTypography.caption,
                        color = PhotonColors.textTertiary,
                        textAlign = TextAlign.Center
                    )
                }
            }
        }
    }
}
