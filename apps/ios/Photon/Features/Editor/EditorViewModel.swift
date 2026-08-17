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

/// Sub-tools under Light category
public enum LightSubTool: String, CaseIterable, Identifiable, Sendable {
    case exposure = "Pozlama"
    case brightness = "Parlaklık"
    case contrast = "Kontrast"
    case highlights = "Açık Ton"
    case shadows = "Gölgeler"
    
    public var id: String { rawValue }
    
    public var systemIcon: String {
        switch self {
        case .exposure: return "plusminus.circle"
        case .brightness: return "sun.min.fill"
        case .contrast: return "circle.righthalf.filled"
        case .highlights: return "sun.and.horizon.fill"
        case .shadows: return "moon.fill"
        }
    }
}

/// Sub-tools under Color category
public enum ColorSubTool: String, CaseIterable, Identifiable, Sendable {
    case temperature = "Sıcaklık"
    case tint = "Ton"
    case saturation = "Doygunluk"
    case vibrance = "Canlılık"
    
    public var id: String { rawValue }
    
    public var systemIcon: String {
        switch self {
        case .temperature: return "thermometer.sun.fill"
        case .tint: return "paintpalette.fill"
        case .saturation: return "drop.fill"
        case .vibrance: return "sparkles"
        }
    }
}

/// Sub-tools under Portrait (Cilt) category
public enum PortraitSubTool: String, CaseIterable, Identifiable, Sendable {
    case smoothing = "Sihirbaz"
    case healing = "Leke Silme"
    
    public var id: String { rawValue }
    
    public var systemIcon: String {
        switch self {
        case .smoothing: return "wand.and.stars"
        case .healing: return "bandage.fill"
        }
    }
}

/// Retouch presets under Sihirbaz (Doğal vs İpeksi)
public enum WizardRetouchMode: String, CaseIterable, Identifiable, Sendable {
    case natural = "Doğal"
    case silky = "İpeksi"
    
    public var id: String { rawValue }
    
    public var intensity: Float {
        switch self {
        case .natural: return 40.0
        case .silky: return 80.0
        }
    }
    
    public var systemIcon: String {
        switch self {
        case .natural: return "leaf.fill"
        case .silky: return "sparkles"
        }
    }
}

/// Preset brush sizes for Spot Healing (Leke Silme)
public enum HealingBrushPreset: String, CaseIterable, Identifiable, Sendable {
    case small = "Küçük"
    case medium = "Orta"
    case large = "Büyük"
    
    public var id: String { rawValue }
    
    public var radius: Float {
        switch self {
        case .small: return 0.012
        case .medium: return 0.022
        case .large: return 0.038
        }
    }
    
    public var iconSize: CGFloat {
        switch self {
        case .small: return 8
        case .medium: return 13
        case .large: return 18
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
    
    // Sub-tool selections
    public var selectedLightSubTool: LightSubTool = .exposure
    public var selectedColorSubTool: ColorSubTool = .temperature
    public var selectedPortraitSubTool: PortraitSubTool = .smoothing
    
    // Sihirbaz (Wizard) & Face Scan State
    public var isWizardScanning: Bool = false
    public var isWizardActive: Bool = false
    public var selectedWizardMode: WizardRetouchMode = .natural
    
    // Skin Mask Overlay (Translucent Cyan Visual Feedback)
    public var isShowingSkinMaskOverlay: Bool = false
    public private(set) var visualSkinMaskImage: UIImage? = nil
    
    // Spot Healing & Loupe Magnifier Parameters
    public var selectedBrushPreset: HealingBrushPreset = .medium {
        didSet {
            healingBrushRadius = selectedBrushPreset.radius
        }
    }
    public var isBrushArmed: Bool = true
    public var healingBrushRadius: Float = 0.022
    public var lastHealedSpotPoint: CGPoint? = nil
    
    // Live Loupe / Magnifier Interactive State
    public var isLoupeActive: Bool = false
    public var loupeTouchPoint: CGPoint = .zero
    public var loupeNormalizedPoint: CGPoint = .zero
    public var lastHealedRipplePoint: CGPoint? = nil
    public var isShowingRipple: Bool = false
    
    // Export Status
    public var isExporting: Bool = false
    public var exportSuccessMessage: String?
    public var exportErrorMessage: String?
    
    // Vision Face Detection Cache
    public private(set) var detectedFaces: [VNFaceObservation] = []
    public private(set) var isDetectingFaces: Bool = false
    private var previewSkinMask: CIImage?
    
    // Disk-Backed Temp Checkpoints & History Tracking
    private var activeSessionId: String?
    private var editActionCounter: Int = 0
    private let checkpointInterval: Int = 3
    
    // Undo / Redo History Stacks
    private var undoStack: [PhotoEditState] = []
    private var redoStack: [PhotoEditState] = []
    private let maxHistoryDepth: Int = 30
    
    public var canUndo: Bool { !undoStack.isEmpty }
    public var canRedo: Bool { !redoStack.isEmpty }
    
    private let processingService: ImageProcessingServiceProtocol
    private let photoLibraryService: PhotoLibraryServiceProtocol
    private let faceDetectionService: FaceDetectionServiceProtocol
    private let diskCacheService: TempDiskCacheServiceProtocol
    private var renderTask: Task<Void, Never>?
    
    public init(
        processingService: ImageProcessingServiceProtocol = ImageProcessingService.shared,
        photoLibraryService: PhotoLibraryServiceProtocol = PhotoLibraryService.shared,
        faceDetectionService: FaceDetectionServiceProtocol = FaceDetectionService.shared,
        diskCacheService: TempDiskCacheServiceProtocol = TempDiskCacheService.shared
    ) {
        self.processingService = processingService
        self.photoLibraryService = photoLibraryService
        self.faceDetectionService = faceDetectionService
        self.diskCacheService = diskCacheService
    }
    
    // MARK: - Photo Binding & Session Lifecycle
    
    public func setPhoto(_ photo: LoadedPhoto) {
        // Cleanup old session if any
        if let oldSession = activeSessionId {
            diskCacheService.cleanupSession(sessionId: oldSession)
        }
        
        let newSession = diskCacheService.startNewSession()
        self.activeSessionId = newSession
        self.editActionCounter = 0
        
        self.loadedPhoto = photo
        self.editState = .identity
        self.renderedPreview = photo.previewUIImage
        self.undoStack.removeAll()
        self.redoStack.removeAll()
        self.exportSuccessMessage = nil
        self.exportErrorMessage = nil
        self.activeCategory = .light
        self.selectedPortraitSubTool = .smoothing
        self.isWizardScanning = false
        self.isWizardActive = false
        self.selectedWizardMode = .natural
        self.isShowingSkinMaskOverlay = false
        self.visualSkinMaskImage = nil
        self.detectedFaces.removeAll()
        self.previewSkinMask = nil
        self.isDetectingFaces = true
        
        // Cache original preview image to disk asynchronously
        Task { [diskCacheService] in
            _ = await diskCacheService.saveOriginalPreview(image: photo.previewUIImage, sessionId: newSession)
        }
        
        // Asynchronously perform face detection once per photo load with EXIF orientation awareness
        Task { [faceDetectionService] in
            let orientation = CGImagePropertyOrientation(photo.previewUIImage.imageOrientation)
            let faces = await faceDetectionService.detectFaces(in: photo.previewCIImage, orientation: orientation)
            let skinMaskCI = !faces.isEmpty ? faceDetectionService.generateSkinMask(
                for: photo.previewCIImage,
                orientation: orientation
            ) : nil
            let visualMask = !faces.isEmpty ? faceDetectionService.generateVisualSkinMask(
                for: photo.previewCIImage,
                orientation: orientation
            ) : nil
            
            await MainActor.run {
                self.detectedFaces = faces
                self.previewSkinMask = skinMaskCI
                self.visualSkinMaskImage = visualMask
                self.isDetectingFaces = false
            }
        }
    }
    
    // MARK: - History Snapshot (Disk-Backed Checkpoint & Undo / Redo)
    
    public func recordHistorySnapshot() {
        undoStack.append(editState)
        if undoStack.count > maxHistoryDepth {
            undoStack.removeFirst()
        }
        redoStack.removeAll()
        
        editActionCounter += 1
        
        // Checkpoint every 3 changes or on spot healing to bound memory footprint
        if editActionCounter % checkpointInterval == 0, let session = activeSessionId, let imageToSave = renderedPreview ?? loadedPhoto?.previewUIImage {
            let currentIndex = editActionCounter
            Task { [diskCacheService] in
                _ = await diskCacheService.saveCheckpoint(image: imageToSave, index: currentIndex, sessionId: session)
            }
        }
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
    
    // MARK: - Portrait & Spot Healing Mutators
    
    public func runWizardRetouch(mode: WizardRetouchMode? = nil) {
        let targetMode = mode ?? selectedWizardMode
        self.selectedWizardMode = targetMode
        self.isWizardScanning = true
        
        withAnimation(.easeInOut(duration: 0.22)) {
            self.isShowingSkinMaskOverlay = true
        }
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        Task {
            // Realistic face scan & lock-on phase (~700ms)
            try? await Task.sleep(nanoseconds: 700_000_000)
            
            await MainActor.run {
                self.isWizardScanning = false
                self.isWizardActive = true
                self.recordHistorySnapshot()
                self.editState.skinSmoothing = targetMode.intensity
                
                let successFeedback = UINotificationFeedbackGenerator()
                successFeedback.notificationOccurred(.success)
                
                self.requestPreviewRender()
                // Mask remains visible on face so user can inspect and refine. User taps "Uygula" to dismiss.
            }
        }
    }
    
    public func applyWizardAndDismissMask() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        withAnimation(.easeInOut(duration: 0.25)) {
            self.isShowingSkinMaskOverlay = false
        }
    }
    
    public func selectWizardMode(_ mode: WizardRetouchMode) {
        guard selectedWizardMode != mode || editState.skinSmoothing == 0 else { return }
        self.selectedWizardMode = mode
        self.isWizardActive = true
        recordHistorySnapshot()
        self.editState.skinSmoothing = mode.intensity
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        requestPreviewRender()
    }
    
    public func toggleSkinMaskOverlay() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
            self.isShowingSkinMaskOverlay.toggle()
        }
    }
    
    public func applyAutoSkinRetouch(intensity: Float = 60.0) {
        recordHistorySnapshot()
        self.editState.skinSmoothing = intensity
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        requestPreviewRender()
    }
    
    public func updateSkinSmoothing(_ value: Float) {
        self.editState.skinSmoothing = value
        requestPreviewRender()
    }
    
    public func addHealedSpot(x: CGFloat, y: CGFloat) {
        recordHistorySnapshot()
        let clampedX = min(max(x, 0.0), 1.0)
        let clampedY = min(max(y, 0.0), 1.0)
        let spot = HealedSpot(x: clampedX, y: clampedY, radius: CGFloat(healingBrushRadius))
        self.editState.healedSpots.append(spot)
        self.lastHealedSpotPoint = CGPoint(x: clampedX, y: clampedY)
        self.lastHealedRipplePoint = CGPoint(x: clampedX, y: clampedY)
        self.isShowingRipple = true
        
        // Haptic feedback for tactile brush wipe feel
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        requestPreviewRender()
        
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            if self.isShowingRipple {
                self.isShowingRipple = false
            }
        }
    }
    
    public func undoLastHealedSpot() {
        guard !editState.healedSpots.isEmpty else { return }
        recordHistorySnapshot()
        self.editState.healedSpots.removeLast()
        requestPreviewRender()
    }
    
    public func clearAllHealedSpots() {
        guard !editState.healedSpots.isEmpty else { return }
        recordHistorySnapshot()
        self.editState.healedSpots.removeAll()
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
    
    // MARK: - Export Decision Flow (Free vs Pro)
    
    /// Central decision point for photo export:
    /// - Pro user -> Exports directly without ads.
    /// - Free user -> Presents 1 AdMob Rewarded Ad.
    ///   - Reward earned -> Proceeds to export.
    ///   - Ad failed / unavailable -> Fails open to export.
    ///   - Dismissed early before reward -> Aborts export without saving.
    public func exportPhoto() async {
        guard loadedPhoto != nil else { return }
        guard !isExporting else { return }
        
        exportErrorMessage = nil
        exportSuccessMessage = nil
        
        let isPro = SubscriptionService.shared.isProUser
        
        if isPro {
            // Pro Subscriber -> Direct immediate export
            await performFullResolutionExport()
        } else {
            // Free User -> Present Rewarded Ad before export
            let adResult = await RewardedAdService.shared.presentRewardedAd()
            
            switch adResult {
            case .rewardEarned:
                // User watched rewarded ad -> Export photo
                await performFullResolutionExport()
                
            case .failedOpen:
                // Ad failed to load/present -> Fail-open policy: do not block user, proceed to export
                await performFullResolutionExport()
                
            case .dismissedWithoutReward:
                // User closed ad before reward was earned -> Do not export
                self.exportErrorMessage = "Fotoğrafı kaydetmek için lütfen kısa reklamı tamamlayın veya Photonla Pro'ya geçin."
                
                // Auto-clear error after 4 seconds
                Task {
                    try? await Task.sleep(nanoseconds: 4_000_000_000)
                    if self.exportErrorMessage != nil {
                        self.exportErrorMessage = nil
                    }
                }
            }
        }
    }
    
    // MARK: - Full Resolution Non-Destructive Export Execution
    
    public func performFullResolutionExport() async {
        guard let photo = loadedPhoto else { return }
        guard !isExporting else { return }
        
        isExporting = true
        exportErrorMessage = nil
        exportSuccessMessage = nil
        
        do {
            // Generate full-resolution skin mask if faces were detected
            let fullResSkinMask: CIImage?
            if !detectedFaces.isEmpty {
                let orientation = CGImagePropertyOrientation(photo.previewUIImage.imageOrientation)
                fullResSkinMask = faceDetectionService.generateSkinMask(
                    for: photo.originalCIImage,
                    orientation: orientation
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
            
            // Clean up temporary checkpoint files on disk after export
            if let session = activeSessionId {
                diskCacheService.cleanupSession(sessionId: session)
            }
            
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
    
    public func cleanupCurrentSession() {
        if let session = activeSessionId {
            diskCacheService.cleanupSession(sessionId: session)
            self.activeSessionId = nil
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

// MARK: - EXIF Orientation Mapping Extension

extension CGImagePropertyOrientation {
    public init(_ uiOrientation: UIImage.Orientation) {
        switch uiOrientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        @unknown default: self = .up
        }
    }
}
