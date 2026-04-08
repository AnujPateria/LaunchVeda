import SwiftUI

struct AllOrganisationsView: View {
    var body: some View {
        ZStack {
            StarFieldBackground()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("\(SpaceOrg.allOrgs.count) Space Organisations")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(SpaceTheme.subtleGray)
                        .padding(.top, 4)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(SpaceOrg.allOrgs) { org in
                            NavigationLink(value: org) {
                                OrganisationCard(org: org)
                            }
                            .buttonStyle(PressScaleButtonStyle())
                        }
                    }

                    Spacer(minLength: 80)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
        }
        .preferredColorScheme(.dark)
        .navigationTitle("Organisations")
#if os(iOS)
        .navigationBarTitleDisplayMode(.large)
#endif
    }
}

// organisation card
struct OrganisationCard: View {
    let org: SpaceOrg

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(org.color.opacity(0.15))
                
                Image(org.imageName)
                    .resizable()
                    .scaledToFit()
                    .padding(14)
            }
            .frame(width: 80, height: 80)
            .clipShape(Circle())
            .overlay(Circle().strokeBorder(org.color.opacity(0.3), lineWidth: 1))

            VStack(spacing: 4) {
                Text(org.abbr)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(org.name)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.65))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(height: 30)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .glassCard(cornerRadius: 20)
    }
}
