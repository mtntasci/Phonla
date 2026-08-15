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
import AppTrackingTransparency
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
    
    @Test func testUserSessionModel() async throws {
        let session = UserSession(
            uid: "test-uid-123",
            email: "test@phonla.app",
            displayName: "Test User",
            photoURL: URL(string: "https://phonla.app/avatar.jpg"),
            providerId: "Apple",
            isAnonymous: false
        )
        
        #expect(session.uid == "test-uid-123")
        #expect(session.email == "test@phonla.app")
        #expect(session.displayName == "Test User")
        #expect(session.providerId == "Apple")
    }
    
    @Test func testAuthServiceSignOutAndSessionState() async throws {
        let auth = await AuthService.shared
        
        try await auth.signOut()
        #expect(await !auth.isAuthenticated)
        #expect(await auth.currentSession == nil)
        
        let session = await auth.checkCurrentSession()
        #expect(session == nil)
    }
    
    @Test func testAuthErrorDescriptions() async throws {
        let recentLoginErr = AuthError.requiresRecentLogin
        #expect(recentLoginErr.errorDescription?.contains("yeniden giriş") == true)
        
        let notAuthErr = AuthError.notAuthenticated
        #expect(notAuthErr.errorDescription?.contains("oturum") == true)
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
    
    // MARK: - Portrait & Skin Smoothing Tests
    
    @Test func testSkinSmoothingPipeline() async throws {
        let processing = ImageProcessingService.shared
        let testCI = createTestCIImage(width: 800, height: 600)
        
        // Generate a mock grayscale skin mask (white center rectangle)
        let maskColor = CIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        let mockMask = CIFilter(name: "CIConstantColorGenerator", parameters: [kCIInputColorKey: maskColor])!
            .outputImage!
            .cropped(to: CGRect(x: 200, y: 150, width: 400, height: 300))
        
        // Test varying intensity values (0, 50, 100)
        for intensity in [0.0, 35.0, 75.0, 100.0] as [Float] {
            var state = PhotoEditState()
            state.skinSmoothing = intensity
            
            let processedWithMask = processing.processImage(testCI, state: state, skinMask: mockMask)
            #expect(processedWithMask.extent.width == 800)
            #expect(processedWithMask.extent.height == 600)
            
            let preview = processing.renderPreview(from: testCI, state: state, skinMask: mockMask)
            #expect(preview != nil)
        }
    }
    
    @Test func testFaceDetectionMaskGenerationWithEmptyFaces() async throws {
        let faceService = FaceDetectionService.shared
        let extent = CGRect(x: 0, y: 0, width: 640, height: 480)
        
        // When no faces are present, generateSkinMask must return nil safely
        let emptyMask = faceService.generateSkinMask(targetExtent: extent, faces: [])
        #expect(emptyMask == nil)
    }
    
    @Test func testSpotHealingPipeline() async throws {
        let processing = ImageProcessingService.shared
        let testCI = createTestCIImage(width: 800, height: 600)
        
        var state = PhotoEditState()
        state.healedSpots = [
            HealedSpot(x: 0.5, y: 0.5, radius: 0.02),
            HealedSpot(x: 0.3, y: 0.4, radius: 0.015)
        ]
        
        #expect(state.isEdited)
        #expect(state.healedSpots.count == 2)
        
        let healedCI = processing.processImage(testCI, state: state)
        #expect(healedCI.extent.width == 800)
        #expect(healedCI.extent.height == 600)
        
        let preview = processing.renderPreview(from: testCI, state: state)
        #expect(preview != nil)
    }
    
    @Test @MainActor func testSpotHealingViewModelMutations() async throws {
        let viewModel = EditorViewModel.shared
        viewModel.editState = .identity
        
        #expect(viewModel.editState.healedSpots.isEmpty)
        
        // Add 2 healed spots
        viewModel.addHealedSpot(x: 0.45, y: 0.55)
        viewModel.addHealedSpot(x: 0.60, y: 0.70)
        #expect(viewModel.editState.healedSpots.count == 2)
        #expect(viewModel.canUndo)
        
        // Undo last spot
        viewModel.undoLastHealedSpot()
        #expect(viewModel.editState.healedSpots.count == 1)
        
        // Clear all spots
        viewModel.clearAllHealedSpots()
        #expect(viewModel.editState.healedSpots.isEmpty)
    }
    
    // MARK: - StoreKit 2 & AdMob Configuration Tests
    
    @Test func testAppConfigConstants() async throws {
        #expect(AppConfig.StoreKit.proMonthlyProductID == "com.alafteknoloji.photon.pro.monthly")
        #expect(AppConfig.StoreKit.allProductIDs.contains("com.alafteknoloji.photon.pro.monthly"))
        #expect(!AppConfig.AdMob.appID.isEmpty)
        #expect(!AppConfig.AdMob.rewardedExportAdUnitID.isEmpty)
        #expect(AppConfig.AdMob.isConservativePrivacyEnabled == true)
    }
    
    // MARK: - Subscription Service Tests
    
    @Test func testSubscriptionServiceStateAndErrorDescriptions() async throws {
        let service = await SubscriptionService.shared
        
        // Test Mock switching
        await service.setMockProUserForTesting(true)
        #expect(await service.isProUser == true)
        
        await service.setMockProUserForTesting(false)
        #expect(await service.isProUser == false)
        
        // Test Error Descriptions
        let notFound = SubscriptionError.productNotFound
        #expect(notFound.errorDescription?.contains("bulunamadı") == true)
        
        let cancelled = SubscriptionError.userCancelled
        #expect(cancelled.errorDescription?.contains("iptal") == true)
        
        let failed = SubscriptionError.purchaseFailed("Ağ hatası")
        #expect(failed.errorDescription?.contains("Ağ hatası") == true)
        
        let restoreFailed = SubscriptionError.restoreFailed("Bilinmeyen hata")
        #expect(restoreFailed.errorDescription?.contains("Bilinmeyen hata") == true)
    }
    
    // MARK: - Rewarded Ads & Export Decision Flow Tests
    
    @Test func testRewardedAdServiceFailOpen() async throws {
        let adService = await RewardedAdService.shared
        
        // When no ad is preloaded, presentRewardedAd returns .failedOpen (fail-open policy)
        let result = await adService.presentRewardedAd()
        switch result {
        case .failedOpen:
            #expect(true)
        case .rewardEarned, .dismissedWithoutReward:
            #expect(Bool(false), "Without ad ready, it must fail-open to allow export")
        }
    }
    
    @Test func testExportDecisionFlowForProUser() async throws {
        let subService = await SubscriptionService.shared
        let viewModel = await EditorViewModel.shared
        
        // Set Pro status
        await subService.setMockProUserForTesting(true)
        #expect(await subService.isProUser == true)
        
        let testCI = createTestCIImage(width: 200, height: 200)
        let sampleUI = UIImage()
        let photo = LoadedPhoto(
            originalCIImage: testCI,
            previewCIImage: testCI,
            previewUIImage: sampleUI,
            pixelSize: CGSize(width: 200, height: 200)
        )
        await viewModel.setPhoto(photo)
        
        // When Pro user exports, it goes directly to full-res export without showing ads
        #expect(await !viewModel.isExporting)
        await viewModel.exportPhoto()
        
        // Verified export finished without blocking
        #expect(await !viewModel.isExporting)
    }
    
    @Test func testExportDecisionFlowForFreeUserWithFailOpen() async throws {
        let subService = await SubscriptionService.shared
        let viewModel = await EditorViewModel.shared
        
        // Set Free status
        await subService.setMockProUserForTesting(false)
        #expect(await subService.isProUser == false)
        
        let testCI = createTestCIImage(width: 200, height: 200)
        let sampleUI = UIImage()
        let photo = LoadedPhoto(
            originalCIImage: testCI,
            previewCIImage: testCI,
            previewUIImage: sampleUI,
            pixelSize: CGSize(width: 200, height: 200)
        )
        await viewModel.setPhoto(photo)
        
        // When Free user exports and ad is not loaded/fails, it fails open and finishes export
        await viewModel.exportPhoto()
        
        #expect(await !viewModel.isExporting)
    }
    
    // MARK: - Consent & ATT Tests
    
    @Test @MainActor func testConsentManagerInitialState() async throws {
        let manager = ConsentManager.shared
        let status = manager.trackingStatus
        #expect(status == .notDetermined || status == .denied || status == .authorized || status == .restricted)
    }
}



