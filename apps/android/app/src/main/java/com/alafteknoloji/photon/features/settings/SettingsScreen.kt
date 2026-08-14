package com.alafteknoloji.photon.features.settings

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
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
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ChevronLeft
import androidx.compose.material.icons.filled.ChevronRight
import androidx.compose.material.icons.filled.EmojiEvents
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Phone
import androidx.compose.material3.Divider
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.Text
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableLongStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.core.content.ContextCompat
import coil.compose.AsyncImage
import com.alafteknoloji.photon.core.designsystem.PhotonColors
import com.alafteknoloji.photon.core.designsystem.PhotonCornerRadius
import com.alafteknoloji.photon.core.designsystem.PhotonSpacing
import com.alafteknoloji.photon.core.designsystem.PhotonTypography
import com.alafteknoloji.photon.core.designsystem.components.PhotonButton
import com.alafteknoloji.photon.core.designsystem.components.PhotonButtonSize
import com.alafteknoloji.photon.core.designsystem.components.PhotonButtonVariant
import com.alafteknoloji.photon.core.navigation.NavigationState
import com.alafteknoloji.photon.services.AuthService
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

/**
 * Profile and Settings screen managing user profile data, notification permissions,
 * membership tiers, privacy commitments, and the special dedicated Easter Egg.
 * 100% Parity with iOS SettingsView.swift.
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SettingsScreen(
    authService: AuthService,
    navigationState: NavigationState
) {
    val context = LocalContext.current
    val scope = rememberCoroutineScope()
    val scrollState = rememberScrollState()

    // Phone editing
    var phoneNumberText by remember { mutableStateOf(authService.currentSession?.phoneNumber ?: "") }
    var phoneSavedFeedback by remember { mutableStateOf(false) }

    // Notifications
    var hasNotificationPermission by remember {
        mutableStateOf(
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                ContextCompat.checkSelfPermission(
                    context,
                    Manifest.permission.POST_NOTIFICATIONS
                ) == PackageManager.PERMISSION_GRANTED
            } else {
                true
            }
        )
    }

    val permissionLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.RequestPermission()
    ) { isGranted ->
        hasNotificationPermission = isGranted
    }

    // Membership Sheet
    var showMembershipSheet by remember { mutableStateOf(false) }
    val sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)

    // Easter Egg (3 Taps within 1.5s)
    var privacyTapCount by remember { mutableIntStateOf(0) }
    var lastPrivacyTapTime by remember { mutableLongStateOf(0L) }
    var showEasterEgg by remember { mutableStateOf(false) }
    var easterEggJob by remember { mutableStateOf<Job?>(null) }

    fun handlePrivacyCardTap() {
        val now = System.currentTimeMillis()
        if (now - lastPrivacyTapTime < 1500) {
            privacyTapCount++
        } else {
            privacyTapCount = 1
        }
        lastPrivacyTapTime = now

        if (privacyTapCount >= 3) {
            privacyTapCount = 0
            easterEggJob?.cancel()
            showEasterEgg = true
            easterEggJob = scope.launch {
                delay(10000)
                showEasterEgg = false
            }
        }
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(PhotonColors.background)
    ) {
        Column(modifier = Modifier.fillMaxSize()) {
            // Header
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = PhotonSpacing.lg, vertical = PhotonSpacing.sm),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Box(
                    modifier = Modifier
                        .size(36.dp)
                        .clip(CircleShape)
                        .background(PhotonColors.surfaceSecondary)
                        .clickable { navigationState.navigateToHome() },
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Default.ChevronLeft,
                        contentDescription = "Geri",
                        tint = PhotonColors.textPrimary,
                        modifier = Modifier.size(22.dp)
                    )
                }

                Text(
                    text = "Profil & Ayarlar",
                    style = PhotonTypography.headline,
                    color = PhotonColors.textPrimary
                )

                Spacer(modifier = Modifier.size(36.dp))
            }

            Divider(color = PhotonColors.divider)

            // Content
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .verticalScroll(scrollState)
                    .padding(PhotonSpacing.lg)
                    .padding(bottom = PhotonSpacing.xxxl),
                verticalArrangement = Arrangement.spacedBy(PhotonSpacing.xl)
            ) {
                // Profile Card
                val session = authService.currentSession
                if (session != null) {
                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .shadow(2.dp, RoundedCornerShape(PhotonCornerRadius.lg))
                            .clip(RoundedCornerShape(PhotonCornerRadius.lg))
                            .background(PhotonColors.surfacePrimary)
                            .border(1.dp, PhotonColors.border, RoundedCornerShape(PhotonCornerRadius.lg))
                            .padding(PhotonSpacing.lg),
                        verticalArrangement = Arrangement.spacedBy(PhotonSpacing.md)
                    ) {
                        // User Avatar & Name
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(PhotonSpacing.md)
                        ) {
                            Box(
                                modifier = Modifier
                                    .size(56.dp)
                                    .clip(CircleShape)
                                    .background(PhotonColors.surfaceSecondary),
                                contentAlignment = Alignment.Center
                            ) {
                                if (session.photoUrl != null) {
                                    AsyncImage(
                                        model = session.photoUrl,
                                        contentDescription = null,
                                        contentScale = ContentScale.Crop,
                                        modifier = Modifier.fillMaxSize()
                                    )
                                } else {
                                    val initial = session.displayName.firstOrNull()?.uppercaseChar()
                                    if (initial != null) {
                                        Text(
                                            text = initial.toString(),
                                            style = PhotonTypography.headline,
                                            color = PhotonColors.textPrimary
                                        )
                                    } else {
                                        Icon(
                                            imageVector = Icons.Default.Person,
                                            contentDescription = null,
                                            tint = PhotonColors.textSecondary,
                                            modifier = Modifier.size(24.dp)
                                        )
                                    }
                                }
                            }

                            Column(verticalArrangement = Arrangement.spacedBy(PhotonSpacing.xxs)) {
                                Text(
                                    text = session.displayName,
                                    style = PhotonTypography.headline,
                                    color = PhotonColors.textPrimary
                                )

                                if (session.email != null) {
                                    Text(
                                        text = session.email,
                                        style = PhotonTypography.caption,
                                        color = PhotonColors.textSecondary
                                    )
                                }

                                Text(
                                    text = "${session.providerId} ile Bağlı",
                                    style = PhotonTypography.caption,
                                    color = PhotonColors.textTertiary
                                )
                            }
                        }

                        Divider(color = PhotonColors.divider)

                        // Phone Number (Optional)
                        Column(verticalArrangement = Arrangement.spacedBy(PhotonSpacing.xs)) {
                            Text(
                                text = "Telefon Numarası (Opsiyonel)",
                                style = PhotonTypography.caption,
                                color = PhotonColors.textTertiary
                            )

                            Row(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .clip(RoundedCornerShape(PhotonCornerRadius.md))
                                    .background(PhotonColors.surfaceSecondary)
                                    .padding(horizontal = PhotonSpacing.sm, vertical = PhotonSpacing.xs),
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.spacedBy(PhotonSpacing.sm)
                            ) {
                                Icon(
                                    imageVector = Icons.Default.Phone,
                                    contentDescription = null,
                                    tint = PhotonColors.textSecondary,
                                    modifier = Modifier.size(16.dp)
                                )

                                BasicTextField(
                                    value = phoneNumberText,
                                    onValueChange = { phoneNumberText = it },
                                    textStyle = PhotonTypography.bodyMedium.copy(color = PhotonColors.textPrimary),
                                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Phone),
                                    modifier = Modifier.weight(1f),
                                    decorationBox = { innerTextField ->
                                        if (phoneNumberText.isEmpty()) {
                                            Text(
                                                text = "Telefon numaranızı girin",
                                                style = PhotonTypography.bodyMedium,
                                                color = PhotonColors.textTertiary
                                            )
                                        }
                                        innerTextField()
                                    }
                                )

                                if (phoneNumberText != (session.phoneNumber ?: "")) {
                                    Box(
                                        modifier = Modifier
                                            .clip(RoundedCornerShape(PhotonCornerRadius.full))
                                            .background(PhotonColors.textPrimary)
                                            .clickable {
                                                authService.savePhoneNumber(phoneNumberText)
                                                phoneSavedFeedback = true
                                                scope.launch {
                                                    delay(2000)
                                                    phoneSavedFeedback = false
                                                }
                                            }
                                            .padding(horizontal = PhotonSpacing.sm, vertical = 6.dp)
                                    ) {
                                        Text(
                                            text = "Kaydet",
                                            style = PhotonTypography.caption.copy(fontWeight = FontWeight.SemiBold),
                                            color = PhotonColors.textInverted
                                        )
                                    }
                                } else if (phoneSavedFeedback) {
                                    Text(
                                        text = "Kaydedildi",
                                        style = PhotonTypography.caption.copy(fontWeight = FontWeight.SemiBold),
                                        color = PhotonColors.success
                                    )
                                }
                            }
                        }

                        Divider(color = PhotonColors.divider)

                        // Sign Out Button
                        PhotonButton(
                            text = "Çıkış Yap",
                            onClick = {
                                scope.launch {
                                    authService.signOut()
                                    navigationState.navigateToAuth()
                                }
                            },
                            variant = PhotonButtonVariant.Secondary,
                            size = PhotonButtonSize.Small,
                            isFullWidth = true
                        )
                    }
                }

                // Settings Group
                Column(verticalArrangement = Arrangement.spacedBy(PhotonSpacing.sm)) {
                    Text(
                        text = "Ayarlar",
                        style = PhotonTypography.caption,
                        color = PhotonColors.textTertiary,
                        modifier = Modifier.padding(horizontal = PhotonSpacing.xs)
                    )

                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .shadow(2.dp, RoundedCornerShape(PhotonCornerRadius.lg))
                            .clip(RoundedCornerShape(PhotonCornerRadius.lg))
                            .background(PhotonColors.surfacePrimary)
                            .border(1.dp, PhotonColors.border, RoundedCornerShape(PhotonCornerRadius.lg))
                            .padding(horizontal = PhotonSpacing.md)
                    ) {
                        // Notifications
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(vertical = PhotonSpacing.md),
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.SpaceBetween
                        ) {
                            Row(
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.spacedBy(PhotonSpacing.sm)
                            ) {
                                Icon(
                                    imageVector = Icons.Default.Notifications,
                                    contentDescription = null,
                                    tint = PhotonColors.textPrimary,
                                    modifier = Modifier.size(20.dp)
                                )
                                Text(
                                    text = "Bildirim İzni",
                                    style = PhotonTypography.bodyMedium,
                                    color = PhotonColors.textPrimary
                                )
                            }

                            if (hasNotificationPermission) {
                                Row(
                                    verticalAlignment = Alignment.CenterVertically,
                                    horizontalArrangement = Arrangement.spacedBy(4.dp)
                                ) {
                                    Box(
                                        modifier = Modifier
                                            .size(6.dp)
                                            .clip(CircleShape)
                                            .background(PhotonColors.success)
                                    )
                                    Text(
                                        text = "İzin Verildi",
                                        style = PhotonTypography.caption.copy(fontWeight = FontWeight.Medium),
                                        color = PhotonColors.success
                                    )
                                }
                            } else {
                                Box(
                                    modifier = Modifier
                                        .clip(RoundedCornerShape(PhotonCornerRadius.full))
                                        .background(PhotonColors.surfaceSecondary)
                                        .clickable {
                                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                                                permissionLauncher.launch(Manifest.permission.POST_NOTIFICATIONS)
                                            }
                                        }
                                        .padding(horizontal = PhotonSpacing.sm, vertical = 4.dp)
                                ) {
                                    Text(
                                        text = "İzin İste",
                                        style = PhotonTypography.caption.copy(fontWeight = FontWeight.Medium),
                                        color = PhotonColors.textSecondary
                                    )
                                }
                            }
                        }

                        Divider(color = PhotonColors.divider)

                        // Memberships
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .clickable { showMembershipSheet = true }
                                .padding(vertical = PhotonSpacing.md),
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.SpaceBetween
                        ) {
                            Row(
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.spacedBy(PhotonSpacing.sm)
                            ) {
                                Icon(
                                    imageVector = Icons.Default.EmojiEvents,
                                    contentDescription = null,
                                    tint = PhotonColors.textPrimary,
                                    modifier = Modifier.size(20.dp)
                                )
                                Text(
                                    text = "Üyelikler",
                                    style = PhotonTypography.bodyMedium,
                                    color = PhotonColors.textPrimary
                                )
                            }

                            Row(
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.spacedBy(PhotonSpacing.xs)
                            ) {
                                Text(
                                    text = "Free",
                                    style = PhotonTypography.caption,
                                    color = PhotonColors.textSecondary
                                )
                                Icon(
                                    imageVector = Icons.Default.ChevronRight,
                                    contentDescription = null,
                                    tint = PhotonColors.textTertiary,
                                    modifier = Modifier.size(16.dp)
                                )
                            }
                        }
                    }
                }

                // Privacy Card (with 3-Tap Easter Egg)
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(PhotonCornerRadius.lg))
                        .background(PhotonColors.surfaceSecondary)
                        .clickable { handlePrivacyCardTap() }
                        .padding(PhotonSpacing.lg),
                    verticalArrangement = Arrangement.spacedBy(PhotonSpacing.md)
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(PhotonSpacing.sm)
                    ) {
                        Icon(
                            imageVector = Icons.Default.Lock,
                            contentDescription = null,
                            tint = PhotonColors.textPrimary,
                            modifier = Modifier.size(20.dp)
                        )
                        Text(
                            text = "Gizlilik & Donanım Hızlandırma",
                            style = PhotonTypography.titleMedium,
                            color = PhotonColors.textPrimary
                        )
                    }

                    Column(verticalArrangement = Arrangement.spacedBy(PhotonSpacing.xs)) {
                        Row(horizontalArrangement = Arrangement.spacedBy(PhotonSpacing.xs)) {
                            Text(text = "•", color = PhotonColors.textPrimary)
                            Text(
                                text = "Fotoğraflar doğrudan cihaz üzerinde işlenir",
                                style = PhotonTypography.bodyMedium,
                                color = PhotonColors.textSecondary
                            )
                        }
                        Row(horizontalArrangement = Arrangement.spacedBy(PhotonSpacing.xs)) {
                            Text(text = "•", color = PhotonColors.textPrimary)
                            Text(
                                text = "Fotoğraflar hiçbir sunucuya yüklenmez",
                                style = PhotonTypography.bodyMedium,
                                color = PhotonColors.textSecondary
                            )
                        }
                        Row(horizontalArrangement = Arrangement.spacedBy(PhotonSpacing.xs)) {
                            Text(text = "•", color = PhotonColors.textPrimary)
                            Text(
                                text = "Android GPU & ColorMatrix donanım hızlandırmalı motor kullanılır",
                                style = PhotonTypography.bodyMedium,
                                color = PhotonColors.textSecondary
                            )
                        }
                    }
                }
            }
        }

        // Easter Egg Floating Toast
        AnimatedVisibility(
            visible = showEasterEgg,
            enter = slideInVertically(initialOffsetY = { it }) + fadeIn(),
            exit = slideOutVertically(targetOffsetY = { it }) + fadeOut(),
            modifier = Modifier
                .align(Alignment.BottomCenter)
                .padding(horizontal = PhotonSpacing.lg)
                .padding(bottom = PhotonSpacing.xl)
        ) {
            Row(
                modifier = Modifier
                    .shadow(16.dp, RoundedCornerShape(PhotonCornerRadius.lg))
                    .clip(RoundedCornerShape(PhotonCornerRadius.lg))
                    .background(Color.Black.copy(alpha = 0.92f))
                    .padding(PhotonSpacing.md),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(PhotonSpacing.sm)
            ) {
                Text(text = "❤️", style = PhotonTypography.titleMedium)
                Text(
                    text = "Bu uygulama Gurbet için Metin tarafından aşkla yapıldı ❤️",
                    style = PhotonTypography.bodyMedium.copy(fontWeight = FontWeight.SemiBold),
                    color = PhotonColors.textInverted
                )
            }
        }

        // Membership Modal Sheet
        if (showMembershipSheet) {
            ModalBottomSheet(
                onDismissRequest = { showMembershipSheet = false },
                sheetState = sheetState,
                containerColor = PhotonColors.background
            ) {
                MembershipScreen(onDismiss = { showMembershipSheet = false })
            }
        }
    }
}
