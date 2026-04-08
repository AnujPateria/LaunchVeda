import SwiftUI

struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // image / icon
            if let imageName = page.imageName {
                // realistic photo from asset catalog
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 300, height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 30, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                    .scaleEffect(isAnimating ? 1.0 : 0.85)
                    .opacity(isAnimating ? 1 : 0)
            } else if let symbol = page.sfSymbol {
                // sf symbol with space glass theme
                ZStack {
                    // icon background
                    Circle()
                        .fill(Color.white.opacity(0.06))
                        .frame(width: 200, height: 200)
                        .overlay(
                            Circle()
                                .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 8)

                    Image(systemName: symbol)
                        .font(.system(size: 80, weight: .light))
                        .foregroundStyle(page.accentColor)
                        .shadow(color: page.accentColor.opacity(0.3), radius: 8)
                }
                .scaleEffect(isAnimating ? 1.0 : 0.85)
                .opacity(isAnimating ? 1 : 0)
            }

            Spacer()
                .frame(height: 20)

            // text content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .offset(y: isAnimating ? 0 : 30)
                    .opacity(isAnimating ? 1 : 0)

                Text(page.subtitle)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(SpaceTheme.subtleGray)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 30)
                    .offset(y: isAnimating ? 0 : 20)
                    .opacity(isAnimating ? 1 : 0)
            }

            Spacer()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                isAnimating = true
            }
        }
        .onDisappear {
            isAnimating = false
        }
    }
}

