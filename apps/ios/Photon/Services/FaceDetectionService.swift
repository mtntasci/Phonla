//
//  FaceDetectionService.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import Vision
import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

/// Protocol defining face detection and skin masking operations using Apple Vision framework.
public protocol FaceDetectionServiceProtocol: Sendable {
    func detectFaces(in image: CIImage, orientation: CGImagePropertyOrientation) async -> [VNFaceObservation]
    func generateSkinMask(for ciImage: CIImage, orientation: CGImagePropertyOrientation) -> CIImage?
    func generateVisualSkinMask(for ciImage: CIImage, orientation: CGImagePropertyOrientation) -> UIImage?
}

/// Vision-powered face detection & skin mask generator for natural portrait smoothing.
public final class FaceDetectionService: FaceDetectionServiceProtocol, @unchecked Sendable {
    public static let shared = FaceDetectionService()
    
    public init() {}
    
    // MARK: - Vision Face & Landmark Detection
    
    /// Detects all face observations and facial landmarks in the given CIImage with EXIF orientation awareness.
    public func detectFaces(in image: CIImage, orientation: CGImagePropertyOrientation = .up) async -> [VNFaceObservation] {
        return await Task.detached(priority: .userInitiated) {
            let request = VNDetectFaceLandmarksRequest()
            let handler = VNImageRequestHandler(ciImage: image, orientation: orientation, options: [:])
            
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
    
    /// Generates a smooth, high-precision grayscale mask (white = skin including full forehead, black = background/eyes/lips/brows)
    /// with EXIF orientation handling and exact bounding-box-relative landmark projection.
    public func generateSkinMask(for ciImage: CIImage, orientation: CGImagePropertyOrientation = .up) -> CIImage? {
        let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation, options: [:])
        let request = VNDetectFaceLandmarksRequest()
        
        do {
            try handler.perform([request])
        } catch {
            return nil
        }
        
        guard let observations = request.results, !observations.isEmpty else {
            return nil
        }
        
        let targetExtent = ciImage.extent
        let imageSize = targetExtent.size
        guard imageSize.width > 0, imageSize.height > 0 else { return nil }
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 1.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // 1. Black background (No smoothing outside face)
        context.setFillColor(UIColor.black.cgColor)
        context.fill(CGRect(origin: .zero, size: imageSize))
        
        for face in observations {
            let box = face.boundingBox
            let faceX = box.origin.x * imageSize.width
            let faceY = (1.0 - box.origin.y - box.height) * imageSize.height
            let faceW = box.width * imageSize.width
            let faceH = box.height * imageSize.height
            
            // Forehead extension: Covers all the way up from eyebrows to hairline
            let foreheadExtension = faceH * 0.35
            
            // 2. Draw Full Face Base (White = Skin, covering forehead, temples, cheeks, chin)
            let fullFaceOval = CGRect(
                x: faceX - faceW * 0.06,
                y: faceY - foreheadExtension,
                width: faceW * 1.12,
                height: faceH + foreheadExtension * 1.06
            )
            context.setFillColor(UIColor.white.cgColor)
            context.fillEllipse(in: fullFaceOval)
            
            // Draw Face Jawline Contour Path
            if let contour = face.landmarks?.faceContour {
                let pts = contour.normalizedPoints.map { pt in
                    CGPoint(
                        x: (box.origin.x + pt.x * box.width) * imageSize.width,
                        y: (1.0 - (box.origin.y + pt.y * box.height)) * imageSize.height
                    )
                }
                let path = UIBezierPath()
                if let first = pts.first {
                    path.move(to: first)
                    for pt in pts.dropFirst() { path.addLine(to: pt) }
                    path.close()
                    context.addPath(path.cgPath)
                    context.fillPath()
                }
            }
            
            // 3. Exclude Critical Facial Features (Eyes, Eyebrows, Lips, Nostrils = Black)
            let exclusions = [
                face.landmarks?.leftEye,
                face.landmarks?.rightEye,
                face.landmarks?.leftEyebrow,
                face.landmarks?.rightEyebrow,
                face.landmarks?.outerLips,
                face.landmarks?.innerLips,
                face.landmarks?.noseCrest,
                face.landmarks?.nose
            ]
            
            context.setFillColor(UIColor.black.cgColor)
            for landmark in exclusions.compactMap({ $0 }) {
                let pts = landmark.normalizedPoints.map { pt in
                    CGPoint(
                        x: (box.origin.x + pt.x * box.width) * imageSize.width,
                        y: (1.0 - (box.origin.y + pt.y * box.height)) * imageSize.height
                    )
                }
                guard pts.count >= 2 else { continue }
                let path = UIBezierPath()
                if let first = pts.first {
                    path.move(to: first)
                    for pt in pts.dropFirst() { path.addLine(to: pt) }
                    path.close()
                    context.addPath(path.cgPath)
                    context.fillPath()
                }
            }
        }
        
        guard let maskUIImage = UIGraphicsGetImageFromCurrentImageContext(),
              let cgMask = maskUIImage.cgImage else {
            UIGraphicsEndImageContext()
            return nil
        }
        UIGraphicsEndImageContext()
        
        let rawMask = CIImage(cgImage: cgMask)
        let blurRadius = max(6.0, targetExtent.width * 0.012)
        return rawMask
            .clampedToExtent()
            .applyingFilter("CIGaussianBlur", parameters: [kCIInputRadiusKey: NSNumber(value: blurRadius)])
            .cropped(to: targetExtent)
    }
    
    // MARK: - Visual Skin Mask Overlay (Translucent Cyan UI Feedback)
    
    /// Generates a translucent cyan overlay accurately locked onto the face and forehead in real-time.
    public func generateVisualSkinMask(for ciImage: CIImage, orientation: CGImagePropertyOrientation = .up) -> UIImage? {
        let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation, options: [:])
        let request = VNDetectFaceLandmarksRequest()
        
        do {
            try handler.perform([request])
        } catch {
            return nil
        }
        
        guard let observations = request.results, !observations.isEmpty else {
            return nil
        }
        
        let targetExtent = ciImage.extent
        let imageSize = targetExtent.size
        guard imageSize.width > 0, imageSize.height > 0 else { return nil }
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 1.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        context.clear(CGRect(origin: .zero, size: imageSize))
        let skinOverlayColor = UIColor(red: 0.05, green: 0.70, blue: 1.0, alpha: 0.42).cgColor
        
        for face in observations {
            let box = face.boundingBox
            let faceX = box.origin.x * imageSize.width
            let faceY = (1.0 - box.origin.y - box.height) * imageSize.height
            let faceW = box.width * imageSize.width
            let faceH = box.height * imageSize.height
            
            // Forehead extension: Covers all the way up from eyebrows to hairline
            let foreheadExtension = faceH * 0.35
            
            // Draw Full Face & Forehead Base (Cyan)
            let fullFaceOval = CGRect(
                x: faceX - faceW * 0.06,
                y: faceY - foreheadExtension,
                width: faceW * 1.12,
                height: faceH + foreheadExtension * 1.06
            )
            context.setBlendMode(.normal)
            context.setFillColor(skinOverlayColor)
            context.fillEllipse(in: fullFaceOval)
            
            if let contour = face.landmarks?.faceContour {
                let pts = contour.normalizedPoints.map { pt in
                    CGPoint(
                        x: (box.origin.x + pt.x * box.width) * imageSize.width,
                        y: (1.0 - (box.origin.y + pt.y * box.height)) * imageSize.height
                    )
                }
                let path = UIBezierPath()
                if let first = pts.first {
                    path.move(to: first)
                    for pt in pts.dropFirst() { path.addLine(to: pt) }
                    path.close()
                    context.addPath(path.cgPath)
                    context.fillPath()
                }
            }
            
            // Subtract Excluded Features with .clear blend mode
            let exclusions = [
                face.landmarks?.leftEye,
                face.landmarks?.rightEye,
                face.landmarks?.leftEyebrow,
                face.landmarks?.rightEyebrow,
                face.landmarks?.outerLips,
                face.landmarks?.innerLips,
                face.landmarks?.noseCrest,
                face.landmarks?.nose
            ]
            
            context.setBlendMode(.clear)
            for landmark in exclusions.compactMap({ $0 }) {
                let pts = landmark.normalizedPoints.map { pt in
                    CGPoint(
                        x: (box.origin.x + pt.x * box.width) * imageSize.width,
                        y: (1.0 - (box.origin.y + pt.y * box.height)) * imageSize.height
                    )
                }
                guard pts.count >= 2 else { continue }
                let path = UIBezierPath()
                if let first = pts.first {
                    path.move(to: first)
                    for pt in pts.dropFirst() { path.addLine(to: pt) }
                    path.close()
                    context.addPath(path.cgPath)
                    context.fillPath()
                }
            }
            
            // Soft contour stroke
            context.setBlendMode(.normal)
            context.setStrokeColor(UIColor(red: 0.20, green: 0.85, blue: 1.0, alpha: 0.70).cgColor)
            context.setLineWidth(max(2.0, targetExtent.width * 0.002))
            
            if let contour = face.landmarks?.faceContour {
                let pts = contour.normalizedPoints.map { pt in
                    CGPoint(
                        x: (box.origin.x + pt.x * box.width) * imageSize.width,
                        y: (1.0 - (box.origin.y + pt.y * box.height)) * imageSize.height
                    )
                }
                let path = UIBezierPath()
                if let first = pts.first {
                    path.move(to: first)
                    for pt in pts.dropFirst() { path.addLine(to: pt) }
                    path.close()
                    context.addPath(path.cgPath)
                    context.strokePath()
                }
            }
        }
        
        guard let maskUIImage = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        UIGraphicsEndImageContext()
        
        guard let cgMask = maskUIImage.cgImage else { return nil }
        let ciMask = CIImage(cgImage: cgMask)
        let blurRadius = max(3.0, targetExtent.width * 0.006)
        let blurredCI = ciMask.applyingFilter("CIGaussianBlur", parameters: [kCIInputRadiusKey: NSNumber(value: blurRadius)])
            .cropped(to: targetExtent)
        
        let ciContext = CIContext(options: [.useSoftwareRenderer: false])
        guard let finalCG = ciContext.createCGImage(blurredCI, from: targetExtent) else {
            return maskUIImage
        }
        
        return UIImage(cgImage: finalCG)
    }
}
