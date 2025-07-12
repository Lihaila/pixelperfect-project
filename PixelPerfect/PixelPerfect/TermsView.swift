import SwiftUI

struct TermsView: View {
    @ObservedObject var themeManager: ThemeManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                // Header
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("Terms of Service")
                        .font(AppFonts.title)
                        .foregroundColor(Color(NSColor.labelColor))
                        .fontWeight(.semibold)
                    
                    Text("Please read these terms carefully")
                        .font(AppFonts.callout)
                        .foregroundColor(Color(NSColor.secondaryLabelColor))
                }
                .padding(.top, AppSpacing.lg)
                
                Divider()
                
                // Terms content
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    termsSection(
                        title: "Acceptance of Terms",
                        content: "By using PixelPerfect, you agree to these terms of service. If you do not agree to these terms, please do not use the application."
                    )
                    
                    termsSection(
                        title: "Use of the Application",
                        content: "PixelPerfect is provided for image optimization purposes. You may use the application to process your own images or images you have permission to modify."
                    )
                    
                    termsSection(
                        title: "Intellectual Property",
                        content: "You retain all rights to your original images. PixelPerfect does not claim any ownership over the images you process."
                    )
                    
                    termsSection(
                        title: "Limitation of Liability",
                        content: "PixelPerfect is provided \"as is\" without warranties. We are not liable for any loss of data or damages resulting from the use of this application."
                    )
                    
                    termsSection(
                        title: "Prohibited Uses",
                        content: "You may not use PixelPerfect to process illegal content, copyrighted material without permission, or content that violates applicable laws."
                    )
                    
                    termsSection(
                        title: "Updates and Changes",
                        content: "We may update these terms from time to time. Continued use of the application constitutes acceptance of any changes."
                    )
                    
                    termsSection(
                        title: "Contact",
                        content: "If you have any questions about these terms, please contact us at wader.zhang@gmail.com"
                    )
                }
                
                Spacer()
            }
            .padding(AppSpacing.xl)
        }
        .background(Color(NSColor.windowBackgroundColor))
        .frame(minWidth: 600, minHeight: 500)
    }
    
    private func termsSection(title: String, content: String) -> some View {
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
    TermsView(themeManager: ThemeManager())
}
