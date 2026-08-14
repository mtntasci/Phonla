//
//  PhotoLibraryService.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import SwiftUI
import PhotosUI
import CoreImage

/// Contract for loading and preparing local photos from native PhotosUI.
public protocol PhotoLibraryServiceProtocol: Sendable {
    func loadPhoto(from item: PhotosPickerItem) async throws -> LoadedPhoto
}

public enum PhotoLoadError: LocalizedError, Sendable {
    case dataLoadingFailed
    case invalidImageFormat
    case downsamplingFailed
    
    public var errorDescription: String? {
        switch self {
        case .dataLoadingFailed:
            return "Fotoğraf verisi galeriden okunamadı."
        case .invalidImageFormat:
            return "Desteklenmeyen veya bozuk görsel formatı."
        case .downsamplingFailed:
            return "Önizleme görseli oluşturulamadı."
        }
    }
}

/// Native service handling photo selection, orientation normalization, and preview pipeline initialization.
public final class PhotoLibraryService: PhotoLibraryServiceProtocol, @unchecked Sendable {
    public static let shared = PhotoLibraryService()
    
    private let processingService = ImageProcessingService.shared
    
    public init() {}
    
    public func loadPhoto(from item: PhotosPickerItem) async throws -> LoadedPhoto {
        guard let data = try await item.loadTransferable(type: Data.self) else {
            throw PhotoLoadError.dataLoadingFailed
        }
        
        guard let uiImage = UIImage(data: data) else {
            throw PhotoLoadError.invalidImageFormat
        }
        
        // Ensure proper EXIF orientation
        guard let sourceCI = CIImage(image: uiImage) else {
            throw PhotoLoadError.invalidImageFormat
        }
        
        let orientedCI = sourceCI.oriented(forExifOrientation: Int32(uiImage.imageOrientation.cgOrientationRawValue))
        
        guard let (previewCI, previewUI) = processingService.generatePreview(from: orientedCI) else {
            throw PhotoLoadError.downsamplingFailed
        }
        
        return LoadedPhoto(
            originalCIImage: orientedCI,
            previewCIImage: previewCI,
            previewUIImage: previewUI,
            pixelSize: orientedCI.extent.size
        )
    }
}

// MARK: - UIImage.Orientation to CGImagePropertyOrientation Helper

private extension UIImage.Orientation {
    var cgOrientationRawValue: UInt32 {
        switch self {
        case .up: return 1
        case .down: return 3
        case .left: return 8
        case .right: return 6
        case .upMirrored: return 2
        case .downMirrored: return 4
        case .leftMirrored: return 5
        case .rightMirrored: return 7
        @unknown default: return 1
        }
    }
}
