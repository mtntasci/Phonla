//
//  ContentView.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import SwiftUI

/// Main content root forwarding to RootCoordinatorView.
public struct ContentView: View {
    @State private var navigationState = NavigationState()
    
    public init() {}
    
    public var body: some View {
        RootCoordinatorView()
            .environment(navigationState)
            .preferredColorScheme(.light)
    }
}

#Preview {
    ContentView()
}
