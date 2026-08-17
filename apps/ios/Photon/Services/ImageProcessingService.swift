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
    func processImage(_ input: CIImage, state: PhotoEditState, skinMask: CIImage?) -> CIImage
    func renderPreview(from input: CIImage, state: PhotoEditState, skinMask: CIImage?) -> UIImage?
    func renderFullResolution(from input: CIImage, state: PhotoEditState, skinMask: CIImage?) -> CGImage?
}

public enum SkinSmoothPreset: String, CaseIterable, Sendable {
    case natural
    case silky
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
    public func processImage(_ input: CIImage, state: PhotoEditState, skinMask: CIImage? = nil) -> CIImage {
        var output = input
        
        // 0. Selective Spot Healing Engine (Tap-to-Heal Blemish Removal)
        if !state.healedSpots.isEmpty {
            output = applySpotHealing(to: output, spots: state.healedSpots)
        }
        
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
                kCIInputBrightnessKey: NSNumber(value: state.brightness * 0.4),
                kCIInputContrastKey: NSNumber(value: state.contrast),
                kCIInputSaturationKey: NSNumber(value: effectiveSat)
            ])
        }
        
        // 4. Temperature & Tint (CITemperatureAndTint)
        if (state.temperature != 6500.0 || state.tint != 0.0) && !state.isMonoActive {
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
        
        // 6. Cinematic Look Engine (Phase 6)
        if let lookId = state.selectedLookId, lookId != "original", !state.isMonoActive {
            output = applyCinematicLook(lookId: lookId, to: output, intensity: state.lookIntensity)
        }
        
        // 7. Professional Monochrome Engine (Phase 7)
        if state.isMonoActive {
            output = applyMonochromeEngine(to: output, state: state)
        }
        
        // 8. Portrait & Skin Smoothing Engine (Frequency Separation)
        if state.skinSmoothing > 0.0 {
            let preset: SkinSmoothPreset = (state.skinSmoothing > 60.0) ? .silky : .natural
            output = applySkinSmoothingInternal(to: output, preset: preset, intensity: state.skinSmoothing / 100.0, skinMask: skinMask)
        }
        
        return output
    }
    
    // MARK: - Portrait & Skin Smoothing Pipeline (Frequency Separation)
    
    public func applySkinSmoothing(
        to inputImage: CIImage,
        preset: SkinSmoothPreset = .natural,
        intensity: Float = 0.7,
        orientation: CGImagePropertyOrientation = .up
    ) -> CIImage? {
        guard let skinMask = FaceDetectionService.shared.generateSkinMask(for: inputImage, orientation: orientation) else {
            return inputImage
        }
        
        return applySkinSmoothingInternal(to: inputImage, preset: preset, intensity: intensity, skinMask: skinMask)
    }
    
    private func applySkinSmoothingInternal(
        to inputImage: CIImage,
        preset: SkinSmoothPreset,
        intensity: Float,
        skinMask: CIImage?
    ) -> CIImage {
        guard intensity > 0.001 else { return inputImage }
        
        let extent = inputImage.extent
        let clamped = inputImage.clampedToExtent()
        let maxDim = max(extent.width, extent.height)
        let scale = max(0.5, (maxDim > 0 ? maxDim : 1920.0) / 1920.0)
        let normIntensity = CGFloat(min(max(intensity, 0.0), 1.0))
        
        // Frequency Separation Parameters
        let toneBlurRadius: CGFloat
        let textureSharpenRadius: CGFloat
        let textureSharpenIntensity: Float
        let textureBlendAlpha: Float
        let overallBlendAlpha: Float
        
        switch preset {
        case .natural:
            // Doğal: Subtle redness & blotch leveling, 100% natural pore texture (No foggy blur!)
            toneBlurRadius = (10.0 * normIntensity + 3.0) * scale
            textureSharpenRadius = max(1.0, 1.4 * scale)
            textureSharpenIntensity = Float(0.90 + 0.40 * normIntensity)
            textureBlendAlpha = 0.65
            overallBlendAlpha = Float(0.55 * normIntensity)
            
        case .silky:
            // İpeksi: Studio-grade porcelain polish, luminous tone leveling + preserved micro-pores
            toneBlurRadius = (20.0 * normIntensity + 6.0) * scale
            textureSharpenRadius = max(1.2, 1.8 * scale)
            textureSharpenIntensity = Float(0.70 + 0.35 * normIntensity)
            textureBlendAlpha = 0.45
            overallBlendAlpha = Float(0.85 * normIntensity)
        }
        
        // 1. Low-Frequency Tone Layer: Levels out redness, uneven pigment and dark blotches
        let lowFrequencyTone = clamped
            .applyingFilter("CIGaussianBlur", parameters: [
                kCIInputRadiusKey: NSNumber(value: toneBlurRadius)
            ])
            .cropped(to: extent)
        
        // 2. High-Frequency Micro-Texture Layer: Preserves crisp skin pores, natural light reflections and fine details
        let highFrequencyTexture = inputImage
            .applyingFilter("CIUnsharpMask", parameters: [
                kCIInputRadiusKey: NSNumber(value: textureSharpenRadius),
                kCIInputIntensityKey: NSNumber(value: textureSharpenIntensity)
            ])
        
        // 3. Re-combine Low-Frequency Smooth Tone with High-Frequency Crisp Texture
        let frequencySeparatedSkin = blendImages(
            base: lowFrequencyTone,
            overlay: highFrequencyTexture,
            alpha: textureBlendAlpha
        )
        
        // 4. Blend original image with frequency-separated skin according to preset intensity
        let retouchedSkin = blendImages(
            base: inputImage,
            overlay: frequencySeparatedSkin,
            alpha: overallBlendAlpha
        )
        
        // 5. Strictly apply to face skin (Forehead, cheeks, chin) - leaving eyes, brows, lips, hair 100% crisp
        if let mask = skinMask {
            let blendFilter = CIFilter.blendWithMask()
            blendFilter.inputImage = retouchedSkin
            blendFilter.backgroundImage = inputImage
            blendFilter.maskImage = mask
            
            return blendFilter.outputImage?.cropped(to: extent) ?? retouchedSkin
        } else {
            return retouchedSkin.cropped(to: extent)
        }
    }
    
    public func render(ciImage: CIImage) -> UIImage? {
        guard let cg = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: cg)
    }
    
    // MARK: - Spot Healing Engine (Adaptive Nearest-Patch Synthesis & Texture Preservation)
    
    private func applySpotHealing(to image: CIImage, spots: [HealedSpot]) -> CIImage {
        guard !spots.isEmpty else { return image }
        
        var healed = image
        let imgWidth = image.extent.width
        let imgHeight = image.extent.height
        let maxDim = max(imgWidth, imgHeight)
        
        for spot in spots {
            // Convert normalized coordinates (0...1, top-left) to CIImage coordinate system (bottom-left origin)
            let centerPoint = CGPoint(x: spot.x * imgWidth, y: (1.0 - spot.y) * imgHeight)
            let spotPixelRadius = max(6.0, spot.radius * maxDim)
            let innerOffset = spotPixelRadius * 1.35
            
            // Define localized Region of Interest (ROI) to prevent full-image overhead
            let roiRadius = spotPixelRadius * 2.2
            let spotRoi = CGRect(
                x: centerPoint.x - roiRadius,
                y: centerPoint.y - roiRadius,
                width: roiRadius * 2.0,
                height: roiRadius * 2.0
            ).intersection(image.extent)
            
            guard !spotRoi.isEmpty else { continue }
            
            // 1. High-speed 4-Direction Annular Skin Tone & Texture Sampling
            let leftSample = healed
                .transformed(by: CGAffineTransform(translationX: -innerOffset, y: 0))
                .cropped(to: spotRoi)
            let rightSample = healed
                .transformed(by: CGAffineTransform(translationX: innerOffset, y: 0))
                .cropped(to: spotRoi)
            let downSample = healed
                .transformed(by: CGAffineTransform(translationX: 0, y: -innerOffset))
                .cropped(to: spotRoi)
            let upSample = healed
                .transformed(by: CGAffineTransform(translationX: 0, y: innerOffset))
                .cropped(to: spotRoi)
            
            let hBlend = blendImages(base: leftSample, overlay: rightSample, alpha: 0.5)
            let vBlend = blendImages(base: downSample, overlay: upSample, alpha: 0.5)
            let cleanSkinPatch = blendImages(base: hBlend, overlay: vBlend, alpha: 0.5)
            
            // 2. Feathered radial circular mask with smooth falloff
            guard let radialMask = CIFilter(name: "CIRadialGradient", parameters: [
                "inputCenter": CIVector(cgPoint: centerPoint),
                "inputRadius0": NSNumber(value: spotPixelRadius * 0.15),
                "inputRadius1": NSNumber(value: spotPixelRadius * 1.05),
                "inputColor0": CIColor(red: 1, green: 1, blue: 1, alpha: 1),
                "inputColor1": CIColor(red: 0, green: 0, blue: 0, alpha: 0)
            ])?.outputImage?.cropped(to: spotRoi) else {
                continue
            }
            
            // 3. Seamlessly blend localized clean skin patch over blemish
            if let blended = CIFilter(name: "CIBlendWithMask", parameters: [
                kCIInputImageKey: cleanSkinPatch,
                kCIInputBackgroundImageKey: healed,
                kCIInputMaskImageKey: radialMask
            ])?.outputImage {
                healed = blended
            }
        }
        
        return healed.cropped(to: image.extent)
    }
    
    // MARK: - Cinematic Look Pipeline
    
    private func applyCinematicLook(lookId: String, to image: CIImage, intensity: Float) -> CIImage {
        guard intensity > 0.001 else { return image }
        
        var graded = image
        
        switch lookId {
        case "cinema": // Teal & Orange split grading
            let matrix = CIFilter(name: "CIColorMatrix", parameters: [
                kCIInputImageKey: graded,
                "inputRVector": CIVector(x: 1.15, y: 0.00, z: -0.05, w: 0.0),
                "inputGVector": CIVector(x: -0.02, y: 1.05, z: 0.02, w: 0.0),
                "inputBVector": CIVector(x: -0.08, y: 0.05, z: 1.15, w: 0.0),
                "inputAVector": CIVector(x: 0, y: 0, z: 0, w: 1.0),
                "inputBiasVector": CIVector(x: 0.04, y: 0.01, z: 0.06, w: 0.0)
            ])?.outputImage ?? graded
            graded = matrix.applyingFilter("CIColorControls", parameters: [
                kCIInputContrastKey: NSNumber(value: 1.12),
                kCIInputSaturationKey: NSNumber(value: 1.10)
            ])
            
        case "warm": // Golden Amber glow
            graded = graded.applyingFilter("CITemperatureAndTint", parameters: [
                "inputNeutral": CIVector(x: 6500, y: 0),
                "inputTargetNeutral": CIVector(x: 5200, y: 10)
            ]).applyingFilter("CIColorControls", parameters: [
                kCIInputBrightnessKey: NSNumber(value: 0.02),
                kCIInputSaturationKey: NSNumber(value: 1.15)
            ])
            
        case "cold": // Moody Nordic Blue
            graded = graded.applyingFilter("CITemperatureAndTint", parameters: [
                "inputNeutral": CIVector(x: 6500, y: 0),
                "inputTargetNeutral": CIVector(x: 8200, y: -5)
            ]).applyingFilter("CIColorControls", parameters: [
                kCIInputContrastKey: NSNumber(value: 1.08),
                kCIInputSaturationKey: NSNumber(value: 0.88)
            ])
            
        case "teal": // Deep Turquoise Shadows
            let matrix = CIFilter(name: "CIColorMatrix", parameters: [
                kCIInputImageKey: graded,
                "inputRVector": CIVector(x: 0.90, y: 0.05, z: 0.00, w: 0.0),
                "inputGVector": CIVector(x: 0.00, y: 1.10, z: 0.05, w: 0.0),
                "inputBVector": CIVector(x: 0.05, y: 0.10, z: 1.20, w: 0.0),
                "inputAVector": CIVector(x: 0, y: 0, z: 0, w: 1.0),
                "inputBiasVector": CIVector(x: -0.02, y: 0.03, z: 0.07, w: 0.0)
            ])?.outputImage ?? graded
            graded = matrix.applyingFilter("CIColorControls", parameters: [
                kCIInputContrastKey: NSNumber(value: 1.15)
            ])
            
        case "fade": // Matte Film Lifted Blacks
            let matrix = CIFilter(name: "CIColorMatrix", parameters: [
                kCIInputImageKey: graded,
                "inputRVector": CIVector(x: 0.95, y: 0.0, z: 0.0, w: 0.0),
                "inputGVector": CIVector(x: 0.0, y: 0.95, z: 0.0, w: 0.0),
                "inputBVector": CIVector(x: 0.0, y: 0.0, z: 0.95, w: 0.0),
                "inputAVector": CIVector(x: 0, y: 0, z: 0, w: 1.0),
                "inputBiasVector": CIVector(x: 0.08, y: 0.08, z: 0.08, w: 0.0)
            ])?.outputImage ?? graded
            graded = matrix.applyingFilter("CIColorControls", parameters: [
                kCIInputContrastKey: NSNumber(value: 0.90),
                kCIInputSaturationKey: NSNumber(value: 0.85)
            ])
            
        case "night": // Urban Midnight
            graded = graded.applyingFilter("CIExposureAdjust", parameters: [
                kCIInputEVKey: NSNumber(value: -0.2)
            ]).applyingFilter("CITemperatureAndTint", parameters: [
                "inputNeutral": CIVector(x: 6500, y: 0),
                "inputTargetNeutral": CIVector(x: 8800, y: 15)
            ]).applyingFilter("CIColorControls", parameters: [
                kCIInputContrastKey: NSNumber(value: 1.25),
                kCIInputSaturationKey: NSNumber(value: 1.05)
            ])
            
        case "forest": // Organic Emerald Greens
            let matrix = CIFilter(name: "CIColorMatrix", parameters: [
                kCIInputImageKey: graded,
                "inputRVector": CIVector(x: 0.92, y: 0.08, z: 0.00, w: 0.0),
                "inputGVector": CIVector(x: 0.05, y: 1.20, z: 0.00, w: 0.0),
                "inputBVector": CIVector(x: 0.00, y: 0.05, z: 0.95, w: 0.0),
                "inputAVector": CIVector(x: 0, y: 0, z: 0, w: 1.0),
                "inputBiasVector": CIVector(x: 0.01, y: 0.02, z: -0.02, w: 0.0)
            ])?.outputImage ?? graded
            graded = matrix.applyingFilter("CIColorControls", parameters: [
                kCIInputContrastKey: NSNumber(value: 1.10),
                kCIInputSaturationKey: NSNumber(value: 1.12)
            ])
            
        case "urban": // High Contrast Architectural Monochrome-like Color
            graded = graded.applyingFilter("CIColorControls", parameters: [
                kCIInputContrastKey: NSNumber(value: 1.30),
                kCIInputSaturationKey: NSNumber(value: 0.65),
                kCIInputBrightnessKey: NSNumber(value: -0.03)
            ])
            
        default:
            break
        }
        
        // Intensity Blending with Original
        if intensity < 0.999 {
            return blendImages(base: image, overlay: graded, alpha: intensity)
        }
        return graded
    }
    
    // MARK: - Monochrome Engine Pipeline
    
    private func applyMonochromeEngine(to image: CIImage, state: PhotoEditState) -> CIImage {
        let presetId = state.selectedMonoPresetId ?? "mono_natural"
        let preset = MonoPreset.allPresets.first(where: { $0.id == presetId }) ?? MonoPreset.allPresets[0]
        
        let rw = CGFloat(preset.redWeight)
        let gw = CGFloat(preset.greenWeight)
        let bw = CGFloat(preset.blueWeight)
        let bias = CGFloat(preset.brightnessOffset)
        
        // RGB Channel Luminance Matrix
        let monoMatrix = CIFilter(name: "CIColorMatrix", parameters: [
            kCIInputImageKey: image,
            "inputRVector": CIVector(x: rw, y: gw, z: bw, w: 0.0),
            "inputGVector": CIVector(x: rw, y: gw, z: bw, w: 0.0),
            "inputBVector": CIVector(x: rw, y: gw, z: bw, w: 0.0),
            "inputAVector": CIVector(x: 0, y: 0, z: 0, w: 1.0),
            "inputBiasVector": CIVector(x: bias, y: bias, z: bias, w: 0.0)
        ])?.outputImage ?? image
        
        // Tone Curve / Contrast Enhancement
        var adjusted = monoMatrix.applyingFilter("CIColorControls", parameters: [
            kCIInputContrastKey: NSNumber(value: preset.contrastMultiplier),
            kCIInputSaturationKey: NSNumber(value: 0.0)
        ])
        
        if preset.shadowLift != 0.0 || preset.highlightRecovery != 0.0 {
            adjusted = adjusted.applyingFilter("CIHighlightShadowAdjust", parameters: [
                "inputHighlightAmount": NSNumber(value: 1.0 - (preset.highlightRecovery * 0.5)),
                "inputShadowAmount": NSNumber(value: preset.shadowLift)
            ])
        }
        
        // Intensity Blending
        if state.monoIntensity < 0.999 {
            return blendImages(base: image, overlay: adjusted, alpha: state.monoIntensity)
        }
        return adjusted
    }
    
    // MARK: - Alpha Blending Helper
    
    private func blendImages(base: CIImage, overlay: CIImage, alpha: Float) -> CIImage {
        let alphaClamped = max(0.0, min(1.0, alpha))
        let alphaMatrix = CIFilter(name: "CIColorMatrix", parameters: [
            kCIInputImageKey: overlay,
            "inputAVector": CIVector(x: 0, y: 0, z: 0, w: CGFloat(alphaClamped))
        ])?.outputImage ?? overlay
        
        let blended = CIFilter(name: "CISourceOverCompositing", parameters: [
            kCIInputImageKey: alphaMatrix,
            kCIInputBackgroundImageKey: base
        ])?.outputImage ?? overlay
        
        return blended.cropped(to: base.extent)
    }
    
    // MARK: - Render Outputs
    
    /// Renders the preview image for interactive 60fps UI display.
    public func renderPreview(from input: CIImage, state: PhotoEditState, skinMask: CIImage? = nil) -> UIImage? {
        autoreleasepool {
            let processed = processImage(input, state: state, skinMask: skinMask)
            guard let cgImage = context.createCGImage(processed, from: processed.extent) else {
                return nil
            }
            return UIImage(cgImage: cgImage)
        }
    }
    
    /// Renders the full resolution image for final photo library export.
    public func renderFullResolution(from input: CIImage, state: PhotoEditState, skinMask: CIImage? = nil) -> CGImage? {
        autoreleasepool {
            let processed = processImage(input, state: state, skinMask: skinMask)
            return context.createCGImage(processed, from: processed.extent)
        }
    }
    
    // MARK: - Downsampling Helper
    
    /// Downsamples a full-resolution CIImage into an optimized preview CIImage and UIImage.
    public func generatePreview(from source: CIImage, maxDimension: CGFloat = 1920) -> (previewCI: CIImage, previewUI: UIImage)? {
        autoreleasepool {
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
}
