package com.alafteknoloji.photon.features.editor

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.detectTapGestures
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
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Redo
import androidx.compose.material.icons.filled.Undo
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Divider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.alafteknoloji.photon.core.designsystem.PhotonColors
import com.alafteknoloji.photon.core.designsystem.PhotonCornerRadius
import com.alafteknoloji.photon.core.designsystem.PhotonSpacing
import com.alafteknoloji.photon.core.designsystem.PhotonTypography
import com.alafteknoloji.photon.core.designsystem.components.PhotonButton
import com.alafteknoloji.photon.core.designsystem.components.PhotonButtonSize
import com.alafteknoloji.photon.core.designsystem.components.PhotonButtonVariant
import com.alafteknoloji.photon.core.navigation.NavigationState
import com.alafteknoloji.photon.features.editor.tools.CinematicToolView
import com.alafteknoloji.photon.features.editor.tools.ColorToolView
import com.alafteknoloji.photon.features.editor.tools.LightToolView
import com.alafteknoloji.photon.features.editor.tools.MonoToolView
import com.alafteknoloji.photon.models.LoadedPhoto
import com.alafteknoloji.photon.services.ImageProcessingService
import com.alafteknoloji.photon.services.PhotoLibraryService

/**
 * Non-destructive photo editor screen.
 * Features 60fps hardware-accelerated preview, hold-to-compare gesture, undo/redo, and gallery export.
 * 100% Parity with iOS EditorView.swift.
 */
@Composable
fun EditorScreen(
    photo: LoadedPhoto,
    imageProcessingService: ImageProcessingService,
    photoLibraryService: PhotoLibraryService,
    navigationState: NavigationState
) {
    val scope = rememberCoroutineScope()
    val viewModel = remember(photo) {
        EditorViewModel(
            photo = photo,
            imageProcessingService = imageProcessingService,
            photoLibraryService = photoLibraryService
        )
    }

    var showDiscardDialog by remember { mutableStateOf(false) }

    // Discard Dialog
    if (showDiscardDialog) {
        AlertDialog(
            onDismissRequest = { showDiscardDialog = false },
            title = {
                Text(
                    text = "Değişiklikleri Sil",
                    style = PhotonTypography.titleMedium,
                    color = PhotonColors.textPrimary
                )
            },
            text = {
                Text(
                    text = "Kaydedilmemiş düzenlemeleriniz kaybolacak.",
                    style = PhotonTypography.bodyMedium,
                    color = PhotonColors.textSecondary
                )
            },
            confirmButton = {
                TextButton(
                    onClick = {
                        showDiscardDialog = false
                        viewModel.resetState()
                        navigationState.navigateToHome()
                    }
                ) {
                    Text(
                        text = "Değişiklikleri Sil ve Çık",
                        color = PhotonColors.error,
                        fontWeight = FontWeight.SemiBold
                    )
                }
            },
            dismissButton = {
                TextButton(onClick = { showDiscardDialog = false }) {
                    Text(text = "İptal", color = PhotonColors.textPrimary)
                }
            },
            containerColor = PhotonColors.surfacePrimary
        )
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(PhotonColors.background)
    ) {
        // MARK: - Top Toolbar
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = PhotonSpacing.md, vertical = PhotonSpacing.sm),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(PhotonSpacing.sm)
        ) {
            // Close Button
            Box(
                modifier = Modifier
                    .size(36.dp)
                    .clip(CircleShape)
                    .background(PhotonColors.surfaceSecondary)
                    .clickable {
                        if (viewModel.isEdited) {
                            showDiscardDialog = true
                        } else {
                            navigationState.navigateToHome()
                        }
                    },
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = Icons.Default.Close,
                    contentDescription = "Kapat",
                    tint = PhotonColors.textPrimary,
                    modifier = Modifier.size(18.dp)
                )
            }

            // Undo Button
            Box(
                modifier = Modifier
                    .size(36.dp)
                    .clip(CircleShape)
                    .background(
                        if (viewModel.canUndo) PhotonColors.surfaceSecondary else PhotonColors.surfaceSecondary.copy(alpha = 0.5f)
                    )
                    .clickable(enabled = viewModel.canUndo) { viewModel.undo() },
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = Icons.Default.Undo,
                    contentDescription = "Geri Al",
                    tint = if (viewModel.canUndo) PhotonColors.textPrimary else PhotonColors.textTertiary.copy(alpha = 0.5f),
                    modifier = Modifier.size(18.dp)
                )
            }

            // Redo Button
            Box(
                modifier = Modifier
                    .size(36.dp)
                    .clip(CircleShape)
                    .background(
                        if (viewModel.canRedo) PhotonColors.surfaceSecondary else PhotonColors.surfaceSecondary.copy(alpha = 0.5f)
                    )
                    .clickable(enabled = viewModel.canRedo) { viewModel.redo() },
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = Icons.Default.Redo,
                    contentDescription = "İleri Al",
                    tint = if (viewModel.canRedo) PhotonColors.textPrimary else PhotonColors.textTertiary.copy(alpha = 0.5f),
                    modifier = Modifier.size(18.dp)
                )
            }

            Spacer(modifier = Modifier.weight(1f))

            // Reset Button on the right next to Kaydet
            if (viewModel.isEdited) {
                Text(
                    text = "Sıfırla",
                    style = PhotonTypography.bodyMedium.copy(fontWeight = FontWeight.Medium),
                    color = PhotonColors.textSecondary,
                    modifier = Modifier
                        .clickable { viewModel.resetState() }
                        .padding(horizontal = PhotonSpacing.xs)
                )
            }

            // Kaydet / Export Button
            PhotonButton(
                text = "Kaydet",
                onClick = { viewModel.exportPhoto(scope) },
                variant = PhotonButtonVariant.Primary,
                size = PhotonButtonSize.Small,
                isLoading = viewModel.isExporting
            )
        }

        // MARK: - Main Canvas Area
        Box(
            modifier = Modifier
                .weight(1f)
                .fillMaxWidth()
                .background(PhotonColors.surfaceTertiary),
            contentAlignment = Alignment.Center
        ) {
            val colorMatrix = remember(viewModel.editState) {
                imageProcessingService.buildColorMatrix(viewModel.editState)
            }
            val colorFilter = remember(viewModel.isComparingOriginal, colorMatrix) {
                if (viewModel.isComparingOriginal) null else ColorFilter.colorMatrix(androidx.compose.ui.graphics.ColorMatrix(colorMatrix.array))
            }

            // Image Preview Canvas with hold-to-compare gesture
            Box(
                modifier = Modifier
                    .padding(PhotonSpacing.md)
                    .shadow(10.dp, RoundedCornerShape(PhotonCornerRadius.sm))
                    .clip(RoundedCornerShape(PhotonCornerRadius.sm))
                    .border(0.5.dp, PhotonColors.border, RoundedCornerShape(PhotonCornerRadius.sm))
                    .pointerInput(viewModel.isEdited) {
                        detectTapGestures(
                            onPress = {
                                if (viewModel.isEdited) {
                                    viewModel.isComparingOriginal = true
                                    tryAwaitRelease()
                                    viewModel.isComparingOriginal = false
                                }
                            }
                        )
                    },
                contentAlignment = Alignment.TopEnd
            ) {
                Image(
                    bitmap = photo.previewBitmap.asImageBitmap(),
                    contentDescription = "Düzenlenen Fotoğraf",
                    contentScale = ContentScale.Fit,
                    colorFilter = colorFilter,
                    modifier = Modifier.fillMaxSize()
                )

                // "Orijinal" overlay pill when hold-to-compare is active
                androidx.compose.animation.AnimatedVisibility(
                    visible = viewModel.isComparingOriginal,
                    enter = fadeIn(),
                    exit = fadeOut()
                ) {
                    Text(
                        text = "Orijinal",
                        style = PhotonTypography.caption.copy(fontWeight = FontWeight.SemiBold),
                        color = PhotonColors.textInverted,
                        modifier = Modifier
                            .padding(PhotonSpacing.md)
                            .background(
                                PhotonColors.textPrimary.copy(alpha = 0.85f),
                                RoundedCornerShape(PhotonCornerRadius.full)
                            )
                            .padding(horizontal = PhotonSpacing.sm, vertical = PhotonSpacing.xxs)
                    )
                }
            }

            // Export Success Floating Toast
            androidx.compose.animation.AnimatedVisibility(
                visible = viewModel.exportSuccessMessage != null,
                enter = slideInVertically() + fadeIn(),
                exit = slideOutVertically() + fadeOut(),
                modifier = Modifier
                    .align(Alignment.TopCenter)
                    .padding(top = PhotonSpacing.md)
            ) {
                Row(
                    modifier = Modifier
                        .shadow(12.dp, RoundedCornerShape(PhotonCornerRadius.full))
                        .clip(RoundedCornerShape(PhotonCornerRadius.full))
                        .background(PhotonColors.surfacePrimary)
                        .padding(horizontal = PhotonSpacing.lg, vertical = PhotonSpacing.md),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(PhotonSpacing.xs)
                ) {
                    Icon(
                        imageVector = Icons.Default.CheckCircle,
                        contentDescription = null,
                        tint = PhotonColors.success,
                        modifier = Modifier.size(18.dp)
                    )
                    Text(
                        text = viewModel.exportSuccessMessage ?: "",
                        style = PhotonTypography.bodyMedium.copy(fontWeight = FontWeight.Medium),
                        color = PhotonColors.textPrimary
                    )
                }
            }

            // Export Error Floating Toast
            androidx.compose.animation.AnimatedVisibility(
                visible = viewModel.exportErrorMessage != null,
                enter = slideInVertically() + fadeIn(),
                exit = slideOutVertically() + fadeOut(),
                modifier = Modifier
                    .align(Alignment.TopCenter)
                    .padding(top = PhotonSpacing.md)
            ) {
                Row(
                    modifier = Modifier
                        .shadow(12.dp, RoundedCornerShape(PhotonCornerRadius.full))
                        .clip(RoundedCornerShape(PhotonCornerRadius.full))
                        .background(PhotonColors.surfacePrimary)
                        .padding(horizontal = PhotonSpacing.lg, vertical = PhotonSpacing.sm),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(PhotonSpacing.xs)
                ) {
                    Icon(
                        imageVector = Icons.Default.Warning,
                        contentDescription = null,
                        tint = PhotonColors.error,
                        modifier = Modifier.size(18.dp)
                    )
                    Text(
                        text = viewModel.exportErrorMessage ?: "",
                        style = PhotonTypography.caption.copy(fontWeight = FontWeight.Medium),
                        color = PhotonColors.textPrimary
                    )
                }
            }
        }

        // MARK: - Bottom Tool Section
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .background(PhotonColors.surfacePrimary)
        ) {
            Divider(color = PhotonColors.divider)

            // Fixed Height Sub-Tool Adjustment Panel
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(144.dp)
            ) {
                when (viewModel.activeCategory) {
                    EditorToolCategory.Light -> LightToolView(viewModel = viewModel)
                    EditorToolCategory.Color -> ColorToolView(viewModel = viewModel)
                    EditorToolCategory.Cinematic -> CinematicToolView(viewModel = viewModel)
                    EditorToolCategory.Mono -> MonoToolView(viewModel = viewModel)
                }
            }

            Divider(color = PhotonColors.divider)

            // Category Tabs Bar
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = PhotonSpacing.sm, vertical = PhotonSpacing.xxs)
                    .padding(bottom = PhotonSpacing.md),
                horizontalArrangement = Arrangement.SpaceEvenly
            ) {
                EditorToolCategory.entries.forEach { category ->
                    val isSelected = viewModel.activeCategory == category
                    Column(
                        modifier = Modifier
                            .weight(1f)
                            .clip(RoundedCornerShape(PhotonCornerRadius.sm))
                            .background(
                                if (isSelected) PhotonColors.surfaceSecondary else Color.Transparent
                            )
                            .clickable { viewModel.activeCategory = category }
                            .padding(vertical = PhotonSpacing.sm),
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.spacedBy(PhotonSpacing.xxs)
                    ) {
                        Icon(
                            imageVector = category.icon,
                            contentDescription = category.title,
                            tint = if (isSelected) PhotonColors.textPrimary else PhotonColors.textSecondary,
                            modifier = Modifier.size(18.dp)
                        )
                        Text(
                            text = category.title,
                            style = PhotonTypography.caption.copy(
                                fontWeight = if (isSelected) FontWeight.SemiBold else FontWeight.Normal,
                                color = if (isSelected) PhotonColors.textPrimary else PhotonColors.textSecondary
                            )
                        )
                    }
                }
            }
        }
    }
}
