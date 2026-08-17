//
//  FaceDetectionService.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import Foundation
import CoreImage
import CoreImage.CIFilterBuiltins
import Vision
import CoreGraphics
import UIKit

/// Protocol defining face detection and skin masking operations using Apple Vision framework.
public protocol FaceDetectionServiceProtocol: Sendable {
    func detectFaces(in image: CIImage) async -> [VNFaceObservation]
    func generateSkinMask(targetExtent: CGRect, faces: [VNFaceObservation]) -> CIImage?
    func generateSkinMask(for ciImage: CIImage) -> CIImage?
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
            let handler = VNImageRequestHandler(ciImage: image, orientation: .up, options: [:])
            
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
    
    /// Generates skin mask directly from CIImage
    public func generateSkinMask(for ciImage: CIImage) -> CIImage? {
        let handler = VNImageRequestHandler(ciImage: ciImage, orientation: .up, options: [:])
        let landmarksRequest = VNDetectFaceLandmarksRequest()
        
        do {
            try handler.perform([landmarksRequest])
        } catch {
            return nil
        }
        
        guard let observations = landmarksRequest.results as? [VNFaceObservation], !observations.isEmpty else {
            return nil
        }
        
        return generateSkinMask(targetExtent: ciImage.extent, faces: observations)
    }
    
    // MARK: - Skin Mask Generation (Core Image Pipeline)
    
    /// Generates a smooth, high-precision grayscale mask (white = skin, black = background/eyes/lips/brows)
    /// scaled for the target CIImage extent with proper Y-flip coordinate transformation.
    public func generateSkinMask(targetExtent: CGRect, faces: [VNFaceObservation]) -> CIImage? {
        guard !faces.isEmpty, targetExtent.width > 0, targetExtent.height > 0 else {
            return nil
        }
        
        let imageSize = targetExtent.size
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 1.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // 1. Fill background with Black (0)
        context.setFillColor(UIColor.black.cgColor)
        context.fill(CGRect(origin: .zero, size: imageSize))
        
        for face in faces {
            let faceBoundingBox = face.boundingBox
            let faceRect = CGRect(
                x: faceBoundingBox.origin.x * imageSize.width,
                y: (1.0 - faceBoundingBox.origin.y - faceBoundingBox.height) * imageSize.height,
                width: faceBoundingBox.width * imageSize.width,
                height: faceBoundingBox.height * imageSize.height
            )
            
            // Forehead & temples expansion oval
            let foreheadRect = CGRect(
                x: faceRect.origin.x - faceRect.width * 0.05,
                y: faceRect.origin.y - faceRect.height * 0.12,
                width: faceRect.width * 1.10,
                height: faceRect.height * 1.14
            )
            context.setFillColor(UIColor.white.cgColor)
            context.fillEllipse(in: foreheadRect)
            
            // Draw Face Contour Path (White = Skin)
            if let faceContour = face.landmarks?.faceContour {
                let points = faceContour.normalizedPoints.map { pt in
                    CGPoint(
                        x: faceRect.origin.x + pt.x * faceRect.width,
                        y: faceRect.origin.y + (1.0 - pt.y) * faceRect.height
                    )
                }
                
                let path = UIBezierPath()
                if let first = points.first {
                    path.move(to: first)
                    for p in points.dropFirst() { path.addLine(to: p) }
                    path.close()
                    
                    context.addPath(path.cgPath)
                    context.fillPath()
                }
            }
            
            // 2. Subtract Feature Regions (Eyes, Eyebrows, Lips, Nostrils = Black)
            let excludedLandmarks = [
                face.landmarks?.leftEye,
                face.landmarks?.rightEye,
                face.landmarks?.leftEyebrow,
                face.landmarks?.rightEyebrow,
                face.landmarks?.outerLips,
                face.landmarks?.innerLips,
                face.landmarks?.nose
            ]
            
            context.setFillColor(UIColor.black.cgColor)
            for landmark in excludedLandmarks.compactMap({ $0 }) {
                let points = landmark.normalizedPoints.map { pt in
                    CGPoint(
                        x: faceRect.origin.x + pt.x * faceRect.width,
                        y: faceRect.origin.y + (1.0 - pt.y) * faceRect.height
                    )
                }
                
                guard points.count >= 2 else { continue }
                let path = UIBezierPath()
                if let first = points.first {
                    path.move(to: first)
                    for p in points.dropFirst() { path.addLine(to: p) }
                    path.close()
                    context.addPath(path.cgPath)
                    context.fillPath()
                }
            }
        }
        
        guard let maskImage = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        UIGraphicsEndImageContext()
        
        guard let cgMask = maskImage.cgImage else { return nil }
        let ciMask = CIImage(cgImage: cgMask)
        
        // Smooth transitions (Feathering)
        let blurRadius = max(8.0, targetExtent.width * 0.015)
        return ciMask.applyingFilter("CIGaussianBlur", parameters: [kCIInputRadiusKey: NSNumber(value: blurRadius)])
            .cropped(to: targetExtent)
    }
    
    // MARK: - Visual Skin Mask Overlay (Translucent Cyan UI Feedback)
    
    /// Generates a translucent cyan/blue overlay UIImage showing the detected skin mask over the photo.
    /// Non-skin areas (eyes, eyebrows, lips, background) are 100% transparent.
    public func generateVisualSkinMask(targetExtent: CGRect, faces: [VNFaceObservation]) -> UIImage? {
        guard !faces.isEmpty, targetExtent.width > 0, targetExtent.height > 0 else {
            return nil
        }
        
        let imageSize = targetExtent.size
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 1.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // 1. Clear background (100% Transparent)
        context.clear(CGRect(origin: .zero, size: imageSize))
        
        let skinOverlayColor = UIColor(red: 0.05, green: 0.70, blue: 1.0, alpha: 0.42).cgColor
        
        for face in faces {
            let faceBoundingBox = face.boundingBox
            let faceRect = CGRect(
                x: faceBoundingBox.origin.x * imageSize.width,
                y: (1.0 - faceBoundingBox.origin.y - faceBoundingBox.height) * imageSize.height,
                width: faceBoundingBox.width * imageSize.width,
                height: faceBoundingBox.height * imageSize.height
            )
            
            // Forehead & temples expansion oval
            let foreheadRect = CGRect(
                x: faceRect.origin.x - faceRect.width * 0.05,
                y: faceRect.origin.y - faceRect.height * 0.12,
                width: faceRect.width * 1.10,
                height: faceRect.height * 1.14
            )
            context.setBlendMode(.normal)
            context.setFillColor(skinOverlayColor)
            context.fillEllipse(in: foreheadRect)
            
            // Draw Face Contour Path
            if let faceContour = face.landmarks?.faceContour {
                let points = faceContour.normalizedPoints.map { pt in
                    CGPoint(
                        x: faceRect.origin.x + pt.x * faceRect.width,
                        y: faceRect.origin.y + (1.0 - pt.y) * faceRect.height
                    )
                }
                
                let path = UIBezierPath()
                if let first = points.first {
                    path.move(to: first)
                    for p in points.dropFirst() { path.addLine(to: p) }
                    path.close()
                    
                    context.addPath(path.cgPath)
                    context.fillPath()
                }
            }
            
            // 2. Subtract Feature Regions (Eyes, Eyebrows, Lips, Nostrils with .clear blend mode)
            let excludedLandmarks = [
                face.landmarks?.leftEye,
                face.landmarks?.rightEye,
                face.landmarks?.leftEyebrow,
                face.landmarks?.rightEyebrow,
                face.landmarks?.outerLips,
                face.landmarks?.innerLips,
                face.landmarks?.nose
            ]
            
            context.setBlendMode(.clear)
            for landmark in excludedLandmarks.compactMap({ $0 }) {
                let points = landmark.normalizedPoints.map { pt in
                    CGPoint(
                        x: faceRect.origin.x + pt.x * faceRect.width,
                        y: faceRect.origin.y + (1.0 - pt.y) * faceRect.height
                    )
                }
                
                guard points.count >= 2 else { continue }
                let path = UIBezierPath()
                if let first = points.first {
                    path.move(to: first)
                    for p in points.dropFirst() { path.addLine(to: p) }
                    path.close()
                    context.addPath(path.cgPath)
                    context.fillPath()
                }
            }
            
            // 3. Draw soft cosmetic contour outline
            context.setBlendMode(.normal)
            context.setStrokeColor(UIColor(red: 0.20, green: 0.85, blue: 1.0, alpha: 0.70).cgColor)
            context.setLineWidth(max(2.0, targetExtent.width * 0.002))
            
            if let faceContour = face.landmarks?.faceContour {
                let points = faceContour.normalizedPoints.map { pt in
                    CGPoint(
                        x: faceRect.origin.x + pt.x * faceRect.width,
                        y: faceRect.origin.y + (1.0 - pt.y) * faceRect.height
                    )
                }
                let path = UIBezierPath()
                if let first = points.first {
                    path.move(to: first)
                    for p in points.dropFirst() { path.addLine(to: p) }
                    path.close()
                    context.addPath(path.cgPath)
                    context.strokePath()
                }
            }
        }
        
        guard let maskImage = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        UIGraphicsEndImageContext()
        
        guard let cgMask = maskImage.cgImage else { return nil }
        let ciMask = CIImage(cgImage: cgMask)
        let blurRadius = max(4.0, targetExtent.width * 0.008)
        let blurredCI = ciMask.applyingFilter("CIGaussianBlur", parameters: [kCIInputRadiusKey: NSNumber(value: blurRadius)])
            .cropped(to: targetExtent)
        
        let ciContext = CIContext(options: [.useSoftwareRenderer: false])
        guard let finalCG = ciContext.createCGImage(blurredCI, from: targetExtent) else {
            return maskImage
        }
        
        return UIImage(cgImage: finalCG)
    }
}
