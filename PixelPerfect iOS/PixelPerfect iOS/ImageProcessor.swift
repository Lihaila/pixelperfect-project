import Foundation
import UIKit
import CoreImage
import UniformTypeIdentifiers
import os.log

struct ImageProcessor {
    // MARK: - ProcessedImage Struct
    struct ProcessedImage {
        let image: UIImage
        let imageData: Data
        let size: Int
        let dimensions: CGSize
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

    // MARK: - Image Optimization
    static func optimizeImage(_ image: UIImage, quality: Double, format: String, resizeTo size: CGSize?, maintainAspectRatio: Bool = true) -> ProcessedImage? {
        logger.info("Starting image optimization - format: \(format), quality: \(quality)")
        
        // Clamp quality to valid range
        let clampedQuality = max(0.1, min(1.0, quality))
        
        // Convert UIImage to CGImage
        guard let cgImage = image.cgImage else {
            logger.error("Failed to convert UIImage to CGImage")
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
    private static func resizeImage(_ cgImage: CGImage, to targetSize: CGSize, maintainAspectRatio: Bool = true) -> CGImage? {
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
        let image = UIImage(cgImage: cgImage)
        guard let data = image.jpegData(compressionQuality: quality) else {
            logger.error("Failed to create JPEG representation")
            return nil
        }
        
        return ProcessedImage(
            image: image,
            imageData: data,
            size: data.count,
            dimensions: CGSize(width: cgImage.width, height: cgImage.height),
            format: "JPEG"
        )
    }
    
    private static func processAsPNG(_ cgImage: CGImage) -> ProcessedImage? {
        let image = UIImage(cgImage: cgImage)
        guard let data = image.pngData() else {
            logger.error("Failed to create PNG representation")
            return nil
        }
        
        return ProcessedImage(
            image: image,
            imageData: data,
            size: data.count,
            dimensions: CGSize(width: cgImage.width, height: cgImage.height),
            format: "PNG"
        )
    }
    
    private static func processAsSVG(_ cgImage: CGImage, quality: Double) -> ProcessedImage? {
        logger.info("Starting SVG processing")
        
        let width = cgImage.width
        let height = cgImage.height
        
        // Create a UIImage to get base64 encoded image data
        let image = UIImage(cgImage: cgImage)
        guard let jpegData = image.jpegData(compressionQuality: quality) else {
            logger.error("Failed to create JPEG data for SVG embedding")
            return nil
        }
        
        let base64String = jpegData.base64EncodedString()
        
        // Create SVG XML with embedded JPEG
        let svgContent = """
        <?xml version="1.0" encoding="UTF-8"?>
        <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="\(width)" height="\(height)" viewBox="0 0 \(width) \(height)">
            <image width="\(width)" height="\(height)" xlink:href="data:image/jpeg;base64,\(base64String)"/>
        </svg>
        """
        
        guard let svgData = svgContent.data(using: .utf8) else {
            logger.error("Failed to create SVG data")
            return nil
        }
        
        // For SVG format, we'll use the original image for display purposes
        // but save the SVG data. This is because UIImage can't directly render SVG.
        // The SVG data will be used when saving/sharing the file.
        logger.info("Successfully created SVG with embedded JPEG, size: \(svgData.count) bytes")
        
        return ProcessedImage(
            image: image, // Use original image for display
            imageData: svgData, // SVG data for saving
            size: svgData.count,
            dimensions: CGSize(width: width, height: height),
            format: "SVG"
        )
    }
    
    // MARK: - Image Saving
    static func saveImage(_ processedImage: ProcessedImage, to url: URL) -> Bool {
        do {
            try processedImage.imageData.write(to: url)
            logger.info("Successfully saved image to \(url.absoluteString)")
            return true
        } catch {
            logger.error("Failed to save image: \(error.localizedDescription)")
            return false
        }
    }
}
