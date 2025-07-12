import SwiftUI

struct SupportView: View {
    @ObservedObject var themeManager: ThemeManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                // Header
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("Support")
                        .font(AppFonts.title)
                        .foregroundColor(Color(NSColor.labelColor))
                        .fontWeight(.semibold)
                    
                    Text("We're here to help")
                        .font(AppFonts.callout)
                        .foregroundColor(Color(NSColor.secondaryLabelColor))
                }
                .padding(.top, AppSpacing.lg)
                
                Divider()
                
                // Contact section
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    Text("Contact Us")
                        .font(AppFonts.title2)
                        .foregroundColor(Color(NSColor.labelColor))
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        contactItem(
                            icon: "envelope.fill",
                            title: "Email Support",
                            description: "Get help with any questions or issues",
                            action: "wader.zhang@gmail.com"
                        )
                    }
                }
                
                Divider()
                
                // FAQ section
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    Text("Frequently Asked Questions")
                        .font(AppFonts.title2)
                        .foregroundColor(Color(NSColor.labelColor))
                        .fontWeight(.semibold)
                    
                    faqSection(
                        question: "How does PixelPerfect work?",
                        answer: "PixelPerfect processes your images locally on your device to optimize file size while maintaining quality. No images are uploaded to external servers."
                    )
                    
                    faqSection(
                        question: "What file formats are supported?",
                        answer: "PixelPerfect supports common image formats including JPEG, PNG, and TIFF. SVG files are also supported for vector graphics."
                    )
                    
                    faqSection(
                        question: "Is my data safe?",
                        answer: "Yes, all processing happens locally on your device. Your images never leave your computer, ensuring complete privacy and security."
                    )
                    
                    faqSection(
                        question: "Can I undo optimizations?",
                        answer: "PixelPerfect creates optimized copies of your images, so your original files remain unchanged. You can always go back to the original."
                    )
                }
                
                Spacer()
            }
            .padding(AppSpacing.xl)
        }
        .background(Color(NSColor.windowBackgroundColor))
        .frame(minWidth: 600, minHeight: 500)
    }
    
    private func contactItem(icon: String, title: String, description: String, action: String) -> some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(themeManager.accent)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(title)
                    .font(AppFonts.headline)
                    .foregroundColor(Color(NSColor.labelColor))
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(AppFonts.body)
                    .foregroundColor(Color(NSColor.secondaryLabelColor))
                
                Button(action: {
                    // Open email client
                    let emailURL = URL(string: "mailto:\(action)")
                    if let emailURL = emailURL {
                        NSWorkspace.shared.open(emailURL)
                    }
                }) {
                    Text(action)
                        .font(AppFonts.body)
                        .foregroundColor(themeManager.accent)
                        .fontWeight(.medium)
                }
                .buttonStyle(.plain)
                .onHover { isHovering in
                    NSCursor.pointingHand.set()
                }
            }
            
            Spacer()
        }
        .padding(AppSpacing.md)
        .background(themeManager.tertiaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.md))
    }
    
    private func faqSection(question: String, answer: String) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(question)
                .font(AppFonts.headline)
                .foregroundColor(Color(NSColor.labelColor))
                .fontWeight(.semibold)
            
            Text(answer)
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
    SupportView(themeManager: ThemeManager())
}
