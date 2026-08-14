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
    
    public let authService: AuthServiceProtocol
    public let imageProcessingService: ImageProcessingServiceProtocol
    public let photoLibraryService: PhotoLibraryServiceProtocol
    
    public init(
        authService: AuthServiceProtocol? = nil,
        imageProcessingService: ImageProcessingServiceProtocol? = nil,
        photoLibraryService: PhotoLibraryServiceProtocol? = nil
    ) {
        self.authService = authService ?? AuthService.shared
        self.imageProcessingService = imageProcessingService ?? ImageProcessingService.shared
        self.photoLibraryService = photoLibraryService ?? PhotoLibraryService.shared
    }
}
