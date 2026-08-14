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
        case .light: return "sun.max.fill"
        case .color: return "paintpalette.fill"
        case .cinematic: return "film.fill"
        case .mono: return "circle.lefthalf.filled"
        }
    }
}

/// Central view model driving the interactive Core Image preview, undo/redo history, and export pipeline.
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
    
    // Export Status
    public var isExporting: Bool = false
    public var exportSuccessMessage: String?
    public var exportErrorMessage: String?
    
    // Undo / Redo History Stacks
    private var undoStack: [PhotoEditState] = []
    private var redoStack: [PhotoEditState] = []
    private let maxHistoryDepth: Int = 30
    
    public var canUndo: Bool { !undoStack.isEmpty }
    public var canRedo: Bool { !redoStack.isEmpty }
    
    private let processingService: ImageProcessingServiceProtocol
    private let photoLibraryService: PhotoLibraryServiceProtocol
    private var renderTask: Task<Void, Never>?
    
    public init(
        processingService: ImageProcessingServiceProtocol = ImageProcessingService.shared,
        photoLibraryService: PhotoLibraryServiceProtocol = PhotoLibraryService.shared
    ) {
        self.processingService = processingService
        self.photoLibraryService = photoLibraryService
    }
    
    // MARK: - Photo Loading
    
    public func setPhoto(_ photo: LoadedPhoto) {
        self.loadedPhoto = photo
        self.editState = .identity
        self.renderedPreview = photo.previewUIImage
        self.activeCategory = .light
        self.isComparingOriginal = false
        self.undoStack.removeAll()
        self.redoStack.removeAll()
        self.exportSuccessMessage = nil
        self.exportErrorMessage = nil
    }
    
    // MARK: - History Snapshot (Undo / Redo)
    
    /// Records the current state into the undo stack before applying a new adjustment.
    public func recordHistorySnapshot() {
        if undoStack.last != editState {
            undoStack.append(editState)
            if undoStack.count > maxHistoryDepth {
                undoStack.removeFirst()
            }
            redoStack.removeAll()
        }
    }
    
    public func undo() {
        guard let previousState = undoStack.popLast() else { return }
        redoStack.append(editState)
        self.editState = previousState
        triggerRender()
    }
    
    public func redo() {
        guard let nextState = redoStack.popLast() else { return }
        undoStack.append(editState)
        self.editState = nextState
        triggerRender()
    }
    
    // MARK: - State Adjustments & Realtime Render
    
    public func updateStateDirectly(_ modifier: (inout PhotoEditState) -> Void) {
        modifier(&editState)
        triggerRender()
    }
    
    public func applyPresetUpdate(action: () -> Void) {
        recordHistorySnapshot()
        action()
        triggerRender()
    }
    
    public func resetState() {
        guard isEdited else { return }
        recordHistorySnapshot()
        editState.reset()
        if let loadedPhoto {
            renderedPreview = loadedPhoto.previewUIImage
        }
    }
    
    /// Triggers an asynchronous Core Image render pass on the downsampled preview CIImage.
    public func triggerRender() {
        guard let photo = loadedPhoto else { return }
        
        isRendering = true
        renderTask?.cancel()
        renderTask = Task.detached(priority: .userInitiated) { [processingService, state = self.editState, previewCI = photo.previewCIImage] in
            let result = processingService.renderPreview(from: previewCI, state: state)
            
            await MainActor.run {
                if !Task.isCancelled {
                    self.renderedPreview = result
                    self.isRendering = false
                }
            }
        }
    }
    
    // MARK: - Full Resolution Export Pipeline (Phase 9)
    
    public func exportPhoto() async {
        guard let photo = loadedPhoto else { return }
        guard !isExporting else { return }
        
        isExporting = true
        exportErrorMessage = nil
        exportSuccessMessage = nil
        
        do {
            // Render on original full-resolution CIImage
            guard let fullResCG = processingService.renderFullResolution(from: photo.originalCIImage, state: editState) else {
                throw PhotoLibraryError.saveFailed("Final render üretilemedi.")
            }
            
            // Save as new photo asset without overwriting
            try await photoLibraryService.savePhotoToLibrary(renderedCGImage: fullResCG)
            
            self.exportSuccessMessage = "Fotoğraf galerinize başarıyla kaydedildi."
            
            // Auto-clear success message after delay
            Task {
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                if self.exportSuccessMessage != nil {
                    self.exportSuccessMessage = nil
                }
            }
        } catch {
            self.exportErrorMessage = error.localizedDescription
        }
        
        isExporting = false
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
