import SwiftUI

struct AllLaunchesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var now = Date()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            StarFieldBackground()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("\(MockData.launches.count) Launches Scheduled")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(SpaceTheme.subtleGray)
                        .padding(.top, 4)

                    ForEach(MockData.launches) { launch in
                        NavigationLink(value: launch) {
                            LaunchListRow(launch: launch, now: now)
                        }
                        .buttonStyle(PressScaleButtonStyle())
                    }

                    Spacer(minLength: 80)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
        }
        .preferredColorScheme(.dark)
        .navigationTitle("Launches")
#if os(iOS)
        .navigationBarTitleDisplayMode(.large)
#endif
        .navigationDestination(for: Launch.self) { launch in
            LaunchDetailView(launch: launch)
        }
        .onReceive(timer) { self.now = $0 }
    }
}

// launch list row
struct LaunchListRow: View {
    let launch: Launch
    let now: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 16) {
                // thumbnail
                Group {
                    if let imageName = launch.resolvedImageName {
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                    } else {
                        ZStack {
                            LinearGradient(
                                colors: [agencyColor.opacity(0.35), Color.black.opacity(0.5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            Image(systemName: "rocket.fill")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                }
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
                )

                // launch details
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        Text(launch.missionName)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .lineLimit(1)

                        Spacer()

                        countdownLabel

                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(SpaceTheme.subtleGray.opacity(0.5))
                            .padding(.leading, 4)
                            .padding(.top, 4)
                    }

                    Text(launch.description)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(SpaceTheme.subtleGray)
                        .lineLimit(2)
                        .lineSpacing(2)

                    HStack(spacing: 8) {
                        Text(launch.agencyAbbr.uppercased())
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(agencyColor)

                        Circle()
                            .fill(SpaceTheme.subtleGray.opacity(0.5))
                            .frame(width: 3, height: 3)

                        Text(launch.rocketName)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white.opacity(0.85))
                            .lineLimit(1)
                    }
                    .padding(.top, 2)
                }
            }

            // bottom info chips
            HStack(spacing: 8) {
                // date chip
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 11))
                    Text(launchDateText)
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(SpaceTheme.subtleGray.opacity(0.9))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.06))
                        .overlay(Capsule().strokeBorder(Color.white.opacity(0.1), lineWidth: 0.5))
                )

                // location chip
                HStack(spacing: 6) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 11))
                    Text(launch.launchSite.components(separatedBy: ",").first ?? launch.launchSite)
                        .font(.system(size: 12, weight: .medium))
                        .lineLimit(1)
                }
                .foregroundColor(SpaceTheme.subtleGray.opacity(0.9))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.06))
                        .overlay(Capsule().strokeBorder(Color.white.opacity(0.1), lineWidth: 0.5))
                )
            }
        }
        .padding(16)
        .glassCard(cornerRadius: 24)
    }

    private var launchDateText: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: launch.launchDate)
    }

    private var countdownLabel: some View {
        let label: String = {
            switch launch.status {
            case .completed: return "Done"
            case .live: return "Live"
            case .upcoming:
                let diff = Calendar.current.dateComponents([.day], from: now, to: launch.launchDate)
                let days = max(diff.day ?? 0, 0)
                return "T–\(days)d"
            }
        }()

        return Text(label)
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(agencyColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(agencyColor.opacity(0.15))
                    .overlay(Capsule().strokeBorder(agencyColor.opacity(0.35), lineWidth: 1))
            )
    }

    private var agencyColor: Color {
        SpaceTheme.electricBlue
    }
}

// press scale button style
struct PressScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
