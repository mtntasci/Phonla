//
//  PhotonLogoMark.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import SwiftUI

/// Elegant, transparent vector brandmark for Photon.
/// Features a minimalist optical aperture & photon ray geometry with zero opaque background.
public struct PhotonLogoMark: View {
    let size: CGFloat
    let color: Color
    
    public init(size: CGFloat = 32, color: Color = .primary) {
        self.size = size
        self.color = color
    }
    
    public var body: some View {
        Canvas { context, canvasSize in
            let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
            let radius = min(canvasSize.width, canvasSize.height) / 2
            let strokeWidth = radius * 0.12
            
            // Outer optical ring
            let outerRect = CGRect(
                x: center.x - radius + strokeWidth / 2,
                y: center.y - radius + strokeWidth / 2,
                width: (radius - strokeWidth / 2) * 2,
                height: (radius - strokeWidth / 2) * 2
            )
            context.stroke(
                Path(ellipseIn: outerRect),
                with: .color(color),
                lineWidth: strokeWidth
            )
            
            // 6-blade minimalist aperture rays
            let bladeCount = 6
            let innerRadius = radius * 0.36
            let rayLength = radius * 0.78
            
            for i in 0..<bladeCount {
                let angle = Double(i) * (2 * Double.pi / Double(bladeCount)) - (Double.pi / 6)
                let tangentAngle = angle + (Double.pi / 3.2)
                
                let startX = center.x + CGFloat(cos(angle)) * innerRadius
                let startY = center.y + CGFloat(sin(angle)) * innerRadius
                let endX = startX + CGFloat(cos(tangentAngle)) * rayLength
                let endY = startY + CGFloat(sin(tangentAngle)) * rayLength
                
                var path = Path()
                path.move(to: CGPoint(x: startX, y: startY))
                path.addLine(to: CGPoint(x: endX, y: endY))
                
                context.stroke(
                    path,
                    with: .color(color),
                    style: StrokeStyle(lineWidth: strokeWidth * 0.9, lineCap: .round)
                )
            }
            
            // Central photon light core point
            let coreRadius = radius * 0.14
            let coreRect = CGRect(
                x: center.x - coreRadius,
                y: center.y - coreRadius,
                width: coreRadius * 2,
                height: coreRadius * 2
            )
            context.fill(Path(ellipseIn: coreRect), with: .color(color))
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack(spacing: 20) {
            PhotonLogoMark(size: 80, color: .white)
            PhotonLogoMark(size: 40, color: .cyan)
        }
    }
}
