import SwiftUI

// glassmorphism card modifier
struct GlassCard: ViewModifier {
    var cornerRadius: CGFloat = 20
    var opacity: CGFloat = 0.08

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.black.opacity(0.4))
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(.ultraThinMaterial)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.15),
                                Color.white.opacity(0.02)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 20, opacity: CGFloat = 0.08) -> some View {
        modifier(GlassCard(cornerRadius: cornerRadius, opacity: opacity))
    }
    
    func glassCapsule() -> some View {
        modifier(GlassCapsule())
    }
}

// glassmorphism capsule modifier
struct GlassCapsule: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                Capsule()
                    .fill(Color.black.opacity(0.4))
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                    )
            )
            .overlay(
                Capsule()
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.15),
                                Color.white.opacity(0.02)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}
