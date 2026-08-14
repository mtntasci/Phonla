//
//  PhotoLibraryService.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import SwiftUI
import PhotosUI
import CoreImage

/// Contract for loading and saving local photos from/to native PhotosUI & Photo Library.
public protocol PhotoLibraryServiceProtocol: Sendable {
    func loadPhoto(from item: PhotosPickerItem) async throws -> LoadedPhoto
    func savePhotoToLibrary(renderedCGImage: CGImage) async throws
}

public enum PhotoLibraryError: LocalizedError, Sendable {
    case dataLoadingFailed
    case invalidImageFormat
    case downsamplingFailed
    case permissionDenied
    case saveFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .dataLoadingFailed:
            return "Fotoğraf verisi galeriden okunamadı."
        case .invalidImageFormat:
            return "Desteklenmeyen veya bozuk görsel formatı."
        case .downsamplingFailed:
            return "Önizleme görseli oluşturulamadı."
        case .permissionDenied:
            return "Fotoğrafı kaydetmek için galeri izni gereklidir. Lütfen Ayarlar'dan izin verin."
        case .saveFailed(let message):
            return "Fotoğraf kaydedilemedi: \(message)"
        }
    }
}

/// Native service handling photo selection, orientation normalization, preview pipeline initialization,
/// and safe full-resolution non-destructive export.
public final class PhotoLibraryService: PhotoLibraryServiceProtocol, @unchecked Sendable {
    public static let shared = PhotoLibraryService()
    
    private let processingService = ImageProcessingService.shared
    
    public init() {}
    
    // MARK: - Load Photo
    
    public func loadPhoto(from item: PhotosPickerItem) async throws -> LoadedPhoto {
        guard let data = try await item.loadTransferable(type: Data.self) else {
            throw PhotoLibraryError.dataLoadingFailed
        }
        
        guard let uiImage = UIImage(data: data) else {
            throw PhotoLibraryError.invalidImageFormat
        }
        
        // Ensure proper EXIF orientation
        guard let sourceCI = CIImage(image: uiImage) else {
            throw PhotoLibraryError.invalidImageFormat
        }
        
        let orientedCI = sourceCI.oriented(forExifOrientation: Int32(uiImage.imageOrientation.cgOrientationRawValue))
        
        guard let (previewCI, previewUI) = processingService.generatePreview(from: orientedCI) else {
            throw PhotoLibraryError.downsamplingFailed
        }
        
        return LoadedPhoto(
            originalCIImage: orientedCI,
            previewCIImage: previewCI,
            previewUIImage: previewUI,
            pixelSize: orientedCI.extent.size
        )
    }
    
    // MARK: - Save Photo (Phase 9 Non-Destructive Export)
    
    public func savePhotoToLibrary(renderedCGImage: CGImage) async throws {
        // Request Add-Only authorization if required
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        guard status == .authorized || status == .limited else {
            throw PhotoLibraryError.permissionDenied
        }
        
        let finalUIImage = UIImage(cgImage: renderedCGImage)
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            PHPhotoLibrary.shared().performChanges({
                PHAssetCreationRequest.creationRequestForAsset(from: finalUIImage)
            }) { success, error in
                if success {
                    continuation.resume()
                } else {
                    let err = error ?? NSError(domain: "Photon", code: -1, userInfo: [NSLocalizedDescriptionKey: "Bilinmeyen bir hata oluştu."])
                    continuation.resume(throwing: PhotoLibraryError.saveFailed(err.localizedDescription))
                }
            }
        }
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
