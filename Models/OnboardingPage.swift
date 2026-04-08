import SwiftUI

struct OnboardingPage: Identifiable {
    let id = UUID()
    let imageName: String?      // asset image name (realistic photo)
    let sfSymbol: String?       // fallback sf symbol
    let title: String
    let subtitle: String
    let accentColor: Color

    static let pages: [OnboardingPage] = [
        OnboardingPage(
            imageName: nil,
            sfSymbol: "globe.americas.fill",
            title: "Missions & Launches",
            subtitle: "Track global space missions. Explore launch timelines, crew details, and live updates.",
            accentColor: SpaceTheme.electricBlue
        ),
        OnboardingPage(
            imageName: nil,
            sfSymbol: "cube.transparent",
            title: "Rocket Explorer",
            subtitle: "Interactive 2D breakdowns. Discover every stage, engine, and component of iconic rockets.",
            accentColor: SpaceTheme.successGreen
        ),
        OnboardingPage(
            imageName: nil,
            sfSymbol: "play.circle.fill",
            title: "Launch Replay",
            subtitle: "Relive historic launches with real-time flight simulations and interactive data dashboards.",
            accentColor: SpaceTheme.nebulaPurple
        )
    ]
}
