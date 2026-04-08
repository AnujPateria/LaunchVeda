import SwiftUI

struct LaunchDetailView: View {
    let launch: Launch
    @State private var now = Date()
    @State private var showRocketAnatomy = false
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {

                // hero image — no GeometryReader, fixed height, fully clipped
                ZStack(alignment: .bottomLeading) {
                    if let imageName = launch.resolvedImageName {
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 400)
                            .clipped()
                            .allowsHitTesting(false)
                    } else {
                        Rectangle()
                            .fill(agencyColor.opacity(0.15))
                            .frame(height: 320)
                        Image(systemName: "rocket")
                            .font(.system(size: 80))
                            .foregroundColor(agencyColor.opacity(0.6))
                    }

                    // scrim
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.4), .black.opacity(0.95)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 320)

                    // text overlay
                    VStack(alignment: .leading, spacing: 8) {
                        statusBadge

                        Text(launch.missionName)
                            .font(.title.weight(.heavy))
                            .foregroundColor(.white)
                            .lineLimit(2)

                        HStack(spacing: 6) {
                            Text(launch.agencyAbbr)
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(agencyColor)
                            Text("•")
                                .foregroundColor(.white.opacity(0.4))
                            Text(launch.rocketName.uppercased())
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 400)
                .clipped()

                // content below hero
                VStack(alignment: .leading, spacing: 32) {

                    // countdown
                    if launch.launchDate > now {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 8) {
                                Image(systemName: "timer")
                                    .foregroundColor(agencyColor)
                                Text("T-MINUS COUNTDOWN")
                                    .font(.caption.weight(.bold))
                                    .foregroundColor(.secondary)
                                    .tracking(1.0)
                            }

                            HStack(spacing: 0) {
                                countdownBlock(value: days, label: "DAYS")
                                separatorView
                                countdownBlock(value: hours, label: "HRS")
                                separatorView
                                countdownBlock(value: minutes, label: "MIN")
                                separatorView
                                countdownBlock(value: seconds, label: "SEC")
                            }
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }

                    // about
                    VStack(alignment: .leading, spacing: 12) {
                        Text("About This Mission")
                            .font(.title3.bold())
                        Text(launch.description)
                            .font(.body)
                            .foregroundColor(.primary.opacity(0.85))
                            .lineSpacing(4)
                    }

                    // launch overview
                    if !launch.missionOverview.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 8) {
                                Image(systemName: "list.bullet.clipboard")
                                    .font(.headline)
                                    .foregroundColor(agencyColor)
                                Text("Launch Overview")
                                    .font(.title3.bold())
                            }
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(Array(launch.missionOverview.enumerated()), id: \.offset) { index, objective in
                                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                                        Text("\(index + 1).")
                                            .font(.subheadline.bold())
                                            .foregroundColor(agencyColor)
                                            .frame(width: 24, alignment: .trailing)
                                        Text(objective)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                            }
                        }
                    }

                    // mission details
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Mission Details")
                            .font(.title3.bold())

                        VStack(spacing: 12) {
                            detailRow(icon: "building.2.fill", label: "Agency", value: launch.agency)
                            detailRow(icon: "mappin.circle.fill", label: "Launch Site", value: launch.launchSite)
                            detailRow(icon: "calendar.circle.fill", label: "Launch Date", value: formattedDate)
                            detailRow(icon: "clock.badge.checkmark.fill", label: "Local Time", value: formattedLocalDateTime)
                        }
                        .padding(16)
                        .background(Color(white: 0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    // explore rocket anatomy
                    Button(action: { showRocketAnatomy = true }) {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(agencyColor.opacity(0.15))
                                    .frame(width: 48, height: 48)
                                Image(systemName: "list.bullet.below.rectangle")
                                    .font(.system(size: 20))
                                    .foregroundColor(agencyColor)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Explore Rocket Anatomy")
                                    .font(.headline)
                                Text("\(launch.rocketName) internals")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .padding(16)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(PressScaleButtonStyle())

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .ignoresSafeArea(edges: .top)
        .navigationTitle(launch.missionName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
        .onReceive(timer) { self.now = $0 }
        .navigationDestination(isPresented: $showRocketAnatomy) {
            RocketAnatomyView(accentColor: agencyColor)
        }
    }

    // helpers

    private func detailRow(icon: String, label: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(agencyColor)
                .frame(width: 24, alignment: .center)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption.weight(.medium))
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
    }

    private func countdownBlock(value: Int, label: String) -> some View {
        VStack(spacing: 2) {
            Text(String(format: "%02d", value))
                .font(.title2.weight(.bold).monospacedDigit())
                .foregroundColor(.primary)
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var separatorView: some View {
        Text(":")
            .font(.title2.weight(.bold).monospacedDigit())
            .foregroundColor(.secondary)
            .offset(y: -8)
    }

    // countdown
    private var components: DateComponents {
        Calendar.current.dateComponents([.day, .hour, .minute, .second], from: now, to: launch.launchDate)
    }
    private var days: Int    { max(components.day    ?? 0, 0) }
    private var hours: Int   { max(components.hour   ?? 0, 0) }
    private var minutes: Int { max(components.minute ?? 0, 0) }
    private var seconds: Int { max(components.second ?? 0, 0) }

    private var formattedDate: String {
        let f = DateFormatter()
        f.dateStyle = .long
        f.timeZone = TimeZone(identifier: "UTC")
        return f.string(from: launch.launchDate)
    }

    private var formattedLocalDateTime: String {
        let f = DateFormatter()
        f.dateStyle = .long
        f.timeStyle = .short
        f.timeZone = .current
        return f.string(from: launch.launchDate)
    }

    private var agencyColor: Color { SpaceTheme.electricBlue }

    private var statusBadge: some View {
        let color: Color = {
            switch launch.status {
            case .upcoming:  return SpaceTheme.electricBlue
            case .live:      return .red
            case .completed: return SpaceTheme.successGreen
            }
        }()
        return Text(launch.status.rawValue.uppercased())
            .font(.caption2.weight(.bold))
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Capsule().fill(color.opacity(0.15)))
    }
}
