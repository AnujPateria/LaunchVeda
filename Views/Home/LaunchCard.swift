import SwiftUI

struct LaunchCard: View {
    let launch: Launch
    @State private var now = Date()

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var launchDateText: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: launch.launchDate)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // agency badge
            HStack(spacing: 6) {
                Circle()
                    .fill(agencyColor)
                    .frame(width: 8, height: 8)

                Text(launch.agencyAbbr)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(agencyColor)
                    .textCase(.uppercase)
                    .tracking(1)

                Spacer()

                statusBadge
            }

            // mission name
            Text(launch.missionName)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)




            Spacer()

            // countdown
            VStack(alignment: .leading, spacing: 6) {
                Text("T-MINUS")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(SpaceTheme.subtleGray)
                    .tracking(2)

                countdownView
            }

            // launch site
            HStack(spacing: 4) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 10))
                    .foregroundColor(SpaceTheme.subtleGray.opacity(0.7))

                Text(launch.launchSite.components(separatedBy: ",").first ?? launch.launchSite)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(SpaceTheme.subtleGray.opacity(0.7))
                    .lineLimit(1)
            }
        }
        
        .padding(16)
        .frame(width: 260, height: 320)
        .background(
            Group {
                if let imageName = launch.resolvedImageName {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 260, height: 320)
                        .overlay(
                            LinearGradient(
                                colors: [Color.black.opacity(0.15), Color.black.opacity(0.45), Color.black.opacity(0.72)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                } else {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(
                            LinearGradient(
                                colors: [agencyColor.opacity(0.3), Color.black.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            Image(systemName: "rocket.fill")
                                .font(.system(size: 46, weight: .bold))
                                .foregroundColor(.white.opacity(0.18))
                        )
                }
            }
        )
        .contentShape(Rectangle()) // ensures the entire card area is clickable
        .onReceive(timer) { self.now = $0 }
    }

    // countdown
    private var countdownView: some View {
        let diff = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: now, to: launch.launchDate)
        let days = max(diff.day ?? 0, 0)
        let hours = max(diff.hour ?? 0, 0)
        let minutes = max(diff.minute ?? 0, 0)
        let seconds = max(diff.second ?? 0, 0)

        return HStack(spacing: 6) {
            countdownUnit(value: days, label: "D")
            countdownSeparator
            countdownUnit(value: hours, label: "H")
            countdownSeparator
            countdownUnit(value: minutes, label: "M")
            countdownSeparator
            countdownUnit(value: seconds, label: "S")
        }
    }

    private func countdownUnit(value: Int, label: String) -> some View {
        VStack(spacing: 2) {
            Text(String(format: "%02d", value))
                .font(.system(size: 14, weight: .bold, design: .monospaced)) // slimmer font
                .foregroundColor(.white)

            Text(label)
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(SpaceTheme.subtleGray)
        }
    }

    private var countdownSeparator: some View {
        Text(":")
            .font(.system(size: 12, weight: .bold, design: .monospaced)) // proportionally slimmer
            .foregroundColor(SpaceTheme.subtleGray.opacity(0.5))
            .offset(y: -4)
    }

    private func infoChip(icon: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 8, weight: .bold))
            Text(text)
                .lineLimit(1)
        }
        .font(.system(size: 9, weight: .semibold))
        .foregroundColor(.white.opacity(0.82))
        .padding(.horizontal, 7)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.12))
                .overlay(Capsule().strokeBorder(Color.white.opacity(0.18), lineWidth: 0.5))
        )
    }

    // status badge
    private var statusBadge: some View {
        Text(launch.status.rawValue)
            .font(.system(size: 9, weight: .bold))
            .foregroundColor(statusColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(statusColor.opacity(0.15))
                    .overlay(Capsule().strokeBorder(statusColor.opacity(0.3), lineWidth: 0.5))
            )
    }

    private var agencyColor: Color {
        SpaceTheme.electricBlue
    }

    private var statusColor: Color {
        switch launch.status {
        case .upcoming: return SpaceTheme.electricBlue
        case .live: return .red
        case .completed: return SpaceTheme.successGreen
        }
    }
}
