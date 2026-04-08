import SwiftUI

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @State private var currentPage = 0
    @State private var buttonScale: CGFloat = 1.0

    private let pages = OnboardingPage.pages

    var body: some View {
        ZStack {
            // background
            StarFieldBackground()

            VStack(spacing: 0) {
                // skip button
                HStack {
                    Spacer()
                    if currentPage < pages.count - 1 {
                        Button(action: {
                            withAnimation { hasSeenOnboarding = true }
                        }) {
                            Text("Skip")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(SpaceTheme.subtleGray)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                        }
                    }
                }
                .padding(.top, 8)
                .padding(.trailing, 8)
                .frame(height: 44)

                // page content
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        OnboardingPageView(page: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // custom page indicator + button
                VStack(spacing: 30) {
                    // page dots
                    HStack(spacing: 10) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Capsule()
                                .fill(index == currentPage ? pages[currentPage].accentColor : Color.white.opacity(0.2))
                                .frame(width: index == currentPage ? 28 : 8, height: 8)
                                .animation(.spring(response: 0.4), value: currentPage)
                        }
                    }

                    // action button
                    Button(action: {
                        if currentPage < pages.count - 1 {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                currentPage += 1
                            }
                        } else {
                            withAnimation(.easeInOut(duration: 0.4)) {
                                hasSeenOnboarding = true
                            }
                        }
                    }) {
                        HStack(spacing: 8) {
                            Text(currentPage < pages.count - 1 ? "Continue" : "Get Started")
                                .font(.system(size: 18, weight: .semibold))

                            Image(systemName: currentPage < pages.count - 1 ? "arrow.right" : "rocket.fill")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                        )
                    }
                    .scaleEffect(buttonScale)
                    .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
                        withAnimation(.easeInOut(duration: 0.15)) {
                            buttonScale = pressing ? 0.96 : 1.0
                        }
                    }, perform: {})
                    .padding(.horizontal, 30)
                }
                .padding(.bottom, 50)
            }
        }
        .preferredColorScheme(.dark)
    }
}

