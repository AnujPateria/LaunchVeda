import SwiftUI

struct HomeView: View {
    @State private var showCalendar = false
    @State private var now = Date()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    // only the first 2 launches are shown as real cards
    private var visibleLaunches: [Launch] {
        Array(MockData.launches.prefix(2))
    }

    // remaining count shown as coming soon
    private var comingSoonCount: Int {
        max(MockData.launches.count - 2, 0)
    }

    private var featuredMissions: [Mission] {
        let all = MockData.allMissions
        var selected: [Mission] = []

        if let apollo = all.first(where: { $0.name.localizedCaseInsensitiveContains("Apollo 11") }) {
            selected.append(apollo)
        }
        
        if let chandrayaan = all.first(where: { $0.name.localizedCaseInsensitiveContains("Chandrayaan-2") }) {
            selected.append(chandrayaan)
        }

        return selected
    }

    var body: some View {
        NavigationStack {
            ZStack {
                StarFieldBackground()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {

                        // recent missions
                        sectionHeader(
                            title: "Featured Missions",
                            color: SpaceTheme.electricBlue,
                            destination: "allMissions"
                        )
                        recentMissionsSection
                        

                        
                        
                        // space organisations
                        sectionHeader(
                            title: "Organisations",
                            color: SpaceTheme.electricBlue,
                            destination: "allOrganisations"
                        )
                        organisationsSection
                        
                        // upcoming launches
                        sectionHeader(
                            title: "Launches",
                            color: SpaceTheme.electricBlue,
                            destination: "allLaunches"
                        )
                        upcomingLaunchesSection

                        

                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }
            }
            .background(Color.black.ignoresSafeArea())
            .preferredColorScheme(.dark)
            .navigationTitle("LaunchVeda")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showCalendar = true } label: {
                        Image(systemName: "calendar")
                            .font(.body.weight(.semibold))
                            .foregroundColor(SpaceTheme.electricBlue)
                    }
                    .accessibilityLabel("Open space calendar")
                    .accessibilityHint("Shows historic and upcoming space events")
                }
            }
            .sheet(isPresented: $showCalendar) {
                SpaceCalendarView()
                    .presentationDetents([.fraction(0.75), .large])
                    .presentationDragIndicator(.visible)
            }
            // navigate to a specific launch detail
            .navigationDestination(for: Launch.self) { launch in
                LaunchDetailView(launch: launch)
            }
            // navigate to all launches list
            .navigationDestination(for: String.self) { route in
                switch route {
                case "allLaunches":
                    AllLaunchesView()
                case "allOrganisations":
                    AllOrganisationsView()
                case "allMissions":
                    AllMissionsView()
                default:
                    EmptyView()
                }
            }
            // navigate to organization detail
            .navigationDestination(for: SpaceOrg.self) { org in
                OrganizationDetailView(org: org)
            }
            // navigate to mission detail
            .navigationDestination(for: Mission.self) { mission in
                MissionDetailView(mission: mission)
            }
        }
    }
    
    // section header
    private func sectionHeader(title: String, color: Color, destination: String?) -> some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.title2.weight(.bold))
                .foregroundColor(.primary)

            if let destination = destination {
                NavigationLink(value: destination) {
                    Image(systemName: "chevron.right")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(color)
                }
            }

            Spacer()
        }
    }

    // upcoming launches (vertical list — same style as missions)
    private var upcomingLaunchesSection: some View {
        VStack(spacing: 14) {
            ForEach(visibleLaunches) { launch in
                NavigationLink(value: launch) {
                    LaunchListRow(launch: launch, now: now)
                }
                .buttonStyle(PressScaleButtonStyle())
            }
        }
        .onReceive(timer) { self.now = $0 }
    }

    // recent missions (horizontal scroll — same style as launches)
    private var recentMissionsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(featuredMissions) { mission in
                    NavigationLink(value: mission) {
                        MissionCard(mission: mission)
                    }
                    .buttonStyle(PressScaleButtonStyle())
                }
            }
            .padding(.vertical, 4)
            .padding(.leading, 16)
            .padding(.trailing, 16)
        }
        .padding(.horizontal, -16)
    }

    // organisations (horizontal scroll)
    private var organisationsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(SpaceOrg.allOrgs) { org in
                    NavigationLink(value: org) {
                        OrgBadge(org: org)
                    }
                }
            }
            .padding(.vertical, 4)
            .padding(.leading, 16)
            .padding(.trailing, 16)
        }
        .padding(.horizontal, -16)
    }
}

// org badge (tappable)
struct OrgBadge: View {
    let org: SpaceOrg
    @State private var isPressed = false

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(org.color.opacity(isPressed ? 0.18 : 0.08))
                    .overlay(Circle().strokeBorder(Color.white.opacity(0.1), lineWidth: 1))
                
                Image(org.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
            }
            .frame(width: 72, height: 72)
            .clipShape(Circle())
            .overlay(Circle().strokeBorder(org.color.opacity(0.35), lineWidth: 1.2))
            .shadow(color: org.color.opacity(0.15), radius: 8)

            Text(org.abbr)
                .font(.caption.weight(.bold))
                .foregroundColor(.primary.opacity(0.85))
        }
        .frame(width: 80)
        .scaleEffect(isPressed ? 0.92 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isPressed)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}
