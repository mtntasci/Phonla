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
        
        // Sign out to clean state
        try await auth.signOut()
        #expect(await !auth.isAuthenticated)
        
        // Sign In with Apple
        let appleSession = try await auth.signIn(with: .apple)
        #expect(appleSession.uid.contains("apple"))
        #expect(await auth.isAuthenticated)
        #expect(await auth.currentSession?.uid == appleSession.uid)
        
        // Sign Out
        try await auth.signOut()
        #expect(await !auth.isAuthenticated)
        #expect(await auth.currentSession == nil)
    }
    
    // MARK: - PhotoEditState Tests
    
    @Test func testPhotoEditStateMutationAndReset() async throws {
        var state = PhotoEditState.identity
        #expect(!state.isEdited)
        #expect(state.exposure == 0.0)
        #expect(state.temperature == 6500.0)
        #expect(state.contrast == 1.0)
        #expect(state.saturation == 1.0)
        #expect(!state.isMonoActive)
        
        // Mutate light & color
        state.exposure = 0.75
        state.contrast = 1.2
        state.temperature = 7200.0
        #expect(state.isEdited)
        
        // Reset
        state.reset()
        #expect(!state.isEdited)
        #expect(state == PhotoEditState.identity)
    }
    
    // MARK: - Core Image Pipeline Tests
    
    @Test func testImageProcessingPipeline() async throws {
        let processing = ImageProcessingService.shared
        
        // Create a 100x100 solid test CIImage
        let color = CIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        guard let testCI = CIFilter(name: "CIConstantColorGenerator", parameters: [kCIInputColorKey: color])?.outputImage?.cropped(to: CGRect(x: 0, y: 0, width: 100, height: 100)) else {
            Issue.record("Failed to create test CIImage")
            return
        }
        
        var state = PhotoEditState()
        state.exposure = 0.5
        state.contrast = 1.1
        state.saturation = 1.2
        
        let outputCI = processing.processImage(testCI, state: state)
        #expect(outputCI.extent.size.width == 100)
        #expect(outputCI.extent.size.height == 100)
        
        // Render preview UIImage
        let previewUI = processing.renderPreview(from: testCI, state: state)
        #expect(previewUI != nil)
        
        // Render full res CGImage
        let fullResCG = processing.renderFullResolution(from: testCI, state: state)
        #expect(fullResCG != nil)
        #expect(fullResCG?.width == 100)
        #expect(fullResCG?.height == 100)
    }
    
    // MARK: - Editor ViewModel Tests
    
    @Test func testEditorViewModelStateHandling() async throws {
        let viewModel = await EditorViewModel.shared
        
        // Create dummy loaded photo
        let color = CIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
        guard let sampleCI = CIFilter(name: "CIConstantColorGenerator", parameters: [kCIInputColorKey: color])?.outputImage?.cropped(to: CGRect(x: 0, y: 0, width: 200, height: 200)) else {
            Issue.record("Failed to create sample CIImage")
            return
        }
        
        guard let cg = ImageProcessingService.shared.renderFullResolution(from: sampleCI, state: .identity) else {
            Issue.record("Failed to render CGImage")
            return
        }
        let sampleUI = UIImage(cgImage: cg)
        
        let photo = LoadedPhoto(
            originalCIImage: sampleCI,
            previewCIImage: sampleCI,
            previewUIImage: sampleUI,
            pixelSize: CGSize(width: 200, height: 200)
        )
        
        await viewModel.setPhoto(photo)
        #expect(await viewModel.loadedPhoto?.id == photo.id)
        #expect(await !viewModel.isEdited)
        
        await viewModel.updateState { state in
            state.exposure = 1.0
        }
        #expect(await viewModel.isEdited)
        
        await viewModel.resetState()
        #expect(await !viewModel.isEdited)
    }
}
