import SwiftUI

// realistic image rocket explorer view
struct RealisticImageRocketExplorerView: View {
    let rocketName: String
    let parts: [RocketPart]
    let accentColor: Color
    @Binding var selectedPart: RocketPart?
    let isDismantled: Bool
    
    private var isolatedImageName: String {
        let name = rocketName.lowercased()
        if name.contains("saturn") || name.contains("apollo") { 
            return !isDismantled ? "saturn_v_exploded_transparent" : "saturn_v_isolated" 
        }
        if name.contains("lvm3") || name.contains("gslv") || name.contains("chandrayan") || name.contains("chandrayaan") {
            return "lvm3_full"
        }
        if name.contains("sls") { return "sls_block1" }
        return !isDismantled ? "saturn_v_exploded_transparent" : "saturn_v_isolated"
    }

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var animateIn = false

    var body: some View {
        GeometryReader { outerGeo in
            let rocketHeight = max(outerGeo.size.height, 1) * 0.78
            let headerHeight: CGFloat = 70
            let safeNumberH = max(outerGeo.size.height, 1) * 0.75
            let numberGap = safeNumberH / CGFloat(max(1, parts.count))
            let numberXOffset = max(outerGeo.size.width, 1) * 0.28
            let topOffset = headerHeight + 10
            
            ZStack {
                // background
                Color.black.ignoresSafeArea()
                StarFieldBackground()
                
                // header
                VStack {
                    VStack(spacing: 8) {
                        Text(isDismantled ? "A S S E M B L E D" : "E X P A N D E D")
                            .font(.system(size: 14, weight: .black, design: .rounded))
                            .foregroundColor(accentColor)
                            .tracking(4)
                        Text("Tap a section to explore")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.top, 12)
                    .frame(maxWidth: .infinity)
                    
                    Spacer()
                }
                .zIndex(50)
                .animation(.easeInOut(duration: 0.3), value: isDismantled)
                
                // layer 1: connector lines
                ForEach(Array(parts.enumerated()), id: \.element.id) { index, _ in
                    let circleY = topOffset + (outerGeo.size.height - topOffset) / 2 - (safeNumberH / 2) + (CGFloat(index) * numberGap) + (numberGap / 2)
                    let isLeft = index % 2 != 0
                    let circleX = isLeft
                        ? (outerGeo.size.width / 2) - numberXOffset
                        : (outerGeo.size.width / 2) + numberXOffset
                    let topOfRocketY = topOffset + (outerGeo.size.height - topOffset) / 2 - (rocketHeight / 2)
                    let targetY = calculateTargetY(index: index, topOfRocketY: topOfRocketY, rocketHeight: rocketHeight)
                    let targetX = outerGeo.size.width / 2
                    
                    Path { path in
                        path.move(to: CGPoint(x: circleX, y: circleY))
                        let horizontalOffset: CGFloat = isLeft ? 30 : -30
                        path.addLine(to: CGPoint(x: circleX + horizontalOffset, y: circleY))
                        path.addLine(to: CGPoint(x: targetX, y: targetY))
                    }
                    .stroke(
                        LinearGradient(
                            colors: [accentColor.opacity(0.6), accentColor.opacity(0.1)],
                            startPoint: isLeft ? .leading : .trailing,
                            endPoint: isLeft ? .trailing : .leading
                        ),
                        style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])
                    )
                }
                .zIndex(1)
                
                // layer 2: rocket image with glow
                ZStack {
                    // glow behind rocket
                    Image(isolatedImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(height: rocketHeight)
                        .blur(radius: 30)
                        .opacity(0.15)
                    
                    // actual rocket
                    Image(isolatedImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(height: rocketHeight)
                }
                .position(x: outerGeo.size.width / 2, y: outerGeo.size.height / 2)
                .scaleEffect(scale)
                .offset(offset)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isDismantled)
                .gesture(
                    MagnificationGesture()
                        .onChanged { val in
                            let delta = val / lastScale
                            lastScale = val
                            scale = max(1.0, min(scale * delta, 5.0))
                        }
                        .onEnded { _ in
                            lastScale = 1.0
                            if scale <= 1.0 {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                    scale = 1.0
                                    offset = .zero
                                }
                            }
                        }
                        .simultaneously(
                            with: DragGesture()
                                .onChanged { val in
                                    guard scale > 1.0 else { return }
                                    offset = CGSize(
                                        width: lastOffset.width + val.translation.width,
                                        height: lastOffset.height + val.translation.height
                                    )
                                }
                                .onEnded { _ in
                                    lastOffset = offset
                                }
                        )
                )
                .zIndex(2)
                
                // layer 3: annotation labels with names
                ForEach(Array(parts.enumerated()), id: \.element.id) { index, part in
                    let circleY = topOffset + (outerGeo.size.height - topOffset) / 2 - (safeNumberH / 2) + (CGFloat(index) * numberGap) + (numberGap / 2)
                    let isLeft = index % 2 != 0
                    let circleX = isLeft
                        ? (outerGeo.size.width / 2) - numberXOffset
                        : (outerGeo.size.width / 2) + numberXOffset
                    
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            selectedPart = part
                        }
                    } label: {
                        HStack(spacing: 10) {
                            if !isLeft {
                                // label on the left for right-side items
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(part.name.uppercased())
                                        .font(.system(size: 9, weight: .black, design: .monospaced))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                    
                                    Text(partSubtitle(for: part))
                                        .font(.system(size: 9, weight: .medium))
                                        .foregroundColor(.white.opacity(0.5))
                                        .lineLimit(1)
                                }
                                .frame(width: 80, alignment: .trailing)
                            }
                            
                            // circle badge
                            ZStack {
                                Circle()
                                    .fill(
                                        selectedPart?.id == part.id
                                            ? accentColor
                                            : Color(white: 0.12)
                                    )
                                    .frame(width: 36, height: 36)
                                    .overlay(
                                        Circle().strokeBorder(
                                            selectedPart?.id == part.id
                                                ? accentColor
                                                : part.swiftUIColor.opacity(0.5),
                                            lineWidth: 1.5
                                        )
                                    )
                                    .shadow(
                                        color: selectedPart?.id == part.id
                                            ? accentColor.opacity(0.5)
                                            : part.swiftUIColor.opacity(0.3),
                                        radius: 6
                                    )
                                
                                Image(systemName: part.icon)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(
                                        selectedPart?.id == part.id
                                            ? .white
                                            : part.swiftUIColor
                                    )
                            }
                            
                            if isLeft {
                                // label on the right for left-side items
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(part.name.uppercased())
                                        .font(.system(size: 9, weight: .black, design: .monospaced))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                    
                                    Text(partSubtitle(for: part))
                                        .font(.system(size: 9, weight: .medium))
                                        .foregroundColor(.white.opacity(0.5))
                                        .lineLimit(1)
                                }
                                .frame(width: 80, alignment: .leading)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .position(x: circleX, y: circleY)
                    .opacity(animateIn ? 1 : 0)
                    .offset(x: animateIn ? 0 : (isLeft ? -20 : 20))
                }
                .zIndex(20)
                .blur(radius: scale > 1.1 ? (scale - 1.1) * 10.0 : 0.0)
                .opacity(scale > 1.1 ? max(CGFloat(0.0), CGFloat(1.0) - (scale - 1.1)) : 1.0)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isDismantled)
            }
        }
        .onAppear {
            withAnimation { animateIn = true }
        }
    }
    
    // helpers
    
    private func partSubtitle(for part: RocketPart) -> String {
        if let heightSpec = part.specs.first(where: { $0.label.lowercased().contains("thrust") }) {
            return heightSpec.value
        }
        if let heightSpec = part.specs.first(where: { $0.label.lowercased().contains("height") }) {
            return heightSpec.value
        }
        if let firstSpec = part.specs.first {
            return firstSpec.value
        }
        return ""
    }
    
    private func extractHeight(from part: RocketPart) -> Double? {
        if let hString = part.specs.first(where: { $0.label.lowercased().contains("height") })?.value {
            let numString = hString.components(separatedBy: CharacterSet(charactersIn: "0123456789. ").inverted).joined()
            let cleanString = numString.trimmingCharacters(in: .whitespaces)
            if let val = Double(cleanString) {
                if part.name.lowercased().contains("fairing") || part.name.lowercased().contains("payload") || part.name.lowercased().contains("capsule") {
                    return val * 1.5
                }
                return val
            }
        }
        return nil
    }
    
    private func calculateTargetY(index: Int, topOfRocketY: CGFloat, rocketHeight: CGFloat) -> CGFloat {
        let name = index < parts.count ? parts[index].name.lowercased() : ""
        let relativeY: CGFloat
        
        // saturn v parts (top to bottom): les, cm, sm, lm, s-ivb, s-ii, s-ic
        if name.contains("escape") {
            relativeY = 0.03
        } else if name.contains("command") {
            relativeY = 0.12
        } else if name.contains("service") {
            relativeY = 0.22
        } else if name.contains("lunar") || name.contains("eagle") {
            relativeY = 0.34
        } else if name.contains("s-ivb") || name.contains("third") {
            relativeY = 0.48
        } else if name.contains("s-ii") || name.contains("second") {
            relativeY = 0.65
        } else if name.contains("s-ic") || name.contains("first") {
            relativeY = 0.87
        // falcon 9 / generic parts
        } else if name.contains("fairing") || name.contains("payload") {
            relativeY = 0.05
        } else if name.contains("interstage") {
            relativeY = 0.30
        } else if name.contains("booster") || name.contains("first stage") {
            relativeY = 0.65
        // lvm3 parts
        } else if name.contains("cryogenic") || name.contains("c25") {
            relativeY = 0.20
        } else if name.contains("l110") || name.contains("core stage") {
            relativeY = 0.50
        } else if name.contains("s200") || name.contains("solid booster") {
            relativeY = 0.80
        } else {
            // even distribution fallback
            let count = max(1, parts.count)
            relativeY = count > 1 ? CGFloat(index) / CGFloat(count - 1) : 0.5
        }
        
        return topOfRocketY + (rocketHeight * relativeY)
    }
}

