//
//  EditorView.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import SwiftUI

/// Non-destructive photo editor powered by Core Image & Metal GPU pipeline.
public struct EditorView: View {
    @Environment(NavigationState.self) private var navigationState
    @State private var viewModel = EditorViewModel.shared
    @State private var showDiscardAlert: Bool = false
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // MARK: - Top Toolbar
            topToolbar
            
            // MARK: - Main Canvas Area
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
    
    // MARK: - Subviews
    
    private var topToolbar: some View {
        HStack {
            // Close / Back
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
            
            Spacer()
            
            // Before / After Compare Button
            if viewModel.isEdited {
                Button {
                    // Tap toggle or hold
                } label: {
                    HStack(spacing: PhotonSpacing.xs) {
                        Image(systemName: "square.split.2x1")
                            .font(.system(size: 13, weight: .medium))
                        Text(viewModel.isComparingOriginal ? "Orijinal" : "Düzenlenen")
                            .font(PhotonTypography.caption.weight(.medium))
                    }
                    .padding(.horizontal, PhotonSpacing.md)
                    .padding(.vertical, PhotonSpacing.xs)
                    .background(PhotonColors.surfaceSecondary)
                    .foregroundColor(PhotonColors.textPrimary)
                    .clipShape(Capsule())
                }
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in viewModel.isComparingOriginal = true }
                        .onEnded { _ in viewModel.isComparingOriginal = false }
                )
            }
            
            // Reset Button
            if viewModel.isEdited {
                Button {
                    withAnimation {
                        viewModel.resetState()
                    }
                } label: {
                    Text("Sıfırla")
                        .font(PhotonTypography.bodyMedium)
                        .foregroundColor(PhotonColors.textSecondary)
                }
                .padding(.horizontal, PhotonSpacing.sm)
            }
            
            // Export / Save Action Button
            PhotonButton("Kaydet", variant: .primary, size: .small, isFullWidth: false) {
                // Export pipeline will be fully wired in Phase 9
            }
        }
        .padding(.horizontal, PhotonSpacing.lg)
        .padding(.vertical, PhotonSpacing.sm)
    }
    
    private var canvasArea: some View {
        GeometryReader { geometry in
            ZStack {
                PhotonColors.surfaceTertiary
                    .ignoresSafeArea()
                
                if let displayImage = viewModel.currentDisplayImage {
                    Image(uiImage: displayImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: geometry.size.width - PhotonSpacing.lg, maxHeight: geometry.size.height - PhotonSpacing.lg)
                        .clipShape(RoundedRectangle(cornerRadius: PhotonCornerRadius.sm, style: .continuous))
                        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
                        .overlay(
                            RoundedRectangle(cornerRadius: PhotonCornerRadius.sm, style: .continuous)
                                .strokeBorder(PhotonColors.border, lineWidth: 0.5)
                        )
                } else {
                    ProgressView()
                        .tint(PhotonColors.textPrimary)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private var bottomToolSection: some View {
        VStack(spacing: 0) {
            Divider()
                .foregroundColor(PhotonColors.divider)
            
            // Active Tool Info / Parameter Preview Placeholder (Foundation for Phase 5)
            VStack(spacing: PhotonSpacing.xs) {
                HStack {
                    Image(systemName: viewModel.activeCategory.systemIcon)
                        .font(.system(size: 14, weight: .medium))
                    Text(categoryDescription(for: viewModel.activeCategory))
                        .font(PhotonTypography.caption)
                    Spacer()
                    if viewModel.isEdited {
                        Text("Aktif Düzenleme")
                            .font(PhotonTypography.caption)
                            .foregroundColor(PhotonColors.textTertiary)
                    }
                }
                .foregroundColor(PhotonColors.textSecondary)
                .padding(.horizontal, PhotonSpacing.lg)
                .padding(.top, PhotonSpacing.sm)
            }
            
            // Category Tabs Bar
            HStack(spacing: PhotonSpacing.xs) {
                ForEach(EditorToolCategory.allCases) { category in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
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
            .padding(.horizontal, PhotonSpacing.md)
            .padding(.top, PhotonSpacing.xs)
            .padding(.bottom, PhotonSpacing.lg)
        }
        .background(PhotonColors.surfacePrimary)
    }
    
    private func categoryDescription(for category: EditorToolCategory) -> String {
        switch category {
        case .light:
            return "Pozlama, Parlaklık, Kontrast, Açık Tonlar, Gölgeler"
        case .color:
            return "Sıcaklık, Ton, Doygunluk, Canlılık"
        case .cinematic:
            return "Sinematik LUT ve Renk Derecelendirme"
        case .mono:
            return "Luminance ve RGB Tabanlı Monochrome Motoru"
        }
    }
}

#Preview {
    EditorView()
        .environment(NavigationState())
}
