import SwiftUI

struct ContentView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        if hasSeenOnboarding {
            MainTabView()
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
        } else {
            OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
                .transition(.opacity)
        }
    }
}

