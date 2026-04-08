import Foundation

// mission status
enum MissionStatus: String, CaseIterable {
    case active = "Active"
    case completed = "Completed"
    case upcoming = "Upcoming"
}

// mission phase (timeline event for a mission)
struct MissionPhase: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let day: String
    let description: String
    let icon: String
}

// mission
struct Mission: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let date: String
    let description: String
    let status: MissionStatus
    let agencyName: String
    let agencyAbbr: String
    let sfSymbol: String
    let imageName: String? // added for custom mission images

    // new enrichment fields
    let rocketModel: String
    let crew: [String]
    let duration: String
    let orbit: String
    let launchSiteStr: String
    let keyFacts: [String]
    let missionPhases: [MissionPhase]
    var satellite: SatellitePart? // root part of the payload/satellite hierarchy

    static func == (lhs: Mission, rhs: Mission) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
