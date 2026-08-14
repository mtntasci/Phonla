//
//  PhotonButton.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import SwiftUI

/// Available button visual variants in Photon's minimalist design system.
public enum PhotonButtonVariant {
    /// Solid dark background (#111111) with white text
    case primary
    /// Light gray background (#F5F5F7) with dark text
    case secondary
    /// White background with 1pt subtle border (#E5E5EA) and dark text
    case outline
    /// Transparent background with dark text
    case ghost
    /// Destructive solid red or red text
    case destructive
}

/// Available button size variants in Photon's design system.
public enum PhotonButtonSize {
    case small
    case medium
    case large
    
    var height: CGFloat {
        switch self {
        case .small: return 36
        case .medium: return 44
        case .large: return 52
        }
    }
    
    var horizontalPadding: CGFloat {
        switch self {
        case .small: return PhotonSpacing.md
        case .medium: return PhotonSpacing.lg
        case .large: return PhotonSpacing.xxl
        }
    }
    
    var font: Font {
        switch self {
        case .small: return PhotonTypography.bodyMedium.weight(.medium)
        case .medium: return PhotonTypography.button
        case .large: return PhotonTypography.button
        }
    }
    
    var cornerRadius: CGFloat {
        switch self {
        case .small: return PhotonCornerRadius.sm
        case .medium: return PhotonCornerRadius.md
        case .large: return PhotonCornerRadius.md
        }
    }
}

/// Minimalist, responsive button component following Photon's light-mode design guidelines.
public struct PhotonButton: View {
    private let title: String
    private let systemImage: String?
    private let variant: PhotonButtonVariant
    private let size: PhotonButtonSize
    private let isFullWidth: Bool
    private let isLoading: Bool
    private let action: () -> Void
    
    public init(
        _ title: String,
        systemImage: String? = nil,
        variant: PhotonButtonVariant = .primary,
        size: PhotonButtonSize = .large,
        isFullWidth: Bool = true,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.variant = variant
        self.size = size
        self.isFullWidth = isFullWidth
        self.isLoading = isLoading
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: PhotonSpacing.sm) {
                if isLoading {
                    ProgressView()
                        .tint(foregroundColor)
                        .scaleEffect(0.85)
                } else {
                    if let systemImage {
                        Image(systemName: systemImage)
                            .font(size.font)
                    }
                    Text(title)
                        .font(size.font)
                }
            }
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .frame(height: size.height)
            .padding(.horizontal, size.horizontalPadding)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous)
                    .strokeBorder(borderColor, lineWidth: borderWidth)
            )
        }
        .buttonStyle(PhotonPressableButtonStyle())
        .disabled(isLoading)
    }
    
    private var backgroundColor: Color {
        switch variant {
        case .primary:
            return PhotonColors.textPrimary
        case .secondary:
            return PhotonColors.surfaceSecondary
        case .outline:
            return PhotonColors.surfacePrimary
        case .ghost:
            return Color.clear
        case .destructive:
            return PhotonColors.error
        }
    }
    
    private var foregroundColor: Color {
        switch variant {
        case .primary, .destructive:
            return PhotonColors.textInverted
        case .secondary, .outline, .ghost:
            return PhotonColors.textPrimary
        }
    }
    
    private var borderColor: Color {
        switch variant {
        case .outline:
            return PhotonColors.border
        default:
            return Color.clear
        }
    }
    
    private var borderWidth: CGFloat {
        switch variant {
        case .outline:
            return 1.0
        default:
            return 0.0
        }
    }
}

/// Custom button style providing subtle micro-animations (scale 0.98 on press) for a premium native feel.
public struct PhotonPressableButtonStyle: ButtonStyle {
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}

#Preview {
    VStack(spacing: PhotonSpacing.lg) {
        PhotonButton("Fotoğraf Yükle", systemImage: "photo.badge.plus", variant: .primary) {}
        PhotonButton("Secondary Button", variant: .secondary) {}
        PhotonButton("Outline Button", variant: .outline) {}
        PhotonButton("Ghost Button", variant: .ghost) {}
    }
    .padding(PhotonSpacing.lg)
    .background(PhotonColors.background)
}
