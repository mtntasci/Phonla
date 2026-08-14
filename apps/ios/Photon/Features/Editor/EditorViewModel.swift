//
//  EditorViewModel.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import SwiftUI
import CoreImage

/// Available adjustment tool categories in Photon Editor.
public enum EditorToolCategory: String, CaseIterable, Identifiable, Sendable {
    case light = "Light"
    case color = "Color"
    case cinematic = "Cinematic"
    case mono = "Mono"
    
    public var id: String { rawValue }
    
    public var systemIcon: String {
        switch self {
        case .light: return "sun.max"
        case .color: return "paintpalette"
        case .cinematic: return "film"
        case .mono: return "circle.lefthalf.filled"
        }
    }
}

/// Central view model driving the interactive Core Image preview and tool state.
@MainActor
@Observable
public final class EditorViewModel {
    public static let shared = EditorViewModel()
    
    public var loadedPhoto: LoadedPhoto?
    public var editState: PhotoEditState = .identity
    public var renderedPreview: UIImage?
    public var isRendering: Bool = false
    public var activeCategory: EditorToolCategory = .light
    public var isComparingOriginal: Bool = false
    public var exportSuccessMessage: String?
    
    private let processingService: ImageProcessingServiceProtocol
    private var renderTask: Task<Void, Never>?
    
    public init(processingService: ImageProcessingServiceProtocol = ImageProcessingService.shared) {
        self.processingService = processingService
    }
    
    // MARK: - Photo Loading
    
    public func setPhoto(_ photo: LoadedPhoto) {
        self.loadedPhoto = photo
        self.editState = .identity
        self.renderedPreview = photo.previewUIImage
        self.activeCategory = .light
        self.isComparingOriginal = false
    }
    
    // MARK: - State Adjustments & Realtime Render
    
    public func updateState(_ modifier: (inout PhotoEditState) -> Void) {
        modifier(&editState)
        triggerRender()
    }
    
    public func resetState() {
        editState.reset()
        if let loadedPhoto {
            renderedPreview = loadedPhoto.previewUIImage
        }
    }
    
    /// Triggers an asynchronous Core Image render pass on the downsampled preview CIImage.
    public func triggerRender() {
        guard let photo = loadedPhoto else { return }
        
        renderTask?.cancel()
        renderTask = Task.detached(priority: .userInitiated) { [processingService, state = self.editState, previewCI = photo.previewCIImage] in
            let result = processingService.renderPreview(from: previewCI, state: state)
            
            await MainActor.run {
                if !Task.isCancelled {
                    self.renderedPreview = result
                }
            }
        }
    }
    
    // MARK: - Display Image Resolver
    
    public var currentDisplayImage: UIImage? {
        if isComparingOriginal {
            return loadedPhoto?.previewUIImage
        }
        return renderedPreview ?? loadedPhoto?.previewUIImage
    }
    
    public var isEdited: Bool {
        editState.isEdited
    }
}
