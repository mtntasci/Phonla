//
//  FaceBoundingBoxOverlayView.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import SwiftUI
import Vision

/// Interactive UI overlay displaying face bounding boxes detected by Vision when Pürüzsüzleştir tool is active.
public struct FaceBoundingBoxOverlayView: View {
    public let faces: [VNFaceObservation]
    public let imageSize: CGSize
    public let canvasSize: CGSize
    
    public init(faces: [VNFaceObservation], imageSize: CGSize, canvasSize: CGSize) {
        self.faces = faces
        self.imageSize = imageSize
        self.canvasSize = canvasSize
    }
    
    public var body: some View {
        ZStack {
            if faces.isEmpty {
                // "Yüz algılanamadı" notification badge
                VStack {
                    HStack(spacing: PhotonSpacing.xs) {
                        Image(systemName: "person.slash.fill")
                            .font(.system(size: 13, weight: .semibold))
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
                    .shadow(color: Color.black.opacity(0.14), radius: 8, x: 0, y: 4)
                    .padding(.top, PhotonSpacing.md)
                    
                    Spacer()
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            } else {
                let rects = calculateFaceRects()
                
                ForEach(0..<rects.count, id: \.self) { index in
                    let rect = rects[index]
                    
                    ZStack(alignment: .topLeading) {
                        // Thin sleek bounding box border matching Photon design system
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(PhotonColors.accent, lineWidth: 1.5)
                            .shadow(color: PhotonColors.accent.opacity(0.35), radius: 6, x: 0, y: 2)
                        
                        // Face index pill tag if multiple faces detected
                        if faces.count > 1 {
                            Text("Yüz \(index + 1)")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(PhotonColors.accent)
                                .foregroundColor(PhotonColors.textInverted)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                .offset(x: 4, y: 4)
                        }
                    }
                    .frame(width: rect.width, height: rect.height)
                    .position(x: rect.midX, y: rect.midY)
                    .transition(.opacity)
                }
            }
        }
        .allowsHitTesting(false)
    }
    
    // MARK: - Geometry Calculation for aspectFit Mapping
    
    private func calculateFaceRects() -> [CGRect] {
        guard imageSize.width > 0, imageSize.height > 0, canvasSize.width > 0, canvasSize.height > 0 else {
            return []
        }
        
        let imageAspect = imageSize.width / imageSize.height
        let canvasAspect = canvasSize.width / canvasSize.height
        
        let displayedWidth: CGFloat
        let displayedHeight: CGFloat
        let offsetX: CGFloat
        let offsetY: CGFloat
        
        if imageAspect > canvasAspect {
            displayedWidth = canvasSize.width
            displayedHeight = canvasSize.width / imageAspect
            offsetX = 0
            offsetY = (canvasSize.height - displayedHeight) / 2.0
        } else {
            displayedHeight = canvasSize.height
            displayedWidth = canvasSize.height * imageAspect
            offsetX = (canvasSize.width - displayedWidth) / 2.0
            offsetY = 0
        }
        
        return faces.map { face -> CGRect in
            let bbox = face.boundingBox
            let w = bbox.width * displayedWidth
            let h = bbox.height * displayedHeight
            let x = offsetX + bbox.origin.x * displayedWidth
            let y = offsetY + (1.0 - bbox.origin.y - bbox.height) * displayedHeight
            return CGRect(x: x, y: y, width: w, height: h)
        }
    }
}
