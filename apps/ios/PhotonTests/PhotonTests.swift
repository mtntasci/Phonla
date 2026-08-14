//
//  PhotonTests.swift
//  PhotonTests
//
//  Created by Metin TASCI on 14.08.2026.
//

import Foundation
import CoreGraphics
import Testing
@testable import Photon

struct PhotonTests {

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
    
    @Test func testUserSessionModel() async throws {
        let session = UserSession(uid: "test_user_123", email: "test@example.com", displayName: "Photon User", isAnonymous: false)
        #expect(session.uid == "test_user_123")
        #expect(session.email == "test@example.com")
        #expect(session.displayName == "Photon User")
        #expect(!session.isAnonymous)
    }
}
