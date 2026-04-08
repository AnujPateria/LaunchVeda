
import SwiftUI

struct OrganizationDetailView: View {
    let org: SpaceOrg

    @Environment(\.accessibilityReduceMotion) private var reduceMotion


    private var allMissions: [Mission] { org.orgMissions }
    private var completedCount: Int { allMissions.filter { $0.status == .completed }.count }
    private var activeCount: Int { allMissions.filter { $0.status == .active }.count }
    private var upcomingCount: Int { allMissions.filter { $0.status == .upcoming }.count }
    private var trackedLaunchCount: Int { org.orgLaunches.count }

    private var activeFleet: [String] {
        let fromOrg = org.activeRockets
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        if !fromOrg.isEmpty { return fromOrg }
        return Array(Set(allMissions.map(\.rocketModel))).sorted()
    }

    private var focusAreas: [String] {
        var areas: [String] = []
        if allMissions.contains(where: {
            $0.orbit.localizedCaseInsensitiveContains("lunar") ||
            $0.name.localizedCaseInsensitiveContains("chandrayaan") ||
            $0.name.localizedCaseInsensitiveContains("apollo")
        }) { areas.append("Lunar Exploration") }

        if allMissions.contains(where: {
            $0.orbit.localizedCaseInsensitiveContains("mars") ||
            $0.name.localizedCaseInsensitiveContains("mars")
        }) { areas.append("Mars and Planetary Science") }

        if allMissions.contains(where: {
            !$0.crew.isEmpty || $0.name.localizedCaseInsensitiveContains("crew")
        }) { areas.append("Human Spaceflight") }

        if allMissions.contains(where: {
            $0.orbit.localizedCaseInsensitiveContains("earth") ||
            $0.orbit.localizedCaseInsensitiveContains("leo") ||
            $0.orbit.localizedCaseInsensitiveContains("iss")
        }) { areas.append("Earth-Orbit Operations") }

        if areas.isEmpty { areas.append("Orbital Missions") }
        return areas
    }

    private var snapshotItems: [OrgInsight] {
        [
            OrgInsight(icon: "calendar", title: "Founded", value: org.founded),
            OrgInsight(icon: "mappin.and.ellipse", title: "Headquarters", value: org.headquarters),
            OrgInsight(icon: "person.crop.circle", title: "Leadership", value: org.director),
            OrgInsight(icon: "target", title: "Mission Success", value: org.successRate)
        ]
    }

    private var showcasePrograms: [Mission] {
        let priority: [MissionStatus: Int] = [.active: 0, .upcoming: 1, .completed: 2]
        return allMissions.sorted { lhs, rhs in
            let l = priority[lhs.status] ?? 3
            let r = priority[rhs.status] ?? 3
            if l != r { return l < r }
            return yearValue(from: lhs.date) > yearValue(from: rhs.date)
        }
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 0) {
                agencyHeroHeader

                agencyIdentity
                    .padding(.horizontal, 16)
                    .padding(.top, -30)
                    .zIndex(1)

                VStack(alignment: .leading, spacing: 24) {

                    Divider().padding(.vertical, 8)
                    aboutSection

                    Divider()
                    agencySnapshotGrid

                    Divider()
                    missionIntelSection

                    if !activeFleet.isEmpty {
                        Divider()
                        fleetSection
                    }

                    focusSection

                    if !org.notableAchievements.isEmpty {
                        Divider()
                        achievementsSection
                    }

                    if !allMissions.isEmpty {
                        Divider()
                        programsSection
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 16)
            }
        }
        .background(Color(.systemBackground))
        .ignoresSafeArea(edges: .top)
        .navigationTitle(org.abbr)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    // hero header

    private var agencyHeroHeader: some View {
        GeometryReader { geo in
            let minY = geo.frame(in: .global).minY
            let baseHeight: CGFloat = 280
            let dynamicHeight = max(baseHeight, baseHeight + minY)
            let safeWidth = max(geo.size.width, 1)
            let yOffset = minY > 0 ? -minY : 0
            // parallax: scale 1.05 → 1.0 as user scrolls
            let scrollProgress = min(max(-minY / 200, 0), 1)
            let imageScale = reduceMotion ? 1.0 : (1.05 - 0.05 * scrollProgress)
            // overlay fade: 0.45 → 0.0
            let overlayOpacity = reduceMotion ? 0.3 : (0.45 - 0.45 * scrollProgress)

            ZStack(alignment: .bottomLeading) {
                Image(org.heroImageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: safeWidth, height: dynamicHeight)
                    .scaleEffect(imageScale)
                    .clipped()
                    .offset(y: yOffset)
                    .accessibilityHidden(true)

                // scrim gradient for text contrast (≥4.5:1)
                LinearGradient(
                    colors: [.clear, .black.opacity(0.5), .black.opacity(0.85)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                .opacity(1.0 - overlayOpacity)
                .frame(height: dynamicHeight)
                .offset(y: yOffset)
            }
        }
        .frame(height: 280)
    }

    // avatar + identity

    private var agencyIdentity: some View {
        VStack(alignment: .leading, spacing: 12) {
            // circular avatar with 6pt white border
            AgencyAvatarView(imageName: org.imageName, orgName: org.name)

            VStack(alignment: .leading, spacing: 4) {
                // agency.title
                Text(org.name)
                    .font(.largeTitle.weight(.heavy))
                    .foregroundColor(.primary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)

                // agency.location
                Text("\(org.abbr) · \(org.headquarters)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // about section

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About") // agency.about.title
                .font(.title2.bold())
                .foregroundColor(.primary)

            Text(org.overview) // agency.about
                .font(.body)
                .foregroundColor(.secondary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // agency snapshot grid

    private var agencySnapshotGrid: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Agency Snapshot") // agency.snapshot.title
                .font(.title2.bold())
                .foregroundColor(.primary)

            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)],
                spacing: 16
            ) {
                ForEach(snapshotItems) { item in
                    InfoItemView(item: item, accentColor: org.color)
                }
            }
        }
    }

    // mission intelligence

    private var missionIntelSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Mission Intelligence") // agency.intel.title
                .font(.title2.bold())
                .foregroundColor(.primary)

            HStack(spacing: 12) {
                MetricCardView(
                    value: "\(completedCount)",
                    label: "Completed",
                    icon: "checkmark.seal.fill",
                    tint: SpaceTheme.successGreen
                )
                MetricCardView(
                    value: "\(activeCount)",
                    label: "Active",
                    icon: "bolt.fill",
                    tint: Color.accentColor
                )
                MetricCardView(
                    value: "\(upcomingCount)",
                    label: "Upcoming",
                    icon: "calendar",
                    tint: Color.orange
                )
            }

            Text("Historical launches: \(org.totalLaunches)+")
                .font(.footnote)
                .foregroundColor(.secondary)
                .padding(.top, 4)
        }
    }

    // fleet section

    private var fleetSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Operational Fleet") // agency.fleet.title
                .font(.title2.bold())
                .foregroundColor(.primary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(activeFleet, id: \.self) { rocket in
                        Text(rocket)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                Color(.secondarySystemBackground),
                                in: Capsule()
                            )
                    }
                }
            }
        }
    }

    // focus section

    private var focusSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Exploration Focus")
                .font(.title2.bold())
                .foregroundColor(.primary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(focusAreas, id: \.self) { focus in
                        Label(focus, systemImage: "star.fill")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                Color(.tertiarySystemFill),
                                in: Capsule()
                            )
                    }
                }
            }
        }
    }

    // achievements

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Major Achievements") // agency.achievements.title
                .font(.title2.bold())
                .foregroundColor(.primary)

            VStack(alignment: .leading, spacing: 16) {
                ForEach(Array(org.notableAchievements.enumerated()), id: \.offset) { index, text in
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.body)
                            .foregroundColor(org.color)
                            .frame(width: 24, alignment: .center)

                        Text(text)
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

    // programs

    private var programsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Key Programs")
                .font(.title2.bold())
                .foregroundColor(.primary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(showcasePrograms.prefix(5)) { mission in
                        NavigationLink(value: mission) {
                            ProgramCardView(mission: mission)
                        }
                    }
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 2)
            }
        }
    }

    // helpers

    private func yearValue(from text: String) -> Int {
        guard let range = text.range(of: #"\b(19|20)\d{2}\b"#, options: .regularExpression) else { return 0 }
        return Int(text[range]) ?? 0
    }
}

// agencyavatarview

private struct AgencyAvatarView: View {
    let imageName: String
    let orgName: String

    @State private var isPressed = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .padding(10)
            .frame(width: 76, height: 76)
            .background(Color(.systemBackground))
            .clipShape(Circle())
            .overlay(Circle().strokeBorder(.white, lineWidth: 6))
            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            .scaleEffect(isPressed && !reduceMotion ? 0.96 : 1.0)
            .onTapGesture {
                // light haptic on tap
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()

                guard !reduceMotion else { return }
                withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                    isPressed = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                        isPressed = false
                    }
                }
            }
            .accessibilityLabel("\(orgName) logo")
            .accessibilityAddTraits(.isImage)
    }
}

// infoitemview
private struct InfoItemView: View {
    let item: OrgInsight
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // icon + label row
            Label {
                Text(item.title.uppercased())
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(.secondary)
            } icon: {
                Image(systemName: item.icon)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(accentColor)
                    .symbolRenderingMode(.hierarchical)
            }

            // value
            Text(item.value)
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .frame(height: 80)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.title): \(item.value)")
    }
}

// metriccardview

private struct MetricCardView: View {
    let value: String
    let label: String
    let icon: String
    let tint: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.weight(.bold))
                .foregroundColor(tint)

            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2.weight(.bold))
                    .foregroundColor(tint)
                Text(label)
                    .font(.caption.weight(.medium))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }
}

// programcardview
private struct ProgramCardView: View {
    let mission: Mission

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // mission image
            if let img = mission.imageName {
                Image(img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 240, height: 140, alignment: .top)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color(.tertiarySystemFill))
                    .frame(width: 240, height: 140)
                    .overlay(
                        Image(systemName: mission.sfSymbol)
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                    )
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(mission.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)

                Text("\(mission.date) · \(mission.rocketModel)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                // status badge
                Text(statusLabel(mission.status))
                    .font(.caption2.weight(.bold))
                    .foregroundColor(statusColor(mission.status))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        statusColor(mission.status).opacity(0.12),
                        in: Capsule()
                    )
                    .padding(.top, 2)
            }
            .padding(14)
        }
        .frame(width: 240)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .combine)
    }

    private func statusLabel(_ status: MissionStatus) -> String {
        switch status {
        case .completed: return "Completed"
        case .active: return "Active"
        case .upcoming: return "Upcoming"
        }
    }

    private func statusColor(_ status: MissionStatus) -> Color {
        switch status {
        case .completed: return SpaceTheme.successGreen
        case .active: return Color.accentColor
        case .upcoming: return Color.orange
        }
    }
}

// data model

private struct OrgInsight: Identifiable {
    let id = UUID()
    let icon: String   // sf symbol name
    let title: String  // caption label
    let value: String  // headline value
}
