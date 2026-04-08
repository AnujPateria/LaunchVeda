import SwiftUI

struct AllMissionsView: View {
    var body: some View {
        ZStack {
            StarFieldBackground()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("\(MockData.allMissions.count) Historical & Featured Missions")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(SpaceTheme.subtleGray)
                        .padding(.top, 4)

                    ForEach(MockData.allMissions) { mission in
                        NavigationLink(value: mission) {
                            MissionListRow(mission: mission)
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
        .navigationTitle("Featured Missions")
#if os(iOS)
        .navigationBarTitleDisplayMode(.large)
#endif
    }
}
