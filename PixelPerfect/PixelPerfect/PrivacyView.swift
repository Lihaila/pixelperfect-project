import SwiftUI

struct PrivacyView: View {
    @ObservedObject var themeManager: ThemeManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                // Header
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("Privacy Policy")
                        .font(AppFonts.title)
                        .foregroundColor(Color(NSColor.labelColor))
                        .fontWeight(.semibold)
                    
                    Text("Your privacy is important to us")
                        .font(AppFonts.callout)
                        .foregroundColor(Color(NSColor.secondaryLabelColor))
                }
                .padding(.top, AppSpacing.lg)
                
                Divider()
                
                // Privacy content
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    privacySection(
                        title: "Data Collection",
                        content: "PixelPerfect does not collect, store, or transmit any personal data. All image processing is performed locally on your device."
                    )
                    
                    privacySection(
                        title: "Image Processing",
                        content: "Your images are processed entirely on your device. No images are uploaded to external servers or stored permanently by the application."
                    )
                    
                    privacySection(
                        title: "Local Storage",
                        content: "The app may temporarily store processed images in your device's memory during use, but these are automatically cleared when you close the application."
                    )
                    
                    privacySection(
                        title: "Third-Party Services",
                        content: "PixelPerfect does not integrate with any third-party services or analytics platforms that would collect your data."
                    )
                    
                    privacySection(
                        title: "Contact",
                        content: "If you have any questions about this privacy policy, please contact us at wader.zhang@gmail.com"
                    )
                }
                
                Spacer()
            }
            .padding(AppSpacing.xl)
        }
        .background(Color(NSColor.windowBackgroundColor))
        .frame(minWidth: 600, minHeight: 500)
    }
    
    private func privacySection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(title)
                .font(AppFonts.headline)
                .foregroundColor(Color(NSColor.labelColor))
                .fontWeight(.semibold)
            
            Text(content)
                .font(AppFonts.body)
                .foregroundColor(Color(NSColor.labelColor))
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(AppSpacing.md)
        .background(themeManager.tertiaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.md))
    }
}

#Preview {
    PrivacyView(themeManager: ThemeManager())
}
