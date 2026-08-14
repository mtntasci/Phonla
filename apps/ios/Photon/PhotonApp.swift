//
//  PhotonApp.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import SwiftUI
import FirebaseCore

@main
struct PhotonApp: App {
    @State private var navigationState = NavigationState()
    
    init() {
        // Initialize Firebase with GoogleService-Info.plist
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
    }

    var body: some Scene {
        WindowGroup {
            RootCoordinatorView()
                .environment(navigationState)
                .preferredColorScheme(.light)
        }
    }
}
