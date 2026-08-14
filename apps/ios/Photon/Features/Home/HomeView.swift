//
//  HomeView.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import SwiftUI
import PhotosUI

/// Minimalist, pure-white Home screen featuring the native PhotosPicker for photo import.
public struct HomeView: View {
    @Environment(NavigationState.self) private var navigationState
    @State private var selectedItem: PhotosPickerItem?
    @State private var isLoadingPhoto: Bool = false
    @State private var errorMessage: String?
    
    private let photoLibraryService = PhotoLibraryService.shared
    private let editorViewModel = EditorViewModel.shared
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // Minimal Navigation Header
            HStack {
                Text("PHOTON")
                    .font(PhotonTypography.titleMedium)
                    .tracking(3)
                    .foregroundColor(PhotonColors.textPrimary)
                
                Spacer()
                
                Button {
                    navigationState.navigateToSettings()
                } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(PhotonColors.textPrimary)
                        .frame(width: 40, height: 40)
                        .background(PhotonColors.surfaceSecondary)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, PhotonSpacing.xl)
            .padding(.vertical, PhotonSpacing.md)
            
            Spacer()
            
            // Center Hero / CTA Area
            VStack(spacing: PhotonSpacing.xl) {
                // Photo-centric visual icon container
                ZStack {
                    RoundedRectangle(cornerRadius: PhotonCornerRadius.xl, style: .continuous)
                        .fill(PhotonColors.surfaceSecondary)
                        .frame(width: 104, height: 104)
                    
                    if isLoadingPhoto {
                        ProgressView()
                            .scaleEffect(1.2)
                            .tint(PhotonColors.textPrimary)
                    } else {
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 42, weight: .light))
                            .foregroundColor(PhotonColors.textPrimary)
                    }
                }
                
                VStack(spacing: PhotonSpacing.xs) {
                    Text("Işık & Sinematik")
                        .font(PhotonTypography.titleLarge)
                        .foregroundColor(PhotonColors.textPrimary)
                    
                    Text("Düzenlemek için galerinizden bir fotoğraf seçin.")
                        .font(PhotonTypography.bodyMedium)
                        .foregroundColor(PhotonColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                
                if let errorMessage {
                    Text(errorMessage)
                        .font(PhotonTypography.caption)
                        .foregroundColor(PhotonColors.error)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, PhotonSpacing.md)
                }
                
                // Prominent Native PhotosPicker CTA
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    HStack(spacing: PhotonSpacing.sm) {
                        Image(systemName: "plus")
                            .font(PhotonTypography.button)
                        Text("Fotoğraf Yükle")
                            .font(PhotonTypography.button)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(PhotonColors.textPrimary)
                    .foregroundColor(PhotonColors.textInverted)
                    .clipShape(RoundedRectangle(cornerRadius: PhotonCornerRadius.md, style: .continuous))
                }
                .buttonStyle(PhotonPressableButtonStyle())
                .disabled(isLoadingPhoto)
                .padding(.horizontal, PhotonSpacing.xl)
                .padding(.top, PhotonSpacing.sm)
            }
            .padding(.horizontal, PhotonSpacing.lg)
            
            Spacer()
            
            // Privacy Commitment Footer
            HStack(spacing: PhotonSpacing.xs) {
                Image(systemName: "lock.shield")
                    .font(PhotonTypography.caption)
                Text("Fotoğraflarınız yalnızca bu cihazda işlenir.")
                    .font(PhotonTypography.caption)
            }
            .foregroundColor(PhotonColors.textTertiary)
            .padding(.bottom, PhotonSpacing.xl)
        }
        .photonBackground()
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
