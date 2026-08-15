//
//  EditorViewModel.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import SwiftUI
import CoreImage
import Vision

/// Available adjustment tool categories in Photon Editor.
public enum EditorToolCategory: String, CaseIterable, Identifiable, Sendable {
    case light = "Işık"
    case color = "Renk"
    case portrait = "Cilt"
    case cinematic = "Sinematik"
    case mono = "Siyah & Beyaz"
    
    public var id: String { rawValue }
    
    public var systemIcon: String {
        switch self {
        case .light: return "sun.max.fill"
        case .color: return "paintpalette.fill"
        case .portrait: return "face.smiling"
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
    
    // Vision Face Detection Cache
    public private(set) var detectedFaces: [VNFaceObservation] = []
    public private(set) var isDetectingFaces: Bool = false
    private var previewSkinMask: CIImage?
    
    // Undo / Redo History Stacks
    private var undoStack: [PhotoEditState] = []
    private var redoStack: [PhotoEditState] = []
    private let maxHistoryDepth: Int = 30
    
    public var canUndo: Bool { !undoStack.isEmpty }
    public var canRedo: Bool { !redoStack.isEmpty }
    
    private let processingService: ImageProcessingServiceProtocol
    private let photoLibraryService: PhotoLibraryServiceProtocol
    private let faceDetectionService: FaceDetectionServiceProtocol
    private var renderTask: Task<Void, Never>?
    
    public init(
        processingService: ImageProcessingServiceProtocol = ImageProcessingService.shared,
        photoLibraryService: PhotoLibraryServiceProtocol = PhotoLibraryService.shared,
        faceDetectionService: FaceDetectionServiceProtocol = FaceDetectionService.shared
    ) {
        self.processingService = processingService
        self.photoLibraryService = photoLibraryService
        self.faceDetectionService = faceDetectionService
    }
    
    // MARK: - Photo Binding
    
    public func setPhoto(_ photo: LoadedPhoto) {
        self.loadedPhoto = photo
        self.editState = .identity
        self.renderedPreview = photo.previewUIImage
        self.undoStack.removeAll()
        self.redoStack.removeAll()
        self.exportSuccessMessage = nil
        self.exportErrorMessage = nil
        self.activeCategory = .light
        self.detectedFaces.removeAll()
        self.previewSkinMask = nil
        self.isDetectingFaces = true
        
        // Asynchronously perform face detection once per photo load
        Task { [faceDetectionService] in
            let faces = await faceDetectionService.detectFaces(in: photo.previewCIImage)
            await MainActor.run {
                self.detectedFaces = faces
                self.isDetectingFaces = false
                if !faces.isEmpty {
                    self.previewSkinMask = self.faceDetectionService.generateSkinMask(
                        targetExtent: photo.previewCIImage.extent,
                        faces: faces
                    )
                    if self.editState.skinSmoothing > 0 {
                        self.requestPreviewRender()
                    }
                }
            }
        }
    }
    
    // MARK: - History Snapshot (Undo / Redo Management)
    
    public func recordHistorySnapshot() {
        undoStack.append(editState)
        if undoStack.count > maxHistoryDepth {
            undoStack.removeFirst()
        }
        redoStack.removeAll()
    }
    
    public func undo() {
        guard let previousState = undoStack.popLast() else { return }
        redoStack.append(editState)
        self.editState = previousState
        requestPreviewRender()
    }
    
    public func redo() {
        guard let nextState = redoStack.popLast() else { return }
        undoStack.append(editState)
        self.editState = nextState
        requestPreviewRender()
    }
    
    public func resetState() {
        guard editState.isEdited else { return }
        recordHistorySnapshot()
        self.editState = .identity
        requestPreviewRender()
    }
    
    // MARK: - State Mutators
    
    public func updateStateDirectly(_ mutate: (inout PhotoEditState) -> Void) {
        mutate(&editState)
        requestPreviewRender()
    }
    
    public func applyPresetUpdate(_ mutate: () -> Void) {
        recordHistorySnapshot()
        mutate()
        requestPreviewRender()
    }
    
    // MARK: - Asynchronous Metal / Core Image Preview Render
    
    public func requestPreviewRender() {
        guard let photo = loadedPhoto else { return }
        
        renderTask?.cancel()
        isRendering = true
        
        let targetState = self.editState
        let previewCI = photo.previewCIImage
        let skinMask = self.previewSkinMask
        
        renderTask = Task.detached(priority: .userInitiated) { [processingService] in
            let processedImage = processingService.renderPreview(from: previewCI, state: targetState, skinMask: skinMask)
            
            guard !Task.isCancelled else { return }
            
            await MainActor.run {
                self.renderedPreview = processedImage
                self.isRendering = false
            }
        }
    }
    
    // MARK: - Full Resolution Non-Destructive Export
    
    public func exportPhoto() async {
        guard let photo = loadedPhoto else { return }
        guard !isExporting else { return }
        
        isExporting = true
        exportErrorMessage = nil
        exportSuccessMessage = nil
        
        do {
            // Generate full-resolution skin mask if faces were detected
            let fullResSkinMask: CIImage?
            if !detectedFaces.isEmpty {
                fullResSkinMask = faceDetectionService.generateSkinMask(
                    targetExtent: photo.originalCIImage.extent,
                    faces: detectedFaces
                )
            } else {
                fullResSkinMask = nil
            }
            
            // Render on original full-resolution CIImage
            guard let fullResCG = processingService.renderFullResolution(from: photo.originalCIImage, state: editState, skinMask: fullResSkinMask) else {
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
