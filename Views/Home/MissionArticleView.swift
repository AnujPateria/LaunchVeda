import SwiftUI

struct MissionArticleView: View {
    let mission: Mission
    @Environment(\.dismiss) private var dismiss
    
    // parallax
    @State private var scrollOffsetY: CGFloat = 0
    @State private var animateIn = false
    
    // interactivity state
    @State private var selectedEvent: MissionPhase? = nil
    @State private var showEventSheet = false
    @State private var selectedStat: String? = nil
    @State private var showStatPopover = false
    private var primaryTint: Color {
        switch mission.agencyAbbr {
        case "NASA", "SpaceX": return SpaceTheme.electricBlue
        case "ISRO": return SpaceTheme.electricBlue
        case "ESA": return SpaceTheme.electricBlue
        case "JAXA": return SpaceTheme.successGreen
        default: return SpaceTheme.electricBlue
        }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.black.ignoresSafeArea()
            StarFieldBackground()
            
            // header action buttons overlay (back/share)
            headerOverlay
                .zIndex(100)
            
            ScrollView(.vertical, showsIndicators: false) {
                // tracking geometry for parallax
                GeometryReader { geo in
                    Color.clear.preference(
                        key: ScrollOffsetKey.self,
                        value: geo.frame(in: .global).minY
                    )
                }
                .frame(height: 0)
                
                VStack(spacing: 0) {
                    // 1. hero parallax
                    heroBanner
                    
                    // main article content
                    VStack(spacing: 50) {
                        // 2. intro typography
                        introSection
                        
                        // 3. visual stat grid
                        statGrid
                        
                        // 4. content text
                        articleBody
                        
                        // 5. rocket spotlight
                        rocketSpotlight
                        
                        // 5. payload spotlight
                        if mission.satellite != nil {
                            payloadSpotlight
                        }
                        
                        // 6. visual timeline
                        if !mission.missionPhases.isEmpty {
                            timelineSection
                        }
                        
                        // 7. magazine quote / key facts
                        if !mission.keyFacts.isEmpty {
                            keyFactsQuoteSection
                        }
                        
                        Spacer(minLength: 80)
                    }
                    .padding(.top, 40)
                    .background(
                        RoundedRectangle(cornerRadius: 32)
                            .fill(Color.black)
                            .shadow(color: .black.opacity(0.8), radius: 20, y: -10)
                    )
                    .offset(y: -40)
                    .zIndex(10)
                }
            }
            .onPreferenceChange(ScrollOffsetKey.self) { value in
                scrollOffsetY = value
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animateIn = true
            }
        }
    }
    
    // components
    
    private var headerOverlay: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 50) // safe area approx
    }
    
    private var heroBanner: some View {
        GeometryReader { geo in
            let minY = geo.frame(in: .global).minY
            let isScrollingDown = minY > 0
            let safeWidth = max(geo.size.width, 1)
            let safeHeight = max(geo.size.height, 1)
            
            ZStack(alignment: .bottomLeading) {
                // the image
                if let safeImageName = mission.imageName, let uiImage = UIImage(named: safeImageName) {
#if os(macOS)
                    Image(nsImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: safeWidth,
                            height: max(safeHeight + (isScrollingDown ? minY : 0), 1)
                        )
                        .clipped()
                        .offset(y: isScrollingDown ? -minY : minY * 0.4) // parallax effect
#else
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: safeWidth,
                            height: max(safeHeight + (isScrollingDown ? minY : 0), 1)
                        )
                        .clipped()
                        .offset(y: isScrollingDown ? -minY : minY * 0.4) // parallax effect
#endif
                } else {
                    Rectangle()
                        .fill(
                            LinearGradient(colors: [primaryTint.opacity(0.6), .black], startPoint: .top, endPoint: .bottom)
                        )
                }
                
                // gradient fade to black
                LinearGradient(
                    colors: [.clear, .black.opacity(0.8), Color.black],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 250)
                
                // title area
                VStack(alignment: .leading, spacing: 6) {
                    Text(mission.agencyName.uppercased())
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(primaryTint)
                        .tracking(2)
                    
                    Text(mission.name)
                        .font(.system(size: 36, weight: .black, design: .rounded)) // slightly reduced for safety
                        .foregroundColor(.white)
                        .lineSpacing(0)
                        .shadow(radius: 10)
                        .fixedSize(horizontal: false, vertical: true) // prevents clipping
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 70) // boosted padding to prevent overlapping with card edge
                .offset(y: isScrollingDown ? -minY * 0.5 : 0) // title parallax
            }
        }
        .frame(height: 480)
        .zIndex(0)
    }
    
    private var introSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "quote.opening")
                .font(.system(size: 40))
                .foregroundColor(primaryTint.opacity(0.3))
            
            Text("A journey to redefine the boundaries of human exploration.")
                .font(.system(size: 24, weight: .light, design: .serif))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .padding(.horizontal, 30)
                .italic()
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 20)
    }
    
    private var statGrid: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Button(action: { showStat("LAUNCH DATE", "The scheduled or actual date this mission began its journey to space.") }) {
                    articleStatCard(icon: "calendar", title: "Launch Date", value: mission.date)
                }.buttonStyle(.plain)
                
                Button(action: { showStat("LAUNCH SITE", "The geographical location and facility from which the rocket lifted off.") }) {
                    articleStatCard(icon: "mappin.and.ellipse", title: "Launch Site", value: mission.launchSiteStr)
                }.buttonStyle(.plain)
            }
            HStack(spacing: 12) {
                Button(action: { showStat("TARGET ORBIT", "The specific trajectory or destination in space the payload was designed to reach (e.g., LEO, GTO, Lunar).") }) {
                    articleStatCard(icon: "sparkles", title: "Target Orbit", value: mission.orbit)
                }.buttonStyle(.plain)
                
                Button(action: { showStat("STATUS", "The current operational state of the mission lifecycle.") }) {
                    articleStatCard(
                        icon: mission.status == .completed ? "checkmark.seal.fill" : "clock.fill",
                        title: "Status",
                        value: mission.status == .completed ? "Success" : "Upcoming",
                        valueColor: mission.status == .completed ? SpaceTheme.successGreen : SpaceTheme.electricBlue
                    )
                }.buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
        .alert(isPresented: $showStatPopover) {
            Alert(title: Text(selectedStat ?? "Info"), message: Text(selectedStatDescription), dismissButton: .default(Text("Got It")))
        }
    }
    
    @State private var selectedStatDescription: String = ""
    
    private func showStat(_ title: String, _ desc: String) {
        selectedStat = title
        selectedStatDescription = desc
        showStatPopover = true
    }
    
    private func articleStatCard(icon: String, title: String, value: String, valueColor: Color = .white) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(primaryTint.opacity(0.15))
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(primaryTint)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title.uppercased())
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.5))
                Text(value)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(valueColor)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .glassCard(cornerRadius: 20)
    }
    
    private var articleBody: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("THE MISSION")
                .font(.system(size: 14, weight: .black, design: .monospaced))
                .foregroundColor(primaryTint)
                .tracking(2)
            
            Text(mission.description)
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.white.opacity(0.9))
                .lineSpacing(8)
        }
        .padding(.horizontal, 24)
    }
    
    private var rocketSpotlight: some View {
        VStack(spacing: 0) {
            // section header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("THE LAUNCH VEHICLE")
                        .font(.system(size: 14, weight: .black, design: .monospaced))
                        .foregroundColor(primaryTint)
                        .tracking(2)
                    Text(mission.rocketModel)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                Spacer()
                
                HStack {
                    Text("Explore Vehicle")
                        .font(.system(size: 12, weight: .bold))
                    Image(systemName: "arrow.right.circle.fill")
                }
                .foregroundColor(primaryTint)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(primaryTint.opacity(0.15))
                .clipShape(Capsule())
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            
            // image spotlight
            rocketNavigationLink {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [primaryTint.opacity(0.2), .clear],
                                center: .center, startRadius: 10, endRadius: 160
                            )
                        )
                        .frame(height: 300)
                    
                    if mission.rocketModel.contains("LVM3") {
                        Image("lvm3_full")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 350)
                            .shadow(color: primaryTint.opacity(0.4), radius: 20)
                    } else if mission.rocketModel.contains("Falcon") {
                        // fallback visual
                        Image(systemName: "flame.fill")
                            .font(.system(size: 100))
                            .foregroundColor(primaryTint)
                            .shadow(color: primaryTint, radius: 20)
                    } else {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 100))
                            .foregroundColor(primaryTint)
                            .shadow(color: primaryTint, radius: 20)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            }
            .buttonStyle(PressScaleButtonStyle())
        }
    }
    
    @ViewBuilder
    private func rocketNavigationLink<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        NavigationLink(destination: Universal2DRocketExplorerView(rocketName: mission.rocketModel, parts: MockData.rocketParts(for: mission.rocketModel), accentColor: primaryTint)) {
            content()
        }
    }
    
    private var payloadSpotlight: some View {
        VStack(spacing: 0) {
            // section header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("THE PAYLOAD")
                        .font(.system(size: 14, weight: .black, design: .monospaced))
                        .foregroundColor(primaryTint)
                        .tracking(2)
                    Text(mission.satellite?.name ?? "Satellite")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                Spacer()
                
                HStack {
                    Text("Explore Payload")
                        .font(.system(size: 12, weight: .bold))
                    Image(systemName: "arrow.right.circle.fill")
                }
                .foregroundColor(primaryTint)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(primaryTint.opacity(0.15))
                .clipShape(Capsule())
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            
            if let sat = mission.satellite {
                NavigationLink(destination: Realistic2DRocketExplorer(rocketName: sat.name, parts: [], accentColor: primaryTint)) {
                    ZStack {
                        Circle()
                            .fill(primaryTint.opacity(0.1))
                            .frame(height: 200)
                        
                        Image(systemName: sat.icon)
                            .font(.system(size: 80))
                            .foregroundColor(primaryTint)
                            .shadow(color: primaryTint.opacity(0.5), radius: 15)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                }
                .buttonStyle(PressScaleButtonStyle())
            }
        }
    }
    
    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("MISSION TIMELINE")
                .font(.system(size: 14, weight: .black, design: .monospaced))
                .foregroundColor(primaryTint)
                .tracking(2)
                .padding(.horizontal, 24)
            
            VStack(spacing: 0) {
                ForEach(Array(mission.missionPhases.enumerated()), id: \.element.id) { index, event in
                    HStack(alignment: .top, spacing: 20) {
                        // timeline graphic
                        VStack(spacing: 0) {
                            Circle()
                                .fill(primaryTint)
                                .frame(width: 14, height: 14)
                                .overlay(Circle().stroke(Color.black, lineWidth: 3))
                                .shadow(color: primaryTint, radius: 5)
                            
                            if index != mission.missionPhases.count - 1 {
                                Rectangle()
                                    .fill(
                                        LinearGradient(colors: [primaryTint.opacity(0.5), primaryTint.opacity(0.1)], startPoint: .top, endPoint: .bottom)
                                    )
                                    .frame(width: 2)
                                    .frame(maxHeight: .infinity)
                            }
                        }
                        
                        // event data
                        Button(action: {
                            selectedEvent = event
                            showEventSheet = true
                        }) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(event.day)
                                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                                    .foregroundColor(primaryTint)
                                Text(event.name)
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                Text(event.description)
                                    .font(.system(size: 15, weight: .regular))
                                    .foregroundColor(.white.opacity(0.7))
                                    .lineSpacing(4)
                                    .padding(.top, 2)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding(.bottom, index == mission.missionPhases.count - 1 ? 0 : 40)
                            .contentShape(Rectangle()) // makes entire text area tappable
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
        .sheet(item: $selectedEvent) { event in
            ZStack {
                Color.black.ignoresSafeArea()
                VStack(spacing: 24) {
                    Image(systemName: event.icon)
                        .font(.system(size: 60))
                        .foregroundColor(primaryTint)
                        .padding(.top, 40)
                    
                    Text(event.day)
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(primaryTint)
                    
                    Text(event.name)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text(event.description)
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.8))
                        .lineSpacing(6)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                    
                    Spacer()
                }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
    
    private var keyFactsQuoteSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("DID YOU KNOW?")
                .font(.system(size: 14, weight: .black, design: .monospaced))
                .foregroundColor(primaryTint)
                .tracking(2)
                .padding(.horizontal, 24)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(mission.keyFacts, id: \.self) { fact in
                        VStack(alignment: .leading, spacing: 12) {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(primaryTint)
                                .font(.system(size: 24))
                            
                            Text(fact)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                                .lineSpacing(6)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                        }
                        .padding(20)
                        .frame(width: 280, height: 180)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white.opacity(0.05))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                                )
                        )
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

// global scroll offset preference key (useful for capturing scrollview offset)
struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}
