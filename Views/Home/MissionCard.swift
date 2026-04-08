import SwiftUI

struct MissionCard: View {
    let mission: Mission

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // agency badge
            HStack(spacing: 6) {
                Circle()
                    .fill(agencyColor)
                    .frame(width: 8, height: 8)

                Text(mission.agencyAbbr)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(agencyColor)
                    .textCase(.uppercase)
                    .tracking(1)

                Spacer()

                statusBadge
            }

            // mission name
            Text(mission.name)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()

            // mission details
            VStack(alignment: .leading, spacing: 6) {
                Text(mission.date)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white.opacity(0.9))

                Text(mission.rocketModel)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(SpaceTheme.subtleGray)
            }

            // agency info
            HStack(spacing: 4) {
                Image(systemName: "building.2.fill")
                    .font(.system(size: 10))
                    .foregroundColor(SpaceTheme.subtleGray.opacity(0.7))

                Text(mission.agencyName)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(SpaceTheme.subtleGray.opacity(0.7))
                    .lineLimit(1)
            }
        }
        .padding(16)
        .frame(width: 260, height: 320)
        .background(
            Group {
                if let imageName = mission.imageName {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 260, height: 320, alignment: .top)
                        .offset(y: imageName == "apollo11_mission" ? -30 : 0) // adjusted for apollo 11 framing
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
                            Image(systemName: mission.sfSymbol)
                                .font(.system(size: 46, weight: .bold))
                                .foregroundColor(.white.opacity(0.18))
                        )
                }
            }
        )
        .contentShape(Rectangle())
    }

    // status badge
    private var statusBadge: some View {
        Text(mission.status.rawValue)
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
        switch mission.status {
        case .active: return SpaceTheme.successGreen
        case .completed: return SpaceTheme.electricBlue
        case .upcoming: return SpaceTheme.electricBlue
        }
    }
}
