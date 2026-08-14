//
//  PhotonApp.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import SwiftUI

@main
struct PhotonApp: App {
    @State private var navigationState = NavigationState()

    var body: some Scene {
        WindowGroup {
            RootCoordinatorView()
                .environment(navigationState)
                .preferredColorScheme(.light)
        }
    }
}
