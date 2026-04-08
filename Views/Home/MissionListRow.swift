import SwiftUI

struct MissionListRow: View {
    let mission: Mission

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 16) {
                // thumbnail
                if let imageName = mission.imageName {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 72, height: 72)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
                        )
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(SpaceTheme.electricBlue.opacity(0.12))
                            .frame(width: 72, height: 72)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .strokeBorder(SpaceTheme.electricBlue.opacity(0.2), lineWidth: 1)
                            )
                        
                        Image(systemName: mission.sfSymbol)
                            .font(.system(size: 28, weight: .medium))
                            .foregroundColor(SpaceTheme.electricBlue)
                    }
                }
                
                // mission details
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        Text(mission.name)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        // time badge (e.g. t-2d) or status
                        HStack(spacing: 4) {
                            Text(mission.status == .upcoming ? "T-" : "")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(SpaceTheme.electricBlue)
                            Text(shortTimeBadge)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(SpaceTheme.electricBlue)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(SpaceTheme.electricBlue.opacity(0.15))
                                .overlay(Capsule().strokeBorder(SpaceTheme.electricBlue.opacity(0.35), lineWidth: 1))
                        )
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(SpaceTheme.subtleGray.opacity(0.5))
                            .padding(.leading, 4)
                            .padding(.top, 4)
                    }
                    
                    HStack(spacing: 8) {
                        Text(mission.agencyAbbr.uppercased())
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(SpaceTheme.electricBlue)
                        
                        Circle()
                            .fill(SpaceTheme.subtleGray.opacity(0.5))
                            .frame(width: 3, height: 3)
                        
                        Text(mission.rocketModel)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white.opacity(0.85))
                    }
                    .padding(.top, 4)
                }
            }
            
            // bottom info chips
            HStack(spacing: 8) {
                // date chip
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 11))
                    Text(mission.date)
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
            }
        }
        .padding(16)
        .glassCard(cornerRadius: 24)
    }
    
    // quick helper for dummy time badges like "2d" shown in the user's mockup
    private var shortTimeBadge: String {
        switch mission.status {
        case .upcoming: return "2d" // mocking the exact ui shown in screenshot
        case .active: return "LIVE"
        case .completed: return "Completed"
        }
    }
}
