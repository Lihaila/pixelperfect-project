import SwiftUI

// MARK: - Native macOS Colors
struct AppColors {
    // System colors that automatically adapt to appearance
    static let primaryBackground = Color(NSColor.controlBackgroundColor)
    static let secondaryBackground = Color(NSColor.controlColor)
    static let tertiaryBackground = Color(NSColor.underPageBackgroundColor)
    
    // Text colors
    static let primaryText = Color(NSColor.labelColor)
    static let secondaryText = Color(NSColor.secondaryLabelColor)
    static let tertiaryText = Color(NSColor.tertiaryLabelColor)
    
    // Accent colors
    static let accent = Color(NSColor.controlAccentColor)
    static let accentSecondary = Color(NSColor.systemBlue)
    static let success = Color(NSColor.systemGreen)
    static let warning = Color(NSColor.systemOrange)
    static let error = Color(NSColor.systemRed)
    
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
    static let borderPrimary = Color(NSColor.separatorColor)
    static let borderSecondary = Color(NSColor.gridColor)
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

// MARK: - Shadows
struct AppShadows {
    static let light = Color.black.opacity(0.1)
    static let medium = Color.black.opacity(0.2)
    static let heavy = Color.black.opacity(0.3)
    
    // Theme-aware shadows
    static func adaptiveShadow(for isDarkMode: Bool) -> Color {
        if isDarkMode {
            return Color.white.opacity(0.05) // Very subtle white shadow for dark mode
        } else {
            return Color.black.opacity(0.1) // Subtle black shadow for light mode
        }
    }
    
    static func adaptiveMediumShadow(for isDarkMode: Bool) -> Color {
        if isDarkMode {
            return Color.white.opacity(0.08) // Slightly more prominent white shadow for dark mode
        } else {
            return Color.black.opacity(0.15) // Medium black shadow for light mode
        }
    }
}

// MARK: - Custom View Modifiers
struct GlassmorphismModifier: ViewModifier {
    @ObservedObject var theme: ThemeManager
    
    func body(content: Content) -> some View {
        content
            .background(
                theme.tertiaryBackground
                    .opacity(0.8)
                    .blur(radius: 10)
            )
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                    .stroke(theme.borderPrimary, lineWidth: 1)
            )
    }
}

struct CardModifier: ViewModifier {
    @ObservedObject var theme: ThemeManager
    
    func body(content: Content) -> some View {
        content
            .background(theme.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                    .stroke(theme.borderPrimary, lineWidth: 1)
            )
    }
}

struct ButtonModifier: ViewModifier {
    @ObservedObject var theme: ThemeManager
    let style: ButtonStyle
    let isEnabled: Bool
    
    enum ButtonStyle {
        case primary, secondary, tertiary
    }
    
    func body(content: Content) -> some View {
        content
            .font(AppFonts.callout)
            .foregroundColor(foregroundColor)
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.md)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.md))
            .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: 2)
            .scaleEffect(isEnabled ? 1.0 : 0.95)
            .animation(.easeInOut(duration: 0.1), value: isEnabled)
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary: return theme.isDarkMode ? .white : .white
        case .secondary: return theme.accent
        case .tertiary: return theme.secondaryText
        }
    }
    
    private var backgroundColor: Color {
        if !isEnabled {
            return theme.tertiaryBackground
        }
        
        switch style {
        case .primary: return theme.accent
        case .secondary: return theme.accent.opacity(0.1)
        case .tertiary: return theme.tertiaryBackground
        }
    }
    
    private var shadowColor: Color {
        isEnabled ? theme.shadowLight : Color.clear
    }
    
    private var shadowRadius: CGFloat {
        isEnabled ? 4 : 0
    }
}

// MARK: - View Extensions
extension View {
    func glassmorphism(theme: ThemeManager) -> some View {
        modifier(GlassmorphismModifier(theme: theme))
    }
    
    func cardStyle(theme: ThemeManager) -> some View {
        modifier(CardModifier(theme: theme))
    }
    
    func buttonStyle(_ style: ButtonModifier.ButtonStyle, theme: ThemeManager, isEnabled: Bool = true) -> some View {
        modifier(ButtonModifier(theme: theme, style: style, isEnabled: isEnabled))
    }
}
// MARK: - macOS 11.5 Compatible Button Styles
struct MacOSCompatibleButtonStyle: ButtonStyle {
    let prominence: Prominence
    
    enum Prominence {
        case primary, secondary, tertiary
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(backgroundColor(for: prominence, isPressed: configuration.isPressed))
            .foregroundColor(foregroundColor(for: prominence))
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(strokeColor(for: prominence), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
    
    private func backgroundColor(for prominence: Prominence, isPressed: Bool) -> Color {
        let opacity = isPressed ? 0.7 : 1.0
        switch prominence {
        case .primary:
            return Color(NSColor.controlAccentColor).opacity(opacity)
        case .secondary:
            return Color(NSColor.controlAccentColor).opacity(0.8 * opacity) // Use more opaque background for better contrast with white text
        case .tertiary:
            return Color(NSColor.controlColor).opacity(opacity) // Use system control color for better visibility
        }
    }
    
    private func foregroundColor(for prominence: Prominence) -> Color {
        switch prominence {
        case .primary:
            return Color.white
        case .secondary:
            return Color.white // Use white text on colored background for better contrast
        case .tertiary:
            return Color(NSColor.labelColor) // Use system label color for better contrast
        }
    }
    
    private func strokeColor(for prominence: Prominence) -> Color {
        switch prominence {
        case .primary:
            return Color.clear
        case .secondary:
            return Color(NSColor.controlAccentColor).opacity(0.5)
        case .tertiary:
            return Color(NSColor.separatorColor) // Use system separator color for better visibility
        }
    }
}

// MARK: - Theme Manager
class ThemeManager: ObservableObject {
    @Published var isDarkMode: Bool
    
    init() {
        // Detect system appearance
        if let appearance = NSApplication.shared.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) {
            self.isDarkMode = appearance == .darkAqua
        } else {
            self.isDarkMode = false
        }
        
        // Listen for system appearance changes
        DistributedNotificationCenter.default.addObserver(
            forName: Notification.Name("AppleInterfaceThemeChangedNotification"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateAppearance()
            }
        }
    }
    
    private func updateAppearance() {
        if let appearance = NSApplication.shared.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) {
            self.isDarkMode = appearance == .darkAqua
        }
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
    
    var shadowLight: Color { AppShadows.light }
    var shadowMedium: Color { AppShadows.medium }
    var shadowHeavy: Color { AppShadows.heavy }
    
    // Theme-aware shadows
    var adaptiveShadow: Color { AppShadows.adaptiveShadow(for: isDarkMode) }
    var adaptiveMediumShadow: Color { AppShadows.adaptiveMediumShadow(for: isDarkMode) }
    
    func toggleTheme() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isDarkMode.toggle()
            // Force the app to use the selected appearance
            let newAppearance: NSAppearance = isDarkMode ? NSAppearance(named: .darkAqua)! : NSAppearance(named: .aqua)!
            NSApplication.shared.appearance = newAppearance
        }
    }
}
