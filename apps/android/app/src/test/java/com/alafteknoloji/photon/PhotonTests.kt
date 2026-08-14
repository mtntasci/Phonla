package com.alafteknoloji.photon

import android.graphics.Bitmap
import androidx.compose.ui.unit.dp
import com.alafteknoloji.photon.core.designsystem.PhotonCornerRadius
import com.alafteknoloji.photon.core.designsystem.PhotonSpacing
import com.alafteknoloji.photon.core.navigation.NavigationState
import com.alafteknoloji.photon.core.navigation.Screen
import com.alafteknoloji.photon.models.CinematicPreset
import com.alafteknoloji.photon.models.LoadedPhoto
import com.alafteknoloji.photon.models.MonoPreset
import com.alafteknoloji.photon.models.PhotoEditState
import com.alafteknoloji.photon.services.ImageProcessingService
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

/**
 * Android Unit Test Suite mirroring 100% of iOS PhotonTests.swift.
 */
@RunWith(RobolectricTestRunner::class)
class PhotonTests {

    private fun createTestBitmap(width: Int = 100, height: Int = 100): Bitmap {
        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        bitmap.eraseColor(android.graphics.Color.rgb(150, 100, 50))
        return bitmap
    }

    // MARK: - Navigation Tests
    @Test
    fun testNavigationStateTransitions() {
        val nav = NavigationState()
        assertEquals(Screen.Splash, nav.currentScreen)

        nav.navigateToAuth()
        assertEquals(Screen.Auth, nav.currentScreen)

        nav.navigateToHome()
        assertEquals(Screen.Home, nav.currentScreen)

        val testBitmap = createTestBitmap(50, 50)
        val photo = LoadedPhoto(
            originalBitmap = testBitmap,
            previewBitmap = testBitmap
        )
        nav.navigateToEditor(photo)
        assertTrue(nav.currentScreen is Screen.Editor)

        nav.navigateToSettings()
        assertEquals(Screen.Settings, nav.currentScreen)

        nav.navigateToSplash()
        assertEquals(Screen.Splash, nav.currentScreen)
    }

    // MARK: - Design System Tests
    @Test
    fun testDesignSystemTokens() {
        assertEquals(2.dp, PhotonSpacing.xxs)
        assertEquals(4.dp, PhotonSpacing.xs)
        assertEquals(8.dp, PhotonSpacing.sm)
        assertEquals(12.dp, PhotonSpacing.md)
        assertEquals(16.dp, PhotonSpacing.lg)

        assertEquals(4.dp, PhotonCornerRadius.xs)
        assertEquals(8.dp, PhotonCornerRadius.sm)
        assertEquals(12.dp, PhotonCornerRadius.md)
        assertEquals(16.dp, PhotonCornerRadius.lg)
        assertEquals(24.dp, PhotonCornerRadius.xl)
        assertEquals(999.dp, PhotonCornerRadius.full)
    }

    // MARK: - Phase 5: Light & Color Adjustments
    @Test
    fun testLightAndColorAdjustments() = runTest {
        val processing = ImageProcessingService()
        val testBitmap = createTestBitmap(80, 80)

        val state = PhotoEditState(
            exposure = 0.75f,
            brightness = 0.20f,
            contrast = 1.15f,
            highlights = -0.30f,
            shadows = 0.40f,
            temperature = 7500.0f,
            tint = 15.0f,
            saturation = 1.25f,
            vibrance = 0.35f
        )

        assertTrue(state.isEdited)

        val matrix = processing.buildColorMatrix(state)
        assertNotNull(matrix)

        val rendered = processing.renderFullResolution(testBitmap, state)
        assertNotNull(rendered)
        assertEquals(80, rendered.width)
        assertEquals(80, rendered.height)
    }

    // MARK: - Phase 6: Cinematic Preset Engine
    @Test
    fun testCinematicPresets() = runTest {
        val processing = ImageProcessingService()
        val testBitmap = createTestBitmap(100, 100)

        val presetIds = listOf("cinema", "warm", "cold", "teal", "fade", "night", "forest", "urban")

        for (presetId in presetIds) {
            val state = PhotoEditState(
                selectedLookId = presetId,
                lookIntensity = 0.85f
            )

            assertTrue(state.isEdited)

            val rendered = processing.renderFullResolution(testBitmap, state)
            assertNotNull(rendered)
            assertEquals(100, rendered.width)
            assertEquals(100, rendered.height)
        }
    }

    // MARK: - Phase 7: Professional Mono Engine
    @Test
    fun testMonochromePresets() = runTest {
        val processing = ImageProcessingService()
        val testBitmap = createTestBitmap(100, 100)

        val monoIds = listOf("mono_natural", "mono_portrait", "mono_high_contrast", "mono_soft", "mono_street", "mono_dramatic")

        for (monoId in monoIds) {
            val state = PhotoEditState(
                isMonoActive = true,
                selectedMonoPresetId = monoId,
                monoIntensity = 0.90f
            )

            assertTrue(state.isEdited)

            val rendered = processing.renderFullResolution(testBitmap, state)
            assertNotNull(rendered)
            assertEquals(100, rendered.width)
            assertEquals(100, rendered.height)
        }
    }

    // MARK: - Phase 8: Editor UX (Undo, Redo, Reset)
    @Test
    fun testEditorUndoRedoAndReset() {
        val undoStack = mutableListOf<PhotoEditState>()
        val redoStack = mutableListOf<PhotoEditState>()
        var editState = PhotoEditState.identity

        // Step 1: Modify Exposure
        undoStack.add(editState)
        editState = editState.copy(exposure = 0.5f)
        assertTrue(undoStack.isNotEmpty())
        assertTrue(redoStack.isEmpty())

        // Step 2: Modify Contrast
        undoStack.add(editState)
        editState = editState.copy(contrast = 1.3f)

        // Undo Step 2
        val previous = undoStack.removeAt(undoStack.lastIndex)
        redoStack.add(editState)
        editState = previous
        assertEquals(1.0f, editState.contrast)
        assertEquals(0.5f, editState.exposure)
        assertTrue(redoStack.isNotEmpty())

        // Redo Step 2
        val next = redoStack.removeAt(redoStack.lastIndex)
        undoStack.add(editState)
        editState = next
        assertEquals(1.3f, editState.contrast)

        // Reset
        undoStack.add(editState)
        editState = PhotoEditState.identity
        assertFalse(editState.isEdited)
        assertTrue(undoStack.isNotEmpty()) // Reset is undoable
    }

    // MARK: - Phase 9: Full Resolution Non-Destructive Integrity
    @Test
    fun testFullResolutionRenderIntegrity() = runTest {
        val processing = ImageProcessingService()
        val originalBitmap = createTestBitmap(1920, 1080)

        val state = PhotoEditState(
            exposure = 0.4f,
            contrast = 1.1f,
            selectedLookId = "cinema",
            lookIntensity = 0.8f
        )

        // Render full resolution
        val fullRes = processing.renderFullResolution(originalBitmap, state)
        assertNotNull(fullRes)
        assertEquals(1920, fullRes.width)
        assertEquals(1080, fullRes.height)

        // Source bitmap dimension unchanged
        assertEquals(1920, originalBitmap.width)
        assertEquals(1080, originalBitmap.height)
    }
}
