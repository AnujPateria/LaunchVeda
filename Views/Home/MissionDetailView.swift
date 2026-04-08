import SwiftUI

struct MissionDetailView: View {
    let mission: Mission

    // presentation state
    @State private var showRocketExplorer = false
    @State private var showLaunchReplay = false
    @State private var showSatellite = false
    @State private var showArticle = false
    @State private var selectedCrewMember: String? = nil
    @State private var showCrewSheet = false
    @State private var showComingSoonAlert = false
    @State private var showApollo11Explorer = false // For Chandrayaan-2's alert option

    // computed helpers

    private var has2DExplorer: Bool {
        !MockData.rocketParts(for: mission.rocketModel).isEmpty || mission.name.contains("Chandrayaan-2")
    }

    private var isRocketExplorerAvailable: Bool {
        !MockData.rocketParts(for: mission.rocketModel).isEmpty
    }

    private var accentColor: Color {
        SpaceTheme.electricBlue
    }

    // body

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 0) {
                heroSection

                VStack(alignment: .leading, spacing: 24) {
                    missionMetaStrip
                        .padding(.top, 16)

                    quickStats

                    overviewSection

                    if !mission.missionPhases.isEmpty {
                        timelineSection
                    }

                    if !mission.keyFacts.isEmpty {
                        keyFactsSection
                    }

                    if let satellite = mission.satellite {
                        payloadExplorerButton(satellite: satellite)
                    }

                    if !mission.crew.isEmpty {
                        crewSection
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 16)
            }
        }
        .background(Color(.systemBackground))
        .ignoresSafeArea(edges: .top)
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationTitle(mission.name)
        .navigationBarTitleDisplayMode(.inline)
        // navigation: 2d rocket explorer
        .navigationDestination(isPresented: $showRocketExplorer) {
            Universal2DRocketExplorerView(
                rocketName: mission.rocketModel,
                parts: MockData.rocketParts(for: mission.rocketModel),
                accentColor: accentColor
            )
        }
        // full-screen cover: launch replay
        .fullScreenCover(isPresented: $showLaunchReplay) {
            NavigationStack {
                LaunchReplayView(launch: Launch(
                    missionName: mission.name,
                    rocketName: mission.rocketModel,
                    agency: mission.agencyName,
                    agencyAbbr: mission.agencyAbbr,
                    launchDate: Date(),
                    launchSite: mission.launchSiteStr,
                    status: .completed,
                    description: mission.description,
                    trajectory: [],
                    orbitType: mission.orbit,
                    maxAltitude: "",
                    targetDestination: mission.orbit,
                    imageName: mission.imageName
                ))
            }
        }
        //satellite explorer
        .navigationDestination(isPresented: $showSatellite) {
            if let sat = mission.satellite {
                Realistic2DRocketExplorer(
                    rocketName: sat.name,
                    parts: [],
                    accentColor: accentColor
                )
            }
        }
        //article
        .fullScreenCover(isPresented: $showArticle) {
            MissionArticleView(mission: mission)
        }
        // apollo 11 fallback explorer
        .fullScreenCover(isPresented: $showApollo11Explorer) {
            NavigationStack {
                Universal2DRocketExplorerView(
                    rocketName: "Saturn V",
                    parts: MockData.saturnVParts,
                    accentColor: .cyan
                )
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            showApollo11Explorer = false
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.body.weight(.semibold))
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Circle().fill(Color.white.opacity(0.1)))
                        }
                    }
                }
            }
        }
    }

    // hero section

    private var heroSection: some View {
        GeometryReader { geo in
            let minY = geo.frame(in: .global).minY
            let height = max(1, 360 + minY)
            let offset = minY > 0 ? -minY : 0
            let safeWidth = max(geo.size.width, 1)

            ZStack(alignment: .bottomLeading) {
                // background fallback
                Rectangle().fill(accentColor.opacity(0.2))

                // hero image
                if let imageName = mission.imageName {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        // top alignment so the astronaut's head isn't cropped, plus an offset to frame perfectly
                        .frame(width: safeWidth, height: height, alignment: .top)
                        .offset(y: imageName == "apollo11_mission" ? (height > 400 ? -20 : -40) : 0) // dynamic framing based on scroll
                        .clipped()
                        .scaleEffect(minY > 0 ? 1 + (minY / 400) : 1)
                } else {
                    Image(systemName: mission.sfSymbol)
                        .font(.system(size: 100, weight: .bold))
                        .foregroundColor(accentColor.opacity(0.85))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .scaleEffect(minY > 0 ? 1 + (minY / 400) : 1)
                }

                // gradient scrim for text legibility (≥4.5:1 contrast)
                LinearGradient(
                    colors: [.clear, .black.opacity(0.4), .black.opacity(0.9), .black],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // text overlay
                VStack(alignment: .leading, spacing: 8) {
                    statusBadge

                    Text(mission.name)
                        .font(.largeTitle.weight(.heavy))
                        .foregroundColor(.white)
                        .lineLimit(2)

                    Text(mission.agencyName)
                        .font(.headline)
                        .foregroundColor(accentColor)

                    // action buttons — below agency name
                    HStack(spacing: 10) {
                        if has2DExplorer {
                            Button(action: {
                                if isRocketExplorerAvailable {
                                    showRocketExplorer = true
                                } else {
                                    showComingSoonAlert = true
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "cube.fill")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(accentColor)
                                    Text("Explore Rocket")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    Capsule()
                                        .fill(Color.black.opacity(0.5))
                                        .background(
                                            Capsule()
                                                .fill(.ultraThinMaterial)
                                        )
                                )
                                .overlay(
                                    Capsule()
                                        .strokeBorder(
                                            LinearGradient(
                                                colors: [accentColor.opacity(0.6), accentColor.opacity(0.15)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1.5
                                        )
                                )
                                .clipShape(Capsule())
                                .shadow(color: accentColor.opacity(0.4), radius: 12, x: 0, y: 4)
                            }
                            .accessibilityLabel("Rocket Explorer")
                            .accessibilityHint("Opens a 2-D interactive view of the rocket")
                            .alert("Available Soon", isPresented: $showComingSoonAlert) {
                                Button("View Apollo 11 Instead") {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        showApollo11Explorer = true
                                    }
                                }
                                Button("OK", role: .cancel) { }
                            } message: {
                                Text("The 3D rocket explorer for \(mission.name) is currently in development. Would you like to view the Apollo 11 rocket instead?")
                            }
                        }

                        if mission.status == .completed {
                            Button(action: { showLaunchReplay = true }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(accentColor)
                                    Text("Launch Replay")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    Capsule()
                                        .fill(Color.black.opacity(0.5))
                                        .background(
                                            Capsule()
                                                .fill(.ultraThinMaterial)
                                        )
                                )
                                .overlay(
                                    Capsule()
                                        .strokeBorder(
                                            LinearGradient(
                                                colors: [accentColor.opacity(0.6), accentColor.opacity(0.15)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1.5
                                        )
                                )
                                .clipShape(Capsule())
                                .shadow(color: accentColor.opacity(0.4), radius: 12, x: 0, y: 4)
                            }
                            .accessibilityLabel("Launch Replay")
                            .accessibilityHint("Opens a full-screen launch replay animation")
                        }
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .frame(width: geo.size.width, height: height)
            .offset(y: offset)
        }
        .frame(height: 360)
    }

    // mission meta strip

    private var missionMetaStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                missionChip(icon: "calendar", text: mission.date)
                missionChip(icon: "mappin.and.ellipse", text: mission.launchSiteStr)
                missionChip(icon: "sparkles", text: mission.orbit)
            }
        }
    }

    // quick stats

    private var quickStats: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                statCard(
                    title: "Status",
                    value: mission.status == .completed ? "Success" : mission.status.rawValue.capitalized,
                    icon: "checkmark.seal.fill",
                    tint: mission.status == .completed ? SpaceTheme.successGreen : accentColor
                )
                statCard(title: "Duration", value: mission.duration, icon: "clock.fill", tint: accentColor)
                statCard(title: "Rocket", value: mission.rocketModel, icon: "rocket.fill", tint: accentColor)
            }
        }
    }

    // overview section

    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Mission Overview")

            Text(mission.description)
                .font(.body)
                .foregroundColor(.secondary)
                .lineSpacing(4)
        }
    }

    // timeline section

    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Flight Timeline")

            VStack(spacing: 0) {
                ForEach(Array(mission.missionPhases.enumerated()), id: \.element.id) { idx, phase in
                    HStack(alignment: .top, spacing: 16) {
                        // timeline connector
                        VStack(spacing: 0) {
                            Circle()
                                .fill(Color.accentColor)
                                .frame(width: 10, height: 10)

                            if idx < mission.missionPhases.count - 1 {
                                Rectangle()
                                    .fill(Color.accentColor.opacity(0.3))
                                    .frame(width: 2)
                                    .padding(.vertical, 4)
                            }
                        }

                        // phase content
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Label(phase.name, systemImage: phase.icon)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Spacer()
                                // date pill
                                Text(phase.day)
                                    .font(.caption2.weight(.bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.accentColor, in: Capsule())
                            }

                            Text(phase.description)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineSpacing(2)
                                .padding(.bottom, idx < mission.missionPhases.count - 1 ? 24 : 0)
                        }
                    }
                    .accessibilityElement(children: .combine)
                }
            }
        }
    }

    // key facts section

    private var keyFactsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Key Highlights")

            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(mission.keyFacts.enumerated()), id: \.offset) { index, fact in
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text("\(index + 1).")
                            .font(.headline)
                            .foregroundColor(.accentColor)
                            .frame(width: 24, alignment: .trailing)

                        Text(fact)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineSpacing(2)
                    }
                    .accessibilityElement(children: .combine)
                }
            }
        }
    }

    // crew section

    private var crewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Crew")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 20) {
                    ForEach(mission.crew, id: \.self) { member in
                        Button(action: {
                            selectedCrewMember = member
                            showCrewSheet = true
                        }) {
                            VStack(spacing: 12) {
                                if let imageName = crewImageName(for: member) {
                                    Image(imageName)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .clipShape(Circle())
                                } else {
                                    Circle()
                                        .fill(Color(.tertiarySystemFill))
                                        .frame(width: 80, height: 80)
                                        .overlay(
                                            Image(systemName: "person.fill")
                                                .font(.title2)
                                                .foregroundColor(accentColor)
                                        )
                                }

                                Text(member)
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.center)
                                    .frame(width: 90)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(member)
                        .accessibilityHint("View crew member details")
                    }
                }
            }
        }
        .sheet(item: Binding(
            get: { selectedCrewMember.map { CrewItem(id: $0) } },
            set: { selectedCrewMember = $0?.id }
        )) { item in
            crewDetailSheet(member: item.id)
        }
    }

    // payload explorer button

    private func payloadExplorerButton(satellite: SatellitePart) -> some View {
        Button(action: { showSatellite = true }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.15))
                        .frame(width: 48, height: 48)
                    Image(systemName: "satellite.fill")
                        .font(.title3.bold())
                        .foregroundColor(accentColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Explore Payload")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text("\(satellite.name)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.body.weight(.semibold))
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
    }

    // reusable components

    private func missionChip(icon: String, text: String) -> some View {
        Label(text, systemImage: icon)
            .font(.caption.weight(.semibold))
            .foregroundColor(.primary)
            .lineLimit(1)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.secondarySystemBackground), in: Capsule())
            .accessibilityElement(children: .combine)
    }

    private func statCard(title: String, value: String, icon: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title.uppercased(), systemImage: icon)
                .font(.caption.weight(.semibold))
                .foregroundColor(tint)
                .symbolRenderingMode(.hierarchical)

            Text(value)
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(2)
                .minimumScaleFactor(0.85)

            Capsule()
                .fill(tint)
                .frame(width: 32, height: 3)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(12)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .accessibilityElement(children: .combine)
    }

    private func sectionHeader(_ label: String) -> some View {
        Text(label)
            .font(.title2.bold())
            .foregroundColor(.primary)
    }

    private var statusBadge: some View {
        let color: Color = {
            switch mission.status {
            case .completed: return SpaceTheme.successGreen
            case .active:    return Color.accentColor
            case .upcoming:  return Color.accentColor
            }
        }()

        return Text(mission.status.rawValue.uppercased())
            .font(.caption2.weight(.bold))
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.15), in: Capsule())
    }

    // crew helpers

    private func crewImageName(for member: String) -> String? {
        let name = member.lowercased()
        if name.contains("armstrong") { return "neil_armstrong" }
        if name.contains("aldrin") { return "buzz_aldrin" }
        if name.contains("collins") { return "michael_collins" }
        return nil
    }

    private func crewBio(for member: String) -> String {
        let name = member.lowercased()
        if name.contains("armstrong") {
            return "Neil Armstrong was an American astronaut and the first person to walk on the Moon. He served as commander of the Apollo 11 mission."
        }
        if name.contains("aldrin") {
            return "Buzz Aldrin is an American former astronaut, engineer, and fighter pilot. He made three spacewalks as pilot of the 1966 Gemini 12 mission, and was the lunar module pilot on the 1969 Apollo 11 mission, becoming the second person to walk on the Moon."
        }
        if name.contains("collins") {
            return "Michael Collins was an American astronaut who flew the Apollo 11 command module Columbia around the Moon while his crewmates Neil Armstrong and Buzz Aldrin made the first crewed landing on the surface."
        }
        return "Crew member of the \(mission.name) mission. Their contributions have brought humanity one step closer to the stars."
    }

    private func crewDetailSheet(member: String) -> some View {
        NavigationStack {
            VStack(spacing: 24) {
                if let imageName = crewImageName(for: member) {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(accentColor, lineWidth: 2))
                } else {
                    Circle()
                        .fill(Color(.tertiarySystemFill))
                        .frame(width: 120, height: 120)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.largeTitle)
                                .foregroundColor(accentColor)
                        )
                }

                Text(member)
                    .font(.title2.weight(.bold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)

                Text(crewBio(for: member))
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 16)

                Spacer()
            }
            .padding(.top, 40)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        selectedCrewMember = nil
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

struct CrewItem: Identifiable {
    let id: String
}
