import Foundation
import UIKit
import UniformTypeIdentifiers
import os.log

class ImageModel: ObservableObject {
    @Published var originalImage: UIImage?
    @Published var processedImage: ImageProcessor.ProcessedImage?
    @Published var quality: Double = 0.8
    @Published var format: String = "JPEG"
    @Published var resizeEnabled: Bool = false
    @Published var customWidth: CGFloat = 0
    @Published var customHeight: CGFloat = 0
    @Published var maintainAspectRatio: Bool = true
    @Published var isProcessing: Bool = false
    @Published var isInitialLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var hasError: Bool = false

    var originalSize: Int = 0
    var originalDimensions: CGSize = .zero
    var originalFormat: String = ""
    
    private let logger = Logger(subsystem: "com.pixelperfect.app", category: "ImageModel")

    // Method for Data
    func loadImage(from data: Data) {
        guard let image = UIImage(data: data) else { return }
        originalImage = image
        originalSize = data.count
        originalDimensions = image.size
        originalFormat = determineFormat(from: data) ?? "UNKNOWN"
        customWidth = image.size.width
        customHeight = image.size.height
        processImage(isInitialLoad: true)
    }

    // Method for UIImage
    func loadImage(from image: UIImage) {
        originalImage = image
        // Estimate size and format since no URL is available
        if let pngData = image.pngData() {
            originalSize = pngData.count
            originalDimensions = image.size
            originalFormat = "PNG"
        } else if let jpegData = image.jpegData(compressionQuality: 1.0) {
            originalSize = jpegData.count
            originalDimensions = image.size
            originalFormat = "JPEG"
        } else {
            originalSize = 0
            originalDimensions = image.size
            originalFormat = "UNKNOWN"
        }
        customWidth = image.size.width
        customHeight = image.size.height
        processImage(isInitialLoad: true)
    }

    // Helper to determine format from data
    private func determineFormat(from data: Data) -> String? {
        if let imageSource = CGImageSourceCreateWithData(data as CFData, nil),
           let utType = CGImageSourceGetType(imageSource) {
            if UTType(utType as String) == .jpeg { return "JPEG" }
            if UTType(utType as String) == .png { return "PNG" }
            if UTType(utType as String) == .svg { return "SVG" }
        }
        return nil
    }

    func processImage(isInitialLoad: Bool = false, force: Bool = false) {
        guard let image = originalImage else {
            logger.warning("processImage called but no original image available")
            return
        }
        
        logger.info("Starting image processing - format: \(self.format), quality: \(self.quality), isInitialLoad: \(isInitialLoad), force: \(force)")
        
        // Clear any previous errors
        hasError = false
        errorMessage = ""
        
        if isInitialLoad {
            isInitialLoading = true
        }
        isProcessing = true
        
        // Capture values to avoid accessing self in the background thread
        let currentQuality = quality
        let currentFormat = format
        let currentResizeEnabled = resizeEnabled
        let currentWidth = customWidth
        let currentHeight = customHeight
        let currentMaintainAspectRatio = maintainAspectRatio
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let size = currentResizeEnabled ? CGSize(width: currentWidth, height: currentHeight) : nil
            self?.logger.info("Processing image with resize enabled: \(currentResizeEnabled), target size: \(size?.width ?? 0)x\(size?.height ?? 0)")
            let processed = ImageProcessor.optimizeImage(image, quality: currentQuality, format: currentFormat, resizeTo: size, maintainAspectRatio: currentMaintainAspectRatio)
            
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let processed = processed {
                    self.logger.info("Image processing completed successfully - format: \(processed.format), size: \(processed.size) bytes, dimensions: \(processed.dimensions.width)x\(processed.dimensions.height)")
                    self.processedImage = processed
                    self.hasError = false
                } else {
                    self.logger.error("Image processing failed")
                    self.processedImage = nil
                    self.hasError = true
                    self.errorMessage = "Failed to process image in \(currentFormat) format"
                }
                
                self.isProcessing = false
                if isInitialLoad {
                    self.isInitialLoading = false
                }
            }
        }
    }

    func saveProcessedImage(to url: URL) -> Bool {
        guard let processed = processedImage else { return false }
        return ImageProcessor.saveImage(processed, to: url)
    }

    func calculateSavings() -> String {
        guard let processed = processedImage else { return "0%" }
        let savings = ((Double(originalSize) - Double(processed.size)) / Double(originalSize) * 100)
        return String(format: "%.0f%%", savings)
    }
}
