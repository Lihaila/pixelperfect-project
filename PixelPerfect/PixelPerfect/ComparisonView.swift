import SwiftUI

struct ComparisonView: View {
    @ObservedObject var imageModel: ImageModel
    @ObservedObject var themeManager: ThemeManager
    
    var body: some View {
        ZStack {
            // Simple background
            Color(NSColor.windowBackgroundColor)
                .ignoresSafeArea()
            
            VStack(spacing: AppSpacing.xl) {
                // Header
                VStack(spacing: AppSpacing.sm) {
                    Text("Image Comparison")
                        .font(AppFonts.title)
                        .foregroundColor(Color(NSColor.labelColor))
                        .fontWeight(.semibold)
                    
                    Text("Side-by-side comparison of original vs optimized")
                        .font(AppFonts.callout)
                        .foregroundColor(Color(NSColor.secondaryLabelColor))
                }
                .padding(.top, AppSpacing.lg)
                
                // Image comparison
                HStack(spacing: AppSpacing.xl) {
                    // Original image
                    VStack(spacing: AppSpacing.md) {
                        if let original = imageModel.originalImage {
                            Image(nsImage: original)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 350, maxHeight: 400)
                                .background(themeManager.tertiaryBackground)
                                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg))
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                                        .stroke(themeManager.borderPrimary, lineWidth: 2)
                                )
                        }
                        
                        Text("Original")
                            .font(AppFonts.headline)
                            .foregroundColor(Color(NSColor.labelColor))
                            .fontWeight(.medium)
                    }
                    
                    // Optimized image
                    VStack(spacing: AppSpacing.md) {
                        if let processed = imageModel.processedImage {
                            Image(nsImage: processed.image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 350, maxHeight: 400)
                                .background(themeManager.tertiaryBackground)
                                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg))
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                                        .stroke(themeManager.accent, lineWidth: 2)
                                )
                        }
                        
                        Text("Optimized")
                            .font(AppFonts.headline)
                            .foregroundColor(Color(NSColor.controlAccentColor))
                            .fontWeight(.medium)
                    }
                }
                
                // Comparison details
                HStack(spacing: AppSpacing.xl) {
                    // Original stats
                    VStack(spacing: AppSpacing.sm) {
                        Text("Original Image")
                            .font(AppFonts.callout)
                            .foregroundColor(Color(NSColor.labelColor))
                            .fontWeight(.medium)
                        
                        VStack(spacing: AppSpacing.xs) {
                            HStack {
                                Text("Dimensions:")
                                    .font(AppFonts.caption)
                                    .foregroundColor(themeManager.tertiaryText)
                                Spacer()
                                Text("\(String(format: "%.0f", imageModel.originalDimensions.width)) × \(String(format: "%.0f", imageModel.originalDimensions.height))")
                                    .font(AppFonts.caption)
                                    .foregroundColor(themeManager.primaryText)
                            }
                            
                            HStack {
                                Text("Format:")
                                    .font(AppFonts.caption)
                                    .foregroundColor(themeManager.tertiaryText)
                                Spacer()
                                Text(imageModel.originalFormat)
                                    .font(AppFonts.caption)
                                    .foregroundColor(themeManager.primaryText)
                            }
                            
                            HStack {
                                Text("Size:")
                                    .font(AppFonts.caption)
                                    .foregroundColor(themeManager.tertiaryText)
                                Spacer()
                                Text(formatFileSize(imageModel.originalSize))
                                    .font(AppFonts.caption)
                                    .foregroundColor(themeManager.primaryText)
                                    .fontWeight(.medium)
                            }
                        }
                    }
                    .padding(AppSpacing.md)
                    .background(themeManager.tertiaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.md))
                    
                    // Arrow
                    Image(systemName: "arrow.right")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(themeManager.accent)
                    
                    // Optimized stats
                    if let processed = imageModel.processedImage {
                        VStack(spacing: AppSpacing.sm) {
                            Text("Optimized Image")
                                .font(AppFonts.callout)
                                .foregroundColor(optimizedImageTextColor)
                                .fontWeight(.medium)
                            
                            VStack(spacing: AppSpacing.xs) {
                                HStack {
                                    Text("Dimensions:")
                                        .font(AppFonts.caption)
                                        .foregroundColor(themeManager.tertiaryText)
                                    Spacer()
                                    Text("\(String(format: "%.0f", processed.dimensions.width)) × \(String(format: "%.0f", processed.dimensions.height))")
                                        .font(AppFonts.caption)
                                        .foregroundColor(themeManager.primaryText)
                                }
                                
                                HStack {
                                    Text("Format:")
                                        .font(AppFonts.caption)
                                        .foregroundColor(themeManager.tertiaryText)
                                    Spacer()
                                    Text(processed.format)
                                        .font(AppFonts.caption)
                                        .foregroundColor(themeManager.primaryText)
                                }
                                
                                HStack {
                                    Text("Size:")
                                        .font(AppFonts.caption)
                                        .foregroundColor(themeManager.tertiaryText)
                                    Spacer()
                                    Text(formatFileSize(processed.size))
                                        .font(AppFonts.caption)
                                        .foregroundColor(themeManager.primaryText)
                                        .fontWeight(.medium)
                                }
                                
                                // Savings highlight
                                HStack {
                                    Text("Savings:")
                                        .font(AppFonts.caption)
                                        .foregroundColor(themeManager.tertiaryText)
                                    Spacer()
                                    Text(imageModel.calculateSavings())
                                        .font(AppFonts.caption)
                                        .foregroundColor(themeManager.success)
                                        .fontWeight(.medium)
                                }
                                .padding(.top, AppSpacing.xs)
                                .padding(.horizontal, AppSpacing.sm)
                                .padding(.vertical, AppSpacing.xs)
                                .background(themeManager.success.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.sm))
                            }
                        }
                        .padding(AppSpacing.md)
                        .background(themeManager.accent.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.md))
                    }
                }
                
                Spacer()
            }
            .padding(AppSpacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // Computed property for optimized image text color with better contrast
    private var optimizedImageTextColor: Color {
        // In light mode, use a darker version of the accent color for better contrast
        // In dark mode, use the regular accent color
        if themeManager.isDarkMode {
            return themeManager.accent
        } else {
            // Use systemBlue in light mode for better contrast
            return Color(NSColor.systemBlue)
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
}

#Preview {
    ComparisonView(imageModel: ImageModel(), themeManager: ThemeManager())
}
