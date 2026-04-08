import SwiftUI
import SceneKit

// universal 2d rocket explorer
struct Universal2DRocketExplorerView: View {
    let rocketName: String
    let parts: [RocketPart]
    let accentColor: Color
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedPart: RocketPart? = nil
    @State private var highlightedPartId: String? = nil
    @State private var selectedInternal: SatellitePart? = nil
    @State private var showInternalCard = false
    @State private var animateIn = false
    @State private var viewMode: ExplorerMode = .realistic

    enum ExplorerMode: String, CaseIterable {
        case realistic = "Assembled"
        case assembled = "Expanded"
        case interior = "Interior"
        
        var icon: String {
            switch self {
            case .realistic: return "square.stack.3d.down.right"
            case .assembled: return "rocket"
            case .interior: return "view.2d"
            }
        }
    }



    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // native segmented picker
                Picker("View Mode", selection: $viewMode.animation(.spring(response: 0.4))) {
                    ForEach(ExplorerMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 12)
                
                ZStack {
                    if viewMode == .realistic || viewMode == .assembled {
                        RealisticImageRocketExplorerView(
                            rocketName: rocketName,
                            parts: parts,
                            accentColor: accentColor,
                            selectedPart: $selectedPart,
                            isDismantled: viewMode == .realistic
                        )
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        .id("realistic_\(viewMode == .realistic)")
                    } else if viewMode == .interior {
                        InteriorCutawayView(
                            rocketName: rocketName, 
                            accentColor: accentColor, 
                            selectedPart: $selectedPart
                        )
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        .id("interior")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            if showInternalCard, let comp = selectedInternal {
                internalComponentCard(comp)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.9).combined(with: .opacity),
                        removal: .opacity
                    ))
                    .zIndex(100)
            }
        }
        .navigationTitle("Rocket Explorer")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 1) {
                    Text("Rocket Explorer")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(rocketName)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .preferredColorScheme(.dark)
        .sheet(item: $selectedPart) { part in
            RocketPartSheetView(part: part, accentColor: accentColor)
                .presentationDetents([.fraction(0.75), .large])
                .presentationDragIndicator(.visible)
                .presentationBackground(.black.opacity(0.95))
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.7)) { animateIn = true }
        }
    }
    

    
    // internal component info card
    @ViewBuilder
    private func internalComponentCard(_ component: SatellitePart) -> some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.3)) {
                        showInternalCard = false
                        selectedInternal = nil
                    }
                }
            
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(component.color.opacity(0.2))
                            .frame(width: 44, height: 44)
                            .overlay(Circle().strokeBorder(component.color, lineWidth: 1.5))
                        Image(systemName: component.icon)
                            .font(.system(size: 18))
                            .foregroundColor(component.color)
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text(component.name)
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("Internal Component")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(component.color)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            showInternalCard = false
                            selectedInternal = nil
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white.opacity(0.6))
                            .frame(width: 30, height: 30)
                            .background(Circle().fill(Color.white.opacity(0.1)))
                    }
                }
                
                Text(component.description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.85))
                    .lineSpacing(4)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(white: 0.12))
            )
            .padding(.horizontal, 24)
        }
    }
}



// custom rounded rect for asymmetric clipping
struct CustomRoundedRect: Shape {
    var tl: CGFloat = 0.0
    var tr: CGFloat = 0.0
    var bl: CGFloat = 0.0
    var br: CGFloat = 0.0

    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let w = rect.size.width
        let h = rect.size.height
        
        let tr = min(min(self.tr, h/2), w/2)
        let tl = min(min(self.tl, h/2), w/2)
        let bl = min(min(self.bl, h/2), w/2)
        let br = min(min(self.br, h/2), w/2)
        
        path.move(to: CGPoint(x: w / 2.0, y: 0))
        path.addLine(to: CGPoint(x: w - tr, y: 0))
        path.addArc(center: CGPoint(x: w - tr, y: tr), radius: tr, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
        path.addLine(to: CGPoint(x: w, y: h - br))
        path.addArc(center: CGPoint(x: w - br, y: h - br), radius: br, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
        path.addLine(to: CGPoint(x: bl, y: h))
        path.addArc(center: CGPoint(x: bl, y: h - bl), radius: bl, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
        path.addLine(to: CGPoint(x: 0, y: tl))
        path.addArc(center: CGPoint(x: tl, y: tl), radius: tl, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
        path.closeSubpath()
        return path
    }
}

struct InteriorCutawayView: View {
    let rocketName: String
    let accentColor: Color
    @Binding var selectedPart: RocketPart?
    
    struct Annotation: Identifiable {
        let id: Int
        let title: String
        let subtitle: String
        let icon: String
        let colorName: String
        let color: Color
        let relativeY: CGFloat
        let isLeft: Bool
        let description: String
        let imageName: String?
    }
    
    let annotations: [Annotation] = [
        .init(id: 1, title: "Launch Escape System", subtitle: "689 kN thrust", icon: "arrow.up.to.line", colorName: "red", color: .red, relativeY: 0.05, isLeft: true, description: "The LES was a safety system that could pull the Command Module away from the Saturn V in case of an emergency during launch.", imageName: "saturn_v_les"),
        .init(id: 2, title: "Command Module", subtitle: "3 astronauts", icon: "person.3.fill", colorName: "blue", color: .cyan, relativeY: 0.12, isLeft: false, description: "The crew cabin where the three astronauts lived throughout the mission. After separation, the CM re-entered Earth's atmosphere.", imageName: "saturn_v_cm"),
        .init(id: 3, title: "Service Module", subtitle: "97.9 kN thrust", icon: "cylinder.fill", colorName: "darkgray", color: .gray, relativeY: 0.18, isLeft: true, description: "Provided propulsion, electrical power, and environmental control for the mission.", imageName: "saturn_v_sm"),
        .init(id: 4, title: "Lunar Module", subtitle: "15,095 kg", icon: "moon.fill", colorName: "gold", color: .yellow, relativeY: 0.25, isLeft: false, description: "The lander that carried Armstrong and Aldrin to the lunar surface.", imageName: "saturn_v_lm"),
        .init(id: 5, title: "Instrument Unit", subtitle: "Navigation", icon: "cpu", colorName: "green", color: .green, relativeY: 0.32, isLeft: true, description: "The IBM Ring containing guidance, navigation and control equipment to guide the Saturn V.", imageName: "instrument_unit"),
        .init(id: 6, title: "S-IVB LOX Tank", subtitle: "Liquid oxygen", icon: "drop.fill", colorName: "blue", color: .blue, relativeY: 0.38, isLeft: false, description: "Liquid oxygen oxidiser tank for the S-IVB third stage.", imageName: "sivb_lox_tank"),
        .init(id: 7, title: "S-IVB Stage", subtitle: "J-2 Engine", icon: "flame.fill", colorName: "orange", color: .orange, relativeY: 0.45, isLeft: true, description: "The third stage powered by a single J-2 engine, used for Earth orbit insertion and trans-lunar injection.", imageName: "saturn_v_sivb"),
        .init(id: 8, title: "S-II LOX Tank", subtitle: "Liquid oxygen", icon: "drop.fill", colorName: "blue", color: .blue, relativeY: 0.52, isLeft: false, description: "Liquid oxygen oxidiser tank for the S-II second stage.", imageName: "sii_lox_tank"),
        .init(id: 9, title: "S-II LH2 Tank", subtitle: "Liquid hydrogen", icon: "drop.fill", colorName: "purple", color: .purple, relativeY: 0.60, isLeft: true, description: "Liquid hydrogen fuel tank for the S-II second stage.", imageName: "sii_lh2_tank"),
        .init(id: 10, title: "S-II Stage", subtitle: "J-2 Engines ×5", icon: "flame.fill", colorName: "orange", color: .orange, relativeY: 0.68, isLeft: false, description: "The second stage powered by five J-2 engines, pushing Apollo into orbit after S-IC separation.", imageName: "saturn_v_sii"),
        .init(id: 11, title: "S-IC LOX Tank", subtitle: "Liquid oxygen", icon: "drop.fill", colorName: "blue", color: .blue, relativeY: 0.78, isLeft: true, description: "Liquid oxygen oxidiser tank for the S-IC first stage, feeding the five F-1 engines.", imageName: "sic_lox_tank"),
        .init(id: 12, title: "S-IC RP-1 Tank", subtitle: "Kerosene fuel", icon: "fuelpump.fill", colorName: "brown", color: .brown, relativeY: 0.85, isLeft: false, description: "Fuel tank holding kerosene for the massive S-IC first stage.", imageName: "sic_rp1_tank"),
        .init(id: 13, title: "S-IC Stage", subtitle: "F-1 Engines ×5", icon: "flame.fill", colorName: "red", color: .red, relativeY: 0.94, isLeft: true, description: "The first stage powered by five F-1 engines, providing 34 MN of thrust to lift the 2,900 ton rocket.", imageName: "saturn_v_sic"),
        .init(id: 14, title: "Stabilizer Fins", subtitle: "Structural", icon: "triangle.fill", colorName: "darkgray", color: .gray, relativeY: 0.98, isLeft: false, description: "Four aerodynamic fins at the base of the S-IC to provide stability during atmospheric flight.", imageName: "stabilizer_fins")
    ]
    
    @State private var animateIn = false
    @State private var currentZoom: CGFloat = 1.0
    @State private var baseZoom: CGFloat = 1.0
    @State private var currentOffset: CGSize = .zero
    @State private var baseOffset: CGSize = .zero
    
    private var cutawayImageName: String {
        let name = rocketName.lowercased()
        if name.contains("lvm3") || name.contains("gslv") || name.contains("chandrayan") || name.contains("chandrayaan") {
            return "chandrayan3Interior"
        }
        return "saturn_v_cutaway_transparent"
    }
    
    var body: some View {
        GeometryReader { outerGeo in
            let rocketHeight = max(outerGeo.size.height, 1) * 0.78
            let numberXOffset = max(outerGeo.size.width, 1) * 0.28
            let topOfRocketY = (max(outerGeo.size.height, 1) / 2) - (rocketHeight / 2)
            
            ZStack {
                // header
                VStack {
                    VStack(spacing: 8) {
                        Text("I N T E R I O R")
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
                
                // connector lines
                ForEach(annotations) { ann in
                    let circleY = topOfRocketY + (rocketHeight * ann.relativeY)
                    let circleX = ann.isLeft 
                        ? (outerGeo.size.width / 2) - numberXOffset
                        : (outerGeo.size.width / 2) + numberXOffset
                    let targetX = outerGeo.size.width / 2
                    let targetY = circleY 
                    
                    Path { path in
                        path.move(to: CGPoint(x: circleX, y: circleY))
                        let horizontalOffset: CGFloat = ann.isLeft ? 30 : -30
                        path.addLine(to: CGPoint(x: circleX + horizontalOffset, y: circleY))
                        path.addLine(to: CGPoint(x: targetX, y: targetY))
                    }
                    .stroke(
                        LinearGradient(
                            colors: [ann.color.opacity(0.6), ann.color.opacity(0.1)],
                            startPoint: ann.isLeft ? .leading : .trailing,
                            endPoint: ann.isLeft ? .trailing : .leading
                        ),
                        style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])
                    )
                }
                .zIndex(1)
                
                // cutaway image — transparent, no background
                Image(cutawayImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: rocketHeight)
                    .shadow(color: accentColor.opacity(0.15), radius: 15)
                    .scaleEffect(currentZoom)
                    .offset(currentOffset)
                    .position(x: outerGeo.size.width / 2, y: outerGeo.size.height / 2)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                currentZoom = max(1.0, min(4.0, baseZoom * value))
                            }
                            .onEnded { _ in
                                baseZoom = 1.0
                                if currentZoom <= 1.0 {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                        currentZoom = 1.0
                                        currentOffset = .zero
                                    }
                                }
                            }
                            .simultaneously(
                                with: DragGesture()
                                    .onChanged { value in
                                        guard currentZoom > 1.0 else { return }
                                        currentOffset = CGSize(
                                            width: baseOffset.width + value.translation.width,
                                            height: baseOffset.height + value.translation.height
                                        )
                                    }
                                    .onEnded { _ in
                                        baseOffset = currentOffset
                                    }
                            )
                    )
                    .zIndex(2)
                
                // icon badges with labels
                ForEach(annotations) { ann in
                    let circleY = topOfRocketY + (rocketHeight * ann.relativeY)
                    let circleX = ann.isLeft 
                        ? (outerGeo.size.width / 2) - numberXOffset
                        : (outerGeo.size.width / 2) + numberXOffset
                    
                    Button(action: {
                        // create a temporary rocketpart for the sheet to present
                        let mockPart = RocketPart(
                            id: "interior_\(ann.id)",
                            name: ann.title.replacingOccurrences(of: "\n", with: " "),
                            icon: ann.icon,
                            description: ann.description,
                            colorName: ann.colorName,
                            specs: [RocketSpec(label: "Key Detail", value: ann.subtitle)],
                            subparts: [],
                            stageImageName: ann.imageName,
                            partImageName: ann.imageName
                        )
                        selectedPart = mockPart
                    }) {
                        HStack(spacing: 8) {
                            if !ann.isLeft {
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(ann.title.replacingOccurrences(of: "\n", with: " ").uppercased())
                                        .font(.system(size: 9, weight: .black, design: .monospaced))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                    Text(ann.subtitle)
                                        .font(.system(size: 9, weight: .medium))
                                        .foregroundColor(.white.opacity(0.5))
                                        .lineLimit(1)
                                }
                                .frame(width: 80, alignment: .trailing)
                            }
                            
                            ZStack {
                                Circle()
                                    .fill(Color(white: 0.12))
                                    .frame(width: 36, height: 36)
                                    .overlay(
                                        Circle().strokeBorder(ann.color.opacity(0.5), lineWidth: 1.5)
                                    )
                                    .shadow(color: ann.color.opacity(0.3), radius: 6)
                                
                                Image(systemName: ann.icon)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(ann.color)
                            }
                            
                            if ann.isLeft {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(ann.title.replacingOccurrences(of: "\n", with: " ").uppercased())
                                        .font(.system(size: 9, weight: .black, design: .monospaced))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                    Text(ann.subtitle)
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
                    .offset(x: animateIn ? 0 : (ann.isLeft ? -20 : 20))
                    .animation(.easeOut(duration: 0.5).delay(Double(ann.id) * 0.05), value: animateIn)
                }
                .zIndex(20)
            }
        }
        .onAppear {
            withAnimation { animateIn = true }
        }
    }
}
