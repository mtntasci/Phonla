//
//  HomeView.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import SwiftUI
import PhotosUI
import Combine

/// Premium, full-screen cinematic Home screen featuring transparent vector branding,
/// dynamic background crossfade, user avatar, and optimized bottom CTA layout.
public struct HomeView: View {
    @Environment(NavigationState.self) private var navigationState
    @State private var authService = AuthService.shared
    @State private var selectedItem: PhotosPickerItem?
    @State private var isLoadingPhoto: Bool = false
    @State private var errorMessage: String?
    
    // Dynamic Background State
    @State private var currentBgIndex: Int = 0
    private let backgroundImages = ["home_bg_cinema", "home_bg_nature", "home_bg_urban"]
    private let timer = Timer.publish(every: 6.0, on: .main, in: .common).autoconnect()
    
    private let photoLibraryService = PhotoLibraryService.shared
    private let editorViewModel = EditorViewModel.shared
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // MARK: - Dynamic Fullscreen Cinematic Background
            GeometryReader { proxy in
                ZStack {
                    ForEach(0..<backgroundImages.count, id: \.self) { index in
                        if index == currentBgIndex {
                            Image(backgroundImages[index])
                                .resizable()
                                .scaledToFill()
                                .frame(width: proxy.size.width, height: proxy.size.height)
                                .clipped()
                                .transition(.opacity)
                        }
                    }
                }
            }
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 1.5), value: currentBgIndex)
            .onReceive(timer) { _ in
                withAnimation(.easeInOut(duration: 1.5)) {
                    currentBgIndex = (currentBgIndex + 1) % backgroundImages.count
                }
            }
            
            // MARK: - Soft Gradient Overlays for UI Contrast
            VStack(spacing: 0) {
                // Top Header Gradient
                LinearGradient(
                    colors: [Color.black.opacity(0.65), Color.black.opacity(0.18), Color.clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 160)
                
                Spacer()
                
                // Bottom Gradient
                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.4), Color.black.opacity(0.85)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 280)
            }
            .ignoresSafeArea()
            
            // MARK: - Foreground Content & Actions
            VStack(spacing: 0) {
                // Top Header: Transparent Vector Logo & User Avatar
                HStack(spacing: PhotonSpacing.sm) {
                    PhotonLogoMark(size: 26, color: .white)
                        .shadow(color: Color.black.opacity(0.6), radius: 4, x: 0, y: 1)
                    
                    Text("PHOTON")
                        .font(PhotonTypography.headline)
                        .tracking(3.5)
                        .foregroundColor(.white)
                        .shadow(color: Color.black.opacity(0.6), radius: 4, x: 0, y: 1)
                    
                    Spacer()
                    
                    // User Avatar Button -> Profile / Settings
                    Button {
                        navigationState.navigateToSettings()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 38, height: 38)
                            
                            if let photoURL = authService.currentSession?.photoURL {
                                AsyncImage(url: photoURL) { phase in
                                    if let image = phase.image {
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 38, height: 38)
                                            .clipShape(Circle())
                                    } else {
                                        avatarFallback
                                    }
                                }
                            } else {
                                avatarFallback
                            }
                        }
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.35), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.4), radius: 4, x: 0, y: 2)
                    }
                }
                .padding(.horizontal, PhotonSpacing.xl)
                .padding(.top, PhotonSpacing.sm)
                
                // Center photo area is left clean and unobstructed
                Spacer()
                
                // Bottom Section: Slogan moved right above the button
                VStack(spacing: PhotonSpacing.md) {
                    // Typography directly above CTA
                    VStack(spacing: PhotonSpacing.xxs) {
                        Text("Işık • Sinematik • Siyah & Beyaz")
                            .font(PhotonTypography.headline)
                            .tracking(2)
                            .foregroundColor(.white.opacity(0.95))
                            .shadow(color: Color.black.opacity(0.7), radius: 8, x: 0, y: 2)
                        
                        Text("Profesyonel fotoğraf düzenleme")
                            .font(PhotonTypography.caption)
                            .foregroundColor(.white.opacity(0.75))
                            .shadow(color: Color.black.opacity(0.6), radius: 6, x: 0, y: 2)
                    }
                    .padding(.bottom, PhotonSpacing.xs)
                    
                    // Error Alert if photo loading failed
                    if let errorMessage {
                        Text(errorMessage)
                            .font(PhotonTypography.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, PhotonSpacing.md)
                            .padding(.vertical, PhotonSpacing.xs)
                            .background(PhotonColors.error.opacity(0.9))
                            .clipShape(Capsule())
                    }
                    
                    // MARK: - Primary Action: Fotoğraf Yükle
                    PhotosPicker(
                        selection: $selectedItem,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        HStack(spacing: PhotonSpacing.sm) {
                            if isLoadingPhoto {
                                ProgressView()
                                    .tint(PhotonColors.textPrimary)
                                    .scaleEffect(0.9)
                            } else {
                                Image(systemName: "plus")
                                    .font(PhotonTypography.button)
                            }
                            
                            Text(isLoadingPhoto ? "Fotoğraf Yükleniyor..." : "Fotoğraf Yükle")
                                .font(PhotonTypography.button)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color.white)
                        .foregroundColor(PhotonColors.textPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .shadow(color: Color.black.opacity(0.35), radius: 18, x: 0, y: 8)
                    }
                    .buttonStyle(PhotonPressableButtonStyle())
                    .disabled(isLoadingPhoto)
                    .padding(.horizontal, PhotonSpacing.xl)
                    .padding(.bottom, PhotonSpacing.xxl)
                }
            }
        }
        .onChange(of: selectedItem) { _, newItem in
            guard let newItem else { return }
            handleSelectedPhoto(item: newItem)
        }
    }
    
    private func handleSelectedPhoto(item: PhotosPickerItem) {
        isLoadingPhoto = true
        errorMessage = nil
        
        Task {
            do {
                let photo = try await photoLibraryService.loadPhoto(from: item)
                editorViewModel.setPhoto(photo)
                navigationState.navigateToEditor()
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoadingPhoto = false
            selectedItem = nil
        }
    }
    
    @ViewBuilder
    private var avatarFallback: some View {
        if let initial = authService.currentSession?.displayName?.prefix(1).uppercased(), !initial.isEmpty {
            Text(initial)
                .font(PhotonTypography.caption.weight(.bold))
                .foregroundColor(.white)
        } else {
            Image(systemName: "person.crop.circle")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    HomeView()
        .environment(NavigationState())
}
