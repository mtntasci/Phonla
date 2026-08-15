package com.alafteknoloji.photon.features.home

import android.net.Uri
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.PickVisualMediaRequest
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.animation.Crossfade
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Person
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import com.alafteknoloji.photon.R
import com.alafteknoloji.photon.core.designsystem.PhotonColors
import com.alafteknoloji.photon.core.designsystem.PhotonCornerRadius
import com.alafteknoloji.photon.core.designsystem.PhotonSpacing
import com.alafteknoloji.photon.core.designsystem.PhotonTypography
import com.alafteknoloji.photon.core.designsystem.components.PhotonLogoMark
import com.alafteknoloji.photon.core.navigation.NavigationState
import com.alafteknoloji.photon.services.AuthService
import com.alafteknoloji.photon.services.PhotoLibraryService
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

/**
 * Premium cinematic Home Screen with dynamic crossfading background, profile avatar,
 * and Photo Picker integration.
 * 100% Parity with iOS HomeView.swift.
 */
@Composable
fun HomeScreen(
    authService: AuthService,
    photoLibraryService: PhotoLibraryService,
    navigationState: NavigationState
) {
    val scope = rememberCoroutineScope()
    var isLoadingPhoto by remember { mutableStateOf(false) }
    var errorMessage by remember { mutableStateOf<String?>(null) }

    // Dynamic background carousel
    val bgList = listOf(
        R.drawable.home_bg_cinema,
        R.drawable.home_bg_nature,
        R.drawable.home_bg_urban
    )
    var currentBgIndex by remember { mutableIntStateOf(0) }

    LaunchedEffect(Unit) {
        while (true) {
            delay(6000)
            currentBgIndex = (currentBgIndex + 1) % bgList.size
        }
    }

    val photoPickerLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.PickVisualMedia()
    ) { uri: Uri? ->
        if (uri != null) {
            isLoadingPhoto = true
            errorMessage = null
            scope.launch {
                val result = photoLibraryService.loadPhoto(uri)
                if (result.isSuccess) {
                    val photo = result.getOrNull()!!
                    navigationState.navigateToEditor(photo)
                } else {
                    errorMessage = result.exceptionOrNull()?.localizedMessage ?: "Fotoğraf yüklenemedi"
                }
                isLoadingPhoto = false
            }
        }
    }

    Box(modifier = Modifier.fillMaxSize()) {
        // Dynamic Fullscreen Background with Crossfade
        Crossfade(
            targetState = currentBgIndex,
            animationSpec = tween(1500),
            modifier = Modifier.fillMaxSize()
        ) { index ->
            Image(
                painter = painterResource(id = bgList[index]),
                contentDescription = null,
                contentScale = ContentScale.Crop,
                modifier = Modifier.fillMaxSize()
            )
        }

        // Soft Gradient Overlays for Readability
        Column(modifier = Modifier.fillMaxSize()) {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(160.dp)
                    .background(
                        Brush.verticalGradient(
                            listOf(
                                Color.Black.copy(alpha = 0.65f),
                                Color.Black.copy(alpha = 0.18f),
                                Color.Transparent
                            )
                        )
                    )
            )
            Spacer(modifier = Modifier.weight(1f))
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(280.dp)
                    .background(
                        Brush.verticalGradient(
                            listOf(
                                Color.Transparent,
                                Color.Black.copy(alpha = 0.4f),
                                Color.Black.copy(alpha = 0.85f)
                            )
                        )
                    )
            )
        }

        // Foreground Content
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = PhotonSpacing.xl)
                .padding(top = PhotonSpacing.xl, bottom = PhotonSpacing.xxl),
            verticalArrangement = Arrangement.SpaceBetween
        ) {
            // Top Header: Vector Logo & User Avatar
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(PhotonSpacing.sm)
                ) {
                    PhotonLogoMark(
                        size = 26.dp,
                        color = Color.White
                    )

                    Text(
                        text = "PHONLA",
                        style = PhotonTypography.headline.copy(
                            letterSpacing = 3.5.sp,
                            color = Color.White,
                            fontWeight = FontWeight.Bold
                        )
                    )
                }

                // User Avatar
                Box(
                    modifier = Modifier
                        .size(38.dp)
                        .clip(CircleShape)
                        .background(Color.White.copy(alpha = 0.2f))
                        .border(1.dp, Color.White.copy(alpha = 0.35f), CircleShape)
                        .clickable { navigationState.navigateToSettings() },
                    contentAlignment = Alignment.Center
                ) {
                    val session = authService.currentSession
                    if (session?.photoUrl != null) {
                        AsyncImage(
                            model = session.photoUrl,
                            contentDescription = "Profil",
                            contentScale = ContentScale.Crop,
                            modifier = Modifier
                                .fillMaxSize()
                                .clip(CircleShape)
                        )
                    } else {
                        val initial = session?.displayName?.firstOrNull()?.uppercaseChar()
                        if (initial != null) {
                            Text(
                                text = initial.toString(),
                                style = PhotonTypography.caption.copy(
                                    fontWeight = FontWeight.Bold,
                                    color = Color.White
                                )
                            )
                        } else {
                            Icon(
                                imageVector = Icons.Default.Person,
                                contentDescription = null,
                                tint = Color.White,
                                modifier = Modifier.size(18.dp)
                            )
                        }
                    }
                }
            }

            // Bottom Section: Slogans and Fotoğraf Yükle CTA
            Column(
                modifier = Modifier.fillMaxWidth(),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.spacedBy(PhotonSpacing.xxs),
                    modifier = Modifier.padding(bottom = PhotonSpacing.md)
                ) {
                    Text(
                        text = "Işık • Sinematik • Siyah & Beyaz",
                        style = PhotonTypography.headline.copy(
                            letterSpacing = 2.sp,
                            color = Color.White.copy(alpha = 0.95f)
                        ),
                        textAlign = TextAlign.Center
                    )

                    Text(
                        text = "Profesyonel fotoğraf düzenleme",
                        style = PhotonTypography.caption.copy(
                            color = Color.White.copy(alpha = 0.75f)
                        ),
                        textAlign = TextAlign.Center
                    )
                }

                if (errorMessage != null) {
                    Text(
                        text = errorMessage!!,
                        style = PhotonTypography.caption,
                        color = Color.White,
                        modifier = Modifier
                            .padding(bottom = PhotonSpacing.sm)
                            .background(PhotonColors.error.copy(alpha = 0.9f), RoundedCornerShape(PhotonCornerRadius.full))
                            .padding(horizontal = PhotonSpacing.md, vertical = PhotonSpacing.xs)
                    )
                }

                // Primary Fotoğraf Yükle CTA Button
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(54.dp)
                        .shadow(18.dp, RoundedCornerShape(14.dp))
                        .clip(RoundedCornerShape(14.dp))
                        .background(Color.White)
                        .clickable(enabled = !isLoadingPhoto) {
                            photoPickerLauncher.launch(
                                PickVisualMediaRequest(ActivityResultContracts.PickVisualMedia.ImageOnly)
                            )
                        },
                    horizontalArrangement = Arrangement.Center,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    if (isLoadingPhoto) {
                        CircularProgressIndicator(
                            modifier = Modifier.size(20.dp),
                            strokeWidth = 2.dp,
                            color = PhotonColors.textPrimary
                        )
                        Spacer(modifier = Modifier.size(PhotonSpacing.sm))
                    } else {
                        Icon(
                            imageVector = Icons.Default.Add,
                            contentDescription = null,
                            tint = PhotonColors.textPrimary,
                            modifier = Modifier.size(20.dp)
                        )
                        Spacer(modifier = Modifier.size(PhotonSpacing.sm))
                    }

                    Text(
                        text = if (isLoadingPhoto) "Fotoğraf Yükleniyor..." else "Fotoğraf Yükle",
                        style = PhotonTypography.button.copy(color = PhotonColors.textPrimary)
                    )
                }
            }
        }
    }
}
