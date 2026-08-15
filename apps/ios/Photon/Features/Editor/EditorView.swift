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
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: displayImage)
                            .resizable()
                            .scaledToFit()
                            .frame(
                                maxWidth: availableWidth,
                                maxHeight: availableHeight
                            )
                            .clipShape(RoundedRectangle(cornerRadius: PhotonCornerRadius.sm, style: .continuous))
                            .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
                            .overlay(
                                RoundedRectangle(cornerRadius: PhotonCornerRadius.sm, style: .continuous)
                                    .strokeBorder(PhotonColors.border, lineWidth: 0.5)
                            )
                            // Spot Healing interactive tap overlay when Healing subtool is active
                            .overlay {
                                if viewModel.activeCategory == .portrait && viewModel.selectedPortraitSubTool == .healing && !viewModel.isComparingOriginal {
                                    GeometryReader { imgGeo in
                                        Color.clear
                                            .contentShape(Rectangle())
                                            .onTapGesture { location in
                                                let w = imgGeo.size.width
                                                let h = imgGeo.size.height
                                                guard w > 0, h > 0 else { return }
                                                let normX = location.x / w
                                                let normY = location.y / h
                                                viewModel.addHealedSpot(x: normX, y: normY)
                                            }
                                            .overlay {
                                                // Render highly visible visual markers on healed spots
                                                ForEach(viewModel.editState.healedSpots) { spot in
                                                    let spotX = spot.x * imgGeo.size.width
                                                    let spotY = spot.y * imgGeo.size.height
                                                    let spotPx = max(24, spot.radius * max(imgGeo.size.width, imgGeo.size.height) * 2)
                                                    
                                                    Circle()
                                                        .strokeBorder(Color.white, lineWidth: 2.0)
                                                        .background(Circle().fill(Color.white.opacity(0.25)))
                                                        .shadow(color: Color.black.opacity(0.6), radius: 3, x: 0, y: 2)
                                                        .frame(width: spotPx, height: spotPx)
                                                        .position(x: spotX, y: spotY)
                                                        .allowsHitTesting(false)
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
                                        zoomScale = min(max(newScale, 1.0), 5.0)
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
                                        let distance = hypot(value.translation.width, value.translation.height)
                                        if zoomScale > 1.05 && distance > 10 {
                                            isPanning = true
                                            viewModel.isComparingOriginal = false
                                            panOffset = CGSize(
                                                width: lastPanOffset.width + value.translation.width,
                                                height: lastPanOffset.height + value.translation.height
                                            )
                                        } else if !isPanning && viewModel.isEdited {
                                            // Press and hold anywhere on photo activates Before/After without shifting
                                            viewModel.isComparingOriginal = true
                                        }
                                    }
                                    .onEnded { _ in
                                        viewModel.isComparingOriginal = false
                                        if isPanning {
                                            lastPanOffset = panOffset
                                            isPanning = false
                                        }
                                    }
                            )
                            // Double Tap to toggle between face/detailed zoom and normal view
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
                        
                        // "Orijinal" overlay tag when comparing
                        if viewModel.isComparingOriginal {
                            HStack(spacing: PhotonSpacing.xxs) {
                                Image(systemName: "eye.fill")
                                    .font(.system(size: 11))
                                Text("Orijinal")
                                    .font(PhotonTypography.caption.weight(.semibold))
                            }
                            .padding(.horizontal, PhotonSpacing.sm)
                            .padding(.vertical, PhotonSpacing.xxs)
                            .background(Color.black.opacity(0.65))
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .padding()
                        }
                        
                        // "Lekeye dokunun" floating hint
                        if viewModel.activeCategory == .portrait && viewModel.selectedPortraitSubTool == .healing && viewModel.editState.healedSpots.isEmpty {
                            VStack {
                                HStack(spacing: 4) {
                                    Image(systemName: "hand.tap.fill")
                                        .font(.system(size: 13))
                                    Text("Lekeye dokunun")
                                        .font(.system(size: 13, weight: .semibold))
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule())
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                                .padding(.top, 16)
                                
                                Spacer()
                            }
                            .allowsHitTesting(false)
                        }
                    }
                } else {
                    ProgressView()
                        .tint(PhotonColors.textPrimary)
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
            switch viewModel.selectedPortraitSubTool {
            case .smoothing:
                VerticalAdjustmentSlider(
                    systemIcon: "sparkles",
                    title: "Pürüzsüzlük",
                    value: Binding(
                        get: { viewModel.editState.skinSmoothing },
                        set: { newVal in viewModel.updateStateDirectly { $0.skinSmoothing = newVal } }
                    ),
                    range: 0.0...100.0,
                    defaultValue: 0.0,
                    step: 1.0,
                    valueFormatter: { val in "\(Int(val))%" },
                    onEditingEnded: { viewModel.recordHistorySnapshot() }
                )
            case .healing:
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
            }
            
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
            .frame(height: 44)
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

#Preview {
    EditorView()
        .environment(NavigationState())
}
