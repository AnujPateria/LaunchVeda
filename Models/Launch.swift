import Foundation

enum LaunchStatus: String, CaseIterable {
    case upcoming = "Upcoming"
    case live = "Live"
    case completed = "Completed"
}

struct TrajectoryPhase: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let altitude: String
    let velocity: String
    let duration: String
    let icon: String
}

struct Launch: Identifiable, Hashable {
    let id = UUID()
    let missionName: String
    let rocketName: String
    let agency: String
    let agencyAbbr: String
    let launchDate: Date
    let launchSite: String
    let status: LaunchStatus
    let description: String
    let trajectory: [TrajectoryPhase]
    let orbitType: String
    let maxAltitude: String
    let targetDestination: String
    let imageName: String?
    var missionOverview: [String] = []
}

extension Launch {
    var resolvedImageName: String? {
        switch imageName {
        case "starlink_upcoming": return "starlink_satellite"
        case "chandrayaan4_upcoming": return "chandrayaan4"
        case "starship_upcoming": return "starship_ift"
        case "artemis3_upcoming": return "artemis3"
        case "gaganyaan_upcoming": return "gaganyaan"
        case let name?: return name
        case nil: break
        }

        let rocket = rocketName.lowercased()
        if rocket.contains("falcon") { return "falcon_9_rocket" }
        if rocket.contains("lvm") || rocket.contains("gslv") { return "lvm3_rocket" }
        if rocket.contains("starship") { return "starship_rocket" }
        if rocket.contains("sls") { return "sls_block1" }
        if rocket.contains("saturn") { return "saturn_v_rocket" }
        if rocket.contains("ariane") { return "ariane5" }
        if rocket.contains("atlas") { return "falcon_9_construction" }
        if rocket.contains("h-iia") || rocket.contains("h2") { return "soyuz" }
        return nil
    }
}
