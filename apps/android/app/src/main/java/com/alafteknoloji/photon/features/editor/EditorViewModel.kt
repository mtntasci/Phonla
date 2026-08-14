package com.alafteknoloji.photon.features.editor

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Contrast
import androidx.compose.material.icons.filled.Movie
import androidx.compose.material.icons.filled.Palette
import androidx.compose.material.icons.filled.WbSunny
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.graphics.vector.ImageVector
import com.alafteknoloji.photon.models.LoadedPhoto
import com.alafteknoloji.photon.models.PhotoEditState
import com.alafteknoloji.photon.services.ImageProcessingService
import com.alafteknoloji.photon.services.PhotoLibraryService
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

enum class EditorToolCategory(val title: String, val icon: ImageVector) {
    Light("Işık", Icons.Default.WbSunny),
    Color("Renk", Icons.Default.Palette),
    Cinematic("Sinematik", Icons.Default.Movie),
    Mono("Siyah & Beyaz", Icons.Default.Contrast)
}

/**
 * View model driving state adjustments, undo/redo history, live preview, and gallery export.
 * 100% Parity with iOS EditorViewModel.swift.
 */
class EditorViewModel(
    val photo: LoadedPhoto,
    private val imageProcessingService: ImageProcessingService,
    private val photoLibraryService: PhotoLibraryService
) {
    var editState by mutableStateOf(PhotoEditState.identity)
        private set

    var activeCategory by mutableStateOf(EditorToolCategory.Light)
    var isComparingOriginal by mutableStateOf(false)

    // Export state
    var isExporting by mutableStateOf(false)
        private set
    var exportSuccessMessage by mutableStateOf<String?>(null)
        private set
    var exportErrorMessage by mutableStateOf<String?>(null)
        private set

    // History Stacks
    private val undoStack = mutableListOf<PhotoEditState>()
    private val redoStack = mutableListOf<PhotoEditState>()
    private val maxHistoryDepth = 30

    val canUndo: Boolean
        get() = undoStack.isNotEmpty()

    val canRedo: Boolean
        get() = redoStack.isNotEmpty()

    val isEdited: Boolean
        get() = editState.isEdited

    fun updateState(mutation: (PhotoEditState) -> PhotoEditState) {
        editState = mutation(editState)
    }

    fun applyPresetUpdate(mutation: (PhotoEditState) -> PhotoEditState) {
        recordHistorySnapshot()
        editState = mutation(editState)
    }

    fun recordHistorySnapshot() {
        undoStack.add(editState)
        if (undoStack.size > maxHistoryDepth) {
            undoStack.removeAt(0)
        }
        redoStack.clear()
    }

    fun undo() {
        if (undoStack.isNotEmpty()) {
            val previous = undoStack.removeAt(undoStack.lastIndex)
            redoStack.add(editState)
            editState = previous
        }
    }

    fun redo() {
        if (redoStack.isNotEmpty()) {
            val next = redoStack.removeAt(redoStack.lastIndex)
            undoStack.add(editState)
            editState = next
        }
    }

    fun resetState() {
        if (isEdited) {
            recordHistorySnapshot()
            editState = PhotoEditState.identity
        }
    }

    fun exportPhoto(scope: CoroutineScope) {
        if (isExporting) return
        isExporting = true
        exportSuccessMessage = null
        exportErrorMessage = null

        scope.launch(Dispatchers.Default) {
            try {
                // 1. Render full resolution original image with non-destructive state
                val fullResRendered = imageProcessingService.renderFullResolution(
                    sourceBitmap = photo.originalBitmap,
                    state = editState
                )

                // 2. Save to Android MediaStore Pictures/Photon
                val saveResult = photoLibraryService.saveToGallery(fullResRendered)
                if (saveResult.isSuccess) {
                    exportSuccessMessage = "Fotoğraf galeriye kaydedildi"
                    delay(3000)
                    exportSuccessMessage = null
                } else {
                    exportErrorMessage = saveResult.exceptionOrNull()?.localizedMessage ?: "Fotoğraf kaydedilemedi"
                    delay(4000)
                    exportErrorMessage = null
                }
            } catch (e: Exception) {
                exportErrorMessage = e.localizedMessage ?: "Dışa aktarma sırasında hata oluştu"
                delay(4000)
                exportErrorMessage = null
            } finally {
                isExporting = false
            }
        }
    }
}
