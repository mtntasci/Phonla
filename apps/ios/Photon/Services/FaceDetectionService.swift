//
//  FaceDetectionService.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import Foundation
import CoreImage
import Vision
import CoreGraphics
import UIKit

/// Protocol defining face detection and skin masking operations using Apple Vision framework.
public protocol FaceDetectionServiceProtocol: Sendable {
    func detectFaces(in image: CIImage) async -> [VNFaceObservation]
    func generateSkinMask(targetExtent: CGRect, faces: [VNFaceObservation]) -> CIImage?
    func generateVisualSkinMask(targetExtent: CGRect, faces: [VNFaceObservation]) -> UIImage?
}

/// Vision-powered face detection & skin mask generator for natural portrait smoothing.
public final class FaceDetectionService: FaceDetectionServiceProtocol, @unchecked Sendable {
    public static let shared = FaceDetectionService()
    
    public init() {}
    
    // MARK: - Vision Face & Landmark Detection
    
    /// Detects all face observations and facial landmarks in the given CIImage.
    public func detectFaces(in image: CIImage) async -> [VNFaceObservation] {
        return await Task.detached(priority: .userInitiated) {
            let request = VNDetectFaceLandmarksRequest()
            let handler = VNImageRequestHandler(ciImage: image, options: [:])
            
            do {
                try handler.perform([request])
                guard let results = request.results as? [VNFaceObservation] else {
                    return []
                }
                return results
            } catch {
                return []
            }
        }.value
    }
    
    // MARK: - Skin Mask Generation (Core Image Pipeline)
    
    /// Generates a smooth, high-precision grayscale mask (white = skin, black = background/eyes/lips/brows)
    /// scaled for the target CIImage extent.
    public func generateSkinMask(targetExtent: CGRect, faces: [VNFaceObservation]) -> CIImage? {
        guard !faces.isEmpty, targetExtent.width > 0, targetExtent.height > 0 else {
            return nil
        }
        
        let width = Int(targetExtent.width)
        let height = Int(targetExtent.height)
        
        guard let colorSpace = CGColorSpace(name: CGColorSpace.genericGrayGamma2_2),
              let context = CGContext(
                data: nil,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: width,
                space: colorSpace,
                bitmapInfo: CGImageAlphaInfo.none.rawValue
              ) else {
            return nil
        }
        
        // 1. Fill background with Black (0)
        context.setFillColor(gray: 0.0, alpha: 1.0)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        
        for face in faces {
            let faceRect = VNImageRectForNormalizedRect(face.boundingBox, width, height)
            
            // 2. Draw Face Base (Skin Area = White 1.0)
            context.setFillColor(gray: 1.0, alpha: 1.0)
            
            // Draw expanded face ellipse to ensure forehead, temples, and jawline are fully covered
            drawFaceEllipse(in: context, rect: faceRect)
            
            if let landmarks = face.landmarks, let contour = landmarks.faceContour {
                let contourPoints = convertLandmarkPoints(contour, faceRect: faceRect)
                if contourPoints.count >= 3 {
                    context.beginPath()
                    context.addLines(between: contourPoints)
                    context.closePath()
                    context.fillPath()
                }
            }
            
            // 3. Subtract Feature Regions (Eyes, Lips, Nostrils = Black 0.0)
            context.setFillColor(gray: 0.0, alpha: 1.0)
            
            if let landmarks = face.landmarks {
                // Left Eye
                if let leftEye = landmarks.leftEye {
                    drawLandmarkPath(in: context, region: leftEye, faceRect: faceRect, expand: 1.15)
                }
                
                // Right Eye
                if let rightEye = landmarks.rightEye {
                    drawLandmarkPath(in: context, region: rightEye, faceRect: faceRect, expand: 1.15)
                }
                
                // Left Eyebrow (gentle exclusion)
                if let leftEyebrow = landmarks.leftEyebrow {
                    drawLandmarkPath(in: context, region: leftEyebrow, faceRect: faceRect, expand: 1.10)
                }
                
                // Right Eyebrow (gentle exclusion)
                if let rightEyebrow = landmarks.rightEyebrow {
                    drawLandmarkPath(in: context, region: rightEyebrow, faceRect: faceRect, expand: 1.10)
                }
                
                // Lips (Outer & Inner)
                if let outerLips = landmarks.outerLips {
                    drawLandmarkPath(in: context, region: outerLips, faceRect: faceRect, expand: 1.10)
                }
                
                // Nostrils / Nose Tip
                if let nose = landmarks.nose {
                    drawLandmarkPath(in: context, region: nose, faceRect: faceRect, expand: 0.80)
                }
            } else {
                // Fallback feature exclusion if detailed landmarks unavailable (bottom-left coordinate system)
                let eyeY = faceRect.origin.y + faceRect.height * 0.58
                let eyeW = faceRect.width * 0.22
                let eyeH = faceRect.height * 0.12
                
                // Exclude Left Eye Region
                let leftEyeRect = CGRect(x: faceRect.origin.x + faceRect.width * 0.18, y: eyeY, width: eyeW, height: eyeH)
                context.fillEllipse(in: leftEyeRect)
                
                // Exclude Right Eye Region
                let rightEyeRect = CGRect(x: faceRect.origin.x + faceRect.width * 0.60, y: eyeY, width: eyeW, height: eyeH)
                context.fillEllipse(in: rightEyeRect)
                
                // Exclude Lips Region
                let lipY = faceRect.origin.y + faceRect.height * 0.18
                let lipW = faceRect.width * 0.40
                let lipH = faceRect.height * 0.16
                let lipRect = CGRect(x: faceRect.origin.x + faceRect.width * 0.30, y: lipY, width: lipW, height: lipH)
                context.fillEllipse(in: lipRect)
            }
        }
        
        guard let maskCG = context.makeImage() else { return nil }
        let rawMaskCI = CIImage(cgImage: maskCG)
        
        // 4. Feather Mask Edges via Soft Gaussian Blur for Natural Skin Transitions
        let blurRadius = max(6.0, CGFloat(width) * 0.02)
        let blurredMask = rawMaskCI
            .clampedToExtent()
            .applyingFilter("CIGaussianBlur", parameters: [
                kCIInputRadiusKey: NSNumber(value: blurRadius)
            ])
            .cropped(to: targetExtent)
        
        return blurredMask
    }
    
    // MARK: - Visual Skin Mask Overlay (Translucent Cyan UI Feedback)
    
    /// Generates a translucent cyan/blue overlay UIImage showing the detected skin mask over the photo.
    /// Non-skin areas (eyes, eyebrows, lips, background) are 100% transparent.
    public func generateVisualSkinMask(targetExtent: CGRect, faces: [VNFaceObservation]) -> UIImage? {
        guard !faces.isEmpty, targetExtent.width > 0, targetExtent.height > 0 else {
            return nil
        }
        
        let width = Int(targetExtent.width)
        let height = Int(targetExtent.height)
        
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
              let context = CGContext(
                data: nil,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: width * 4,
                space: colorSpace,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
              ) else {
            return nil
        }
        
        // 1. Clear background (100% Transparent)
        context.clear(CGRect(x: 0, y: 0, width: width, height: height))
        
        // Cyan / Electric Blue translucent color for skin overlay
        let skinOverlayColor = UIColor(red: 0.05, green: 0.70, blue: 1.0, alpha: 0.42).cgColor
        
        for face in faces {
            let faceRect = VNImageRectForNormalizedRect(face.boundingBox, width, height)
            
            // 2. Draw Translucent Cyan Skin Fill (Normal Blend Mode)
            context.setBlendMode(.normal)
            context.setFillColor(skinOverlayColor)
            
            // Draw expanded face ellipse
            drawFaceEllipse(in: context, rect: faceRect)
            
            if let landmarks = face.landmarks, let contour = landmarks.faceContour {
                let contourPoints = convertLandmarkPoints(contour, faceRect: faceRect)
                if contourPoints.count >= 3 {
                    context.beginPath()
                    context.addLines(between: contourPoints)
                    context.closePath()
                    context.fillPath()
                }
            }
            
            // 3. Subtract Feature Regions with CLEAR Blend Mode (100% Transparent Cutout for Eyes, Lips, Brows)
            context.setBlendMode(.clear)
            
            if let landmarks = face.landmarks {
                if let leftEye = landmarks.leftEye {
                    drawLandmarkPath(in: context, region: leftEye, faceRect: faceRect, expand: 1.18)
                }
                if let rightEye = landmarks.rightEye {
                    drawLandmarkPath(in: context, region: rightEye, faceRect: faceRect, expand: 1.18)
                }
                if let leftEyebrow = landmarks.leftEyebrow {
                    drawLandmarkPath(in: context, region: leftEyebrow, faceRect: faceRect, expand: 1.12)
                }
                if let rightEyebrow = landmarks.rightEyebrow {
                    drawLandmarkPath(in: context, region: rightEyebrow, faceRect: faceRect, expand: 1.12)
                }
                if let outerLips = landmarks.outerLips {
                    drawLandmarkPath(in: context, region: outerLips, faceRect: faceRect, expand: 1.12)
                }
                if let nose = landmarks.nose {
                    drawLandmarkPath(in: context, region: nose, faceRect: faceRect, expand: 0.85)
                }
            } else {
                let eyeY = faceRect.origin.y + faceRect.height * 0.58
                let eyeW = faceRect.width * 0.22
                let eyeH = faceRect.height * 0.12
                
                context.fillEllipse(in: CGRect(x: faceRect.origin.x + faceRect.width * 0.18, y: eyeY, width: eyeW, height: eyeH))
                context.fillEllipse(in: CGRect(x: faceRect.origin.x + faceRect.width * 0.60, y: eyeY, width: eyeW, height: eyeH))
                
                let lipY = faceRect.origin.y + faceRect.height * 0.18
                let lipW = faceRect.width * 0.40
                let lipH = faceRect.height * 0.16
                context.fillEllipse(in: CGRect(x: faceRect.origin.x + faceRect.width * 0.30, y: lipY, width: lipW, height: lipH))
            }
            
            // 4. Draw crisp cosmetic contour outlines (Normal Blend Mode)
            context.setBlendMode(.normal)
            context.setStrokeColor(UIColor(red: 0.20, green: 0.85, blue: 1.0, alpha: 0.75).cgColor)
            context.setLineWidth(max(2.0, CGFloat(width) * 0.002))
            
            if let landmarks = face.landmarks, let contour = landmarks.faceContour {
                let contourPoints = convertLandmarkPoints(contour, faceRect: faceRect)
                if contourPoints.count >= 3 {
                    context.beginPath()
                    context.addLines(between: contourPoints)
                    context.closePath()
                    context.strokePath()
                }
            }
        }
        
        guard let visualCG = context.makeImage() else { return nil }
        
        // Apply soft Gaussian Blur to feather edges for natural translucent look
        let rawCI = CIImage(cgImage: visualCG)
        let blurRadius = max(4.0, CGFloat(width) * 0.012)
        let blurredCI = rawCI
            .clampedToExtent()
            .applyingFilter("CIGaussianBlur", parameters: [
                kCIInputRadiusKey: NSNumber(value: blurRadius)
            ])
            .cropped(to: targetExtent)
        
        let ciContext = CIContext(options: [.useSoftwareRenderer: false])
        guard let finalCG = ciContext.createCGImage(blurredCI, from: targetExtent) else {
            return UIImage(cgImage: visualCG, scale: 1.0, orientation: .up)
        }
        
        return UIImage(cgImage: finalCG, scale: 1.0, orientation: .up)
    }
    
    // MARK: - Helpers
    
    private func drawFaceEllipse(in context: CGContext, rect: CGRect) {
        // Naturally cover face oval without spilling down to neck
        let expandedRect = CGRect(
            x: rect.origin.x - rect.width * 0.04,
            y: rect.origin.y - rect.height * 0.01,
            width: rect.width * 1.08,
            height: rect.height * 1.03
        )
        context.fillEllipse(in: expandedRect)
    }
    
    private func drawLandmarkPath(in context: CGContext, region: VNFaceLandmarkRegion2D, faceRect: CGRect, expand: CGFloat) {
        let points = convertLandmarkPoints(region, faceRect: faceRect)
        guard points.count >= 2 else { return }
        
        if points.count >= 3 {
            // Apply subtle expansion padding around feature
            let centroid = points.reduce(CGPoint.zero) { CGPoint(x: $0.x + $1.x, y: $0.y + $1.y) }
            let center = CGPoint(x: centroid.x / CGFloat(points.count), y: centroid.y / CGFloat(points.count))
            
            let expandedPoints = points.map { pt -> CGPoint in
                let dx = pt.x - center.x
                let dy = pt.y - center.y
                return CGPoint(x: center.x + dx * expand, y: center.y + dy * expand)
            }
            
            context.beginPath()
            context.addLines(between: expandedPoints)
            context.closePath()
            context.fillPath()
        } else {
            // Draw line segment bounding rect
            let minX = points.map(\.x).min() ?? faceRect.minX
            let maxX = points.map(\.x).max() ?? faceRect.maxX
            let minY = points.map(\.y).min() ?? faceRect.minY
            let maxY = points.map(\.y).max() ?? faceRect.maxY
            let bound = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
            context.fillEllipse(in: bound.insetBy(dx: -4, dy: -4))
        }
    }
    
    private func convertLandmarkPoints(_ region: VNFaceLandmarkRegion2D, faceRect: CGRect) -> [CGPoint] {
        return (0..<region.pointCount).map { i -> CGPoint in
            let point = region.normalizedPoints[i]
            let x = faceRect.origin.x + point.x * faceRect.width
            let y = faceRect.origin.y + point.y * faceRect.height
            return CGPoint(x: x, y: y)
        }
    }
}
