import SwiftUI
import UniformTypeIdentifiers
import os.log

struct ResultsView: View {
    @ObservedObject var imageModel: ImageModel
    @ObservedObject var themeManager: ThemeManager
    @EnvironmentObject var windowManager: WindowManager
    @State private var widthText: String = ""
    @State private var heightText: String = ""
    @State private var isEditingDimensions = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""

    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            // Preview Section
            VStack {
                Text("Preview")
                    .font(.title2)
                    .foregroundColor(themeManager.primaryText)

                HStack {
                    if let original = imageModel.originalImage {
                        Image(nsImage: original)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 300, maxHeight: 300)
                            .border(themeManager.borderPrimary, width: 1)
                            .overlay(
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Original")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                    Text("\(String(format: "%.0f", imageModel.originalDimensions.width)) × \(String(format: "%.0f", imageModel.originalDimensions.height))")
                                        .font(.caption2)
                                        .foregroundColor(.white.opacity(0.9))
                                    Text(imageModel.originalFormat)
                                        .font(.caption2)
                                        .foregroundColor(.white.opacity(0.9))
                                    Text(formatFileSize(imageModel.originalSize))
                                        .font(.caption2)
                                        .foregroundColor(.white.opacity(0.9))
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(.black.opacity(0.75))
                                )
                                .padding(8),
                                alignment: .bottomLeading
                            )
                    }
                    if let processed = imageModel.processedImage {
                        Image(nsImage: processed.image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 300, maxHeight: 300)
                            .border(themeManager.accent, width: 1)
                            .id("processed-\(processed.dimensions.width)-\(processed.dimensions.height)-\(processed.size)")
                            .overlay(
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Optimized")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                    Text("\(String(format: "%.0f", processed.dimensions.width)) × \(String(format: "%.0f", processed.dimensions.height))")
                                        .font(.caption2)
                                        .foregroundColor(.white.opacity(0.9))
                                    Text(processed.format)
                                        .font(.caption2)
                                        .foregroundColor(.white.opacity(0.9))
                                    Text(formatFileSize(processed.size))
                                        .font(.caption2)
                                        .foregroundColor(.white.opacity(0.9))
                                    Text("Saved: \(imageModel.calculateSavings())")
                                        .font(.caption2)
                                        .fontWeight(.medium)
                                        .foregroundColor(.green.opacity(0.9))
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(.black.opacity(0.75))
                                )
                                .padding(8),
                                alignment: .bottomLeading
                            )
                    }
                }

                // Show processing indicator
                if imageModel.isProcessing {
                    ProgressView("Processing...")
                        .progressViewStyle(CircularProgressViewStyle(tint: themeManager.accent))
                        .foregroundColor(themeManager.primaryText)
                        .padding()
                } else {
                    Button(action: showComparison) {
                        HStack {
                            Image(systemName: "eye")
                            Text("Compare")
                        }
                    }
                    .buttonStyle(MacOSCompatibleButtonStyle(prominence: .primary))
                    .disabled(imageModel.processedImage == nil)
                }
            }
            .frame(maxWidth: .infinity)

            // Advanced Options
            VStack(alignment: .leading, spacing: 10) {
                Text("Advanced Options")
                    .font(.title2)
                    .foregroundColor(themeManager.primaryText)

                // Quality Slider
                HStack {
                    Text("Quality: \(Int(imageModel.quality * 100))%")
                        .foregroundColor(themeManager.primaryText)
                    Slider(value: $imageModel.quality, in: 0.1...1.0, step: 0.1)
                        .accentColor(themeManager.accent)
                        .onChange(of: imageModel.quality) { _ in 
                            imageModel.processImage()
                        }
                }

                // Format Selection
                VStack(alignment: .leading, spacing: 5) {
                    Text("Output Format")
                        .foregroundColor(themeManager.primaryText)
                    
                    Picker("Output Format", selection: $imageModel.format) {
                        Text("JPEG").tag("JPEG")
                        Text("PNG").tag("PNG")
                        Text("SVG").tag("SVG")
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: imageModel.format) { newValue in 
                        print("[DEBUG] Format changed to: \(newValue)")
                        imageModel.processImage()
                    }
                }

                // Resize Options
                Toggle("Resize Image", isOn: $imageModel.resizeEnabled)
                    .toggleStyle(SwitchToggleStyle())
                    .onChange(of: imageModel.resizeEnabled) { newValue in 
                        print("[DEBUG] Resize enabled changed to: \(newValue)")
                        imageModel.processImage()
                    }

                if imageModel.resizeEnabled {
                    VStack(spacing: 8) {
                        HStack {
                            Text("Width:")
                                .foregroundColor(themeManager.primaryText)
                                .frame(width: 50, alignment: .leading)
                            TextField("Width", text: $widthText)
                                .textFieldStyle(.roundedBorder)
                                .onChange(of: widthText) { newValue in
                                    print("[DEBUG] Width text changed to: \(newValue)")
                                    updateWidthFromText()
                                }
                            Text("Height:")
                                .foregroundColor(themeManager.primaryText)
                                .frame(width: 50, alignment: .leading)
                            TextField("Height", text: $heightText)
                                .textFieldStyle(.roundedBorder)
                                .onChange(of: heightText) { newValue in
                                    print("[DEBUG] Height text changed to: \(newValue)")
                                    updateHeightFromText()
                                }
                        }
                        
                        Toggle("Maintain Aspect Ratio", isOn: $imageModel.maintainAspectRatio)
                            .toggleStyle(SwitchToggleStyle())
                            .onChange(of: imageModel.maintainAspectRatio) { newValue in
                                print("[DEBUG] Maintain aspect ratio changed to: \(newValue)")
                                // When aspect ratio changes, update text fields to reflect current values
                                updateTextFields()
                                imageModel.processImage()
                            }
                    }
                }

                // Action Buttons
                HStack(spacing: 12) {
                    Button(action: {
                        // Reset dimensions to original
                        if let original = imageModel.originalImage {
                            imageModel.customWidth = original.size.width
                            imageModel.customHeight = original.size.height
                            updateTextFields()
                            if imageModel.resizeEnabled {
                                imageModel.processImage()
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: "arrow.uturn.left")
                            Text("Reset Size")
                        }
                    }
                    .buttonStyle(MacOSCompatibleButtonStyle(prominence: .secondary))
                    .disabled(imageModel.originalImage == nil)

                    Button(action: saveImage) {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                            Text("Download")
                        }
                    }
                    .buttonStyle(MacOSCompatibleButtonStyle(prominence: .primary))
                    .disabled(imageModel.processedImage == nil)

                    Button(action: {
                        imageModel.originalImage = nil
                        imageModel.processedImage = nil
                        widthText = ""
                        heightText = ""
                    }) {
                        HStack {
                            Image(systemName: "doc.badge.plus")
                            Text("New File")
                        }
                    }
                    .buttonStyle(MacOSCompatibleButtonStyle(prominence: .tertiary))
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .onAppear {
            print("[DEBUG] ResultsView appeared!")
            updateTextFields()
        }
        .onChange(of: imageModel.customWidth) { _ in
            if !isEditingDimensions {
                updateTextFields()
            }
        }
        .onChange(of: imageModel.customHeight) { _ in
            if !isEditingDimensions {
                updateTextFields()
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private func updateTextFields() {
        widthText = String(format: "%.0f", imageModel.customWidth)
        heightText = String(format: "%.0f", imageModel.customHeight)
    }

    private func updateWidthFromText() {
        print("[DEBUG] updateWidthFromText called with: \(widthText)")
        print("[DEBUG] maintainAspectRatio: \(imageModel.maintainAspectRatio)")
        
        isEditingDimensions = true
        defer { isEditingDimensions = false }

        guard let value = NumberFormatter().number(from: widthText)?.doubleValue, value > 0 else {
            print("[DEBUG] Invalid width value: \(widthText)")
            return
        }
        
        print("[DEBUG] Setting customWidth to: \(value)")
        imageModel.customWidth = CGFloat(value)
        
        if imageModel.maintainAspectRatio, let original = imageModel.originalImage {
            let aspectRatio = original.size.height / original.size.width
            let newHeight = imageModel.customWidth * aspectRatio
            print("[DEBUG] Aspect ratio mode: new height calculated as \(newHeight)")
            imageModel.customHeight = newHeight
            heightText = String(format: "%.0f", imageModel.customHeight)
        } else {
            print("[DEBUG] Independent mode: height stays \(imageModel.customHeight)")
        }
        
        // Process image with updated dimensions
        if imageModel.resizeEnabled {
            print("[DEBUG] Processing image with dimensions: \(imageModel.customWidth)x\(imageModel.customHeight)")
            imageModel.processImage()
        }
    }

    private func updateHeightFromText() {
        print("[DEBUG] updateHeightFromText called with: \(heightText)")
        print("[DEBUG] maintainAspectRatio: \(imageModel.maintainAspectRatio)")
        
        isEditingDimensions = true
        defer { isEditingDimensions = false }

        guard let value = NumberFormatter().number(from: heightText)?.doubleValue, value > 0 else {
            print("[DEBUG] Invalid height value: \(heightText)")
            return
        }
        
        print("[DEBUG] Setting customHeight to: \(value)")
        imageModel.customHeight = CGFloat(value)
        
        if imageModel.maintainAspectRatio, let original = imageModel.originalImage {
            let aspectRatio = original.size.width / original.size.height
            let newWidth = imageModel.customHeight * aspectRatio
            print("[DEBUG] Aspect ratio mode: new width calculated as \(newWidth)")
            imageModel.customWidth = newWidth
            widthText = String(format: "%.0f", imageModel.customWidth)
        } else {
            print("[DEBUG] Independent mode: width stays \(imageModel.customWidth)")
        }
        
        // Process image with updated dimensions
        if imageModel.resizeEnabled {
            print("[DEBUG] Processing image with dimensions: \(imageModel.customWidth)x\(imageModel.customHeight)")
            imageModel.processImage()
        }
    }

    private func formatFileSize(_ bytes: Int) -> String {
        let kilobyte = 1000.0
        let megabyte = kilobyte * 1000
        if Double(bytes) < kilobyte {
            return "\(bytes) B"
        } else if Double(bytes) < megabyte {
            return String(format: "%.1f KB", Double(bytes) / kilobyte)
        } else {
            return String(format: "%.2f MB", Double(bytes) / megabyte)
        }
    }

    private func saveImage() {
        guard let processed = imageModel.processedImage else { 
            showAlert("Error", "No processed image to save.")
            return 
        }

        let panel = NSSavePanel()

        // Set up correct file types based on format
        switch imageModel.format.lowercased() {
        case "png":
            panel.allowedContentTypes = [.png]
            panel.nameFieldStringValue = "optimized-image.png"
        case "svg":
            panel.allowedContentTypes = [.svg]
            panel.nameFieldStringValue = "optimized-image.svg"
        default:
            panel.allowedContentTypes = [.jpeg]
            panel.nameFieldStringValue = "optimized-image.jpg"
        }

        if panel.runModal() == .OK, let url = panel.url {
            let success = ImageProcessor.saveImage(processed, to: url)
            if success {
                showAlert("Success", "Image saved successfully!")
            } else {
                showAlert("Error", "Failed to save image. Please try again.")
            }
        }
    }

    private func showAlert(_ title: String, _ message: String) {
        alertTitle = title
        alertMessage = message
        showingAlert = true
    }

    private func showComparison() {
        print("[DEBUG] Opening comparison window")
        print("[DEBUG] Current format selection: \(imageModel.format)")
        if let processed = imageModel.processedImage {
            print("[DEBUG] Processed image format: \(processed.format)")
            print("[DEBUG] Processed image size: \(processed.size)")
        } else {
            print("[DEBUG] No processed image available")
        }
        windowManager.showComparisonWindow(with: imageModel, themeManager: themeManager)
    }
    
}
