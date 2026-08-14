//
//  ServiceContainer.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import Foundation

/// Dependency injection and service registry for Photon services.
@MainActor
public final class ServiceContainer {
    public static let shared = ServiceContainer()
    
    private init() {}
    
    // Future service instances (AuthService, RenderEngine, PhotoLibraryService)
    // will be lazily registered and accessed from here.
}
