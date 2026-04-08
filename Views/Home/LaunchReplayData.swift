import Foundation
import SwiftUI

// stage event (when a stage separates, ignites, or is jettisoned)
struct StageEvent: Identifiable, Hashable {
    let id = UUID()
    let time: Double          // seconds after liftoff
    let altitude: Double      // km
    let stageName: String
    let eventType: EventType

    enum EventType: String, Hashable {
        case ignition = "Ignition"
        case separation = "Separation"
        case jettison = "Jettison"
        case deployment = "Deployment"
        case landing = "Landing"
    }

    var icon: String {
        switch eventType {
        case .ignition:   return "flame.fill"
        case .separation: return "arrow.up.and.down.circle.fill"
        case .jettison:   return "arrow.down.right.circle.fill"
        case .deployment: return "satellite.fill"
        case .landing:    return "checkmark.seal.fill"
        }
    }

    var color: Color {
        switch eventType {
        case .ignition:   return .orange
        case .separation: return .cyan
        case .jettison:   return .yellow
        case .deployment: return .green
        case .landing:    return .mint
        }
    }
}

// trajectory point (3d position along flight path)
struct TrajectoryPoint {
    let time: Double        // seconds
    let x: Float            // downrange (km)
    let y: Float            // altitude (km)
    let z: Float            // cross-range (km)
    let velocity: Double    // km/h
    let activeStages: [String]  // names of stages still attached
}

// launch flight profile generator
struct FlightProfileGenerator {

    /// generate trajectory points for a given rocket and launch
    static func generateProfile(rocketName: String, trajectory: [TrajectoryPhase], stageEvents: [StageEvent]) -> [TrajectoryPoint] {
        let totalTime: Double = 600  // ~10 min
        let steps = 360              // high resolution for smooth curves
        let dt = totalTime / Double(steps)

        var points: [TrajectoryPoint] = []
        let stages = RocketStageData.stages(for: rocketName).map { $0.name }

        for i in 0...steps {
            let t = Double(i) * dt
            let phase = t / totalTime
            var alt: Float = 0.0
            var downrange: Float = 0.0
            var vel: Double = 0.0

            // ── continuous trajectory with hermite-blended transitions ──
            if phase < 0.03 {
                // vertical liftoff: mostly up, slight downrange
                let p = phase / 0.03
                let s = smoothstep(p)  // smooth ease-in
                alt = Float(s * 15.0)
                downrange = Float(s * 1.5)
                vel = s * 1200.0

            } else if phase < 0.25 {
                // gravity turn: smooth pitch-over using sin/cos curves
                let p = (phase - 0.03) / 0.22
                let s = smoothstep(p)
                let angle = s * (.pi / 2.0) * 0.85  // max ~76 degrees pitch
                alt = Float(15.0 + sin(angle) * 75.0)       // 15→90 km
                downrange = Float(1.5 + (1.0 - cos(angle)) * 120.0)  // 1.5→121.5 km
                vel = 1200.0 + s * 7800.0                    // →9000 km/h

            } else if phase < 0.45 {
                // first stage burnout / second stage: steeper climb
                let p = (phase - 0.25) / 0.20
                let s = smoothstep(p)
                alt = Float(90.0 + s * 130.0)               // 90→220 km
                downrange = Float(121.5 + s * 350.0)          // 121.5→471.5 km
                vel = 9000.0 + s * 15500.0                    // →24500 km/h

            } else if phase < 0.75 {
                // s-ivb / upper stage: approaching orbital altitude
                let p = (phase - 0.45) / 0.30
                let s = smoothstep(p)
                let altCurve = sin(s * (.pi / 2.0))
                alt = Float(220.0 + altCurve * 60.0)          // 220→280 km
                let drCurve = 1.0 - cos(s * (.pi / 2.0))
                downrange = Float(471.5 + Float(drCurve) * 900.0)   // 471.5→1371.5 km
                vel = 24500.0 + s * 3200.0                    // →27700 km/h

            } else {
                // orbital insertion: nearly horizontal
                let p = (phase - 0.75) / 0.25
                let s = smoothstep(p)
                alt = Float(280.0 + s * 20.0)                 // 280→300 km (parking orbit)
                downrange = Float(1371.5 + s * 1300.0)          // 1371.5→2671.5 km
                vel = 27700.0 + s * 200.0                     // →27900 km/h
            }

            // active stages
            let separatedStageNames = stageEvents
                .filter { $0.time <= t && ($0.eventType == .separation || $0.eventType == .jettison) }
                .map { $0.stageName }
            let activeStages = stages.filter { !separatedStageNames.contains($0) }

            points.append(TrajectoryPoint(
                time: t, x: downrange, y: alt, z: 0,
                velocity: vel, activeStages: activeStages
            ))
        }

        return points
    }

    /// hermite smoothstep for c¹-continuous transitions (no sharp corners)
    private static func smoothstep(_ t: Double) -> Double {
        let x = max(0, min(1, t))
        return x * x * (3 - 2 * x)
    }
}

// default stage events per rocket
extension StageEvent {
    static func events(for rocketName: String) -> [StageEvent] {
        if rocketName.contains("Falcon") { return falcon9Events() }
        if rocketName.contains("LVM")    { return lvm3Events() }
        if rocketName.contains("SLS")    { return slsEvents() }
        if rocketName.contains("Saturn") { return saturnVEvents() }
        if rocketName.contains("Ariane") { return ariane5Events() }
        if rocketName.contains("H-II")   { return hiiaEvents() }
        if rocketName.contains("Atlas")  { return atlasVEvents() }
        if rocketName.contains("PSLV")   { return pslvEvents() }
        return genericEvents()
    }

    static func falcon9Events() -> [StageEvent] {[
        StageEvent(time: 0, altitude: 0, stageName: "Falcon 9 First Stage", eventType: .ignition),
        StageEvent(time: 159, altitude: 68, stageName: "Falcon 9 First Stage", eventType: .separation),
        StageEvent(time: 161, altitude: 70, stageName: "Second Stage + Interstage", eventType: .ignition),
        StageEvent(time: 210, altitude: 115, stageName: "Payload Fairing", eventType: .jettison),
        StageEvent(time: 540, altitude: 340, stageName: "Payload Fairing", eventType: .deployment),
    ]}

    static func lvm3Events() -> [StageEvent] {[
        StageEvent(time: 0, altitude: 0, stageName: "S200 Solid Strap-ons", eventType: .ignition),
        StageEvent(time: 128, altitude: 52, stageName: "S200 Solid Strap-ons", eventType: .separation),
        StageEvent(time: 130, altitude: 55, stageName: "L110 Core Stage", eventType: .ignition),
        StageEvent(time: 310, altitude: 125, stageName: "L110 Core Stage", eventType: .separation),
        StageEvent(time: 312, altitude: 127, stageName: "C25 Cryo Upper Stage", eventType: .ignition),
        StageEvent(time: 240, altitude: 115, stageName: "Payload Fairing", eventType: .jettison),
        StageEvent(time: 955, altitude: 180, stageName: "C25 Cryo Upper Stage", eventType: .separation),
    ]}

    static func slsEvents() -> [StageEvent] {[
        StageEvent(time: 0, altitude: 0, stageName: "Core Stage + 2 SRBs", eventType: .ignition),
        StageEvent(time: 126, altitude: 48, stageName: "Core Stage + 2 SRBs", eventType: .separation),
        StageEvent(time: 480, altitude: 160, stageName: "Core Stage + 2 SRBs", eventType: .separation),
        StageEvent(time: 482, altitude: 162, stageName: "ICPS Upper Stage", eventType: .ignition),
        StageEvent(time: 7200, altitude: 185, stageName: "ICPS Upper Stage", eventType: .separation),
    ]}

    static func saturnVEvents() -> [StageEvent] {[
        // real apollo 11 timeline (july 16, 1969)
        StageEvent(time: 0,   altitude: 0,   stageName: "S-IC First Stage", eventType: .ignition),
        StageEvent(time: 135, altitude: 56,  stageName: "Inboard Engine Cutoff", eventType: .jettison),
        StageEvent(time: 150, altitude: 62,  stageName: "S-IC First Stage", eventType: .separation),
        StageEvent(time: 152, altitude: 62,  stageName: "S-II Second Stage", eventType: .ignition),
        StageEvent(time: 192, altitude: 92,  stageName: "Launch Escape System", eventType: .jettison),
        StageEvent(time: 540, altitude: 175, stageName: "S-II Second Stage", eventType: .separation),
        StageEvent(time: 542, altitude: 176, stageName: "S-IVB Third Stage", eventType: .ignition),
        StageEvent(time: 700, altitude: 191, stageName: "S-IVB Third Stage", eventType: .separation),
    ]}

    static func ariane5Events() -> [StageEvent] {[
        StageEvent(time: 0, altitude: 0, stageName: "EPC Core + 2 EAP", eventType: .ignition),
        StageEvent(time: 132, altitude: 58, stageName: "EPC Core + 2 EAP", eventType: .separation),
        StageEvent(time: 589, altitude: 170, stageName: "EPC Core + 2 EAP", eventType: .separation),
        StageEvent(time: 591, altitude: 172, stageName: "ESC-A Upper Stage", eventType: .ignition),
        StageEvent(time: 210, altitude: 110, stageName: "Dual-Launch Fairing", eventType: .jettison),
    ]}

    static func hiiaEvents() -> [StageEvent] {[
        StageEvent(time: 0, altitude: 0, stageName: "First Stage + 2 SRB-A", eventType: .ignition),
        StageEvent(time: 100, altitude: 38, stageName: "First Stage + 2 SRB-A", eventType: .separation),
        StageEvent(time: 392, altitude: 210, stageName: "First Stage + 2 SRB-A", eventType: .separation),
        StageEvent(time: 394, altitude: 212, stageName: "Second Stage (LE-5B)", eventType: .ignition),
    ]}

    static func atlasVEvents() -> [StageEvent] {[
        StageEvent(time: 0, altitude: 0, stageName: "CCB + 4 SRBs", eventType: .ignition),
        StageEvent(time: 94, altitude: 35, stageName: "CCB + 4 SRBs", eventType: .separation),
        StageEvent(time: 253, altitude: 100, stageName: "Payload Fairing", eventType: .jettison),
        StageEvent(time: 277, altitude: 120, stageName: "CCB + 4 SRBs", eventType: .separation),
        StageEvent(time: 279, altitude: 122, stageName: "Centaur Upper Stage", eventType: .ignition),
    ]}

    static func pslvEvents() -> [StageEvent] {[
        StageEvent(time: 0, altitude: 0, stageName: "PS1 + 6 PSOM-XL", eventType: .ignition),
        StageEvent(time: 103, altitude: 30, stageName: "PS1 + 6 PSOM-XL", eventType: .separation),
        StageEvent(time: 105, altitude: 32, stageName: "PS2 Second Stage", eventType: .ignition),
        StageEvent(time: 263, altitude: 120, stageName: "PS2 Second Stage", eventType: .separation),
        StageEvent(time: 265, altitude: 122, stageName: "PS3 + PS4", eventType: .ignition),
    ]}

    static func genericEvents() -> [StageEvent] {[
        StageEvent(time: 0, altitude: 0, stageName: "First Stage", eventType: .ignition),
        StageEvent(time: 160, altitude: 70, stageName: "First Stage", eventType: .separation),
        StageEvent(time: 162, altitude: 72, stageName: "Upper Stage", eventType: .ignition),
        StageEvent(time: 540, altitude: 200, stageName: "Upper Stage", eventType: .separation),
    ]}
}
