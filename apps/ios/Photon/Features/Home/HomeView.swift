//
//  HomeView.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import SwiftUI
import PhotosUI
import Combine

/// Premium, full-screen cinematic Home screen featuring dynamic background crossfade and native PhotosPicker.
public struct HomeView: View {
    @Environment(NavigationState.self) private var navigationState
    @State private var selectedItem: PhotosPickerItem?
    @State private var isLoadingPhoto: Bool = false
    @State private var errorMessage: String?
    
    // Dynamic Background State
    @State private var currentBgIndex: Int = 0
    private let backgroundImages = ["home_bg_cinema", "home_bg_nature", "home_bg_urban"]
    private let timer = Timer.publish(every: 5.5, on: .main, in: .common).autoconnect()
    
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
            .animation(.easeInOut(duration: 1.6), value: currentBgIndex)
            .onReceive(timer) { _ in
                withAnimation(.easeInOut(duration: 1.6)) {
                    currentBgIndex = (currentBgIndex + 1) % backgroundImages.count
                }
            }
            
            // MARK: - Soft Gradient Overlays for UI Contrast
            VStack(spacing: 0) {
                // Top Header Gradient
                LinearGradient(
                    colors: [Color.black.opacity(0.6), Color.black.opacity(0.15), Color.clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 180)
                
                Spacer()
                
                // Bottom Gradient
                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.35), Color.black.opacity(0.8)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 260)
            }
            .ignoresSafeArea()
            
            // MARK: - Foreground Content & Actions
            VStack(spacing: 0) {
                // Top Header: Branding & Settings
                HStack(spacing: PhotonSpacing.sm) {
                    Image("PhotonLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    
                    Text("PHOTON")
                        .font(PhotonTypography.titleMedium)
                        .tracking(3)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button {
                        navigationState.navigateToSettings()
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 38, height: 38)
                            .background(Color.white.opacity(0.18))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, PhotonSpacing.xl)
                .padding(.top, PhotonSpacing.sm)
                
                Spacer()
                
                // Center Atmospheric Slogan
                VStack(spacing: PhotonSpacing.xs) {
                    Text("Işık • Sinematik • Monochrome")
                        .font(PhotonTypography.headline)
                        .tracking(2)
                        .foregroundColor(.white.opacity(0.92))
                        .shadow(color: Color.black.opacity(0.5), radius: 8, x: 0, y: 2)
                    
                    Text("Profesyonel fotoğraf düzenleme")
                        .font(PhotonTypography.bodyMedium)
                        .foregroundColor(.white.opacity(0.75))
                        .shadow(color: Color.black.opacity(0.5), radius: 6, x: 0, y: 2)
                }
                .padding(.horizontal, PhotonSpacing.lg)
                
                Spacer()
                
                // Error Alert if photo loading failed
                if let errorMessage {
                    Text(errorMessage)
                        .font(PhotonTypography.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, PhotonSpacing.md)
                        .padding(.vertical, PhotonSpacing.xs)
                        .background(PhotonColors.error.opacity(0.9))
                        .clipShape(Capsule())
                        .padding(.bottom, PhotonSpacing.sm)
                }
                
                // MARK: - Bottom Primary Action: Fotoğraf Yükle
                VStack(spacing: PhotonSpacing.md) {
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
                        .shadow(color: Color.black.opacity(0.25), radius: 16, x: 0, y: 6)
                    }
                    .buttonStyle(PhotonPressableButtonStyle())
                    .disabled(isLoadingPhoto)
                    .padding(.horizontal, PhotonSpacing.xl)
                    
                    // Privacy Footer
                    HStack(spacing: PhotonSpacing.xxs) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 11))
                        Text("Fotoğraflarınız yalnızca bu cihazda işlenir.")
                            .font(PhotonTypography.caption)
                    }
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.bottom, PhotonSpacing.lg)
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
}

#Preview {
    HomeView()
        .environment(NavigationState())
}
