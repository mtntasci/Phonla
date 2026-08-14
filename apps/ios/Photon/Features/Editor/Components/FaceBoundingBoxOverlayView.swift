//
//  FaceBoundingBoxOverlayView.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import SwiftUI
import Vision

/// Interactive UI overlay displaying face bounding boxes detected by Vision when Pürüzsüzleştir tool is active.
/// Does not affect rendered / exported pixels.
public struct FaceBoundingBoxOverlayView: View {
    public let faces: [VNFaceObservation]
    public let isDetecting: Bool
    
    public init(faces: [VNFaceObservation], isDetecting: Bool = false) {
        self.faces = faces
        self.isDetecting = isDetecting
    }
    
    public var body: some View {
        GeometryReader { geometry in
            let viewWidth = geometry.size.width
            let viewHeight = geometry.size.height
            
            ZStack {
                if !isDetecting && faces.isEmpty {
                    // "Yüz algılanamadı" notification badge
                    VStack {
                        HStack(spacing: PhotonSpacing.xs) {
                            Image(systemName: "person.slash.fill")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(PhotonColors.textSecondary)
                            Text("Yüz algılanamadı")
                                .font(PhotonTypography.caption.weight(.semibold))
                                .foregroundColor(PhotonColors.textPrimary)
                        }
                        .padding(.horizontal, PhotonSpacing.md)
                        .padding(.vertical, PhotonSpacing.xs)
                        .background(PhotonColors.surfacePrimary.opacity(0.92))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().strokeBorder(PhotonColors.border, lineWidth: 0.5)
                        )
                        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 3)
                        .padding(.top, PhotonSpacing.md)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                } else if !faces.isEmpty {
                    ForEach(Array(faces.enumerated()), id: \.offset) { index, face in
                        let bbox = face.boundingBox
                        let w = bbox.width * viewWidth
                        let h = bbox.height * viewHeight
                        let x = bbox.origin.x * viewWidth
                        let y = (1.0 - bbox.origin.y - bbox.height) * viewHeight
                        
                        ZStack(alignment: .topLeading) {
                            // Thin sleek bounding box border matching Photon design system
                            RoundedRectangle(cornerRadius: PhotonCornerRadius.sm, style: .continuous)
                                .stroke(PhotonColors.accent, lineWidth: 1.5)
                                .shadow(color: PhotonColors.accent.opacity(0.35), radius: 6, x: 0, y: 2)
                            
                            // Multi-face indicator tag if 2 or more faces detected
                            if faces.count > 1 {
                                Text("Yüz \(index + 1)")
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(PhotonColors.accent)
                                    .foregroundColor(PhotonColors.textInverted)
                                    .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                                    .offset(x: 4, y: 4)
                            }
                        }
                        .frame(width: w, height: h)
                        .position(x: x + w / 2.0, y: y + h / 2.0)
                        .transition(.opacity)
                    }
                }
            }
        }
        .allowsHitTesting(false)
        .animation(.easeInOut(duration: 0.25), value: faces.count)
    }
}
