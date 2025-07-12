import SwiftUI
import PhotosUI
import Photos

struct ContentView: View {
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var imageModel = ImageModel()
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(themeManager: themeManager, imageModel: imageModel)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0)
            
            AboutView(themeManager: themeManager)
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
                .tag(1)
        }
        .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
    }
}

struct HomeView: View {
    @ObservedObject var themeManager: ThemeManager
    @ObservedObject var imageModel: ImageModel
    @StateObject private var navigationManager = NavigationManager()
    @State private var selectedItem: PhotosPickerItem? = nil
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                HeaderView(themeManager: themeManager)
                
                // Main content area
                Group {
                    if imageModel.originalImage == nil {
                        ImageSelectionView(selectedItem: $selectedItem)
                    } else if imageModel.isInitialLoading {
                        ProcessingView(imageModel: imageModel, themeManager: themeManager)
                    } else {
                        ResultsView(imageModel: imageModel, themeManager: themeManager)
                    }
                }
                .cardStyle(theme: themeManager)
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
        }
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let newItem = newItem,
                   let data = try? await newItem.loadTransferable(type: Data.self) {
                    imageModel.loadImage(from: data)
                }
            }
        }
    }
}

struct HeaderView: View {
    @ObservedObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                HStack(spacing: 12) {
                    // Logo with fallback
                    if let logoImage = UIImage(named: "Logo") {
                        Image(uiImage: logoImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                            .cornerRadius(8)
                    } else {
                        // Fallback icon if logo not found
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 32, weight: .medium))
                            .foregroundColor(themeManager.accent)
                            .frame(width: 40, height: 40)
                    }
                    
                    Text("PixelPerfect")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(themeManager.accent)
                }
                
                Spacer()
                
                Button(action: {
                    themeManager.toggleTheme()
                }) {
                    Image(systemName: themeManager.isDarkMode ? "sun.max.fill" : "moon.fill")
                        .font(.title2)
                        .foregroundColor(themeManager.accent)
                }
            }
            
            Text("Professional Image Optimization")
                .font(.subheadline)
                .foregroundColor(themeManager.secondaryText)
        }
    }
}

struct ImageSelectionView: View {
    @Binding var selectedItem: PhotosPickerItem?
    @State private var isHovered = false
    
    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            // Icon and main text
            VStack(spacing: AppSpacing.lg) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 80, height: 80)
                        .scaleEffect(isHovered ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.3), value: isHovered)
                    
                    Image(systemName: "photo.badge.plus")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(.blue)
                        .scaleEffect(isHovered ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.3), value: isHovered)
                }
                
                VStack(spacing: AppSpacing.sm) {
                    Text("Select Your Image")
                        .font(.title2)
                        .foregroundColor(.primary)
                        .fontWeight(.semibold)
                    
                    Text("Tap to choose a photo from your library")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            // Supported formats
            VStack(spacing: AppSpacing.sm) {
                Text("SUPPORTED FORMATS")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: AppSpacing.md) {
                    ForEach(["JPG", "PNG", "SVG"], id: \.self) { format in
                        Text(format)
                            .font(.caption2)
                            .foregroundColor(.primary)
                            .padding(.horizontal, AppSpacing.sm)
                            .padding(.vertical, AppSpacing.xs)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.sm))
                    }
                }
            }
            
            // Browse button
            PhotosPicker(
                selection: $selectedItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 14, weight: .medium))
                    
                    Text("Choose Photo")
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
            }
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isHovered)
            .onHover { hovering in
                isHovered = hovering
            }
            
            // File size limit
            Text("Maximum file size: 10MB")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(AppSpacing.xxl)
        .frame(maxWidth: .infinity, minHeight: 400)
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.xl)
                .fill(Color.gray.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: AppCornerRadius.xl)
                        .stroke(
                            Color.gray.opacity(0.3),
                            style: StrokeStyle(lineWidth: 2, dash: [10, 5])
                        )
                )
        )
    }
}

struct ProcessingView: View {
    @ObservedObject var imageModel: ImageModel
    @ObservedObject var themeManager: ThemeManager
    @State private var animationProgress: CGFloat = 0
    
    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            // Animated processing indicator
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 3)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: animationProgress)
                    .stroke(.blue, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: false), value: animationProgress)
                
                Image(systemName: "wand.and.rays")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.blue)
                    .rotationEffect(.degrees(animationProgress * 360))
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: false), value: animationProgress)
            }
            .onAppear {
                animationProgress = 1.0
            }
            
            VStack(spacing: AppSpacing.sm) {
                Text("Processing Image...")
                    .font(.title2)
                    .foregroundColor(.primary)
                    .fontWeight(.semibold)
                
                Text("Optimizing your \(imageModel.originalFormat) image")
                    .font(.callout)
                    .foregroundColor(.secondary)
            }
            
            // Image info card
            VStack(spacing: AppSpacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text("ORIGINAL SIZE")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(formatFileSize(imageModel.originalSize))
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: AppSpacing.xs) {
                        Text("FORMAT")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(imageModel.originalFormat)
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                }
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                
                HStack {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text("DIMENSIONS")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(Int(imageModel.originalDimensions.width)) × \(Int(imageModel.originalDimensions.height))")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: AppSpacing.xs) {
                        Text("STATUS")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: AppSpacing.xs) {
                            Circle()
                                .fill(.orange)
                                .frame(width: 6, height: 6)
                                .scaleEffect(1.2)
                                .animation(.easeInOut(duration: 0.8).repeatForever(), value: animationProgress)
                            
                            Text("Processing")
                                .font(.callout)
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
            .padding(AppSpacing.lg)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(AppCornerRadius.md)
        }
        .padding(AppSpacing.xl)
        .frame(maxWidth: .infinity, minHeight: 400)
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
}

struct ResultsView: View {
    @ObservedObject var imageModel: ImageModel
    @ObservedObject var themeManager: ThemeManager
    @State private var showingResize = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Original vs Processed Images
            HStack(spacing: 16) {
                VStack {
                    Text("Original")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let originalImage = imageModel.originalImage {
                        Image(uiImage: originalImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 120)
                            .cornerRadius(8)
                    }
                    
                    VStack(spacing: 2) {
                        Text(formatFileSize(imageModel.originalSize))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Text("\(Int(imageModel.originalDimensions.width)) × \(Int(imageModel.originalDimensions.height))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Image(systemName: "arrow.right")
                    .foregroundColor(.blue)
                
                VStack {
                    Text("Optimized")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let processedImage = imageModel.processedImage {
                        Image(uiImage: processedImage.image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 120)
                            .cornerRadius(8)
                    }
                    
                    if let processed = imageModel.processedImage {
                        VStack(spacing: 2) {
                            Text(formatFileSize(processed.size))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            Text("\(Int(processed.dimensions.width)) × \(Int(processed.dimensions.height))")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            // Stats
            if let processed = imageModel.processedImage {
                HStack {
                    VStack {
                        Text("Saved")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(imageModel.calculateSavings())
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    
                    Spacer()
                    
                    VStack {
                        Text("Format")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(processed.format)
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                    
                    VStack {
                        Text("Quality")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(Int(imageModel.quality * 100))%")
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }
            
            // Format Selection
            VStack(alignment: .leading, spacing: 12) {
                Text("Output Format")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Picker("Format", selection: $imageModel.format) {
                    Label("JPEG", systemImage: "photo")
                        .tag("JPEG")
                    Label("PNG", systemImage: "photo")
                        .tag("PNG")
                    Label("SVG", systemImage: "doc.text")
                        .tag("SVG")
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: imageModel.format) { _, _ in
                    imageModel.processImage()
                }
                
                // Format-specific options
                if imageModel.format == "SVG" {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                                .font(.system(size: 14))
                            Text("SVG with embedded JPEG")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Text("Quality: \(Int(imageModel.quality * 100))%")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Slider(value: $imageModel.quality, in: 0.1...1.0, step: 0.1)
                            .onChange(of: imageModel.quality) { _, _ in
                                imageModel.processImage()
                            }
                        
                        Text("Creates a scalable SVG file with your image embedded as high-quality JPEG data.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                } else if imageModel.format == "JPEG" {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Quality: \(Int(imageModel.quality * 100))%")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Slider(value: $imageModel.quality, in: 0.1...1.0, step: 0.1)
                            .onChange(of: imageModel.quality) { _, _ in
                                imageModel.processImage()
                            }
                    }
                } else if imageModel.format == "PNG" {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                                .font(.system(size: 14))
                            Text("Lossless compression")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Text("PNG format preserves all image data without quality loss, ideal for images with transparency.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
            
            // Actions
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Button(action: { showingResize = true }) {
                        Label("Resize", systemImage: "arrow.up.left.and.arrow.down.right")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    
                    Button(action: downloadImage) {
                        Label("Save", systemImage: "square.and.arrow.down")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                HStack(spacing: 12) {
                    Button(action: {
                        imageModel.originalImage = nil
                        imageModel.processedImage = nil
                    }) {
                        Label("New Image", systemImage: "photo.badge.plus")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    
                    Button(action: shareImage) {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding()
        .sheet(isPresented: $showingResize) {
            ResizeView(imageModel: imageModel)
        }
    }
    
    private func formatFileSize(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
    
    private func shareImage() {
        guard let processedImage = imageModel.processedImage else { return }
        
        let activityController = UIActivityViewController(
            activityItems: [processedImage.image],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityController, animated: true)
        }
    }
    
    private func downloadImage() {
        guard let processedImage = imageModel.processedImage else { return }
        
        // Save using Photos framework with iOS 14+ authorization
        if #available(iOS 14, *) {
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                DispatchQueue.main.async {
                    if status == .authorized {
                        self.saveImageToPhotoLibrary(processedImage.image)
                    } else {
                        self.imageModel.errorMessage = "Permission denied to access Photos"
                        self.imageModel.hasError = true
                    }
                }
            }
        } else {
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    if status == .authorized {
                        self.saveImageToPhotoLibrary(processedImage.image)
                    } else {
                        self.imageModel.errorMessage = "Permission denied to access Photos"
                        self.imageModel.hasError = true
                    }
                }
            }
        }
        
        // Provide haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private func saveImageToPhotoLibrary(_ image: UIImage) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { success, error in
            DispatchQueue.main.async {
                if success {
                    print("Image saved successfully")
                    self.imageModel.errorMessage = "Image saved to Photos"
                    self.imageModel.hasError = false
                } else {
                    print("Error saving image: \(error?.localizedDescription ?? "Unknown error")")
                    self.imageModel.errorMessage = "Failed to save image"
                    self.imageModel.hasError = true
                }
            }
        }
    }
}

struct SettingsView: View {
    @ObservedObject var imageModel: ImageModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Quality: \(Int(imageModel.quality * 100))%")
                        .font(.headline)
                    
                    Slider(value: $imageModel.quality, in: 0.1...1.0, step: 0.1)
                        .onChange(of: imageModel.quality) { _, _ in
                            imageModel.processImage()
                        }
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Format")
                        .font(.headline)
                    
                    Picker("Format", selection: $imageModel.format) {
                        HStack {
                            Image(systemName: "photo")
                                .foregroundColor(.blue)
                            Text("JPEG")
                        }.tag("JPEG")
                        
                        HStack {
                            Image(systemName: "photo")
                                .foregroundColor(.blue)
                            Text("PNG")
                        }.tag("PNG")
                        
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.orange)
                            Text("SVG")
                        }.tag("SVG")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: imageModel.format) { _, _ in
                        imageModel.processImage()
                    }
                }
                
                if imageModel.format == "SVG" {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                            Text("SVG Info")
                                .font(.headline)
                        }
                        Text("SVG (Scalable Vector Graphics) format is ideal for logos and simple graphics that need to scale without loss of quality.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ResizeView: View {
    @ObservedObject var imageModel: ImageModel
    @Environment(\.dismiss) var dismiss
    @State private var widthString: String = ""
    @State private var heightString: String = ""
    @FocusState private var isWidthFocused: Bool
    @FocusState private var isHeightFocused: Bool
    @State private var lastUserModifiedField: String? = nil
    @State private var isUpdatingProgrammatically: Bool = false
    
    private var aspectRatio: CGFloat {
        guard imageModel.originalDimensions.width > 0 else { return 1.0 }
        return imageModel.originalDimensions.height / imageModel.originalDimensions.width
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Current dimensions card
                VStack(alignment: .leading, spacing: 16) {
                    Text("Current Size")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Label("\(Int(imageModel.originalDimensions.width)) × \(Int(imageModel.originalDimensions.height))", systemImage: "viewfinder")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Toggle("Enable Resize", isOn: $imageModel.resizeEnabled)
                            .labelsHidden()
                            .toggleStyle(SwitchToggleStyle(tint: .blue))
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
                
                if imageModel.resizeEnabled {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("New Dimensions")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 16) {
                            HStack(spacing: 12) {
                                Text("Width")
                                    .frame(width: 60, alignment: .leading)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                TextField("Width", text: $widthString)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.numberPad)
                                    .focused($isWidthFocused)
                                    .onChange(of: widthString) { _, newValue in
                                        onWidthChanged(newValue)
                                    }
                                
                                Text("px")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack(spacing: 12) {
                                Text("Height")
                                    .frame(width: 60, alignment: .leading)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                TextField("Height", text: $heightString)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.numberPad)
                                    .focused($isHeightFocused)
                                    .onChange(of: heightString) { _, newValue in
                                        onHeightChanged(newValue)
                                    }
                                
                                Text("px")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        HStack {
                            Image(systemName: imageModel.maintainAspectRatio ? "lock" : "lock.open")
                                .foregroundColor(imageModel.maintainAspectRatio ? .blue : .secondary)
                                .font(.system(size: 16, weight: .medium))
                            
                            Toggle("Maintain Aspect Ratio", isOn: $imageModel.maintainAspectRatio)
                                .onChange(of: imageModel.maintainAspectRatio) { _, enabled in
                                    if enabled {
                                        updateAspectRatioFromWidth()
                                    }
                                }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                    
                    // Preview of new size
                    if !widthString.isEmpty && !heightString.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Preview")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Text("New size: \(widthString) × \(heightString)")
                                    .font(.callout)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if let width = Double(widthString), let height = Double(heightString) {
                                    let originalPixels = imageModel.originalDimensions.width * imageModel.originalDimensions.height
                                    let newPixels = width * height
                                    let ratio = newPixels / Double(originalPixels)
                                    
                                    Text(ratio > 1 ? "↑\(String(format: "%.1f", ratio))x" : "↓\(String(format: "%.1f", 1/ratio))x")
                                        .font(.caption)
                                        .foregroundColor(ratio > 1 ? .orange : .green)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(6)
                                }
                            }
                        }
                        .padding()
                        .background(Color.blue.opacity(0.05))
                        .cornerRadius(12)
                    }
                }
                
                Spacer()
                
                if imageModel.resizeEnabled {
                    Button(action: {
                        imageModel.processImage(force: true)
                        dismiss()
                    }) {
                        Label("Apply Resize", systemImage: "checkmark")
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
            }
            .padding()
            .navigationTitle("Resize Image")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
            }
        }
        .onAppear {
            widthString = "\(Int(imageModel.customWidth))"
            heightString = "\(Int(imageModel.customHeight))"
        }
    }
    
    private func onWidthChanged(_ newValue: String) {
        print("📝 onWidthChanged called with: \(newValue)")
        
        // Skip if we're in the middle of a programmatic update
        if isUpdatingProgrammatically {
            print("🔄 Skipping width update - programmatic update in progress")
            return
        }
        
        // Mark this as a user-initiated change
        lastUserModifiedField = "width"
        
        // Update the model with the new width value
        if let width = Double(newValue), width > 0 {
            imageModel.customWidth = CGFloat(width)
            print("✅ Updated customWidth to: \(imageModel.customWidth)")
        } else {
            print("❌ Invalid width value: \(newValue)")
        }
        
        // If aspect ratio is locked, update height based on width
        if imageModel.maintainAspectRatio && !newValue.isEmpty {
            updateHeightFromWidth()
        }
    }
    
    private func onHeightChanged(_ newValue: String) {
        print("📝 onHeightChanged called with: \(newValue)")
        
        // Skip if we're in the middle of a programmatic update
        if isUpdatingProgrammatically {
            print("🔄 Skipping height update - programmatic update in progress")
            return
        }
        
        // Mark this as a user-initiated change
        lastUserModifiedField = "height"
        
        // Update the model with the new height value
        if let height = Double(newValue), height > 0 {
            imageModel.customHeight = CGFloat(height)
            print("✅ Updated customHeight to: \(imageModel.customHeight)")
        } else {
            print("❌ Invalid height value: \(newValue)")
        }
        
        // If aspect ratio is locked, update width based on height
        if imageModel.maintainAspectRatio && !newValue.isEmpty {
            updateWidthFromHeight()
        }
    }
    
    private func updateHeightFromWidth() {
        // Only update height if width was the last user-modified field
        guard lastUserModifiedField == "width",
              imageModel.maintainAspectRatio,
              imageModel.originalDimensions.width > 0,
              let width = Double(widthString),
              width > 0 else { 
            print("🚫 updateHeightFromWidth: Guard failed")
            return 
        }
        
        print("📐 updateHeightFromWidth: width=\(width), originalDims=\(imageModel.originalDimensions)")
        
        isUpdatingProgrammatically = true
        
        let aspectRatio = imageModel.originalDimensions.height / imageModel.originalDimensions.width
        let newHeight = Int(CGFloat(width) * aspectRatio)
        heightString = "\(newHeight)"
        imageModel.customHeight = CGFloat(newHeight)
        
        print("🔢 Calculated: aspectRatio=\(aspectRatio), newHeight=\(newHeight)")
        
        // Reset the flag after a short delay to allow onChange to process
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.isUpdatingProgrammatically = false
        }
    }
    
    private func updateWidthFromHeight() {
        // Only update width if height was the last user-modified field
        guard lastUserModifiedField == "height",
              imageModel.maintainAspectRatio,
              imageModel.originalDimensions.height > 0,
              let height = Double(heightString),
              height > 0 else { 
            print("🚫 updateWidthFromHeight: Guard failed")
            return 
        }
        
        print("📐 updateWidthFromHeight: height=\(height), originalDims=\(imageModel.originalDimensions)")
        
        isUpdatingProgrammatically = true
        
        let aspectRatio = imageModel.originalDimensions.width / imageModel.originalDimensions.height
        let newWidth = Int(CGFloat(height) * aspectRatio)
        widthString = "\(newWidth)"
        imageModel.customWidth = CGFloat(newWidth)
        
        print("🔢 Calculated: aspectRatio=\(aspectRatio), newWidth=\(newWidth)")
        
        // Reset the flag after a short delay to allow onChange to process
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.isUpdatingProgrammatically = false
        }
    }
    
    private func updateAspectRatioFromWidth() {
        // This function is called when the aspect ratio toggle is turned on
        // Set width as the last modified field and update height
        lastUserModifiedField = "width"
        updateHeightFromWidth()
    }
}

struct AboutView: View {
    @ObservedObject var themeManager: ThemeManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // App Header
                    VStack(spacing: 16) {
                        // Logo
                        if let logoImage = UIImage(named: "Logo") {
                            Image(uiImage: logoImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 120, height: 120)
                                .cornerRadius(24)
                        } else {
                            Image(systemName: "photo.badge.plus")
                                .font(.system(size: 80, weight: .medium))
                                .foregroundColor(themeManager.accent)
                                .frame(width: 120, height: 120)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(24)
                        }
                        
                        VStack(spacing: 8) {
                            Text("PixelPerfect")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(themeManager.accent)
                            
                            Text("Professional Image Optimization")
                                .font(.subheadline)
                                .foregroundColor(themeManager.secondaryText)
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    // Features Section
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Features")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 16) {
                            FeatureRow(
                                icon: "photo",
                                title: "Multiple Formats",
                                description: "Support for JPEG, PNG, and SVG formats with optimized compression",
                                color: .blue
                            )
                            
                            FeatureRow(
                                icon: "arrow.up.left.and.arrow.down.right",
                                title: "Smart Resizing",
                                description: "Resize images with aspect ratio preservation for perfect results",
                                color: .green
                            )
                            
                            FeatureRow(
                                icon: "slider.horizontal.3",
                                title: "Quality Control",
                                description: "Adjust compression quality to balance file size and image quality",
                                color: .orange
                            )
                            
                            FeatureRow(
                                icon: "square.and.arrow.down",
                                title: "Easy Export",
                                description: "Save to Photos or share optimized images instantly",
                                color: .purple
                            )
                        }
                    }
                    
                    // App Info Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("About")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("PixelPerfect is a professional image optimization tool designed to help you reduce file sizes while maintaining high quality. Perfect for web developers, designers, and anyone who needs to optimize images for faster loading times.")
                                .font(.body)
                                .foregroundColor(.secondary)
                            
                            Text("Built with SwiftUI and optimized for iOS 17+, PixelPerfect provides a native, fast, and intuitive experience for all your image optimization needs.")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Version and Copyright
                    VStack(spacing: 8) {
                        Text("Version 1.0.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("© 2024 PixelPerfect. All rights reserved.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                }
                .padding()
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        themeManager.toggleTheme()
                    }) {
                        Image(systemName: themeManager.isDarkMode ? "sun.max.fill" : "moon.fill")
                            .font(.title2)
                            .foregroundColor(themeManager.accent)
                    }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.1))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}
