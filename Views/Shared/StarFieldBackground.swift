import SwiftUI

// animated deep-space background with aurora shimmer & layered stars
struct StarFieldBackground: View {
    @State private var stars: [Star] = StarFieldBackground.generateStars(count: 45)

    var body: some View {
        TimelineView(.animation(minimumInterval: 0.05)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate

            Canvas { context, size in
                drawAuroraGlows(in: &context, size: size, time: time)
                drawStars(in: &context, size: size, time: time)
            }
        }
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.02, green: 0.02, blue: 0.06),
                    Color.black,
                    Color(red: 0.01, green: 0.01, blue: 0.04)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .ignoresSafeArea()
    }

    private func drawAuroraGlows(in context: inout GraphicsContext, size: CGSize, time: Double) {
        let auroraPhase1 = sin(time * 0.08) * 0.5 + 0.5
        let auroraPhase2 = cos(time * 0.06 + 1.2) * 0.5 + 0.5
        let auroraPhase3 = sin(time * 0.1 + 2.5) * 0.5 + 0.5

        // top-right blue-cyan glow
        let glow1Center = CGPoint(
            x: size.width * (0.75 + 0.08 * sin(time * 0.04)),
            y: size.height * (0.12 + 0.06 * cos(time * 0.05))
        )
        let glow1Radius = size.width * 0.45
        context.opacity = 0.06 + 0.03 * auroraPhase1
        context.fill(
            Path(ellipseIn: CGRect(
                x: glow1Center.x - glow1Radius,
                y: glow1Center.y - glow1Radius,
                width: glow1Radius * 2,
                height: glow1Radius * 2
            )),
            with: .radialGradient(
                Gradient(colors: [
                    Color(red: 0.15, green: 0.4, blue: 0.9).opacity(0.5),
                    Color.clear
                ]),
                center: glow1Center,
                startRadius: 0,
                endRadius: glow1Radius
            )
        )

        // bottom-left purple-indigo glow
        let glow2Center = CGPoint(
            x: size.width * (0.2 + 0.06 * cos(time * 0.035)),
            y: size.height * (0.82 + 0.05 * sin(time * 0.045))
        )
        let glow2Radius = size.width * 0.4
        context.opacity = 0.05 + 0.025 * auroraPhase2
        context.fill(
            Path(ellipseIn: CGRect(
                x: glow2Center.x - glow2Radius,
                y: glow2Center.y - glow2Radius,
                width: glow2Radius * 2,
                height: glow2Radius * 2
            )),
            with: .radialGradient(
                Gradient(colors: [
                    Color(red: 0.4, green: 0.15, blue: 0.75).opacity(0.45),
                    Color.clear
                ]),
                center: glow2Center,
                startRadius: 0,
                endRadius: glow2Radius
            )
        )

        // center teal accent
        let glow3Center = CGPoint(
            x: size.width * (0.5 + 0.1 * sin(time * 0.03)),
            y: size.height * (0.45 + 0.08 * cos(time * 0.04))
        )
        let glow3Radius = size.width * 0.3
        context.opacity = 0.04 + 0.02 * auroraPhase3
        context.fill(
            Path(ellipseIn: CGRect(
                x: glow3Center.x - glow3Radius,
                y: glow3Center.y - glow3Radius,
                width: glow3Radius * 2,
                height: glow3Radius * 2
            )),
            with: .radialGradient(
                Gradient(colors: [
                    Color(red: 0.05, green: 0.55, blue: 0.65).opacity(0.4),
                    Color.clear
                ]),
                center: glow3Center,
                startRadius: 0,
                endRadius: glow3Radius
            )
        )
    }

    private func drawStars(in context: inout GraphicsContext, size: CGSize, time: Double) {
        context.opacity = 1.0

        for star in stars {
            let twinkle = sin(time * star.speed + star.phase)
            let opacity = 0.25 + 0.75 * ((twinkle + 1) / 2)
            let x = star.x * size.width
            let y = star.y * size.height
            let radius = star.radius

            // soft glow
            let glowRect = CGRect(
                x: x - radius * 3.5, y: y - radius * 3.5,
                width: radius * 7, height: radius * 7
            )
            context.opacity = opacity * 0.15
            context.fill(Path(ellipseIn: glowRect), with: .color(star.color))

            // crisp core
            let coreRect = CGRect(
                x: x - radius, y: y - radius,
                width: radius * 2, height: radius * 2
            )
            context.opacity = opacity
            context.fill(Path(ellipseIn: coreRect), with: .color(star.color))
        }
    }
    // star model
    struct Star {
        let x: CGFloat, y: CGFloat, radius: CGFloat
        let speed: Double, phase: Double
        let color: Color
    }

    // nebula model (kept for compatibility)
    struct Nebula {
        let x: CGFloat, y: CGFloat, radius: CGFloat
        let color: Color, coreColor: Color
        let opacity: Double
        let driftSpeed: Double, pulseSpeed: Double, phase: Double
    }

    static func generateStars(count: Int) -> [Star] {
        let colors: [Color] = [
            .white,
            Color(red: 0.85, green: 0.9, blue: 1.0),   // cool blue-white
            Color(red: 1.0, green: 0.92, blue: 0.8),    // warm yellow-white
            Color(red: 0.7, green: 0.82, blue: 1.0),    // blue
            Color(red: 0.9, green: 0.8, blue: 1.0)      // lavender
        ]
        return (0..<count).map { _ in
            Star(
                x: .random(in: 0...1), y: .random(in: 0...1),
                radius: .random(in: 0.4...1.8),
                speed: .random(in: 0.3...2.0),
                phase: .random(in: 0...(2 * .pi)),
                color: colors.randomElement()!
            )
        }
    }

    static func generateNebulae() -> [Nebula] { [] }
}
