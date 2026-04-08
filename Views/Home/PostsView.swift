import SwiftUI

// saved posts manager
class SavedPostsManager: ObservableObject {
    @Published var savedPostIDs: Set<UUID> = []

    func toggleSave(_ post: SpacePost) {
        if savedPostIDs.contains(post.id) {
            savedPostIDs.remove(post.id)
        } else {
            savedPostIDs.insert(post.id)
        }
    }

    func isSaved(_ post: SpacePost) -> Bool {
        savedPostIDs.contains(post.id)
    }
}

// liked posts manager
class LikedPostsManager: ObservableObject {
    @Published var likedPostIDs: Set<UUID> = []

    func toggleLike(_ post: SpacePost) {
        if likedPostIDs.contains(post.id) {
            likedPostIDs.remove(post.id)
        } else {
            likedPostIDs.insert(post.id)
        }
    }

    func isLiked(_ post: SpacePost) -> Bool {
        likedPostIDs.contains(post.id)
    }
}

// posts view
struct PostsView: View {
    @State private var showView = false
    @State private var searchText = ""
    @State private var selectedPost: SpacePost? = nil
    @State private var showSavedOnly = false
    @StateObject private var savedManager = SavedPostsManager()
    @StateObject private var likedManager = LikedPostsManager()

    private var filteredPosts: [SpacePost] {
        var result = MockPosts.posts
        if showSavedOnly {
            result = result.filter { savedManager.isSaved($0) }
        }
        if searchText.isEmpty { return result }
        let query = searchText.lowercased()
        return result.filter {
            $0.title.lowercased().contains(query) ||
            $0.body.lowercased().contains(query) ||
            $0.organisation.lowercased().contains(query) ||
            $0.orgAbbr.lowercased().contains(query) ||
            $0.category.rawValue.lowercased().contains(query)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                StarFieldBackground()

                ScrollView(.vertical, showsIndicators: true) {
                    if filteredPosts.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: showSavedOnly ? "bookmark.slash" : "magnifyingglass")
                                .font(.largeTitle.weight(.light))
                                .foregroundColor(.secondary.opacity(0.5))

                            Text(showSavedOnly ? "No saved posts yet" : "No results found")
                                .font(.headline)
                                .foregroundColor(.secondary)

                            Text(showSavedOnly ? "Tap the bookmark icon on any post to save it" : "Try a different search term")
                                .font(.footnote)
                                .foregroundColor(.secondary.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 80)
                    } else {
                        LazyVStack(spacing: 18) {
                            ForEach(Array(filteredPosts.enumerated()), id: \.element.id) { index, post in
                                PostCard(
                                    post: post,
                                    savedManager: savedManager,
                                    likedManager: likedManager,
                                    onPostTap: {
                                        selectedPost = post
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                }
            }
            .navigationTitle(showSavedOnly ? "Saved Posts" : "Space Updates")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search posts, agencies, topics...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        withAnimation {
                            showSavedOnly.toggle()
                        }
                    }) {
                        Image(systemName: showSavedOnly ? "bookmark.fill" : "bookmark")
                            .font(.body.weight(.medium))
                            .foregroundColor(showSavedOnly ? SpaceTheme.electricBlue : .secondary)
                            .accessibilityLabel(showSavedOnly ? "Show all posts" : "Show saved posts only")
                    }
                }
            }
            .navigationDestination(for: SpaceOrg.self) { org in
                OrganizationDetailView(org: org)
            }
        }
        
        .sheet(item: $selectedPost) { post in
            PostDetailView(post: post, savedManager: savedManager, likedManager: likedManager)
        }
    }
}

struct SpacePost: Identifiable, Equatable {
    let id = UUID()
    let organisation: String
    let orgAbbr: String
    let timestamp: String
    let title: String
    let body: String
    let category: PostCategory
    var likes: Int
    let comments: Int
    let sfSymbol: String
    let imageName: String?
    let fullContent: String

    var orgImageName: String {
        switch orgAbbr {
        case "ISRO": return "isro_logo"
        case "SpaceX": return "spacex_logo"
        case "NASA": return "nasa_logo"
        case "ESA": return "esa_logo"
        default: return ""
        }
    }

    static func == (lhs: SpacePost, rhs: SpacePost) -> Bool {
        lhs.id == rhs.id
    }
}

enum PostCategory: String {
    case event = "Event"
    case launch = "Launch"
    case discovery = "Discovery"
    case announcement = "Announcement"
    case milestone = "Milestone"
}

struct PostCard: View {
    let post: SpacePost
    @ObservedObject var savedManager: SavedPostsManager
    @ObservedObject var likedManager: LikedPostsManager
    var onPostTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // org header — navigates to organizationdetailview
            if let org = SpaceOrg.allOrgs.first(where: { $0.abbr == post.orgAbbr }) {
                NavigationLink(value: org) {
                    orgHeaderContent
                }
                .buttonStyle(.plain)
            } else {
                orgHeaderContent
            }
            
            Button(action: onPostTap) {
                VStack(alignment: .leading, spacing: 14) {
                    // post title
                    Text(post.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // post body (truncated)
                    Text(post.body)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                        .lineLimit(3)
                    
                    // image area
                    if let img = post.imageName {
                        Image(img)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 180)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .contentShape(RoundedRectangle(cornerRadius: 14))
                    } else {
                        ZStack {
                            Image(systemName: post.sfSymbol)
                                .font(.system(size: 36, weight: .light))
                                .foregroundColor(orgColor.opacity(0.4))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 120)
                        .glassCard(cornerRadius: 14)
                    }
                }
            }
            .buttonStyle(.plain)
            .contentShape(Rectangle())
            
            // interaction bar
            HStack {
                HStack(spacing: 24) {
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            likedManager.toggleLike(post)
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: likedManager.isLiked(post) ? "heart.fill" : "heart")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(likedManager.isLiked(post) ? .red : .secondary)
                                .scaleEffect(likedManager.isLiked(post) ? 1.2 : 1.0)
                            
                            Text("\(post.likes + (likedManager.isLiked(post) ? 1 : 0))")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(likedManager.isLiked(post) ? .red : .secondary)
                        }
                        .contentShape(Rectangle())
                    }
                    .accessibilityLabel("Like, \(post.likes + (likedManager.isLiked(post) ? 1 : 0)) likes")
                    
                    Button(action: {
                        // action for commenting on the post
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "bubble.right")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.secondary)
                            Text("\(post.comments)")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                        .contentShape(Rectangle())
                    }
                }
                
                Spacer()
                
                HStack(spacing: 24) {
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            savedManager.toggleSave(post)
                        }
                    }) {
                        Image(systemName: savedManager.isSaved(post) ? "bookmark.fill" : "bookmark")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(savedManager.isSaved(post) ? SpaceTheme.electricBlue : .secondary.opacity(0.8))
                            .scaleEffect(savedManager.isSaved(post) ? 1.15 : 1.0)
                            .contentShape(Rectangle())
                    }
                    .accessibilityLabel(savedManager.isSaved(post) ? "Remove bookmark" : "Bookmark post")
                    
                    Button(action: {
                        // action for sharing the post
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.secondary.opacity(0.8))
                            .contentShape(Rectangle())
                    }
                    .accessibilityLabel("Share post")
                }
            }
            .padding(.top, 4)
        }
        .padding(18)
        .glassCard(cornerRadius: 30)
    }
        
    private var orgHeaderContent: some View {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(0.4))
                        .frame(width: 40, height: 40)
                        .background(
                            Circle().fill(.ultraThinMaterial)
                        )
                        .overlay(Circle().strokeBorder(Color.white.opacity(0.15), lineWidth: 1))
                        .clipShape(Circle())
                        
                    
                    if !post.orgImageName.isEmpty {
                        Image(post.orgImageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(orgColor)
                            .clipShape(Circle())
                    } else {
                        Text(String(post.orgAbbr.prefix(2)))
                            .font(.footnote.weight(.bold))
                            .foregroundColor(orgColor)
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.organisation)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.primary)
                    
                    Text(post.timestamp)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(post.category.rawValue)
                    .font(.caption2.weight(.bold))
                    .foregroundColor(categoryColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .glassCapsule()
            }
        }
        
        private var orgColor: Color {
            SpaceTheme.electricBlue
        }
        
        private var categoryColor: Color {
            switch post.category {
            case .event: return SpaceTheme.electricBlue
            case .launch: return SpaceTheme.electricBlue
            case .discovery: return SpaceTheme.successGreen
            case .announcement: return SpaceTheme.electricBlue
            case .milestone: return Color(red: 1.0, green: 0.84, blue: 0.0)
            }
        }
    }
    
    // post detail view (full screen sheet)
    struct PostDetailView: View {
        let post: SpacePost
        @ObservedObject var savedManager: SavedPostsManager
        @ObservedObject var likedManager: LikedPostsManager
        @Environment(\.dismiss) private var dismiss
        
        var body: some View {
            NavigationStack {
                ZStack {
                    Color(.systemGroupedBackground).ignoresSafeArea()
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 20) {
                            
                            // category + timestamp
                            HStack(spacing: 10) {
                                Text(post.category.rawValue.uppercased())
                                    .font(.system(size: 11, weight: .bold))
                                    .tracking(1.5)
                                    .foregroundColor(detailAccentColor)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 5)
                                    .glassCapsule()
                                
                                Text(post.timestamp)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(SpaceTheme.subtleGray)
                            }
                            
                            // title
                            Text(post.title)
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            // organisation banner (display only)
                            orgBanner
                            
                            // hero image area
                            if let img = post.imageName {
                                Image(img)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 240)
                                    .clipShape(RoundedRectangle(cornerRadius: 18))
                                    .contentShape(RoundedRectangle(cornerRadius: 18))
                            } else {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(
                                            LinearGradient(
                                                colors: [detailOrgColor.opacity(0.12), detailOrgColor.opacity(0.04)],
                                                startPoint: .topLeading, endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(height: 200)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 18)
                                                .strokeBorder(detailOrgColor.opacity(0.15), lineWidth: 1)
                                        )
                                    
                                    Image(systemName: post.sfSymbol)
                                        .font(.system(size: 60, weight: .light))
                                        .foregroundColor(detailOrgColor.opacity(0.35))
                                }
                            }
                            
                            // full content
                            Text(post.fullContent)
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(.secondary)
                                .lineSpacing(6)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Divider()
                            
                            // stats row
                            HStack(spacing: 0) {
                                let isLiked = likedManager.isLiked(post)
                                statItem(icon: isLiked ? "heart.fill" : "heart", value: "\(post.likes + (isLiked ? 1 : 0))", label: "Likes", color: isLiked ? .red : SpaceTheme.electricBlue)
                                Spacer()
                                statItem(icon: "bubble.right.fill", value: "\(post.comments)", label: "Comments", color: SpaceTheme.electricBlue)
                                Spacer()
                                statItem(icon: "eye.fill", value: "\(post.likes * 3)", label: "Views", color: SpaceTheme.electricBlue)
                            }
                            .padding(16)
                            .glassCard(cornerRadius: 16)
                            
                            // action buttons
                            HStack(spacing: 12) {
                                // save button
                                Button(action: {
                                    withAnimation(.spring(response: 0.3)) {
                                        savedManager.toggleSave(post)
                                    }
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: savedManager.isSaved(post) ? "bookmark.fill" : "bookmark")
                                            .font(.system(size: 15, weight: .semibold))
                                        Text(savedManager.isSaved(post) ? "Saved" : "Save Post")
                                            .font(.system(size: 14, weight: .semibold))
                                    }
                                    .foregroundColor(savedManager.isSaved(post) ? SpaceTheme.electricBlue : .primary)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(savedManager.isSaved(post) ? SpaceTheme.electricBlue.opacity(0.15) : Color(.secondarySystemFill))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 14)
                                                    .strokeBorder(savedManager.isSaved(post) ? SpaceTheme.electricBlue.opacity(0.3) : Color(.separator), lineWidth: 1)
                                            )
                                    )
                                }
                                
                                // share
                                Button(action: {}) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "square.and.arrow.up")
                                            .font(.system(size: 15, weight: .semibold))
                                        Text("Share")
                                            .font(.system(size: 14, weight: .semibold))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(SpaceTheme.electricBlue)
                                    )
                                    .shadow(color: SpaceTheme.electricBlue.opacity(0.3), radius: 10, y: 4)
                                }
                            }
                            
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .navigationTitle("Update")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
            }
        }
        
        private var orgBanner: some View {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(detailOrgColor.opacity(0.15))
                        .frame(width: 48, height: 48)
                        .overlay(Circle().strokeBorder(detailOrgColor.opacity(0.3), lineWidth: 1))
                    
                    if !post.orgImageName.isEmpty {
                        Image(post.orgImageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 28)
                            .foregroundColor(detailOrgColor)
                            .clipShape(Circle())
                    } else {
                        Text(String(post.orgAbbr.prefix(2)))
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(detailOrgColor)
                    }
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(post.organisation)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("Official Account")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(SpaceTheme.subtleGray)
                }
                
                Spacer()
            }
            .padding(14)
            .glassCard(cornerRadius: 16)
        }
        
        private func statItem(icon: String, value: String, label: String, color: Color) -> some View {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
                Text(value)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(SpaceTheme.subtleGray)
            }
            .frame(maxWidth: .infinity)
        }
        
        private var detailOrgColor: Color {
            SpaceTheme.electricBlue
        }
        
        private var detailAccentColor: Color {
            switch post.category {
            case .event: return SpaceTheme.electricBlue
            case .launch: return SpaceTheme.electricBlue
            case .discovery: return SpaceTheme.successGreen
            case .announcement: return SpaceTheme.electricBlue
            case .milestone: return Color(red: 1.0, green: 0.84, blue: 0.0)
            }
        }
    }
    
    // mock posts
    struct MockPosts {
        static let posts: [SpacePost] = [
            SpacePost(
                organisation: "Indian Space Research Organisation",
                orgAbbr: "ISRO",
                timestamp: "2 hours ago",
                title: "🚀 Chandrayaan-4 Launch Window Confirmed",
                body: "ISRO has officially confirmed the launch window for Chandrayaan-4, India's ambitious lunar sample return mission.",
                category: .launch,
                likes: 2847,
                comments: 312,
                sfSymbol: "moon.fill",
                imageName: "chandrayaan4",
                fullContent: "ISRO has officially confirmed the launch window for Chandrayaan-4, India's ambitious lunar sample return mission. The spacecraft will launch aboard the LVM3 (GSLV Mk III) rocket from the Satish Dhawan Space Centre at Sriharikota.\n\nThe Chandrayaan-4 mission aims to achieve what no Indian mission has done before — collecting lunar soil samples and returning them safely to Earth. The mission architecture involves a complex multi-module spacecraft:\n\n• Propulsion Module — provides orbital transfer from Earth to Moon\n• Lander Module — achieves soft landing near the lunar south pole\n• Ascent Module — launches from the lunar surface with collected samples\n• Transfer Module — carries samples from lunar orbit back to Earth\n• Re-entry Capsule — safely delivers samples to Earth's surface\n\nThis mission will place India among an elite group of nations that have successfully returned samples from the Moon, alongside the USA, Soviet Union, and China."
            ),
            SpacePost(
                organisation: "National Aeronautics and Space Administration",
                orgAbbr: "NASA",
                timestamp: "5 hours ago",
                title: "🔭 James Webb Captures New Exoplanet Atmosphere",
                body: "JWST has detected water vapour and carbon dioxide in the atmosphere of a super-Earth orbiting a nearby star.",
                category: .discovery,
                likes: 5621,
                comments: 489,
                sfSymbol: "sparkles",
                imageName: "jwst",
                fullContent: "The James Webb Space Telescope has made another groundbreaking discovery — detecting water vapour and carbon dioxide in the atmosphere of a super-Earth orbiting a nearby red dwarf star, just 40 light-years from our solar system.\n\nThe planet, designated TOI-7134 b, is roughly 1.6 times the size of Earth and orbits within the habitable zone of its host star. Using JWST's Near-Infrared Spectrograph (NIRSpec), scientists were able to identify distinct spectral signatures of:\n\n• Water Vapour (H₂O) — indicating possible surface water or active water cycle\n• Carbon Dioxide (CO₂) — suggesting a substantial atmosphere\n• Methane (CH₄) — a potential biosignature when combined with CO₂\n\nThis marks the first time all three molecules have been confirmed in a single exoplanet atmosphere in the habitable zone. While not definitive proof of life, this combination closely mirrors Earth's atmospheric composition, making TOI-7134 b one of the most promising candidates for further study."
            ),
            SpacePost(
                organisation: "Space Exploration Technologies",
                orgAbbr: "SpaceX",
                timestamp: "8 hours ago",
                title: "🛰️ Starlink Gen3 Satellite Deployment Event",
                body: "Join us live for the deployment of 60 next-gen Starlink satellites from Cape Canaveral.",
                category: .event,
                likes: 3104,
                comments: 276,
                sfSymbol: "antenna.radiowaves.left.and.right.circle.fill",
                imageName: "starlink_satellite",
                fullContent: "SpaceX is preparing for the deployment of 60 next-generation Starlink V2 Mini satellites aboard a Falcon 9 Block 5 rocket from Space Launch Complex 40 at Cape Canaveral Space Force Station.\n\nThis mission will mark the 15th flight for this particular Falcon 9 first-stage booster, setting a new record for booster reuse. The booster will attempt its landing on the autonomous drone ship 'Of Course I Still Love You' positioned in the Atlantic Ocean.\n\nMission Timeline:\n• T-45 min: SpaceX webcast begins\n• T-0: Liftoff\n• T+2:33: First stage main engine cutoff (MECO)\n• T+2:37: Stage separation\n• T+8:20: First stage landing\n• T+15:25: Second engine cutoff (SECO)\n• T+62:00: Starlink satellite deployment begins\n\nThe Gen3 Starlink satellites feature enhanced throughput speeds up to 4x faster than previous generations, improved laser inter-satellite links for global mesh coverage, and reduced orbital altitude for lower latency."
            ),
            SpacePost(
                organisation: "European Space Agency",
                orgAbbr: "ESA",
                timestamp: "1 day ago",
                title: "🌍 Copernicus Sentinel-6B Ready for Launch",
                body: "ESA's next Earth observation satellite will continue monitoring global sea-level rise with unprecedented accuracy.",
                category: .announcement,
                likes: 1893,
                comments: 145,
                sfSymbol: "globe.europe.africa.fill",
                imageName: "ariane5", // added this image for the esa post
                fullContent: "The European Space Agency's Copernicus Sentinel-6B satellite has completed all pre-launch testing and is now in final integration at the Vandenberg Space Force Base launch facility.\n\nSentinel-6B will join its predecessor Sentinel-6A (Michael Freilich) in orbit to form a tandem mission providing the most accurate measurements of sea-level change ever recorded from space.\n\nKey Capabilities:\n• Poseidon-4 Radar Altimeter — measures sea surface height with millimetre-level precision\n• AMR-C Microwave Radiometer — corrects for atmospheric water vapour interference\n• GNSS-RO Receiver — provides atmospheric temperature and humidity profiles\n• DORIS System — enables precise orbit determination\n\nSea levels are currently rising at approximately 3.7mm per year — double the rate observed in the 1990s. Sentinel-6B's data will be critical for understanding how climate change affects ocean dynamics, coastal communities, and global weather patterns."
            ),
            SpacePost(
                organisation: "Indian Space Research Organisation",
                orgAbbr: "ISRO",
                timestamp: "2 days ago",
                title: "🎉 Gaganyaan Crew Module Test Successful",
                body: "ISRO completed the crew module atmospheric re-entry test, paving the way for India's first crewed spaceflight.",
                category: .milestone,
                likes: 4210,
                comments: 567,
                sfSymbol: "person.3.fill",
                imageName: "gaganyaan",
                fullContent: "In a historic milestone for India's human spaceflight programme, ISRO has successfully completed a full-scale atmospheric re-entry test of the Gaganyaan crew module.\n\nThe unmanned crew module was launched to an altitude of 17 km aboard a single-stage test vehicle, then separated and re-entered Earth's atmosphere at near-orbital velocities. Key systems that were validated:\n\n• Thermal Protection System (TPS) — carbon-phenolic heat shield withstood temperatures exceeding 1,600°C during re-entry\n• Parachute Deployment Sequence — drogue chutes deployed at 15 km, followed by three main parachutes at 5 km altitude\n• Splashdown and Recovery — the module landed safely in the Bay of Bengal, within 500 metres of the planned impact point\n• Life Support Systems — cabin pressure, oxygen levels, and CO₂ scrubbing operated within nominal parameters throughout\n\nThe Gaganyaan mission, planned to launch in 2026, will carry three Indian astronauts (Vyomanauts) aboard the LVM3-G1 rocket for a 7-day mission in low Earth orbit at approximately 400 km altitude. India will become the fourth nation to independently launch humans into space."
            )
        ]
    }

