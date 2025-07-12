import SwiftUI

struct ProcessingView: View {
    @ObservedObject var imageModel: ImageModel
    @ObservedObject var themeManager: ThemeManager
    @State private var animationProgress: CGFloat = 0
    
    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            // Animated processing indicator
            ZStack {
                Circle()
                    .stroke(themeManager.borderPrimary, lineWidth: 3)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: animationProgress)
                    .stroke(themeManager.accent, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: false), value: animationProgress)
                
                Image(systemName: "wand.and.rays")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(themeManager.accent)
                    .rotationEffect(.degrees(animationProgress * 360))
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: false), value: animationProgress)
            }
            .onAppear {
                animationProgress = 1.0
            }
            
            VStack(spacing: AppSpacing.sm) {
                Text("Processing Image...")
                    .font(AppFonts.title2)
                    .foregroundColor(themeManager.primaryText)
                    .fontWeight(.semibold)
                
                Text("Optimizing your \(imageModel.originalFormat) image")
                    .font(AppFonts.callout)
                    .foregroundColor(themeManager.secondaryText)
            }
            
            // Image info card
            VStack(spacing: AppSpacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text("ORIGINAL SIZE")
                            .font(AppFonts.caption)
                            .foregroundColor(themeManager.tertiaryText)
                        
                        Text(formatFileSize(imageModel.originalSize))
                            .font(AppFonts.headline)
                            .foregroundColor(themeManager.primaryText)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: AppSpacing.xs) {
                        Text("FORMAT")
                            .font(AppFonts.caption)
                            .foregroundColor(themeManager.tertiaryText)
                        
                        Text(imageModel.originalFormat)
                            .font(AppFonts.headline)
                            .foregroundColor(themeManager.primaryText)
                    }
                }
                
                Divider()
                    .background(themeManager.borderSecondary)
                
                HStack {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text("DIMENSIONS")
                            .font(AppFonts.caption)
                            .foregroundColor(themeManager.tertiaryText)
                        
                        Text("\(Int(imageModel.originalDimensions.width)) × \(Int(imageModel.originalDimensions.height))")
                            .font(AppFonts.headline)
                            .foregroundColor(themeManager.primaryText)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: AppSpacing.xs) {
                        Text("STATUS")
                            .font(AppFonts.caption)
                            .foregroundColor(themeManager.tertiaryText)
                        
                        HStack(spacing: AppSpacing.xs) {
                            Circle()
                                .fill(themeManager.warning)
                                .frame(width: 6, height: 6)
                                .scaleEffect(1.2)
                                .animation(.easeInOut(duration: 0.8).repeatForever(), value: animationProgress)
                            
                            Text("Processing")
                                .font(AppFonts.callout)
                                .foregroundColor(themeManager.warning)
                        }
                    }
                }
            }
            .padding(AppSpacing.lg)
            .cardStyle(theme: themeManager)
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

#Preview {
    ProcessingView(imageModel: ImageModel(), themeManager: ThemeManager())
        .preferredColorScheme(.dark)
}