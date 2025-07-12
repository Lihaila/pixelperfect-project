import SwiftUI
import UniformTypeIdentifiers

struct DropZoneView: View {
    @ObservedObject var imageModel: ImageModel
    @ObservedObject var themeManager: ThemeManager
    @State private var isDragging = false
    @State private var isHovered = false
    
    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            // Icon and main text
            VStack(spacing: AppSpacing.lg) {
                ZStack {
                    Circle()
                        .fill(themeManager.accent.opacity(0.2))
                        .frame(width: 80, height: 80)
                        .scaleEffect(isDragging ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.3), value: isDragging)
                    
                    Image(systemName: "photo.badge.plus")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(themeManager.accent)
                        .scaleEffect(isDragging ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.3), value: isDragging)
                }
                
                VStack(spacing: AppSpacing.sm) {
                    Text("Drop Your Image Here")
                        .font(AppFonts.title2)
                        .foregroundColor(themeManager.primaryText)
                        .fontWeight(.semibold)
                    
                    Text("or click to browse")
                        .font(AppFonts.callout)
                        .foregroundColor(themeManager.secondaryText)
                }
            }
            
            // Supported formats
            VStack(spacing: AppSpacing.sm) {
                Text("SUPPORTED FORMATS")
                    .font(AppFonts.caption)
                    .foregroundColor(themeManager.tertiaryText)
                
                HStack(spacing: AppSpacing.md) {
                    ForEach(["JPG", "PNG", "SVG"], id: \.self) { format in
                        Text(format)
                            .font(AppFonts.caption2)
                            .foregroundColor(themeManager.primaryText)
                            .padding(.horizontal, AppSpacing.sm)
                            .padding(.vertical, AppSpacing.xs)
                            .background(themeManager.tertiaryBackground)
                            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.sm))
                    }
                }
            }
            
            // Browse button
            Button(action: openFilePicker) {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "folder")
                        .font(.system(size: 14, weight: .medium))
                    
                    Text("Browse Files")
                        .fontWeight(.medium)
                }
            }
            .buttonStyle(MacOSCompatibleButtonStyle(prominence: .primary))
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isHovered)
            .onHover { hovering in
                isHovered = hovering
            }
            
            // File size limit
            Text("Maximum file size: 10MB")
                .font(AppFonts.caption)
                .foregroundColor(themeManager.tertiaryText)
        }
        .padding(AppSpacing.xxl)
        .frame(maxWidth: .infinity, minHeight: 400)
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.xl)
                .fill(isDragging ? themeManager.accent.opacity(0.1) : themeManager.secondaryBackground.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: AppCornerRadius.xl)
                        .stroke(
                            isDragging ? themeManager.accent : themeManager.borderSecondary,
                            style: StrokeStyle(lineWidth: 2, dash: [10, 5])
                        )
                )
        )
        .scaleEffect(isDragging ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.3), value: isDragging)
        .onDrop(of: [.image], delegate: ImageDropDelegate(imageModel: imageModel, isDragging: $isDragging))
    }
    
    private func openFilePicker() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.jpeg, .png, .svg]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        
        if panel.runModal() == .OK, let url = panel.url {
            withAnimation(.easeInOut(duration: 0.3)) {
                imageModel.loadImage(from: url)
            }
        }
    }
}

struct ImageDropDelegate: DropDelegate {
    let imageModel: ImageModel
    @Binding var isDragging: Bool
    
    func dropEntered(info: DropInfo) {
        withAnimation(.easeInOut(duration: 0.3)) {
            isDragging = true
        }
    }
    
    func dropExited(info: DropInfo) {
        withAnimation(.easeInOut(duration: 0.3)) {
            isDragging = false
        }
    }
    
    func performDrop(info: DropInfo) -> Bool {
        withAnimation(.easeInOut(duration: 0.3)) {
            isDragging = false
        }
        
        guard let provider = info.itemProviders(for: [.image]).first else { return false }
        
        provider.loadItem(forTypeIdentifier: UTType.image.identifier, options: nil) { (item, error) in
            if let error = error {
                print("Drop error: \(error.localizedDescription)")
                return
            }
            
            switch item {
            case let url as URL:
                DispatchQueue.main.async {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        imageModel.loadImage(from: url)
                    }
                }
            case let data as Data:
                DispatchQueue.main.async {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        imageModel.loadImage(from: data)
                    }
                }
            case let image as NSImage:
                DispatchQueue.main.async {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        imageModel.loadImage(from: image)
                    }
                }
            default:
                print("Unsupported drop type: \(String(describing: item))")
            }
        }
        
        return true
    }
    
    func validateDrop(info: DropInfo) -> Bool {
        return info.hasItemsConforming(to: [.image])
    }
}

