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
        authService: AuthServiceProtocol = AuthService.shared,
        imageProcessingService: ImageProcessingServiceProtocol = ImageProcessingService.shared,
        photoLibraryService: PhotoLibraryServiceProtocol = PhotoLibraryService.shared
    ) {
        self.authService = authService
        self.imageProcessingService = imageProcessingService
        self.photoLibraryService = photoLibraryService
    }
}
