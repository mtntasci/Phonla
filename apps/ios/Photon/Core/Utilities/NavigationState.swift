//
//  NavigationState.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import SwiftUI

/// Core application routes matching the product flow: Splash -> Auth -> Home -> Editor.
public enum AppRoute: Hashable, Identifiable {
    case splash
    case auth
    case home
    case editor
    case settings
    
    public var id: String {
        switch self {
        case .splash: return "splash"
        case .auth: return "auth"
        case .home: return "home"
        case .editor: return "editor"
        case .settings: return "settings"
        }
    }
}

/// Central navigation coordinator state managing root transitions and navigation stacks.
@MainActor
@Observable
public final class NavigationState {
    /// Active root destination (Splash, Auth, Home, Editor)
    public var currentRoot: AppRoute = .splash
    
    /// Secondary navigation path for pushed subviews
    public var path = NavigationPath()
    
    public init() {}
    
    // MARK: - Navigation Transitions
    
    public func navigateToAuth() {
        withAnimation(.easeInOut(duration: 0.25)) {
            self.currentRoot = .auth
        }
    }
    
    public func navigateToHome() {
        withAnimation(.easeInOut(duration: 0.25)) {
            self.currentRoot = .home
        }
    }
    
    public func navigateToEditor() {
        withAnimation(.easeInOut(duration: 0.25)) {
            self.currentRoot = .editor
        }
    }
    
    public func navigateToSettings() {
        withAnimation(.easeInOut(duration: 0.25)) {
            self.currentRoot = .settings
        }
    }
    
    public func resetToSplash() {
        withAnimation(.easeInOut(duration: 0.25)) {
            self.currentRoot = .splash
            self.path = NavigationPath()
        }
    }
}
