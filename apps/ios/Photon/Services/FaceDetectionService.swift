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

/// Anatomical Face Zone representation (Forehead = White, Eyes/Midface = Green, Lips/Chin = Red)
public struct FacialZoneBox: Sendable, Identifiable, Equatable {
    public var id: String { name }
    public var name: String
    public var rect: CGRect // Normalized [0, 1] UI coordinates (top-left is (0,0))
    public var colorType: ZoneColorType
    
    public enum ZoneColorType: String, Sendable {
        case white = "Beyaz" // Alın (Saç çizgisinden kaşlara kadar)
        case green = "Yeşil" // Göz & Orta Yüz (Kaşlardan burun alt ucuna kadar)
        case red = "Kırmızı" // Dudak & Çene (Burun altından çeneye kadar)
    }
    
    public init(name: String, rect: CGRect, colorType: ZoneColorType) {
        self.name = name
        self.rect = rect
        self.colorType = colorType
    }
}

public struct BlemishDetectionResult: Sendable {
    public var detectedSpots: [HealedSpot]
    public var facialZones: [FacialZoneBox]
    
    public init(detectedSpots: [HealedSpot], facialZones: [FacialZoneBox]) {
        self.detectedSpots = detectedSpots
        self.facialZones = facialZones
    }
}

/// Protocol defining face detection and skin masking operations using Apple Vision framework.
public protocol FaceDetectionServiceProtocol: Sendable {
    func detectFaces(in image: CIImage, orientation: CGImagePropertyOrientation) async -> [VNFaceObservation]
    func generateSkinMask(for ciImage: CIImage, orientation: CGImagePropertyOrientation) -> CIImage?
    func generateVisualSkinMask(for ciImage: CIImage, orientation: CGImagePropertyOrientation) -> UIImage?
    func detectBlemishes(in image: CIImage, orientation: CGImagePropertyOrientation) async -> [HealedSpot]
    func detectBlemishesAndZones(in image: CIImage, orientation: CGImagePropertyOrientation) async -> BlemishDetectionResult
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
    
    // MARK: - Automated 3-Zone Face Segmentation & Landmark-Based Anomaly Detection
    
    /// Detects facial blemishes across all skin zones using dense contrast scanning, while extracting exact anatomical facial zones via Vision landmarks.
    public func detectBlemishesAndZones(in image: CIImage, orientation: CGImagePropertyOrientation = .up) async -> BlemishDetectionResult {
        return await Task.detached(priority: .userInitiated) {
            let request = VNDetectFaceLandmarksRequest()
            let handler = VNImageRequestHandler(ciImage: image, orientation: orientation, options: [:])
            
            do {
                try handler.perform([request])
                guard let faces = request.results as? [VNFaceObservation], !faces.isEmpty else {
                    return BlemishDetectionResult(detectedSpots: [], facialZones: [])
                }
                
                var detectedSpots: [HealedSpot] = []
                var facialZones: [FacialZoneBox] = []
                
                let extent = image.extent
                let imageW = extent.width
                let imageH = extent.height
                guard imageW > 0, imageH > 0 else {
                    return BlemishDetectionResult(detectedSpots: [], facialZones: [])
                }
                
                // Downscale image to a lightweight 300x300 bitmap context for fast color/anomaly inspection
                let thumbW = 300
                let thumbH = 300
                var pixelBuffer = [UInt8](repeating: 0, count: thumbW * thumbH * 4)
                
                let colorSpace = CGColorSpaceCreateDeviceRGB()
                let ciContext = CIContext(options: [.useSoftwareRenderer: true])
                let thumbCI = image.transformed(by: CGAffineTransform(scaleX: CGFloat(thumbW) / imageW, y: CGFloat(thumbH) / imageH))
                
                if let thumbCG = ciContext.createCGImage(thumbCI, from: CGRect(x: 0, y: 0, width: thumbW, height: thumbH)),
                   let ctx = CGContext(
                    data: &pixelBuffer,
                    width: thumbW,
                    height: thumbH,
                    bitsPerComponent: 8,
                    bytesPerRow: thumbW * 4,
                    space: colorSpace,
                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
                   ) {
                    ctx.draw(thumbCG, in: CGRect(x: 0, y: 0, width: thumbW, height: thumbH))
                }
                
                let getPixelLuma: (Int, Int) -> Float = { px, py in
                    let clampedX = min(max(px, 0), thumbW - 1)
                    let clampedY = min(max(py, 0), thumbH - 1)
                    let offset = (clampedY * thumbW + clampedX) * 4
                    let r = Float(pixelBuffer[offset])
                    let g = Float(pixelBuffer[offset + 1])
                    let b = Float(pixelBuffer[offset + 2])
                    return 0.299 * r + 0.587 * g + 0.114 * b
                }
                
                let getPixelRGB: (Int, Int) -> (r: Float, g: Float, b: Float) = { px, py in
                    let clampedX = min(max(px, 0), thumbW - 1)
                    let clampedY = min(max(py, 0), thumbH - 1)
                    let offset = (clampedY * thumbW + clampedX) * 4
                    return (Float(pixelBuffer[offset]), Float(pixelBuffer[offset + 1]), Float(pixelBuffer[offset + 2]))
                }
                
                for face in faces {
                    let box = face.boundingBox
                    let faceMinX = box.origin.x
                    let faceMinY = 1.0 - box.origin.y - box.height
                    let faceW = box.width
                    let faceH = box.height
                    
                    // MARK: - 1. Calculate Exact Anatomical Facial Landmarks
                    
                    var eyebrowTopY = faceMinY + faceH * 0.10
                    var noseBottomY = faceMinY + faceH * 0.58
                    var chinBottomY = faceMinY + faceH * 0.98
                    var faceLeftX = faceMinX
                    var faceRightX = faceMinX + faceW
                    
                    // Eyebrow Landmark coordinates (defines boundary between Forehead and Eyes/Midface)
                    var eyebrowYPoints: [CGFloat] = []
                    if let leftBrow = face.landmarks?.leftEyebrow {
                        for pt in leftBrow.normalizedPoints {
                            eyebrowYPoints.append(1.0 - (box.origin.y + pt.y * box.height))
                        }
                    }
                    if let rightBrow = face.landmarks?.rightEyebrow {
                        for pt in rightBrow.normalizedPoints {
                            eyebrowYPoints.append(1.0 - (box.origin.y + pt.y * box.height))
                        }
                    }
                    if let minBrowY = eyebrowYPoints.min() {
                        eyebrowTopY = minBrowY
                    }
                    
                    // Nose Landmark coordinates (defines boundary between Eyes/Midface and Lips/Chin)
                    if let nose = face.landmarks?.nose {
                        let noseYs = nose.normalizedPoints.map { 1.0 - (box.origin.y + $0.y * box.height) }
                        if let maxNoseY = noseYs.max() {
                            noseBottomY = maxNoseY
                        }
                    }
                    
                    // Face Contour Landmark (defines chin bottom and lateral face boundaries)
                    if let contour = face.landmarks?.faceContour {
                        let contourYs = contour.normalizedPoints.map { 1.0 - (box.origin.y + $0.y * box.height) }
                        let contourXs = contour.normalizedPoints.map { box.origin.x + $0.x * box.width }
                        if let maxContourY = contourYs.max() {
                            chinBottomY = maxContourY
                        }
                        if let minX = contourXs.min(), let maxX = contourXs.max() {
                            faceLeftX = minX
                            faceRightX = maxX
                        }
                    }
                    
                    // Lips Landmark coordinates (to exclude lips from blemish search)
                    var lipTopY = noseBottomY + 0.04
                    var lipBottomY = chinBottomY - 0.05
                    var lipMinX = faceLeftX + (faceRightX - faceLeftX) * 0.30
                    var lipMaxX = faceLeftX + (faceRightX - faceLeftX) * 0.70
                    if let lips = face.landmarks?.outerLips {
                        let lipYs = lips.normalizedPoints.map { 1.0 - (box.origin.y + $0.y * box.height) }
                        let lipXs = lips.normalizedPoints.map { box.origin.x + $0.x * box.width }
                        if let minY = lipYs.min(), let maxY = lipYs.max() {
                            lipTopY = minY
                            lipBottomY = maxY
                        }
                        if let minX = lipXs.min(), let maxX = lipXs.max() {
                            lipMinX = minX
                            lipMaxX = maxX
                        }
                    }
                    
                    // Eye landmarks for exclusion
                    var leftEyeRect = CGRect(x: faceLeftX + (faceRightX - faceLeftX) * 0.15, y: eyebrowTopY, width: (faceRightX - faceLeftX) * 0.32, height: (noseBottomY - eyebrowTopY) * 0.45)
                    var rightEyeRect = CGRect(x: faceLeftX + (faceRightX - faceLeftX) * 0.53, y: eyebrowTopY, width: (faceRightX - faceLeftX) * 0.32, height: (noseBottomY - eyebrowTopY) * 0.45)
                    
                    if let leftEye = face.landmarks?.leftEye {
                        let eyeXs = leftEye.normalizedPoints.map { box.origin.x + $0.x * box.width }
                        let eyeYs = leftEye.normalizedPoints.map { 1.0 - (box.origin.y + $0.y * box.height) }
                        if let minX = eyeXs.min(), let maxX = eyeXs.max(), let minY = eyeYs.min(), let maxY = eyeYs.max() {
                            leftEyeRect = CGRect(x: minX - 0.02, y: minY - 0.02, width: (maxX - minX) + 0.04, height: (maxY - minY) + 0.04)
                        }
                    }
                    if let rightEye = face.landmarks?.rightEye {
                        let eyeXs = rightEye.normalizedPoints.map { box.origin.x + $0.x * box.width }
                        let eyeYs = rightEye.normalizedPoints.map { 1.0 - (box.origin.y + $0.y * box.height) }
                        if let minX = eyeXs.min(), let maxX = eyeXs.max(), let minY = eyeYs.min(), let maxY = eyeYs.max() {
                            rightEyeRect = CGRect(x: minX - 0.02, y: minY - 0.02, width: (maxX - minX) + 0.04, height: (maxY - minY) + 0.04)
                        }
                    }
                    
                    let faceWidth = max(0.1, faceRightX - faceLeftX)
                    let faceHeight = max(0.1, chinBottomY - eyebrowTopY)
                    
                    // Forehead extends upward from eyebrows ~46% of face height
                    let foreheadTopY = max(0.015, eyebrowTopY - faceHeight * 0.46)
                    
                    // MARK: - 2. Construct the 3 Anatomical Facial Zones
                    
                    // Zone 1: Alın (Hairline to Eyebrows Top) -> BEYAZ
                    let foreheadRect = CGRect(
                        x: max(0.01, faceLeftX + faceWidth * 0.03),
                        y: foreheadTopY,
                        width: min(0.98, faceWidth * 0.94),
                        height: max(0.04, eyebrowTopY - foreheadTopY)
                    )
                    facialZones.append(FacialZoneBox(name: "Alın", rect: foreheadRect, colorType: .white))
                    
                    // Zone 2: Göz & Orta Yüz (Eyebrows to Bottom of Nose) -> YEŞİL
                    let midFaceRect = CGRect(
                        x: max(0.01, faceLeftX),
                        y: eyebrowTopY,
                        width: min(0.98, faceWidth),
                        height: max(0.04, noseBottomY - eyebrowTopY)
                    )
                    facialZones.append(FacialZoneBox(name: "Göz & Orta Yüz", rect: midFaceRect, colorType: .green))
                    
                    // Zone 3: Dudak & Çene (Bottom of Nose to Bottom of Chin) -> KIRMIZI
                    let lowerFaceRect = CGRect(
                        x: max(0.01, faceLeftX),
                        y: noseBottomY,
                        width: min(0.98, faceWidth),
                        height: max(0.04, chinBottomY - noseBottomY)
                    )
                    facialZones.append(FacialZoneBox(name: "Dudak & Çene", rect: lowerFaceRect, colorType: .red))
                    
                    // MARK: - 3. Multi-Scale Dense Grid Anomaly Scoring Function
                    
                    let scoreAnomalyAt: (CGFloat, CGFloat) -> Float = { normX, normY in
                        let px = Int(normX * CGFloat(thumbW))
                        let py = Int((1.0 - normY) * CGFloat(thumbH)) // CGContext coordinate mapping
                        
                        let centerLuma = getPixelLuma(px, py)
                        let centerRGB = getPixelRGB(px, py)
                        
                        // Inner 3x3 mean
                        var innerLumaSum: Float = 0
                        var innerCount: Float = 0
                        for dy in -1...1 {
                            for dx in -1...1 {
                                innerLumaSum += getPixelLuma(px + dx, py + dy)
                                innerCount += 1
                            }
                        }
                        let innerLuma = innerCount > 0 ? (innerLumaSum / innerCount) : centerLuma
                        
                        // Outer 15x15 surrounding neighborhood halo
                        var outerLumaSum: Float = 0
                        var outerRSum: Float = 0
                        var outerGSum: Float = 0
                        var outerBSum: Float = 0
                        var outerCount: Float = 0
                        
                        for dy in stride(from: -7, through: 7, by: 2) {
                            for dx in stride(from: -7, through: 7, by: 2) {
                                if abs(dx) >= 3 || abs(dy) >= 3 {
                                    outerLumaSum += getPixelLuma(px + dx, py + dy)
                                    let rgb = getPixelRGB(px + dx, py + dy)
                                    outerRSum += rgb.r
                                    outerGSum += rgb.g
                                    outerBSum += rgb.b
                                    outerCount += 1
                                }
                            }
                        }
                        
                        guard outerCount > 0 else { return 0 }
                        let outerLuma = outerLumaSum / outerCount
                        let outerR = outerRSum / outerCount
                        let outerG = outerGSum / outerCount
                        let outerB = outerBSum / outerCount
                        
                        let deltaLuma = abs(innerLuma - outerLuma)
                        let deltaColor = abs(centerRGB.r - outerR) + abs(centerRGB.g - outerG) + abs(centerRGB.b - outerB)
                        
                        return deltaLuma * 1.8 + deltaColor * 0.5
                    }
                    
                    // MARK: - 4. Dense Grid Candidate Gathering
                    
                    struct CandidatePoint {
                        var x: CGFloat
                        var y: CGFloat
                        var score: Float
                        var zone: Int
                    }
                    
                    var candidates: [CandidatePoint] = []
                    let gridStep: CGFloat = 0.024
                    
                    // 4A. Scan Entire Forehead (Zone 1 - White) -> Catches dents, indentations, bumps, pimples, dark/light spots
                    var curY = foreheadRect.minY + 0.035
                    while curY <= foreheadRect.maxY - 0.025 {
                        var curX = foreheadRect.minX + 0.035
                        while curX <= foreheadRect.maxX - 0.035 {
                            let score = scoreAnomalyAt(curX, curY)
                            if score > 4.5 {
                                candidates.append(CandidatePoint(x: curX, y: curY, score: score, zone: 1))
                            }
                            curX += gridStep
                        }
                        curY += gridStep
                    }
                    
                    // 4B. Scan Cheeks & Mid-Face (Zone 2 - Green) -> Avoiding eyes and nose bridge
                    curY = midFaceRect.minY + 0.03
                    while curY <= midFaceRect.maxY - 0.015 {
                        var curX = midFaceRect.minX + 0.03
                        while curX <= midFaceRect.maxX - 0.03 {
                            let pt = CGPoint(x: curX, y: curY)
                            let inLeftEye = leftEyeRect.contains(pt)
                            let inRightEye = rightEyeRect.contains(pt)
                            let inNoseRidge = (curX >= faceLeftX + faceWidth * 0.44 && curX <= faceLeftX + faceWidth * 0.56)
                            
                            if !inLeftEye && !inRightEye && !inNoseRidge {
                                let score = scoreAnomalyAt(curX, curY)
                                if score > 5.0 {
                                    candidates.append(CandidatePoint(x: curX, y: curY, score: score, zone: 2))
                                }
                            }
                            curX += gridStep
                        }
                        curY += gridStep
                    }
                    
                    // 4C. Scan Lower Face & Chin (Zone 3 - Red) -> High threshold for mustache, normal for chin skin
                    let mustacheMinY = noseBottomY
                    let mustacheMaxY = lipTopY + 0.01
                    
                    curY = lowerFaceRect.minY + 0.015
                    while curY <= lowerFaceRect.maxY - 0.02 {
                        var curX = lowerFaceRect.minX + 0.04
                        while curX <= lowerFaceRect.maxX - 0.04 {
                            let pt = CGPoint(x: curX, y: curY)
                            let inLips = (curX >= lipMinX && curX <= lipMaxX && curY >= lipTopY && curY <= lipBottomY)
                            let inMustache = (curY >= mustacheMinY && curY <= mustacheMaxY && curX >= lipMinX - 0.04 && curX <= lipMaxX + 0.04)
                            
                            if !inLips {
                                let score = scoreAnomalyAt(curX, curY)
                                if inMustache {
                                    // Mustache hair: only accept if there is a severe anomaly / difference (score > 22.0)
                                    if score > 22.0 {
                                        candidates.append(CandidatePoint(x: curX, y: curY, score: score, zone: 3))
                                    }
                                } else {
                                    // Chin skin: standard blemish threshold
                                    if score > 5.5 {
                                        candidates.append(CandidatePoint(x: curX, y: curY, score: score, zone: 3))
                                    }
                                }
                            }
                            curX += gridStep
                        }
                        curY += gridStep
                    }
                    
                    // MARK: - 5. Non-Maximum Suppression (NMS) per Zone
                    
                    let spotRadius: CGFloat = 0.022
                    let minDistance: CGFloat = 0.042
                    
                    // Select Zone 1 (Forehead) Top Anomaly Peaks (up to 3)
                    var selectedForehead: [CandidatePoint] = []
                    let sortedZ1 = candidates.filter { $0.zone == 1 }.sorted { $0.score > $1.score }
                    for cand in sortedZ1 {
                        if !selectedForehead.contains(where: { hypot($0.x - cand.x, $0.y - cand.y) < minDistance }) {
                            selectedForehead.append(cand)
                            if selectedForehead.count >= 3 { break }
                        }
                    }
                    
                    // Select Zone 2 (Cheeks) Top Anomaly Peaks (up to 3)
                    var selectedMidface: [CandidatePoint] = []
                    let sortedZ2 = candidates.filter { $0.zone == 2 }.sorted { $0.score > $1.score }
                    for cand in sortedZ2 {
                        if !selectedMidface.contains(where: { hypot($0.x - cand.x, $0.y - cand.y) < minDistance }) {
                            selectedMidface.append(cand)
                            if selectedMidface.count >= 3 { break }
                        }
                    }
                    
                    // Select Zone 3 (Chin) Top Anomaly Peaks (up to 2)
                    var selectedLower: [CandidatePoint] = []
                    let sortedZ3 = candidates.filter { $0.zone == 3 }.sorted { $0.score > $1.score }
                    for cand in sortedZ3 {
                        if !selectedLower.contains(where: { hypot($0.x - cand.x, $0.y - cand.y) < minDistance }) {
                            selectedLower.append(cand)
                            if selectedLower.count >= 2 { break }
                        }
                    }
                    
                    // Add all selected blemishes
                    for cand in (selectedForehead + selectedMidface + selectedLower) {
                        detectedSpots.append(HealedSpot(x: cand.x, y: cand.y, radius: spotRadius))
                    }
                }
                
                return BlemishDetectionResult(detectedSpots: detectedSpots, facialZones: facialZones)
            } catch {
                return BlemishDetectionResult(detectedSpots: [], facialZones: [])
            }
        }.value
    }
    
    public func detectBlemishes(in image: CIImage, orientation: CGImagePropertyOrientation = .up) async -> [HealedSpot] {
        let result = await detectBlemishesAndZones(in: image, orientation: orientation)
        return result.detectedSpots
    }
}
