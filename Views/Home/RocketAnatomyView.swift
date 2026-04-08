import SwiftUI

// main rocket anatomy view - realistic rocket with callout labels
struct RocketAnatomyView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPartIndex: Int? = nil
    @State private var appeared = false

    let rocketParts = RocketAnatomyData.standardDetailedRocket
    let accentColor: Color

    var body: some View {
        ZStack {
            StarFieldBackground()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    // subtitle under nav title
                    Text("Tap a section to explore")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 12)
                        .padding(.bottom, 28)

                    // rocket with callouts
                    GeometryReader { geo in
                        let screenW = max(geo.size.width, 1) // guard against zero
                        let rocketW = screenW * 0.28
                        let sideW = max((screenW - rocketW) / 2, 0)

                        ZStack {
                            // vertical center line behind rocket
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            accentColor.opacity(0.0),
                                            accentColor.opacity(0.12),
                                            accentColor.opacity(0.12),
                                            accentColor.opacity(0.0)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 1)

                            VStack(spacing: 0) {
                                ForEach(Array(rocketParts.enumerated()), id: \.element.id) { index, part in
                                    let isSelected = selectedPartIndex == index

                                    VStack(spacing: 0) {
                                        // section with callout
                                        RocketSectionWithCallout(
                                            part: part,
                                            index: index,
                                            totalParts: rocketParts.count,
                                            isSelected: isSelected,
                                            accentColor: accentColor,
                                            appeared: appeared,
                                            rocketWidth: rocketW,
                                            labelWidth: max(sideW - 16, 0)
                                        ) {
                                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                                selectedPartIndex = isSelected ? nil : index
                                            }
                                        }

                                        // expanded detail panel
                                        if isSelected {
                                            AnatomyInlineDetail(part: part, accentColor: accentColor)
                                                .transition(.opacity.combined(with: .move(edge: .top)))
                                                .padding(.horizontal, 16)
                                                .padding(.top, 8)
                                                .padding(.bottom, 12)
                                        }
                                    }
                                }
                            }
                        }
                        .frame(width: screenW)
                    }
                    .frame(height: totalRocketHeight)

                    Spacer(minLength: 80)
                }
            }
        }
        .navigationTitle("Rocket Anatomy")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                appeared = true
            }
        }
    }

    private var totalRocketHeight: CGFloat {
        // sum of all section heights + expanded panels if any
        let baseHeight: CGFloat = 100 + 110 + 130 + 70 // fairing + second + first + engine
        let expandedExtra: CGFloat = selectedPartIndex != nil ? 280 : 0
        return baseHeight + expandedExtra + 20
    }
}

// a single rocket section with its realistic shape and callout label
struct RocketSectionWithCallout: View {
    let part: AnatomySection
    let index: Int
    let totalParts: Int
    let isSelected: Bool
    let accentColor: Color
    let appeared: Bool
    let rocketWidth: CGFloat
    let labelWidth: CGFloat
    let onTap: () -> Void

    // alternating callout sides
    private var isLeftCallout: Bool { index % 2 == 0 }

    var body: some View {
        HStack(spacing: 0) {
            if isLeftCallout {
                // callout label on the left
                calloutLabel
                    .frame(width: labelWidth, alignment: .trailing)
                    .padding(.trailing, 4)

                // connector line
                connectorLine
                    .frame(width: 24, height: sectionHeight)
            } else {
                Spacer()
                    .frame(width: labelWidth + 24)
            }

            // rocket body piece
            Button(action: onTap) {
                RealisticRocketPiece(
                    index: index,
                    totalParts: totalParts,
                    isSelected: isSelected,
                    accentColor: accentColor
                )
                .frame(width: rocketWidth, height: sectionHeight)
            }
            .buttonStyle(PlainButtonStyle())

            if !isLeftCallout {
                // connector line
                connectorLine
                    .frame(width: 24, height: sectionHeight)

                // callout label on the right
                calloutLabel
                    .frame(width: labelWidth, alignment: .leading)
                    .padding(.leading, 4)
            } else {
                Spacer()
                    .frame(width: labelWidth + 24)
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.easeOut(duration: 0.5).delay(Double(index) * 0.1), value: appeared)
    }

    private var sectionHeight: CGFloat {
        switch index {
        case 0: return 100  // fairing
        case 1: return 110  // second stage
        case 2: return 130  // first stage - tallest
        case 3: return 70   // engine section
        default: return 90
        }
    }

    private var calloutLabel: some View {
        VStack(alignment: isLeftCallout ? .trailing : .leading, spacing: 4) {
            Text(part.name.uppercased())
                .font(.system(size: 11, weight: .heavy, design: .monospaced))
                .foregroundColor(isSelected ? accentColor : .white.opacity(0.9))
                .tracking(1)
                .lineLimit(2)
                .multilineTextAlignment(isLeftCallout ? .trailing : .leading)
                .fixedSize(horizontal: false, vertical: true)

            Text(part.headlineText)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(isLeftCallout ? .trailing : .leading)
        }
    }

    private var connectorLine: some View {
        GeometryReader { geo in
            let midY = max(geo.size.height, 1) / 2
            Path { path in
                path.move(to: CGPoint(x: 0, y: midY))
                path.addLine(to: CGPoint(x: geo.size.width, y: midY))
            }
            .stroke(
                isSelected ? accentColor : Color.white.opacity(0.25),
                style: StrokeStyle(lineWidth: 1, dash: [4, 3])
            )

            // dot at the end near the rocket
            Circle()
                .fill(isSelected ? accentColor : Color.white.opacity(0.5))
                .frame(width: 6, height: 6)
                .position(x: isLeftCallout ? geo.size.width - 3 : 3, y: midY)

            if isSelected {
                Circle()
                    .fill(accentColor.opacity(0.3))
                    .frame(width: 16, height: 16)
                    .position(x: isLeftCallout ? geo.size.width - 3 : 3, y: midY)
            }
        }
    }
}

// the actual rocket piece shape - drawn to look realistic
struct RealisticRocketPiece: View {
    let index: Int
    let totalParts: Int
    let isSelected: Bool
    let accentColor: Color

    // metallic color palette
    private var metalColors: (light: Color, dark: Color) {
        switch index {
        case 0: return (Color(white: 0.92), Color(white: 0.72))
        case 1: return (Color(white: 0.85), Color(white: 0.62))
        case 2: return (Color(white: 0.75), Color(white: 0.50))
        case 3: return (Color(white: 0.55), Color(white: 0.30))
        default: return (Color(white: 0.8), Color(white: 0.6))
        }
    }

    var body: some View {
        GeometryReader { geo in
            let w = max(geo.size.width, 1)
            let h = max(geo.size.height, 1)

            ZStack {
                // glow behind when selected
                if isSelected {
                    RoundedRectangle(cornerRadius: index == 0 ? 16 : 4)
                        .fill(accentColor.opacity(0.15))
                        .frame(width: w + 8, height: h + 8)
                        .blur(radius: 10)
                }

                // rocket body shape
                RocketPieceShape(index: index, totalParts: totalParts)
                    .fill(
                        LinearGradient(
                            colors: isSelected
                                ? [accentColor.opacity(0.6), accentColor.opacity(0.3)]
                                : [metalColors.light, metalColors.dark],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .overlay(
                        RocketPieceShape(index: index, totalParts: totalParts)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(isSelected ? 0.35 : 0.2),
                                        Color.white.opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    // metallic highlight strip
                    .overlay(
                        RocketPieceShape(index: index, totalParts: totalParts)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.25),
                                        Color.white.opacity(0.0),
                                        Color.white.opacity(0.0)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .mask(
                                Rectangle()
                                    .frame(width: w * 0.25)
                                    .offset(x: -w * 0.25)
                            )
                    )
                    .shadow(color: .black.opacity(0.4), radius: 6, x: 3, y: 3)
                    .shadow(color: isSelected ? accentColor.opacity(0.4) : .clear, radius: 12)

                // icon when selected
                if isSelected {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white.opacity(0.9))
                }
            }
            .frame(width: w, height: h)
        }
        .contentShape(Rectangle())
    }
}

// custom shape for each rocket piece
struct RocketPieceShape: InsettableShape {
    let index: Int
    let totalParts: Int
    var insetAmount: CGFloat = 0

    func inset(by amount: CGFloat) -> RocketPieceShape {
        var shape = self
        shape.insetAmount += amount
        return shape
    }

    func path(in rect: CGRect) -> Path {
        let r = rect.insetBy(dx: insetAmount, dy: insetAmount)
        var path = Path()

        switch index {
        case 0:
            // nose cone / payload fairing - smooth ogive shape
            let tipRadius: CGFloat = min(r.width * 0.12, 10)
            let bodyStart = r.minY + r.height * 0.4

            // ogive curve from tip
            path.move(to: CGPoint(x: r.midX, y: r.minY + tipRadius))

            // left curve from tip down to body
            path.addQuadCurve(
                to: CGPoint(x: r.minX + 2, y: bodyStart),
                control: CGPoint(x: r.midX - r.width * 0.15, y: r.minY + tipRadius + 12)
            )

            // left side straight down
            path.addLine(to: CGPoint(x: r.minX, y: r.maxY))

            // bottom edge
            path.addLine(to: CGPoint(x: r.maxX, y: r.maxY))

            // right side straight up
            path.addLine(to: CGPoint(x: r.maxX - 2, y: bodyStart))

            // right curve up to tip
            path.addQuadCurve(
                to: CGPoint(x: r.midX, y: r.minY + tipRadius),
                control: CGPoint(x: r.midX + r.width * 0.15, y: r.minY + tipRadius + 12)
            )

            path.closeSubpath()

            // tip cap circle
            path.addEllipse(in: CGRect(
                x: r.midX - tipRadius,
                y: r.minY,
                width: tipRadius * 2,
                height: tipRadius * 2
            ))

        case 1:
            // second stage - slightly narrower cylinder
            let inset: CGFloat = r.width * 0.03
            let cr: CGFloat = 3
            path.addRoundedRect(
                in: CGRect(x: r.minX + inset, y: r.minY, width: r.width - inset * 2, height: r.height),
                cornerSize: CGSize(width: cr, height: cr)
            )

        case 2:
            // first stage core - full width cylinder
            let cr: CGFloat = 2
            path.addRoundedRect(
                in: r,
                cornerSize: CGSize(width: cr, height: cr)
            )

        case 3:
            // engine section - flares out at the bottom
            let topInset: CGFloat = r.width * 0.06
            let flare: CGFloat = r.width * 0.08

            path.move(to: CGPoint(x: r.minX + topInset, y: r.minY))
            path.addLine(to: CGPoint(x: r.maxX - topInset, y: r.minY))

            // flare out
            path.addQuadCurve(
                to: CGPoint(x: r.maxX + flare, y: r.maxY),
                control: CGPoint(x: r.maxX - topInset, y: r.maxY - 8)
            )
            path.addLine(to: CGPoint(x: r.minX - flare, y: r.maxY))
            path.addQuadCurve(
                to: CGPoint(x: r.minX + topInset, y: r.minY),
                control: CGPoint(x: r.minX + topInset, y: r.maxY - 8)
            )
            path.closeSubpath()

            // engine nozzles
            let nozzleY = r.maxY - 8
            let nozzleR: CGFloat = min(r.width * 0.08, 7)
            let spacing = r.width * 0.2
            for xOff in [-spacing, 0.0, spacing] {
                path.addEllipse(in: CGRect(
                    x: r.midX + xOff - nozzleR,
                    y: nozzleY - nozzleR,
                    width: nozzleR * 2,
                    height: nozzleR * 2
                ))
            }

        default:
            path.addRoundedRect(in: r, cornerSize: CGSize(width: 6, height: 6))
        }

        return path
    }
}

// inline detail (appears below the row when selected)
struct AnatomyInlineDetail: View {
    let part: AnatomySection
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(part.description)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
                .lineSpacing(4)

            // sub-parts preview
            VStack(alignment: .leading, spacing: 10) {
                ForEach(part.subParts.prefix(3)) { sub in
                    HStack(spacing: 12) {
                        Image(systemName: anatomyIcon(for: sub.systemType))
                            .font(.system(size: 13))
                            .foregroundColor(accentColor)
                            .frame(width: 22)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(sub.name)
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.white.opacity(0.9))
                            Text(sub.systemType.uppercased())
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(.secondary)
                                .tracking(0.5)
                        }
                    }
                }
            }

            NavigationLink(destination: AnatomySubPartView(part: part, accentColor: accentColor)) {
                HStack {
                    Image(systemName: "cpu")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Explore Sub-Systems")
                        .font(.system(size: 14, weight: .bold))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .foregroundColor(.white)
                .background(accentColor.opacity(0.8))
                .cornerRadius(14)
            }
        }
        .padding(18)
        .glassCard(cornerRadius: 16)
    }
}

func anatomyIcon(for systemType: String) -> String {
    switch systemType {
    case "Propulsion": return "flame.fill"
    case "Propellant": return "drop.fill"
    case "Control": return "cpu"
    case "Protection": return "shield.fill"
    case "Deployment": return "arrow.up.forward"
    case "Aerodynamics": return "wind"
    case "Structural": return "building.columns.fill"
    case "Mechanics": return "gearshape.2.fill"
    default: return "info.circle"
    }
}

func anatomyPartColor(for systemType: String) -> Color {
    switch systemType {
    case "Propulsion": return .orange
    case "Propellant": return .cyan
    case "Control": return .green
    case "Protection": return .yellow
    case "Deployment": return .purple
    case "Aerodynamics": return .mint
    case "Structural": return .gray
    case "Mechanics": return .red
    default: return .blue
    }
}
