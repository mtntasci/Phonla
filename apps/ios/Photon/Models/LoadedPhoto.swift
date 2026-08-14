//
//  LoadedPhoto.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import SwiftUI
import CoreImage

/// In-memory representation of a photo loaded for non-destructive editing.
public struct LoadedPhoto: Identifiable, @unchecked Sendable {
    public let id: UUID
    public let originalCIImage: CIImage
    public let previewCIImage: CIImage
    public let previewUIImage: UIImage
    public let pixelSize: CGSize
    public let aspectRatio: CGFloat
    
    public init(
        id: UUID = UUID(),
        originalCIImage: CIImage,
        previewCIImage: CIImage,
        previewUIImage: UIImage,
        pixelSize: CGSize
    ) {
        self.id = id
        self.originalCIImage = originalCIImage
        self.previewCIImage = previewCIImage
        self.previewUIImage = previewUIImage
        self.pixelSize = pixelSize
        self.aspectRatio = pixelSize.height > 0 ? (pixelSize.width / pixelSize.height) : 1.0
    }
}
