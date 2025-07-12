import SwiftUI

// MARK: - iOS System Colors
struct AppColors {
    // System colors that automatically adapt to appearance
    static let primaryBackground = Color(UIColor.systemBackground)
    static let secondaryBackground = Color(UIColor.secondarySystemBackground)
    static let tertiaryBackground = Color(UIColor.tertiarySystemBackground)
    
    // Text colors
    static let primaryText = Color(UIColor.label)
    static let secondaryText = Color(UIColor.secondaryLabel)
    static let tertiaryText = Color(UIColor.tertiaryLabel)
    
    // Accent colors
    static let accent = Color(UIColor.systemBlue)
    static let accentSecondary = Color(UIColor.systemBlue)
    static let success = Color(UIColor.systemGreen)
    static let warning = Color(UIColor.systemOrange)
    static let error = Color(UIColor.systemRed)
    
    // Gradients
    static let primaryGradient = LinearGradient(
        colors: [accent, accentSecondary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let backgroundGradient = LinearGradient(
        colors: [primaryBackground, secondaryBackground],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Border colors
    static let borderPrimary = Color(UIColor.separator)
    static let borderSecondary = Color(UIColor.opaqueSeparator)
}

// MARK: - Typography
struct AppFonts {
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title = Font.system(size: 28, weight: .semibold, design: .rounded)
    static let title2 = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let title3 = Font.system(size: 20, weight: .medium, design: .rounded)
    static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let body = Font.system(size: 17, weight: .regular, design: .rounded)
    static let callout = Font.system(size: 16, weight: .regular, design: .rounded)
    static let subheadline = Font.system(size: 15, weight: .regular, design: .rounded)
    static let footnote = Font.system(size: 13, weight: .regular, design: .rounded)
    static let caption = Font.system(size: 12, weight: .regular, design: .rounded)
    static let caption2 = Font.system(size: 11, weight: .regular, design: .rounded)
}

// MARK: - Spacing
struct AppSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: - Corner Radius
struct AppCornerRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 28
}

// MARK: - Theme Manager
class ThemeManager: ObservableObject {
    @Published var isDarkMode: Bool
    
    init() {
        // Detect system appearance
        self.isDarkMode = UITraitCollection.current.userInterfaceStyle == .dark
    }
    
    // Native system color getters - these automatically adapt to appearance
    var primaryBackground: Color { AppColors.primaryBackground }
    var secondaryBackground: Color { AppColors.secondaryBackground }
    var tertiaryBackground: Color { AppColors.tertiaryBackground }
    
    var primaryText: Color { AppColors.primaryText }
    var secondaryText: Color { AppColors.secondaryText }
    var tertiaryText: Color { AppColors.tertiaryText }
    
    var accent: Color { AppColors.accent }
    var accentSecondary: Color { AppColors.accentSecondary }
    var success: Color { AppColors.success }
    var warning: Color { AppColors.warning }
    var error: Color { AppColors.error }
    
    var primaryGradient: LinearGradient { AppColors.primaryGradient }
    var backgroundGradient: LinearGradient { AppColors.backgroundGradient }
    
    var borderPrimary: Color { AppColors.borderPrimary }
    var borderSecondary: Color { AppColors.borderSecondary }
    
    func toggleTheme() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isDarkMode.toggle()
        }
    }
}

// MARK: - View Extensions
extension View {
    func cardStyle(theme: ThemeManager) -> some View {
        self
            .background(theme.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                    .stroke(theme.borderPrimary, lineWidth: 1)
            )
    }
}
