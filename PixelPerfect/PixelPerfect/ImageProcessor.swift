import Foundation
import AppKit
import CoreImage
import UniformTypeIdentifiers
import os.log

struct ImageProcessor {
    // MARK: - ProcessedImage Struct
    struct ProcessedImage {
        let image: NSImage
        let imageData: Data
        let size: Int
        let dimensions: NSSize
        let format: String
    }
    
    // MARK: - Error Types
    enum ProcessingError: LocalizedError {
        case invalidImage
        case unsupportedFormat
        case processingFailed
        case svgGenerationFailed
        
        var errorDescription: String? {
            switch self {
            case .invalidImage: return "Invalid image data"
            case .unsupportedFormat: return "Unsupported image format"
            case .processingFailed: return "Image processing failed"
            case .svgGenerationFailed: return "SVG generation failed"
            }
        }
    }

    // Shared CIContext to avoid creating new ones repeatedly
    private static let sharedContext = CIContext()
    private static let logger = Logger(subsystem: "com.pixelperfect.app", category: "ImageProcessor")

    // MARK: - Image Loading
    static func loadImage(from url: URL) -> NSImage? {
        logger.info("Loading image from URL: \(url.absoluteString)")
        return NSImage(contentsOf: url)
    }

    // MARK: - Image Optimization
    static func optimizeImage(_ image: NSImage, quality: Double, format: String, resizeTo size: NSSize?, maintainAspectRatio: Bool = true) -> ProcessedImage? {
        logger.info("Starting image optimization - format: \(format), quality: \(quality)")
        
        // Clamp quality to valid range
        let clampedQuality = max(0.1, min(1.0, quality))
        
        // Convert NSImage to CGImage
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            logger.error("Failed to convert NSImage to CGImage")
            return nil
        }
        
        // Apply resize if specified
        let processedCGImage: CGImage
        if let targetSize = size, targetSize.width > 0, targetSize.height > 0 {
            processedCGImage = resizeImage(cgImage, to: targetSize, maintainAspectRatio: maintainAspectRatio) ?? cgImage
        } else {
            processedCGImage = cgImage
        }
        
        // Process based on format
        let result: ProcessedImage?
        switch format.lowercased() {
        case "jpeg":
            result = processAsJPEG(processedCGImage, quality: clampedQuality)
        case "png":
            result = processAsPNG(processedCGImage)
        case "svg":
            result = processAsSVG(processedCGImage, quality: clampedQuality)
        default:
            logger.warning("Unknown format \(format), defaulting to JPEG")
            result = processAsJPEG(processedCGImage, quality: clampedQuality)
        }
        
        if let result = result {
            logger.info("Image optimization completed - output format: \(result.format), size: \(result.size) bytes")
        } else {
            logger.error("Image optimization failed")
        }
        
        return result
    }
    
    // MARK: - Private Processing Methods
    private static func resizeImage(_ cgImage: CGImage, to targetSize: NSSize, maintainAspectRatio: Bool = true) -> CGImage? {
        let originalWidth = cgImage.width
        let originalHeight = cgImage.height
        
        logger.info("Resizing image from \(originalWidth)x\(originalHeight) to \(targetSize.width)x\(targetSize.height), maintainAspectRatio: \(maintainAspectRatio)")
        
        let newWidth: Int
        let newHeight: Int
        
        if maintainAspectRatio {
            // Maintain aspect ratio behavior
            let scaleX = targetSize.width / CGFloat(originalWidth)
            let scaleY = targetSize.height / CGFloat(originalHeight)
            let scale = min(scaleX, scaleY)
            
            newWidth = Int(CGFloat(originalWidth) * scale)
            newHeight = Int(CGFloat(originalHeight) * scale)
            
            // Check if we even need to resize
            if newWidth == originalWidth && newHeight == originalHeight {
                return cgImage
            }
        } else {
            // New behavior: stretch to exact dimensions
            newWidth = Int(targetSize.width)
            newHeight = Int(targetSize.height)
            
            // Check if we even need to resize
            if newWidth == originalWidth && newHeight == originalHeight {
                return cgImage
            }
        }
        
        guard let colorSpace = cgImage.colorSpace else { return nil }
        
        guard let context = CGContext(
            data: nil,
            width: newWidth,
            height: newHeight,
            bitsPerComponent: cgImage.bitsPerComponent,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: cgImage.bitmapInfo.rawValue
        ) else { return nil }
        
        context.interpolationQuality = .high
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        logger.info("Successfully resized image to \(newWidth)x\(newHeight)")
        return context.makeImage()
    }
    
    private static func processAsJPEG(_ cgImage: CGImage, quality: Double) -> ProcessedImage? {
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        let properties: [NSBitmapImageRep.PropertyKey: Any] = [
            .compressionFactor: quality
        ]
        
        guard let data = bitmapRep.representation(using: .jpeg, properties: properties),
              let image = NSImage(data: data) else {
            logger.error("Failed to create JPEG representation")
            return nil
        }
        
        return ProcessedImage(
            image: image,
            imageData: data,
            size: data.count,
            dimensions: NSSize(width: cgImage.width, height: cgImage.height),
            format: "JPEG"
        )
    }
    
    private static func processAsPNG(_ cgImage: CGImage) -> ProcessedImage? {
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        
        guard let data = bitmapRep.representation(using: .png, properties: [:]),
              let image = NSImage(data: data) else {
            logger.error("Failed to create PNG representation")
            return nil
        }
        
        return ProcessedImage(
            image: image,
            imageData: data,
            size: data.count,
            dimensions: NSSize(width: cgImage.width, height: cgImage.height),
            format: "PNG"
        )
    }
    
    private static func processAsSVG(_ cgImage: CGImage, quality: Double) -> ProcessedImage? {
        logger.info("Starting SVG processing")
        
        let width = cgImage.width
        let height = cgImage.height
        
        // Create a bitmap representation to get base64 encoded image data
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        let properties: [NSBitmapImageRep.PropertyKey: Any] = [
            .compressionFactor: quality
        ]
        
        guard let jpegData = bitmapRep.representation(using: .jpeg, properties: properties) else {
            logger.error("Failed to create JPEG data for SVG embedding")
            return nil
        }
        
        let base64String = jpegData.base64EncodedString()
        
        // Create SVG XML with embedded JPEG
        let svgContent = """
        <?xml version="1.0" encoding="UTF-8"?>
        <svg width="\(width)" height="\(height)" viewBox="0 0 \(width) \(height)" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
            <image width="\(width)" height="\(height)" xlink:href="data:image/jpeg;base64,\(base64String)"/>
        </svg>
        """
        
        guard let svgData = svgContent.data(using: .utf8),
              let svgImage = NSImage(data: svgData) else {
            logger.error("Failed to create SVG representation")
            return nil
        }
        
        logger.info("SVG processing completed - embedded JPEG quality: \(quality)")
        
        return ProcessedImage(
            image: svgImage,
            imageData: svgData,
            size: svgData.count,
            dimensions: NSSize(width: width, height: height),
            format: "SVG"
        )
    }

    // MARK: - Image Saving
    static func saveImage(_ processedImage: ProcessedImage, to url: URL) -> Bool {
        do {
            try processedImage.imageData.write(to: url)
            logger.info("Image saved successfully to: \(url.absoluteString)")
            return true
        } catch {
            logger.error("Failed to save image: \(error.localizedDescription)")
            return false
        }
    }
}
