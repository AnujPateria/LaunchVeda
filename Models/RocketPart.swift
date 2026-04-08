import SwiftUI

// rocket spec
struct RocketSpec: Identifiable, Hashable, Sendable {
    let id = UUID()
    let label: String
    let value: String
}

// rocket overview (real-life specs for the info panel)
struct RocketOverview: Sendable {
    let name: String
    let agency: String
    let agencyIcon: String       // sf symbol
    let country: String
    let height: String           // e.g. "110.6 m"
    let diameter: String
    let liftoffMass: String      // e.g. "2,970,000 kg"
    let liftoffThrust: String    // e.g. "35,100 kn"
    let payloadLEO: String
    let payloadGTO: String
    let stages: Int
    let firstFlight: String
    let successRate: String      // e.g. "93%"
    let totalLaunches: String
    let status: String           // "active" / "retired"
    let description: String
}

// rocket part (recursive)
struct RocketPart: Identifiable, Hashable, Sendable {
    let id: String          // stable string id (used as scnnode name too)
    let name: String
    let icon: String
    let description: String
    let colorName: String   // "orange", "blue", "gray", "silver", "gold", "red", "white", "cream"
    let specs: [RocketSpec]
    let subparts: [RocketPart]
    var stageImageName: String? = nil  // optional asset image name for exploded view
    var partImageName: String? = nil   // optional asset image name for detailed component view
    var internalParts: [SatellitePart]? = nil // components inside the skin (tanks, etc.) using geometric shapes
    var controlledBy: [String]? = nil  // billet ids that control this part

    static func == (lhs: RocketPart, rhs: RocketPart) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }

    var uiColor: UIColor {
        switch colorName {
        case "orange":  return UIColor(red: 0.95, green: 0.45, blue: 0.05, alpha: 1)
        case "red":     return UIColor(red: 0.85, green: 0.15, blue: 0.1, alpha: 1)
        case "blue":    return UIColor(red: 0.15, green: 0.55, blue: 0.95, alpha: 1)
        case "gold":    return UIColor(red: 0.9, green: 0.72, blue: 0.2, alpha: 1)
        case "silver":  return UIColor(red: 0.75, green: 0.78, blue: 0.82, alpha: 1)
        case "cream":   return UIColor(red: 0.95, green: 0.93, blue: 0.88, alpha: 1)
        case "darkgray":return UIColor(red: 0.25, green: 0.26, blue: 0.28, alpha: 1)
        case "lightgray": return UIColor(red: 0.88, green: 0.89, blue: 0.9, alpha: 1)
        case "purple":  return UIColor(red: 0.55, green: 0.2, blue: 0.9, alpha: 1)
        default:        return UIColor(red: 0.92, green: 0.93, blue: 0.95, alpha: 1)  // white
        }
    }

    var swiftUIColor: Color {
        switch colorName {
        case "orange":  return .orange
        case "red":     return .red
        case "blue":    return Color(red: 0.15, green: 0.55, blue: 0.95)
        case "gold":    return Color(red: 0.9, green: 0.72, blue: 0.2)
        case "silver":  return Color(red: 0.75, green: 0.78, blue: 0.82)
        case "cream":   return Color(red: 0.95, green: 0.93, blue: 0.88)
        case "darkgray":return Color(red: 0.25, green: 0.26, blue: 0.28)
        case "purple":  return Color(red: 0.55, green: 0.2, blue: 0.9)
        default:        return Color(red: 0.92, green: 0.93, blue: 0.95)
        }
    }
}
