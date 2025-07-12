import SwiftUI

struct ContentView: View {
    @StateObject private var imageModel = ImageModel()
    @StateObject private var themeManager = ThemeManager()
    
    var body: some View {
        ZStack {
            // Simple native background
            Color(NSColor.windowBackgroundColor)
                .ignoresSafeArea()
            
            VStack(spacing: AppSpacing.xl) {
                HeaderView(themeManager: themeManager)
                
                // Main content area with native styling
                Group {
                    if imageModel.originalImage == nil {
                        DropZoneView(imageModel: imageModel, themeManager: themeManager)
                    } else if imageModel.isInitialLoading {
                        ProcessingView(imageModel: imageModel, themeManager: themeManager)
                    } else {
                        ResultsView(imageModel: imageModel, themeManager: themeManager)
                    }
                }
                .cardStyle(theme: themeManager)
                .padding(.horizontal, AppSpacing.lg)
                
                Spacer()
                FooterView(themeManager: themeManager)
            }
            .padding(AppSpacing.lg)
        }
        .frame(minWidth: 900, minHeight: 700)
        .animation(.easeInOut(duration: 0.3), value: themeManager.isDarkMode)
    }
}

struct HeaderView: View {
    @ObservedObject var themeManager: ThemeManager
    
    var body: some View {
        HStack {
            HStack(spacing: AppSpacing.md) {
                LogoView(size: 32)
                
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("PixelPerfect")
                        .font(AppFonts.largeTitle)
                        .foregroundColor(Color(NSColor.controlAccentColor))
                    
                    Text("Professional Image Optimization")
                        .font(AppFonts.callout)
                        .foregroundColor(Color(NSColor.secondaryLabelColor))
                }
            }
            
            Spacer()
            
            // Theme toggle button
            Button(action: {
                themeManager.toggleTheme()
            }) {
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: themeManager.isDarkMode ? "sun.max.fill" : "moon.fill")
                        .font(.system(size: 14, weight: .medium))
                    Text(themeManager.isDarkMode ? "Light" : "Dark")
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }
            .buttonStyle(MacOSCompatibleButtonStyle(prominence: .tertiary))
            
            // Status indicator
            HStack(spacing: AppSpacing.sm) {
                Circle()
                    .fill(themeManager.success)
                    .frame(width: 8, height: 8)
                
                Text("Ready")
                    .font(AppFonts.caption)
                    .foregroundColor(Color(NSColor.secondaryLabelColor))
            }
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.bottom, AppSpacing.md)
    }
}

struct FooterView: View {
    @ObservedObject var themeManager: ThemeManager
    @EnvironmentObject var windowManager: WindowManager
    
    var body: some View {
        HStack {
            Text(" 2025 PixelPerfect. All rights reserved.")
                .font(AppFonts.caption)
                .foregroundColor(Color(NSColor.tertiaryLabelColor))
            
            Spacer()
            
            HStack(spacing: AppSpacing.lg) {
                Button("Privacy") {
                    windowManager.showPrivacyWindow()
                }
                .buttonStyle(PlainButtonStyle())
                
                Button("Terms") {
                    windowManager.showTermsWindow()
                }
                .buttonStyle(PlainButtonStyle())
                
                Button("Support") {
                    windowManager.showSupportWindow()
                }
                .buttonStyle(PlainButtonStyle())
            }
            .font(AppFonts.caption)
            .foregroundColor(Color(NSColor.tertiaryLabelColor))
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.top, AppSpacing.md)
    }
}

#Preview {
    ContentView()
}