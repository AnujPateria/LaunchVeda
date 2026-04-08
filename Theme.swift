import SwiftUI

// app theme
struct SpaceTheme {
    // accent colors (custom brand)
    static let electricBlue = Color(red: 0.29, green: 0.56, blue: 0.97)
    static let nebulaPurple = Color(red: 0.545, green: 0.36, blue: 0.965)
    static let successGreen = Color(red: 0.2, green: 0.85, blue: 0.5)

    // system-dynamic colors (hig compliant)
    static let textPrimary = Color.primary          // adapts to light/dark
    static let textSecondary = Color.secondary      // adapts to light/dark
    static let subtleGray = Color.secondary         // was hardcoded gray
    static let starWhite = Color.primary            // was hardcoded near-white

    // backgrounds
    static let deepNavy = Color.black
    static let darkSpace = Color.black
    static let cardBackground = Color.white.opacity(0.06)
    static let cardBorder = Color.white.opacity(0.12)

    // gradients
    static let backgroundGradient = LinearGradient(
        colors: [Color.black, Color.black, Color(white: 0.02)],
        startPoint: .top,
        endPoint: .bottom
    )

    static let accentGradient = LinearGradient(
        colors: [electricBlue, nebulaPurple],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let cardGradient = LinearGradient(
        colors: [Color.white.opacity(0.1), Color.white.opacity(0.03)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
