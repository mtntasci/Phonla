//
//  PhotonTests.swift
//  PhotonTests
//
//  Created by Metin TASCI on 14.08.2026.
//

import Foundation
import CoreGraphics
import CoreImage
import UIKit
import Testing
@testable import Photon

struct PhotonTests {

    // MARK: - Helper to generate solid test CIImage
    
    private func createTestCIImage(width: Int = 100, height: Int = 100) -> CIImage {
        let color = CIColor(red: 0.6, green: 0.4, blue: 0.2, alpha: 1.0)
        return CIFilter(name: "CIConstantColorGenerator", parameters: [kCIInputColorKey: color])!
            .outputImage!
            .cropped(to: CGRect(x: 0, y: 0, width: width, height: height))
    }

    // MARK: - Navigation Tests
    
    @Test func testNavigationStateTransitions() async throws {
        let nav = await NavigationState()
        
        #expect(await nav.currentRoot == .splash)
        
        await nav.navigateToAuth()
        #expect(await nav.currentRoot == .auth)
        
        await nav.navigateToHome()
        #expect(await nav.currentRoot == .home)
        
        await nav.navigateToEditor()
        #expect(await nav.currentRoot == .editor)
        
        await nav.navigateToSettings()
        #expect(await nav.currentRoot == .settings)
        
        await nav.resetToSplash()
        #expect(await nav.currentRoot == .splash)
    }
    
    // MARK: - Design System Tests
    
    @Test func testDesignSystemTokens() async throws {
        #expect(PhotonSpacing.xxs == CGFloat(2))
        #expect(PhotonSpacing.xs == CGFloat(4))
        #expect(PhotonSpacing.sm == CGFloat(8))
        #expect(PhotonSpacing.md == CGFloat(12))
        #expect(PhotonSpacing.lg == CGFloat(16))
        
        #expect(PhotonCornerRadius.xs == CGFloat(4))
        #expect(PhotonCornerRadius.sm == CGFloat(8))
        #expect(PhotonCornerRadius.md == CGFloat(12))
        #expect(PhotonCornerRadius.lg == CGFloat(16))
        #expect(PhotonCornerRadius.xl == CGFloat(24))
        #expect(PhotonCornerRadius.full == CGFloat(999))
    }
    
    // MARK: - Auth & Session Tests
    
    @Test func testAuthServiceSignInAndSignOut() async throws {
        let auth = await AuthService.shared
        
        try await auth.signOut()
        #expect(await !auth.isAuthenticated)
        
        let appleSession = try await auth.signIn(with: .apple)
        #expect(appleSession.uid.contains("apple"))
        #expect(await auth.isAuthenticated)
        #expect(await auth.currentSession?.uid == appleSession.uid)
        
        try await auth.signOut()
        #expect(await !auth.isAuthenticated)
        #expect(await auth.currentSession == nil)
    }
    
    // MARK: - Phase 5: Light & Color Adjustments
    
    @Test func testLightAndColorAdjustments() async throws {
        let processing = ImageProcessingService.shared
        let testCI = createTestCIImage(width: 80, height: 80)
        
        var state = PhotoEditState()
        state.exposure = 0.75
        state.brightness = 0.20
        state.contrast = 1.15
        state.highlights = -0.30
        state.shadows = 0.40
        state.temperature = 7500.0
        state.tint = 15.0
        state.saturation = 1.25
        state.vibrance = 0.35
        
        #expect(state.isEdited)
        
        let renderedCI = processing.processImage(testCI, state: state)
        #expect(renderedCI.extent.size.width == 80)
        #expect(renderedCI.extent.size.height == 80)
        
        let preview = processing.renderPreview(from: testCI, state: state)
        #expect(preview != nil)
    }
    
    // MARK: - Phase 6: Cinematic Preset Engine
    
    @Test func testCinematicPresets() async throws {
        let processing = ImageProcessingService.shared
        let testCI = createTestCIImage(width: 100, height: 100)
        
        let presetIds = ["cinema", "warm", "cold", "teal", "fade", "night", "forest", "urban"]
        
        for presetId in presetIds {
            var state = PhotoEditState()
            state.selectedLookId = presetId
            state.lookIntensity = 0.85
            
            #expect(state.isEdited)
            
            let rendered = processing.processImage(testCI, state: state)
            #expect(rendered.extent.size.width == 100)
            #expect(rendered.extent.size.height == 100)
            
            let preview = processing.renderPreview(from: testCI, state: state)
            #expect(preview != nil)
        }
    }
    
    // MARK: - Phase 7: Professional Mono Engine
    
    @Test func testMonochromePresets() async throws {
        let processing = ImageProcessingService.shared
        let testCI = createTestCIImage(width: 100, height: 100)
        
        let monoIds = ["mono_natural", "mono_portrait", "mono_high_contrast", "mono_soft", "mono_street", "mono_dramatic"]
        
        for monoId in monoIds {
            var state = PhotoEditState()
            state.isMonoActive = true
            state.selectedMonoPresetId = monoId
            state.monoIntensity = 0.90
            
            #expect(state.isEdited)
            
            let rendered = processing.processImage(testCI, state: state)
            #expect(rendered.extent.size.width == 100)
            
            let preview = processing.renderPreview(from: testCI, state: state)
            #expect(preview != nil)
        }
    }
    
    // MARK: - Phase 8: Editor UX (Undo, Redo, Reset, Before/After)
    
    @Test func testEditorUndoRedoAndReset() async throws {
        let viewModel = await EditorViewModel.shared
        let testCI = createTestCIImage(width: 120, height: 120)
        let sampleUI = UIImage()
        
        let photo = LoadedPhoto(
            originalCIImage: testCI,
            previewCIImage: testCI,
            previewUIImage: sampleUI,
            pixelSize: CGSize(width: 120, height: 120)
        )
        
        await viewModel.setPhoto(photo)
        #expect(await !viewModel.canUndo)
        #expect(await !viewModel.canRedo)
        
        // Step 1: Modify Exposure
        await viewModel.recordHistorySnapshot()
        await viewModel.updateStateDirectly { $0.exposure = 0.5 }
        #expect(await viewModel.canUndo)
        #expect(await !viewModel.canRedo)
        
        // Step 2: Modify Contrast
        await viewModel.recordHistorySnapshot()
        await viewModel.updateStateDirectly { $0.contrast = 1.3 }
        
        // Undo Step 2
        await viewModel.undo()
        #expect(await viewModel.editState.contrast == 1.0)
        #expect(await viewModel.editState.exposure == 0.5)
        #expect(await viewModel.canRedo)
        
        // Redo Step 2
        await viewModel.redo()
        #expect(await viewModel.editState.contrast == 1.3)
        
        // Reset
        await viewModel.resetState()
        #expect(await !viewModel.isEdited)
        #expect(await viewModel.canUndo) // Reset is undoable!
    }
    
    // MARK: - Phase 9: Full Resolution Export Non-Destructive Integrity
    
    @Test func testFullResolutionRenderIntegrity() async throws {
        let processing = ImageProcessingService.shared
        let originalCI = createTestCIImage(width: 1920, height: 1080)
        
        var state = PhotoEditState()
        state.exposure = 0.4
        state.contrast = 1.1
        state.selectedLookId = "cinema"
        state.lookIntensity = 0.8
        
        // Render full resolution
        let fullResCG = processing.renderFullResolution(from: originalCI, state: state)
        #expect(fullResCG != nil)
        #expect(fullResCG?.width == 1920)
        #expect(fullResCG?.height == 1080)
        
        // Ensure source CIImage is unchanged
        #expect(originalCI.extent.width == 1920)
        #expect(originalCI.extent.height == 1080)
    }
}
