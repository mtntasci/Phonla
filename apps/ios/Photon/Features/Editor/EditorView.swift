//
//  EditorView.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import SwiftUI

/// Non-destructive photo editor powered by Core Image & Metal GPU pipeline.
/// Supports real-time Light, Color, Cinematic, Mono processing, Undo/Redo, Before/After, and full-resolution export.
public struct EditorView: View {
    @Environment(NavigationState.self) private var navigationState
    @State private var viewModel = EditorViewModel.shared
    @State private var showDiscardAlert: Bool = false
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // MARK: - Top Toolbar
            topToolbar
            
            // MARK: - Main Canvas Area (Photo Preview & Gestures)
            canvasArea
            
            // MARK: - Bottom Tool Section
            bottomToolSection
        }
        .photonBackground()
        .confirmationDialog(
            "Değişiklikleri Sil",
            isPresented: $showDiscardAlert,
            titleVisibility: .visible
        ) {
            Button("Değişiklikleri Sil ve Çık", role: .destructive) {
                viewModel.resetState()
                navigationState.navigateToHome()
            }
            Button("İptal", role: .cancel) {}
        } message: {
            Text("Kaydedilmemiş düzenlemeleriniz kaybolacak.")
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
                    .font(.system(size: 15, weight: .semibold))
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
                    .font(.system(size: 14, weight: .semibold))
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
                    .font(.system(size: 14, weight: .semibold))
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
        .padding(.vertical, PhotonSpacing.sm)
    }
    
    // MARK: - Main Canvas Area
    
    private var canvasArea: some View {
        GeometryReader { geometry in
            ZStack {
                PhotonColors.surfaceTertiary
                    .ignoresSafeArea()
                
                if let displayImage = viewModel.currentDisplayImage {
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: displayImage)
                            .resizable()
                            .scaledToFit()
                            .frame(
                                maxWidth: geometry.size.width - PhotonSpacing.md,
                                maxHeight: geometry.size.height - PhotonSpacing.sm
                            )
                            .clipShape(RoundedRectangle(cornerRadius: PhotonCornerRadius.sm, style: .continuous))
                            .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
                            .overlay(
                                RoundedRectangle(cornerRadius: PhotonCornerRadius.sm, style: .continuous)
                                    .strokeBorder(PhotonColors.border, lineWidth: 0.5)
                            )
                            // Hold anywhere on photo canvas for Before / After
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { _ in
                                        if viewModel.isEdited {
                                            viewModel.isComparingOriginal = true
                                        }
                                    }
                                    .onEnded { _ in
                                        viewModel.isComparingOriginal = false
                                    }
                            )
                        
                        // "Orijinal" overlay tag when comparing
                        if viewModel.isComparingOriginal {
                            Text("Orijinal")
                                .font(PhotonTypography.caption.weight(.semibold))
                                .padding(.horizontal, PhotonSpacing.sm)
                                .padding(.vertical, PhotonSpacing.xxs)
                                .background(PhotonColors.textPrimary.opacity(0.85))
                                .foregroundColor(PhotonColors.textInverted)
                                .clipShape(Capsule())
                                .padding(PhotonSpacing.md)
                                .transition(.opacity)
                        }
                    }
                } else {
                    ProgressView()
                        .tint(PhotonColors.textPrimary)
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
        }
    }
    
    // MARK: - Bottom Tool Section
    
    private var bottomToolSection: some View {
        VStack(spacing: 0) {
            Divider()
                .foregroundColor(PhotonColors.divider)
            
            // Active Tool Adjustment Panel (Height fixed for stability)
            Group {
                switch viewModel.activeCategory {
                case .light:
                    LightToolView(viewModel: viewModel)
                case .color:
                    ColorToolView(viewModel: viewModel)
                case .cinematic:
                    CinematicToolView(viewModel: viewModel)
                case .mono:
                    MonoToolView(viewModel: viewModel)
                }
            }
            .frame(height: 144)
            
            Divider()
                .foregroundColor(PhotonColors.divider)
            
            // Category Tabs Bar
            HStack(spacing: PhotonSpacing.xs) {
                ForEach(EditorToolCategory.allCases) { category in
                    Button {
                        withAnimation(.easeInOut(duration: 0.18)) {
                            viewModel.activeCategory = category
                        }
                    } label: {
                        VStack(spacing: PhotonSpacing.xxs) {
                            Image(systemName: category.systemIcon)
                                .font(.system(size: 16, weight: viewModel.activeCategory == category ? .semibold : .regular))
                            
                            Text(category.rawValue)
                                .font(PhotonTypography.caption.weight(viewModel.activeCategory == category ? .semibold : .regular))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, PhotonSpacing.sm)
                        .background(viewModel.activeCategory == category ? PhotonColors.surfaceSecondary : Color.clear)
                        .foregroundColor(viewModel.activeCategory == category ? PhotonColors.textPrimary : PhotonColors.textSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: PhotonCornerRadius.sm, style: .continuous))
                    }
                }
            }
            .padding(.horizontal, PhotonSpacing.sm)
            .padding(.top, PhotonSpacing.xxs)
            .padding(.bottom, PhotonSpacing.lg)
        }
        .background(PhotonColors.surfacePrimary)
    }
}

#Preview {
    EditorView()
        .environment(NavigationState())
}
