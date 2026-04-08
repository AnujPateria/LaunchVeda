import SwiftUI

enum AuthorityLevel: String, Codable {
    case high = "HIGH"
    case medium = "MEDIUM"
    case low = "LOW"

    var color: Color {
        switch self {
        case .high: return .red
        case .medium: return .orange
        case .low: return .yellow
        }
    }
}

struct Billet: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let icon: String // sf symbol name
    let controls: [String] // systems
    let activePhases: [String] // "launch", "orbit", "landing"
    let authority: AuthorityLevel
    let reportsTo: String
    let handlesFailures: [String]
}
