//
//  PhotonApp.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import SwiftUI
import FirebaseCore

/// Application delegate guaranteeing Firebase initialization at the earliest possible lifecycle event.
final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        if FirebaseApp.app() == nil {
            if let plistPath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
               let options = FirebaseOptions(contentsOfFile: plistPath) {
                FirebaseApp.configure(options: options)
            } else {
                FirebaseApp.configure()
            }
        }
        return true
    }
}

@main
struct PhotonApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var navigationState = NavigationState()

    var body: some Scene {
        WindowGroup {
            RootCoordinatorView()
                .environment(navigationState)
                .preferredColorScheme(.light)
        }
    }
}
