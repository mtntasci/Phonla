//
//  EditorView.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import SwiftUI
import Vision

/// Non-destructive photo editor powered by Core Image & Metal GPU pipeline.
/// Supports real-time Light, Color, Cilt (Portrait), Cinematic, Mono processing, Undo/Redo, Before/After, and full-resolution export.
public struct EditorView: View {
    @Environment(NavigationState.self) private var navigationState
    @State private var viewModel = EditorViewModel.shared
    @State private var showDiscardAlert: Bool = false
    
    // MARK: - Zoom & Pan States
    @State private var zoomScale: CGFloat = 1.0
    @State private var lastZoomScale: CGFloat = 1.0
    @State private var panOffset: CGSize = .zero
    @State private var lastPanOffset: CGSize = .zero
    @State private var canvasSize: CGSize = .zero
    @State private var isPanning: Bool = false
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // MARK: - Top Toolbar
            topToolbar
            
            // MARK: - Main Canvas Area (Photo Preview & Gestures)
            canvasArea
            
            // MARK: - Bottom Tool Section (Dynamic Height & Translucent Material)
            bottomToolSection
        }
        .photonBackground()
        .ignoresSafeArea(edges: .bottom)
        .confirmationDialog(
            "Değişiklikleri Sil",
            isPresented: $showDiscardAlert,
            titleVisibility: .visible
        ) {
            Button("Değişiklikleri Sil ve Çık", role: .destructive) {
                resetZoom(animated: false)
                viewModel.cleanupCurrentSession()
                viewModel.resetState()
                navigationState.navigateToHome()
            }
            Button("İptal", role: .cancel) {}
        } message: {
            Text("Kaydedilmemiş düzenlemeleriniz kaybolacak.")
        }
        .onChange(of: viewModel.loadedPhoto?.id) { _, _ in
            resetZoom(animated: false)
        }
        .onChange(of: viewModel.activeCategory) { oldCategory, newCategory in
            handleCategoryChange(to: newCategory, from: oldCategory)
        }
        .onChange(of: viewModel.isDetectingFaces) { _, isDetecting in
            if !isDetecting && viewModel.activeCategory == .portrait && zoomScale <= 1.05 {
                applyFaceZoom()
            }
        }
    }
    
    // MARK: - Zoom & Viewport Management
    
    private func resetZoom(animated: Bool = true) {
        if animated {
            withAnimation(.spring(response: 0.38, dampingFraction: 0.85)) {
                zoomScale = 1.0
                lastZoomScale = 1.0
                panOffset = .zero
                lastPanOffset = .zero
            }
        } else {
            zoomScale = 1.0
            lastZoomScale = 1.0
            panOffset = .zero
            lastPanOffset = .zero
        }
    }
    
    private func handleCategoryChange(to newCategory: EditorToolCategory, from oldCategory: EditorToolCategory) {
        if newCategory == .portrait {
            // Smoothly auto-zoom to the detected face(s)
            applyFaceZoom()
        } else if oldCategory == .portrait {
            // Smoothly return to normal photo view when leaving Cilt tool
            resetZoom(animated: true)
        }
    }
    
    private func applyFaceZoom() {
        guard !viewModel.detectedFaces.isEmpty else { return }
        
        let faces = viewModel.detectedFaces
        
        // 1. Calculate enclosing union bounding box in normalized coordinates [0, 1]
        let minX = faces.map { $0.boundingBox.minX }.min() ?? 0
        let maxX = faces.map { $0.boundingBox.maxX }.max() ?? 1
        let minY = faces.map { 1.0 - $0.boundingBox.maxY }.min() ?? 0
        let maxY = faces.map { 1.0 - $0.boundingBox.minY }.max() ?? 1
        
        let unionWidth = max(maxX - minX, 0.05)
        let unionHeight = max(maxY - minY, 0.05)
        
        // 2. Add comfortable margin (ensures forehead, hair, and chin stay comfortably in frame)
        let paddingMultiplier: CGFloat = faces.count > 1 ? 0.35 : 0.55
        let paddedWidth = min(unionWidth * (1.0 + paddingMultiplier * 2), 1.0)
        let paddedHeight = min(unionHeight * (1.0 + paddingMultiplier * 2), 1.0)
        
        // 3. Compute optimal zoom scale between 1.3x and 3.2x
        let targetScale = min(max(min(0.72 / paddedWidth, 0.72 / paddedHeight), 1.3), 3.2)
        
        // 4. Center of the face box
        let faceCenterX = (minX + maxX) / 2.0
        let faceCenterY = (minY + maxY) / 2.0
        
        // 5. Pan offset to focus face cleanly in center of canvas
        let currentW = canvasSize.width > 0 ? canvasSize.width : 340
        let currentH = canvasSize.height > 0 ? canvasSize.height : 400
        let targetOffsetX = (0.5 - faceCenterX) * currentW * targetScale
        let targetOffsetY = (0.5 - faceCenterY) * currentH * targetScale
        
        withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
            zoomScale = targetScale
            lastZoomScale = targetScale
            panOffset = CGSize(width: targetOffsetX, height: targetOffsetY)
            lastPanOffset = panOffset
        }
    }
    
    // MARK: - Spot Healing Gesture Handlers
    
    private func handleSpotHealingDragChanged(value: DragGesture.Value, imgW: CGFloat, imgH: CGFloat, availableWidth: CGFloat, availableHeight: CGFloat) {
        guard imgW > 0, imgH > 0 else { return }
        
        let dragDist = hypot(value.translation.width, value.translation.height)
        
        if zoomScale > 1.05 && dragDist > 8 {
            viewModel.isLoupeActive = false
            isPanning = true
            
            panOffset = CGSize(
                width: lastPanOffset.width + value.translation.width,
                height: lastPanOffset.height + value.translation.height
            )
            return
        }
        
        if isPanning { return }
        
        let normX = min(max(value.location.x / imgW, 0.0), 1.0)
        let normY = min(max(value.location.y / imgH, 0.0), 1.0)
        
        let canvasCenter = CGPoint(x: availableWidth / 2.0 + panOffset.width, y: availableHeight / 2.0 + panOffset.height)
        let screenX = canvasCenter.x + (value.location.x - imgW / 2.0) * zoomScale
        let screenY = canvasCenter.y + (value.location.y - imgH / 2.0) * zoomScale
        
        viewModel.loupeTouchPoint = CGPoint(x: screenX, y: screenY)
        viewModel.loupeNormalizedPoint = CGPoint(x: normX, y: normY)
        if !viewModel.isLoupeActive {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                viewModel.isLoupeActive = true
            }
        }
    }
    
    private func handleSpotHealingDragEnded(value: DragGesture.Value, imgW: CGFloat, imgH: CGFloat) {
        if isPanning {
            lastPanOffset = panOffset
            isPanning = false
            return
        }
        
        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
            viewModel.isLoupeActive = false
        }
        
        guard imgW > 0, imgH > 0 else { return }
        let normX = min(max(value.location.x / imgW, 0.0), 1.0)
        let normY = min(max(value.location.y / imgH, 0.0), 1.0)
        viewModel.addHealedSpot(x: normX, y: normY)
    }
    
    // MARK: - Automated Blemish Scanning Laser Overlay
    
    @ViewBuilder
    private func laserScanOverlay(width: CGFloat, height: CGFloat) -> some View {
        if viewModel.isScanningBlemishes {
            let scanY = height * viewModel.scanProgress
            
            ZStack(alignment: .top) {
                // Soft trailing cyan glow above the laser line
                LinearGradient(
                    colors: [
                        Color.cyan.opacity(0.0),
                        Color.cyan.opacity(0.12),
                        Color.cyan.opacity(0.35)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(width: width, height: max(15, scanY))
                .position(x: width / 2.0, y: scanY / 2.0)
                
                // Neon Blue/Cyan Laser Beam Line across entire width (left to right)
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.cyan.opacity(0.2),
                                Color.white,
                                Color.cyan,
                                Color.white,
                                Color.cyan.opacity(0.2)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: width, height: 2.5)
                    .shadow(color: Color.cyan, radius: 8, x: 0, y: 0)
                    .shadow(color: Color.white, radius: 2, x: 0, y: 0)
                    .position(x: width / 2.0, y: scanY)
            }
            .clipShape(RoundedRectangle(cornerRadius: PhotonCornerRadius.sm, style: .continuous))
            .allowsHitTesting(false)
            .transition(.opacity)
        }
    }
    
    // MARK: - Detected Blemish Circle Markers (Slightly larger than the spot)
    
    @ViewBuilder
    private func spotMarkersOverlay(width: CGFloat, height: CGFloat) -> some View {
        if viewModel.activeCategory == .portrait && !viewModel.isScanningBlemishes && !viewModel.isComparingOriginal {
            ForEach(viewModel.editState.healedSpots) { spot in
                let spotX = spot.x * width
                let spotY = spot.y * height
                let baseRadius = CGFloat(spot.radius) * max(width, height)
                let markerDiameter = max(18.0, baseRadius * 2.3)
                
                ZStack {
                    // Soft translucent cyan fill
                    Circle()
                        .fill(Color.cyan.opacity(0.14))
                        .frame(width: markerDiameter, height: markerDiameter)
                    
                    // Fine dashed circular perimeter
                    Circle()
                        .strokeBorder(
                            Color.cyan.opacity(0.92),
                            style: StrokeStyle(lineWidth: 1.3, dash: [4, 3])
                        )
                        .frame(width: markerDiameter, height: markerDiameter)
                        .shadow(color: Color.black.opacity(0.4), radius: 2, x: 0, y: 1)
                    
                    // Glowing center target dot
                    Circle()
                        .fill(Color.white)
                        .frame(width: 3.5, height: 3.5)
                        .shadow(color: Color.cyan, radius: 3)
                }
                .position(x: spotX, y: spotY)
                .allowsHitTesting(false)
                .transition(.scale(scale: 0.2).combined(with: .opacity))
            }
        }
    }
    
    // MARK: - 3-Zone Facial Segmentation Overlay (White = Forehead, Green = Eyes/Midface, Red = Lips/Chin)
    
    @ViewBuilder
    private func facialZonesOverlay(width: CGFloat, height: CGFloat) -> some View {
        if viewModel.activeCategory == .portrait && viewModel.isShowingFacialZones && !viewModel.isScanningBlemishes && !viewModel.isComparingOriginal {
            ForEach(viewModel.detectedFacialZones) { zone in
                let zoneRect = CGRect(
                    x: zone.rect.origin.x * width,
                    y: zone.rect.origin.y * height,
                    width: zone.rect.width * width,
                    height: zone.rect.height * height
                )
                
                let zoneColor: Color = {
                    switch zone.colorType {
                    case .white: return Color.white
                    case .green: return Color(red: 0.15, green: 0.95, blue: 0.45)
                    case .red: return Color(red: 1.0, green: 0.25, blue: 0.25)
                    }
                }()
                
                ZStack(alignment: .topLeading) {
                    // Soft translucent zone fill
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(zoneColor.opacity(0.08))
                        .frame(width: zoneRect.width, height: zoneRect.height)
                    
                    // Fine dashed zone bounding border
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .strokeBorder(zoneColor.opacity(0.85), style: StrokeStyle(lineWidth: 1.5, dash: [5, 3]))
                        .frame(width: zoneRect.width, height: zoneRect.height)
                        .shadow(color: Color.black.opacity(0.4), radius: 3, x: 0, y: 1)
                    
                    // Zone Tag Badge on Top-Left corner
                    HStack(spacing: 3) {
                        Circle()
                            .fill(zoneColor)
                            .frame(width: 5, height: 5)
                        Text(zone.name)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.black.opacity(0.75))
                    .clipShape(Capsule())
                    .padding(4)
                }
                .position(x: zoneRect.midX, y: zoneRect.midY)
                .allowsHitTesting(false)
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
    }
    
    // MARK: - Top Toolbar
    
    private var topToolbar: some View {
        HStack(spacing: PhotonSpacing.sm) {
            // Close / Back Button
            Button {
                if viewModel.isEdited {
                    showDiscardAlert = true
                } else {
                    navigationState.navigateToHome()
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(PhotonColors.textPrimary)
                    .frame(width: 36, height: 36)
                    .background(PhotonColors.surfaceSecondary)
                    .clipShape(Circle())
            }
            
            // Undo Button
            Button {
                viewModel.undo()
            } label: {
                Image(systemName: "arrow.uturn.backward")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(viewModel.canUndo ? PhotonColors.textPrimary : PhotonColors.textTertiary.opacity(0.5))
                    .frame(width: 36, height: 36)
                    .background(PhotonColors.surfaceSecondary.opacity(viewModel.canUndo ? 1.0 : 0.5))
                    .clipShape(Circle())
            }
            .disabled(!viewModel.canUndo)
            
            // Redo Button
            Button {
                viewModel.redo()
            } label: {
                Image(systemName: "arrow.uturn.forward")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(viewModel.canRedo ? PhotonColors.textPrimary : PhotonColors.textTertiary.opacity(0.5))
                    .frame(width: 36, height: 36)
                    .background(PhotonColors.surfaceSecondary.opacity(viewModel.canRedo ? 1.0 : 0.5))
                    .clipShape(Circle())
            }
            .disabled(!viewModel.canRedo)
            
            Spacer()
            
            // Reset Button (Right aligned next to Kaydet)
            if viewModel.isEdited {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.resetState()
                    }
                } label: {
                    Text("Sıfırla")
                        .font(PhotonTypography.bodyMedium.weight(.medium))
                        .foregroundColor(PhotonColors.textSecondary)
                }
                .padding(.horizontal, PhotonSpacing.xs)
                .transition(.opacity)
            }
            
            // Full Resolution Export / Save Button
            PhotonButton(
                "Kaydet",
                variant: .primary,
                size: .small,
                isFullWidth: false,
                isLoading: viewModel.isExporting
            ) {
                Task {
                    await viewModel.exportPhoto()
                }
            }
        }
        .padding(.horizontal, PhotonSpacing.md)
        .padding(.vertical, 4)
    }
    
    // MARK: - Main Canvas Area
    
    private var canvasArea: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width - PhotonSpacing.xxs
            let availableHeight = geometry.size.height - PhotonSpacing.xxs
            
            ZStack {
                PhotonColors.surfaceTertiary
                    .ignoresSafeArea()
                
                if let displayImage = viewModel.currentDisplayImage {
                    let imgSize = displayImage.size
                    let fitScale = min(availableWidth / max(imgSize.width, 1), availableHeight / max(imgSize.height, 1))
                    let fittedWidth = imgSize.width * fitScale
                    let fittedHeight = imgSize.height * fitScale
                    
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: displayImage)
                            .resizable()
                            .frame(width: fittedWidth, height: fittedHeight)
                            .clipShape(RoundedRectangle(cornerRadius: PhotonCornerRadius.sm, style: .continuous))
                            .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
                            .overlay(
                                RoundedRectangle(cornerRadius: PhotonCornerRadius.sm, style: .continuous)
                                    .strokeBorder(PhotonColors.border, lineWidth: 0.5)
                            )
                            .overlay(facialZonesOverlay(width: fittedWidth, height: fittedHeight))
                            .overlay(spotMarkersOverlay(width: fittedWidth, height: fittedHeight))
                            .overlay(laserScanOverlay(width: fittedWidth, height: fittedHeight))
                            // Spot Healing interactive tap and drag overlay when Healing subtool is active
                            .overlay {
                                if viewModel.activeCategory == .portrait && viewModel.selectedPortraitSubTool == .healing && !viewModel.isComparingOriginal {
                                    GeometryReader { imgGeo in
                                        let imgW = imgGeo.size.width
                                        let imgH = imgGeo.size.height
                                        
                                        ZStack {
                                            Color.clear
                                                .contentShape(Rectangle())
                                                .gesture(
                                                    DragGesture(minimumDistance: 0, coordinateSpace: .local)
                                                        .onChanged { value in
                                                            handleSpotHealingDragChanged(
                                                                value: value,
                                                                imgW: imgW,
                                                                imgH: imgH,
                                                                availableWidth: availableWidth,
                                                                availableHeight: availableHeight
                                                            )
                                                        }
                                                        .onEnded { value in
                                                            handleSpotHealingDragEnded(
                                                                value: value,
                                                                imgW: imgW,
                                                                imgH: imgH
                                                            )
                                                        }
                                                )
                                            
                                            // Visual Brush Effects & Dissolve Animations
                                            ZStack {
                                                // 1. Animated Brush Wipe & Sparkle Dissolve upon healing a spot
                                                if viewModel.isShowingRipple, let ripplePoint = viewModel.lastHealedRipplePoint {
                                                    let rippleX = ripplePoint.x * imgW
                                                    let rippleY = ripplePoint.y * imgH
                                                    let baseRadius = CGFloat(viewModel.healingBrushRadius) * max(imgW, imgH) * 2.0
                                                    
                                                    HealingWipeEffectView(radius: baseRadius)
                                                        .position(x: rippleX, y: rippleY)
                                                        .allowsHitTesting(false)
                                                }
                                                
                                                // 2. Live Soft Cosmetic Brush Footprint indicator when dragging/touching
                                                if viewModel.isLoupeActive {
                                                    let brushX = viewModel.loupeNormalizedPoint.x * imgW
                                                    let brushY = viewModel.loupeNormalizedPoint.y * imgH
                                                    let brushPx = CGFloat(viewModel.healingBrushRadius) * max(imgW, imgH) * 2.0
                                                    
                                                    ZStack {
                                                        // Soft feathered aura
                                                        Circle()
                                                            .fill(
                                                                RadialGradient(
                                                                    colors: [Color.white.opacity(0.35), Color.white.opacity(0.08), Color.clear],
                                                                    center: .center,
                                                                    startRadius: 0,
                                                                    endRadius: max(16, brushPx) / 2.0
                                                                )
                                                            )
                                                            .frame(width: max(20, brushPx * 1.25), height: max(20, brushPx * 1.25))
                                                        
                                                        // Fine dashed cosmetic brush perimeter
                                                        Circle()
                                                            .strokeBorder(
                                                                Color.white.opacity(0.95),
                                                                style: StrokeStyle(lineWidth: 1.2, dash: [4, 3])
                                                            )
                                                            .frame(width: max(16, brushPx), height: max(16, brushPx))
                                                            .shadow(color: Color.black.opacity(0.5), radius: 2, x: 0, y: 1)
                                                        
                                                        // Subtle glowing center touch point
                                                        Circle()
                                                            .fill(Color.white)
                                                            .frame(width: 4, height: 4)
                                                            .shadow(color: Color.black.opacity(0.6), radius: 1)
                                                    }
                                                    .position(x: brushX, y: brushY)
                                                    .allowsHitTesting(false)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            // Zoom & Pan transforms (Maintains identical zoom & position for Before and After)
                            .scaleEffect(zoomScale)
                            .offset(panOffset)
                            // Pinch to Zoom gesture
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { scale in
                                        let newScale = lastZoomScale * scale
                                        zoomScale = min(max(newScale, 1.0), 6.0)
                                    }
                                    .onEnded { _ in
                                        lastZoomScale = zoomScale
                                        if zoomScale <= 1.05 {
                                            resetZoom()
                                        }
                                    }
                            )
                            // Simultaneous Drag: Hold to Compare (Before/After) or Drag to Pan when zoomed
                            .simultaneousGesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        // When in Healing mode, the healing touch gesture handles gestures
                                        if viewModel.activeCategory == .portrait && viewModel.selectedPortraitSubTool == .healing {
                                            return
                                        }
                                        
                                        let distance = hypot(value.translation.width, value.translation.height)
                                        if zoomScale > 1.05 && distance > 8 {
                                            isPanning = true
                                            panOffset = CGSize(
                                                width: lastPanOffset.width + value.translation.width,
                                                height: lastPanOffset.height + value.translation.height
                                            )
                                        }
                                    }
                                    .onEnded { _ in
                                        if viewModel.activeCategory == .portrait && viewModel.selectedPortraitSubTool == .healing {
                                            return
                                        }
                                        if isPanning {
                                            lastPanOffset = panOffset
                                            isPanning = false
                                        }
                                    }
                            )
                            // Double Tap to toggle between detailed zoom and normal view
                            .simultaneousGesture(
                                TapGesture(count: 2)
                                    .onEnded {
                                        withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                                            if zoomScale > 1.05 {
                                                resetZoom()
                                            } else if viewModel.activeCategory == .portrait && !viewModel.detectedFaces.isEmpty {
                                                applyFaceZoom()
                                            } else {
                                                zoomScale = 2.4
                                                lastZoomScale = 2.4
                                            }
                                        }
                                    }
                            )
                    }
                } else {
                    ProgressView()
                        .tint(PhotonColors.textPrimary)
                }
                // MARK: - Floating Canvas Overlay Controls (Zoom Reset & High-Contrast Orijinal)
                if !viewModel.isLoupeActive {
                    VStack {
                        HStack(spacing: 8) {
                            if viewModel.isScanningBlemishes {
                                HStack(spacing: 6) {
                                    ProgressView()
                                        .scaleEffect(0.65)
                                        .tint(Color.cyan)
                                    Text("Yüz ve Lekeler Taranıyor...")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal, 11)
                                .padding(.vertical, 6)
                                .background(Color(red: 0.05, green: 0.18, blue: 0.32).opacity(0.92))
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .strokeBorder(Color.cyan.opacity(0.6), lineWidth: 1.0)
                                )
                                .shadow(color: Color.black.opacity(0.35), radius: 8, x: 0, y: 3)
                                .transition(.move(edge: .top).combined(with: .opacity))
                            }
                            
                            if viewModel.activeCategory == .portrait && !viewModel.detectedFacialZones.isEmpty && !viewModel.isScanningBlemishes {
                                Button {
                                    viewModel.toggleFacialZones()
                                } label: {
                                    HStack(spacing: 4) {
                                        Circle()
                                            .fill(viewModel.isShowingFacialZones ? Color.cyan : Color.gray)
                                            .frame(width: 6, height: 6)
                                        Text("Bölgeler")
                                            .font(.system(size: 11, weight: .semibold))
                                            .foregroundColor(.white)
                                    }
                                    .padding(.horizontal, 9)
                                    .padding(.vertical, 6)
                                    .background(Color(red: 0.12, green: 0.12, blue: 0.14).opacity(0.90))
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule()
                                            .strokeBorder(Color.white.opacity(0.25), lineWidth: 1.0)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                            
                            Spacer()
                            
                            // 1. Zoom Reset Button (Visible when canvas is zoomed or panned)
                            if zoomScale > 1.05 || panOffset != .zero {
                                Button {
                                    let generator = UIImpactFeedbackGenerator(style: .light)
                                    generator.impactOccurred()
                                    resetZoom(animated: true)
                                } label: {
                                    HStack(spacing: 5) {
                                        Image(systemName: "arrow.down.right.and.arrow.up.left")
                                            .font(.system(size: 11, weight: .bold))
                                        Text("Orj.Boyut")
                                            .font(.system(size: 12, weight: .semibold))
                                    }
                                    .padding(.horizontal, 11)
                                    .padding(.vertical, 7)
                                    .background(Color(red: 0.12, green: 0.12, blue: 0.14).opacity(0.90))
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                                    .shadow(color: Color.black.opacity(0.35), radius: 8, x: 0, y: 3)
                                    .overlay(
                                        Capsule()
                                            .strokeBorder(Color.white.opacity(0.3), lineWidth: 1.0)
                                    )
                                }
                                .buttonStyle(.plain)
                                .transition(.opacity.combined(with: .scale(scale: 0.9)))
                            }
                            
                            // 2. High-Contrast "Orijinal" Compare Button (Press & Hold)
                            if viewModel.isEdited {
                                HStack(spacing: 5) {
                                    Image(systemName: viewModel.isComparingOriginal ? "eye.fill" : "eye")
                                        .font(.system(size: 12, weight: .bold))
                                    Text("Orijinal")
                                        .font(.system(size: 12, weight: .semibold))
                                }
                                .padding(.horizontal, 13)
                                .padding(.vertical, 7)
                                .background(
                                    viewModel.isComparingOriginal
                                    ? Color.white
                                    : Color(red: 0.12, green: 0.12, blue: 0.14).opacity(0.90)
                                )
                                .foregroundColor(viewModel.isComparingOriginal ? Color.black : Color.white)
                                .clipShape(Capsule())
                                .shadow(color: Color.black.opacity(0.35), radius: 8, x: 0, y: 3)
                                .overlay(
                                    Capsule()
                                        .strokeBorder(
                                            viewModel.isComparingOriginal ? Color.white : Color.white.opacity(0.3),
                                            lineWidth: 1.0
                                        )
                                )
                                .scaleEffect(viewModel.isComparingOriginal ? 0.96 : 1.0)
                                .animation(.spring(response: 0.2, dampingFraction: 0.8), value: viewModel.isComparingOriginal)
                                .simultaneousGesture(
                                    DragGesture(minimumDistance: 0)
                                        .onChanged { _ in
                                            if !viewModel.isComparingOriginal {
                                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                                generator.impactOccurred()
                                                viewModel.isComparingOriginal = true
                                            }
                                        }
                                        .onEnded { _ in
                                            viewModel.isComparingOriginal = false
                                        }
                                )
                                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                            }
                        }
                        .padding(.top, 14)
                        .padding(.trailing, 16)
                        
                        Spacer()
                    }
                }
                
                // MARK: - Floating Magnifier Loupe Overlay (Renders above entire canvas)
                if viewModel.isLoupeActive && viewModel.activeCategory == .portrait && viewModel.selectedPortraitSubTool == .healing {
                    MagnifierLoupeView(
                        displayImage: viewModel.currentDisplayImage,
                        touchLocation: viewModel.loupeTouchPoint,
                        normalizedPoint: viewModel.loupeNormalizedPoint,
                        brushRadius: viewModel.healingBrushRadius,
                        canvasSize: canvasSize,
                        zoomScale: zoomScale
                    )
                }
                
                // MARK: - Floating Spot Healing Controls (Above Bottom Menu on Photo Canvas)
                if viewModel.activeCategory == .portrait && viewModel.selectedPortraitSubTool == .healing && !viewModel.isComparingOriginal {
                    VStack {
                        Spacer()
                        
                        HStack(spacing: 8) {
                            // Brush Size Selector Chips
                            // Undo & Clear buttons if spots exist
                            if !viewModel.editState.healedSpots.isEmpty {
                                HStack(spacing: 5) {
                                    Button {
                                        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                            viewModel.undoLastHealedSpot()
                                        }
                                    } label: {
                                        HStack(spacing: 3) {
                                            Image(systemName: "arrow.uturn.backward")
                                                .font(.system(size: 11, weight: .bold))
                                            Text("\(viewModel.editState.healedSpots.count)")
                                                .font(.system(size: 11, weight: .bold))
                                        }
                                        .padding(.horizontal, 9)
                                        .padding(.vertical, 7)
                                        .background(PhotonColors.surfaceSecondary.opacity(0.85))
                                        .foregroundColor(PhotonColors.textPrimary)
                                        .clipShape(Capsule())
                                        .overlay(
                                            Capsule()
                                                .strokeBorder(PhotonColors.border.opacity(0.5), lineWidth: 0.8)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                    
                                    Button {
                                        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                            viewModel.clearAllHealedSpots()
                                        }
                                    } label: {
                                        Image(systemName: "trash.fill")
                                            .font(.system(size: 11, weight: .bold))
                                            .padding(7)
                                            .background(PhotonColors.surfaceSecondary.opacity(0.85))
                                            .foregroundColor(Color.red.opacity(0.9))
                                            .clipShape(Circle())
                                            .overlay(
                                                Circle()
                                                    .strokeBorder(PhotonColors.border.opacity(0.5), lineWidth: 0.8)
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .shadow(color: Color.black.opacity(0.18), radius: 10, x: 0, y: 4)
                        .overlay(
                            Capsule()
                                .strokeBorder(Color.white.opacity(0.2), lineWidth: 0.8)
                        )
                        .padding(.bottom, 12)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                // MARK: - Floating Vertical Adjustment Slider (Right Edge)
                if !viewModel.isComparingOriginal {
                    HStack {
                        Spacer()
                        
                        floatingVerticalSlider
                            .padding(.trailing, PhotonSpacing.md)
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }
                
                // Export Success Toast
                if let successMessage = viewModel.exportSuccessMessage {
                    VStack {
                        HStack(spacing: PhotonSpacing.xs) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(PhotonColors.success)
                            Text(successMessage)
                                .font(PhotonTypography.bodyMedium.weight(.medium))
                                .foregroundColor(PhotonColors.textPrimary)
                        }
                        .padding(.horizontal, PhotonSpacing.lg)
                        .padding(.vertical, PhotonSpacing.md)
                        .background(PhotonColors.surfacePrimary)
                        .clipShape(Capsule())
                        .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 6)
                        .padding(.top, PhotonSpacing.md)
                        
                        Spacer()
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.spring(duration: 0.35), value: viewModel.exportSuccessMessage)
                }
                
                // Export Error Banner
                if let errorMessage = viewModel.exportErrorMessage {
                    VStack {
                        HStack(spacing: PhotonSpacing.xs) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(PhotonColors.error)
                            Text(errorMessage)
                                .font(PhotonTypography.caption.weight(.medium))
                                .foregroundColor(PhotonColors.textPrimary)
                        }
                        .padding(.horizontal, PhotonSpacing.lg)
                        .padding(.vertical, PhotonSpacing.sm)
                        .background(PhotonColors.surfacePrimary)
                        .clipShape(Capsule())
                        .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 6)
                        .padding(.top, PhotonSpacing.md)
                        
                        Spacer()
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .onAppear {
                canvasSize = CGSize(width: availableWidth, height: availableHeight)
            }
            .onChange(of: geometry.size) { _, newSize in
                canvasSize = CGSize(width: newSize.width - PhotonSpacing.xxs, height: newSize.height - PhotonSpacing.xxs)
            }
        }
    }
    
    // MARK: - Floating Right-Side Vertical Slider
    
    @ViewBuilder
    private var floatingVerticalSlider: some View {
        switch viewModel.activeCategory {
        case .light:
            switch viewModel.selectedLightSubTool {
            case .exposure:
                VerticalAdjustmentSlider(
                    systemIcon: viewModel.selectedLightSubTool.systemIcon,
                    title: viewModel.selectedLightSubTool.rawValue,
                    value: Binding(
                        get: { viewModel.editState.exposure },
                        set: { newVal in viewModel.updateStateDirectly { $0.exposure = newVal } }
                    ),
                    range: -2.0...2.0,
                    defaultValue: 0.0,
                    step: 0.05,
                    valueFormatter: { val in
                        val >= 0 ? String(format: "+%.2f EV", val) : String(format: "%.2f EV", val)
                    },
                    onEditingEnded: { viewModel.recordHistorySnapshot() }
                )
            case .brightness:
                VerticalAdjustmentSlider(
                    systemIcon: viewModel.selectedLightSubTool.systemIcon,
                    title: viewModel.selectedLightSubTool.rawValue,
                    value: Binding(
                        get: { viewModel.editState.brightness },
                        set: { newVal in viewModel.updateStateDirectly { $0.brightness = newVal } }
                    ),
                    range: -1.0...1.0,
                    defaultValue: 0.0,
                    step: 0.02,
                    valueFormatter: { val in
                        let pct = Int(val * 100)
                        return pct >= 0 ? "+\(pct)%" : "\(pct)%"
                    },
                    onEditingEnded: { viewModel.recordHistorySnapshot() }
                )
            case .contrast:
                VerticalAdjustmentSlider(
                    systemIcon: viewModel.selectedLightSubTool.systemIcon,
                    title: viewModel.selectedLightSubTool.rawValue,
                    value: Binding(
                        get: { viewModel.editState.contrast },
                        set: { newVal in viewModel.updateStateDirectly { $0.contrast = newVal } }
                    ),
                    range: 0.5...1.5,
                    defaultValue: 1.0,
                    step: 0.02,
                    valueFormatter: { val in
                        let pct = Int((val - 1.0) * 100)
                        return pct >= 0 ? "+\(pct)%" : "\(pct)%"
                    },
                    onEditingEnded: { viewModel.recordHistorySnapshot() }
                )
            case .highlights:
                VerticalAdjustmentSlider(
                    systemIcon: viewModel.selectedLightSubTool.systemIcon,
                    title: viewModel.selectedLightSubTool.rawValue,
                    value: Binding(
                        get: { viewModel.editState.highlights },
                        set: { newVal in viewModel.updateStateDirectly { $0.highlights = newVal } }
                    ),
                    range: -1.0...1.0,
                    defaultValue: 0.0,
                    step: 0.02,
                    valueFormatter: { val in
                        let pct = Int(val * 100)
                        return pct >= 0 ? "+\(pct)%" : "\(pct)%"
                    },
                    onEditingEnded: { viewModel.recordHistorySnapshot() }
                )
            case .shadows:
                VerticalAdjustmentSlider(
                    systemIcon: viewModel.selectedLightSubTool.systemIcon,
                    title: viewModel.selectedLightSubTool.rawValue,
                    value: Binding(
                        get: { viewModel.editState.shadows },
                        set: { newVal in viewModel.updateStateDirectly { $0.shadows = newVal } }
                    ),
                    range: -1.0...1.0,
                    defaultValue: 0.0,
                    step: 0.02,
                    valueFormatter: { val in
                        let pct = Int(val * 100)
                        return pct >= 0 ? "+\(pct)%" : "\(pct)%"
                    },
                    onEditingEnded: { viewModel.recordHistorySnapshot() }
                )
            }
            
        case .color:
            switch viewModel.selectedColorSubTool {
            case .temperature:
                VerticalAdjustmentSlider(
                    systemIcon: viewModel.selectedColorSubTool.systemIcon,
                    title: viewModel.selectedColorSubTool.rawValue,
                    value: Binding(
                        get: { viewModel.editState.temperature },
                        set: { newVal in viewModel.updateStateDirectly { $0.temperature = newVal } }
                    ),
                    range: 2000.0...10000.0,
                    defaultValue: 6500.0,
                    step: 50.0,
                    valueFormatter: { val in
                        let diff = Int(val - 6500.0)
                        if diff == 0 { return "6500K" }
                        return diff > 0 ? "+\(diff)K" : "\(diff)K"
                    },
                    onEditingEnded: { viewModel.recordHistorySnapshot() }
                )
            case .tint:
                VerticalAdjustmentSlider(
                    systemIcon: viewModel.selectedColorSubTool.systemIcon,
                    title: viewModel.selectedColorSubTool.rawValue,
                    value: Binding(
                        get: { viewModel.editState.tint },
                        set: { newVal in viewModel.updateStateDirectly { $0.tint = newVal } }
                    ),
                    range: -100.0...100.0,
                    defaultValue: 0.0,
                    step: 1.0,
                    valueFormatter: { val in
                        let ival = Int(val)
                        return ival >= 0 ? "+\(ival)" : "\(ival)"
                    },
                    onEditingEnded: { viewModel.recordHistorySnapshot() }
                )
            case .saturation:
                VerticalAdjustmentSlider(
                    systemIcon: viewModel.selectedColorSubTool.systemIcon,
                    title: viewModel.selectedColorSubTool.rawValue,
                    value: Binding(
                        get: { viewModel.editState.saturation },
                        set: { newVal in viewModel.updateStateDirectly { $0.saturation = newVal } }
                    ),
                    range: 0.0...2.0,
                    defaultValue: 1.0,
                    step: 0.02,
                    valueFormatter: { val in
                        let pct = Int((val - 1.0) * 100)
                        return pct >= 0 ? "+\(pct)%" : "\(pct)%"
                    },
                    onEditingEnded: { viewModel.recordHistorySnapshot() }
                )
            case .vibrance:
                VerticalAdjustmentSlider(
                    systemIcon: viewModel.selectedColorSubTool.systemIcon,
                    title: viewModel.selectedColorSubTool.rawValue,
                    value: Binding(
                        get: { viewModel.editState.vibrance },
                        set: { newVal in viewModel.updateStateDirectly { $0.vibrance = newVal } }
                    ),
                    range: -1.0...1.0,
                    defaultValue: 0.0,
                    step: 0.02,
                    valueFormatter: { val in
                        let pct = Int(val * 100)
                        return pct >= 0 ? "+\(pct)%" : "\(pct)%"
                    },
                    onEditingEnded: { viewModel.recordHistorySnapshot() }
                )
            }
            
        case .portrait:
            VerticalAdjustmentSlider(
                systemIcon: "circle.dashed",
                title: "Fırça Boyutu",
                value: Binding(
                    get: { viewModel.healingBrushRadius },
                    set: { newVal in viewModel.healingBrushRadius = newVal }
                ),
                range: 0.010...0.050,
                defaultValue: 0.022,
                step: 0.002,
                valueFormatter: { val in "\(Int(val * 1000)) px" },
                onEditingEnded: {}
            )
            
        case .cinematic:
            if viewModel.editState.selectedLookId != nil {
                VerticalAdjustmentSlider(
                    systemIcon: "slider.vertical.3",
                    title: "Yoğunluk",
                    value: Binding(
                        get: { viewModel.editState.lookIntensity },
                        set: { newVal in viewModel.updateStateDirectly { $0.lookIntensity = newVal } }
                    ),
                    range: 0.0...1.0,
                    defaultValue: 1.0,
                    step: 0.02,
                    valueFormatter: { val in "\(Int(val * 100))%" },
                    onEditingEnded: { viewModel.recordHistorySnapshot() }
                )
            }
            
        case .mono:
            if viewModel.editState.isMonoActive {
                VerticalAdjustmentSlider(
                    systemIcon: "slider.vertical.3",
                    title: "Yoğunluk",
                    value: Binding(
                        get: { viewModel.editState.monoIntensity },
                        set: { newVal in viewModel.updateStateDirectly { $0.monoIntensity = newVal } }
                    ),
                    range: 0.0...1.0,
                    defaultValue: 1.0,
                    step: 0.02,
                    valueFormatter: { val in "\(Int(val * 100))%" },
                    onEditingEnded: { viewModel.recordHistorySnapshot() }
                )
            }
        }
    }
    
    // MARK: - Ultra-Compact 2-Tier Bottom Bar (Maximized Photo Viewport)
    
    private var bottomToolSection: some View {
        VStack(spacing: 0) {
            Divider()
                .foregroundColor(PhotonColors.divider)
            
            // Tier 1: Sub-tool Bar / Presets Row (Only ~42pt high, no large expanding panels!)
            Group {
                switch viewModel.activeCategory {
                case .light:
                    LightToolView(viewModel: viewModel)
                case .color:
                    ColorToolView(viewModel: viewModel)
                case .portrait:
                    SmoothToolView(viewModel: viewModel)
                case .cinematic:
                    CinematicToolView(viewModel: viewModel)
                case .mono:
                    MonoToolView(viewModel: viewModel)
                }
            }
            .frame(height: 48)
            .padding(.horizontal, PhotonSpacing.xxs)
            .animation(.spring(response: 0.28, dampingFraction: 0.85), value: viewModel.activeCategory)
            
            Divider()
                .foregroundColor(PhotonColors.divider.opacity(0.6))
            
            // Tier 2: Main Category Tabs (Compact ~46pt high)
            HStack(spacing: PhotonSpacing.xxs) {
                ForEach(EditorToolCategory.allCases) { category in
                    Button {
                        withAnimation(.easeInOut(duration: 0.18)) {
                            viewModel.activeCategory = category
                        }
                    } label: {
                        VStack(spacing: 2) {
                            Image(systemName: category.systemIcon)
                                .font(.system(size: 14, weight: viewModel.activeCategory == category ? .semibold : .regular))
                            
                            Text(category.rawValue)
                                .font(.system(size: 11, weight: viewModel.activeCategory == category ? .semibold : .regular))
                        }
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .padding(.vertical, 3)
                        .background(viewModel.activeCategory == category ? PhotonColors.surfaceSecondary : Color.clear)
                        .foregroundColor(viewModel.activeCategory == category ? PhotonColors.textPrimary : PhotonColors.textSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: PhotonCornerRadius.sm, style: .continuous))
                    }
                }
            }
            .padding(.horizontal, PhotonSpacing.xs)
            .padding(.top, 2)
            .padding(.bottom, 12)
        }
        .background(
            ZStack {
                Rectangle()
                    .fill(.ultraThinMaterial)
                PhotonColors.surfacePrimary.opacity(0.85)
            }
            .ignoresSafeArea(edges: .bottom)
        )
    }
}

/// An organic cosmetic brush wipe and sparkle dissolve effect that animates when a spot is healed.
public struct HealingWipeEffectView: View {
    let radius: CGFloat
    @State private var isAnimating: Bool = false
    
    public var body: some View {
        ZStack {
            // Expanding soft wipe aura
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.65),
                            PhotonColors.accent.opacity(0.35),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: radius * 1.2
                    )
                )
                .frame(width: radius * 2.2, height: radius * 2.2)
                .scaleEffect(isAnimating ? 1.4 : 0.6)
                .opacity(isAnimating ? 0.0 : 0.95)
            
            // Subtle rotating brush sparkle bristles
            Image(systemName: "sparkle")
                .font(.system(size: max(12, radius * 0.75)))
                .foregroundColor(.white)
                .rotationEffect(.degrees(isAnimating ? 45 : 0))
                .scaleEffect(isAnimating ? 1.25 : 0.4)
                .opacity(isAnimating ? 0.0 : 1.0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.45)) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    EditorView()
        .environment(NavigationState())
}
