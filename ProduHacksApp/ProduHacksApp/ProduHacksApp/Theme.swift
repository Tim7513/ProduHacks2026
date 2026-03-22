import SwiftUI

// Material Design 3 Color System
extension Color {
    // Primary Colors
    static let primary = Color(hex: "#005da7")
    static let primaryDim = Color(hex: "#005192")
    static let primaryContainer = Color(hex: "#68abff")
    static let onPrimary = Color(hex: "#eef3ff")

    // Secondary Colors
    static let secondary = Color(hex: "#00693f")
    static let secondaryContainer = Color(hex: "#95f7bb")
    static let onSecondaryContainer = Color(hex: "#005e38")

    // Tertiary Colors
    static let tertiary = Color(hex: "#705900")
    static let tertiaryContainer = Color(hex: "#fdd355")
    static let onTertiaryContainer = Color(hex: "#5d4800")

    // Surface Colors
    static let surfaceBackground = Color(hex: "#f5f6f7")
    static let surfaceContainer = Color(hex: "#e6e8ea")
    static let surfaceContainerLow = Color(hex: "#eff1f2")
    static let surfaceContainerLowest = Color(hex: "#ffffff")
    static let surfaceContainerHighest = Color(hex: "#dadddf")

    // Text Colors
    static let onSurface = Color(hex: "#2c2f30")
    static let onSurfaceVariant = Color(hex: "#595c5d")
    static let outline = Color(hex: "#757778")
    static let outlineVariant = Color(hex: "#abadae")

    // Helper to create Color from hex
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Custom Shadow Styles
extension View {
    func popUpShadow() -> some View {
        self.shadow(color: Color.onSurface.opacity(0.06), radius: 16, x: 0, y: 8)
    }

    func readingGlow() -> some View {
        self.shadow(color: Color.primaryContainer.opacity(0.3), radius: 20, x: 0, y: 0)
    }

    func asymmetricTiltLeft() -> some View {
        self.rotationEffect(.degrees(-2))
    }

    func asymmetricTiltRight() -> some View {
        self.rotationEffect(.degrees(1.5))
    }

    func glassPanel() -> some View {
        self
            .background(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .strokeBorder(Color.white.opacity(0.5), lineWidth: 1)
            )
    }
}

// Custom Fonts
extension Font {
    // Plus Jakarta Sans for headlines
    static func jakartaDisplay(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        return .system(size: size, weight: weight, design: .rounded)
    }

    // Lexend for body text
    static func lexendBody(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        return .system(size: size, weight: weight)
    }
}
