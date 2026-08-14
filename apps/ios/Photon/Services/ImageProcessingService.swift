//
//  ImageProcessingService.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
import Metal

/// Contract for non-destructive Core Image rendering pipeline.
public protocol ImageProcessingServiceProtocol: Sendable {
    func processImage(_ input: CIImage, state: PhotoEditState) -> CIImage
    func renderPreview(from input: CIImage, state: PhotoEditState) -> UIImage?
    func renderFullResolution(from input: CIImage, state: PhotoEditState) -> CGImage?
}

/// Metal-accelerated Core Image processing engine.
/// Reuses a single CIContext for optimal GPU throughput and memory stability.
public final class ImageProcessingService: ImageProcessingServiceProtocol, @unchecked Sendable {
    public static let shared = ImageProcessingService()
    
    private let context: CIContext
    
    public init() {
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            self.context = CIContext(mtlDevice: metalDevice, options: [
                .useSoftwareRenderer: false,
                .cacheIntermediates: false,
                .priorityRequestLow: false
            ])
        } else {
            self.context = CIContext(options: [
                .useSoftwareRenderer: false
            ])
        }
    }
    
    // MARK: - Pipeline Application
    
    /// Chains Core Image filters based on the provided `PhotoEditState`.
    public func processImage(_ input: CIImage, state: PhotoEditState) -> CIImage {
        var output = input
        
        // 1. Exposure (CIExposureAdjust)
        if state.exposure != 0.0 {
            output = output.applyingFilter("CIExposureAdjust", parameters: [
                kCIInputEVKey: NSNumber(value: state.exposure)
            ])
        }
        
        // 2. Highlights and Shadows (CIHighlightShadowAdjust)
        if state.highlights != 0.0 || state.shadows != 0.0 {
            output = output.applyingFilter("CIHighlightShadowAdjust", parameters: [
                "inputHighlightAmount": NSNumber(value: 1.0 - (state.highlights * 0.5)),
                "inputShadowAmount": NSNumber(value: state.shadows)
            ])
        }
        
        // 3. Brightness, Contrast, Saturation (CIColorControls)
        let effectiveSat = state.isMonoActive ? 0.0 : state.saturation
        if state.brightness != 0.0 || state.contrast != 1.0 || effectiveSat != 1.0 {
            output = output.applyingFilter("CIColorControls", parameters: [
                kCIInputBrightnessKey: NSNumber(value: state.brightness * 0.5),
                kCIInputContrastKey: NSNumber(value: state.contrast),
                kCIInputSaturationKey: NSNumber(value: effectiveSat)
            ])
        }
        
        // 4. Temperature & Tint (CITemperatureAndTint)
        if state.temperature != 6500.0 || state.tint != 0.0 {
            let neutral = CIVector(x: 6500.0, y: 0.0)
            let target = CIVector(x: CGFloat(state.temperature), y: CGFloat(state.tint))
            output = output.applyingFilter("CITemperatureAndTint", parameters: [
                "inputNeutral": neutral,
                "inputTargetNeutral": target
            ])
        }
        
        // 5. Vibrance (CIVibrance)
        if state.vibrance != 0.0 && !state.isMonoActive {
            output = output.applyingFilter("CIVibrance", parameters: [
                "inputAmount": NSNumber(value: state.vibrance)
            ])
        }
        
        // 6. Monochrome Engine (Luminance matrix / Mono preset)
        if state.isMonoActive {
            let monoFilter = output.applyingFilter("CIColorMonochrome", parameters: [
                kCIInputColorKey: CIColor(red: 0.9, green: 0.9, blue: 0.9),
                kCIInputIntensityKey: NSNumber(value: state.monoIntensity)
            ])
            output = monoFilter
        }
        
        return output
    }
    
    // MARK: - Render Outputs
    
    /// Renders the preview image for interactive 60fps UI display.
    public func renderPreview(from input: CIImage, state: PhotoEditState) -> UIImage? {
        let processed = processImage(input, state: state)
        guard let cgImage = context.createCGImage(processed, from: processed.extent) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
    
    /// Renders the full resolution image for final photo library export.
    public func renderFullResolution(from input: CIImage, state: PhotoEditState) -> CGImage? {
        let processed = processImage(input, state: state)
        return context.createCGImage(processed, from: processed.extent)
    }
    
    // MARK: - Downsampling Helper
    
    /// Downsamples a full-resolution CIImage into an optimized preview CIImage and UIImage.
    public func generatePreview(from source: CIImage, maxDimension: CGFloat = 1920) -> (previewCI: CIImage, previewUI: UIImage)? {
        let extent = source.extent
        guard extent.width > 0 && extent.height > 0 else { return nil }
        
        let largestSide = max(extent.width, extent.height)
        let scale = min(1.0, maxDimension / largestSide)
        
        let resizedCI = source.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        guard let cgImage = context.createCGImage(resizedCI, from: resizedCI.extent) else {
            return nil
        }
        
        let previewUI = UIImage(cgImage: cgImage)
        return (previewCI: resizedCI, previewUI: previewUI)
    }
}
