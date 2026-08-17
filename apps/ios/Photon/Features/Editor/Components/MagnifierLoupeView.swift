//
//  MagnifierLoupeView.swift
//  Photon
//
//  Created by Metin TASCI on 17.08.2026.
//

import SwiftUI

/// High-precision interactive Magnifier Loupe (Büyüteç) designed for pixel-perfect Spot Healing on skin.
/// Hovers gracefully above the user's touch so the finger never obstructs the blemish.
public struct MagnifierLoupeView: View {
    let displayImage: UIImage?
    let touchLocation: CGPoint
    let normalizedPoint: CGPoint
    let brushRadius: Float
    let canvasSize: CGSize
    let zoomScale: CGFloat
    
    private let loupeDiameter: CGFloat = 120.0
    private let magnification: CGFloat = 2.6
    
    public init(
        displayImage: UIImage?,
        touchLocation: CGPoint,
        normalizedPoint: CGPoint,
        brushRadius: Float,
        canvasSize: CGSize,
        zoomScale: CGFloat
    ) {
        self.displayImage = displayImage
        self.touchLocation = touchLocation
        self.normalizedPoint = normalizedPoint
        self.brushRadius = brushRadius
        self.canvasSize = canvasSize
        self.zoomScale = zoomScale
    }
    
    /// Computes optimal loupe position to prevent clipping at screen boundaries
    private var loupeOffset: CGSize {
        let isNearTop = touchLocation.y < 130
        let verticalOffset: CGFloat = isNearTop ? 85 : -85
        
        // Clamp horizontal offset to keep loupe within screen bounds
        let halfLoupe = loupeDiameter / 2.0
        let targetX = touchLocation.x
        let clampedX = min(max(targetX, halfLoupe + 16), canvasSize.width - halfLoupe - 16)
        let horizontalShift = clampedX - targetX
        
        return CGSize(width: horizontalShift, height: verticalOffset)
    }
    
    public var body: some View {
        ZStack {
            if let image = displayImage {
                // Loupe Magnified Content
                GeometryReader { geo in
                    let imgW = canvasSize.width
                    let imgH = canvasSize.height
                    
                    ZStack {
                        // Background base fill
                        Color.black.opacity(0.85)
                        
                        // Magnified Image centered at the touch's normalized coordinate
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: imgW * magnification * zoomScale, height: imgH * magnification * zoomScale)
                            .offset(
                                x: (0.5 - normalizedPoint.x) * imgW * magnification * zoomScale,
                                y: (0.5 - normalizedPoint.y) * imgH * magnification * zoomScale
                            )
                        
                        // Center Cosmetic Brush Reticle
                        ZStack {
                            let effectiveBrushPx = CGFloat(brushRadius) * max(imgW, imgH) * magnification * 2.0
                            
                            // Feathered brush aura
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [Color.white.opacity(0.30), Color.white.opacity(0.08), Color.clear],
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: max(16, effectiveBrushPx) / 2.0
                                    )
                                )
                                .frame(width: max(20, effectiveBrushPx * 1.2), height: max(20, effectiveBrushPx * 1.2))
                            
                            // Dashed brush boundary
                            Circle()
                                .strokeBorder(
                                    Color.white.opacity(0.95),
                                    style: StrokeStyle(lineWidth: 1.4, dash: [4, 3])
                                )
                                .frame(width: max(16, effectiveBrushPx), height: max(16, effectiveBrushPx))
                                .shadow(color: Color.black.opacity(0.6), radius: 2, x: 0, y: 1)
                            
                            // Center target dot
                            Circle()
                                .fill(Color.white)
                                .frame(width: 4, height: 4)
                                .shadow(color: Color.black.opacity(0.8), radius: 1)
                        }
                    }
                    .frame(width: loupeDiameter, height: loupeDiameter)
                    .clipShape(Circle())
                }
                .frame(width: loupeDiameter, height: loupeDiameter)
                
                // Outer Glassmorphic Bezel & Ring
                Circle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [Color.white.opacity(0.95), Color.white.opacity(0.40)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2.5
                    )
                    .frame(width: loupeDiameter, height: loupeDiameter)
                    .shadow(color: Color.black.opacity(0.35), radius: 10, x: 0, y: 6)
                
                // Loupe Bottom Pointer Indicator
                VStack {
                    Spacer()
                    Image(systemName: touchLocation.y < 130 ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill")
                        .font(.system(size: 8))
                        .foregroundColor(Color.white.opacity(0.9))
                        .offset(y: touchLocation.y < 130 ? -loupeDiameter - 4 : 4)
                }
                .frame(width: loupeDiameter, height: loupeDiameter)
            }
        }
        .position(
            x: touchLocation.x + loupeOffset.width,
            y: touchLocation.y + loupeOffset.height
        )
        .transition(.scale(scale: 0.5).combined(with: .opacity))
        .allowsHitTesting(false)
    }
}
