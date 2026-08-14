//
//  RootCoordinatorView.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import SwiftUI

/// Root view observing `NavigationState` and rendering the active flow.
public struct RootCoordinatorView: View {
    @Environment(NavigationState.self) private var navigationState
    
    public init() {}
    
    public var body: some View {
        Group {
            switch navigationState.currentRoot {
            case .splash:
                SplashView()
            case .auth:
                AuthPlaceholderView()
            case .home:
                HomePlaceholderView()
            case .editor:
                EditorPlaceholderView()
            case .settings:
                SettingsPlaceholderView()
            }
        }
        .animation(.easeInOut(duration: 0.25), value: navigationState.currentRoot)
    }
}

#Preview {
    RootCoordinatorView()
        .environment(NavigationState())
}
