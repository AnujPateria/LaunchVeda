import SwiftUI

// stage data model
struct RocketStageData: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let specs: [(String, String)]
    let bodyColor: Color
    let highlightColor: Color
    let shadowColor: Color
    let relativeWidth: CGFloat
    let height: CGFloat
    let topCapHeight: CGFloat
    let bottomCapHeight: CGFloat
    let hasCone: Bool
    let hasEngines: Bool
    let engineCount: Int
    let bands: [StageColorBand]

    struct StageColorBand {
        let y: CGFloat
        let height: CGFloat
        let color: Color
    }

    static func stages(for rocketName: String) -> [RocketStageData] {
        if rocketName.contains("Saturn") { return saturnV() }
        if rocketName.contains("Falcon") { return falcon9() }
        if rocketName.contains("LVM")    { return lvm3() }
        if rocketName.contains("PSLV")   { return pslv() }
        if rocketName.contains("SLS")    { return sls() }
        if rocketName.contains("Ariane") { return ariane5() }
        if rocketName.contains("H-II")   { return hiia() }
        if rocketName.contains("Atlas")  { return atlasV() }
        return genericStages()
    }

    static func saturnV() -> [RocketStageData] {[
        RocketStageData(
            name: "S-IC First Stage",
            description: "Powered by 5 Rocketdyne F-1 engines, the most powerful single-chamber engines ever built. Burns RP-1 kerosene and liquid oxygen.",
            specs: [("Engines","5 × F-1"),("Thrust","35,100 kN"),("Propellant","RP-1 / LOX"),("Burn Time","150 s")],
            bodyColor: Color(red:0.87,green:0.88,blue:0.90),
            highlightColor: Color(red:0.96,green:0.97,blue:0.99),
            shadowColor: Color(red:0.56,green:0.58,blue:0.62),
            relativeWidth: 1.0, height: 150, topCapHeight: 12, bottomCapHeight: 36,
            hasCone: false, hasEngines: true, engineCount: 5,
            bands: [
                .init(y:0.18, height:0.10, color:Color.black.opacity(0.88)),
                .init(y:0.42, height:0.035, color:Color.black.opacity(0.82)),
            ]),
        RocketStageData(
            name: "S-II Second Stage",
            description: "Five J-2 engines burning liquid hydrogen and oxygen.",
            specs: [("Engines","5 × J-2"),("Thrust","5,141 kN"),("Propellant","LH₂ / LOX"),("Burn Time","360 s")],
            bodyColor: Color(red:0.84,green:0.85,blue:0.87),
            highlightColor: Color(red:0.94,green:0.94,blue:0.96),
            shadowColor: Color(red:0.54,green:0.56,blue:0.60),
            relativeWidth: 0.92, height: 110, topCapHeight: 10, bottomCapHeight: 28,
            hasCone: false, hasEngines: true, engineCount: 5,
            bands: [.init(y:0.12, height:0.08, color:Color.black.opacity(0.90))]),
        RocketStageData(
            name: "S-IVB Third Stage",
            description: "Single J-2 engine, restarted for trans-lunar injection.",
            specs: [("Engines","1 × J-2"),("Thrust","1,000 kN"),("Propellant","LH₂ / LOX"),("Burn Time","165+335 s")],
            bodyColor: Color(red:0.90,green:0.91,blue:0.93),
            highlightColor: Color(red:0.97,green:0.97,blue:0.98),
            shadowColor: Color(red:0.60,green:0.62,blue:0.66),
            relativeWidth: 0.80, height: 90, topCapHeight: 8, bottomCapHeight: 22,
            hasCone: false, hasEngines: true, engineCount: 1, bands: []),
        RocketStageData(
            name: "Apollo Spacecraft",
            description: "Includes the LM Adapter, Service Module, Command Module and Launch Escape System.",
            specs: [("CM Mass","5,809 kg"),("SM Engine","SPS"),("LM Mass","15,103 kg"),("Crew","3")],
            bodyColor: Color(red:0.88,green:0.88,blue:0.88),
            highlightColor: Color(red:0.97,green:0.97,blue:0.96),
            shadowColor: Color(red:0.60,green:0.60,blue:0.58),
            relativeWidth: 0.65, height: 105, topCapHeight: 50, bottomCapHeight: 14,
            hasCone: true, hasEngines: false, engineCount: 0,
            bands: [.init(y:0.55, height:0.06, color:Color(red:0.80,green:0.68,blue:0.22).opacity(0.60))]),
    ]}

    static func falcon9() -> [RocketStageData] {[
        RocketStageData(
            name: "Falcon 9 First Stage",
            description: "9 Merlin engines in octaweb. Reusable with grid fins and landing legs.",
            specs: [("Engines","9 × Merlin"),("Thrust","7,607 kN"),("Propellant","RP-1 / LOX"),("Reusable","Yes")],
            bodyColor: Color(red:0.93,green:0.94,blue:0.95),
            highlightColor: Color(red:0.99,green:0.99,blue:1.00),
            shadowColor: Color(red:0.63,green:0.65,blue:0.68),
            relativeWidth: 1.0, height: 160, topCapHeight: 10, bottomCapHeight: 32,
            hasCone: false, hasEngines: true, engineCount: 9,
            bands: [
                .init(y:0.14, height:0.020, color:Color(red:0.13,green:0.14,blue:0.17).opacity(0.85)),
                .init(y:0.72, height:0.040, color:Color(red:0.08,green:0.10,blue:0.13).opacity(0.95)),
            ]),
        RocketStageData(
            name: "Second Stage + Interstage",
            description: "One Merlin Vacuum engine with extended nozzle for vacuum efficiency.",
            specs: [("Engine","1 × MVac"),("Thrust","934 kN"),("Propellant","RP-1 / LOX"),("Nozzle","Extended")],
            bodyColor: Color(red:0.92,green:0.93,blue:0.95),
            highlightColor: Color(red:0.98,green:0.98,blue:1.00),
            shadowColor: Color(red:0.62,green:0.64,blue:0.67),
            relativeWidth: 0.95, height: 90, topCapHeight: 8, bottomCapHeight: 26,
            hasCone: false, hasEngines: true, engineCount: 1,
            bands: [.init(y:0.0, height:0.10, color:Color(red:0.16,green:0.18,blue:0.22))]),
        RocketStageData(
            name: "Payload Fairing",
            description: "5.2 m composite fairing protecting payload during ascent.",
            specs: [("Diameter","5.2 m"),("Length","13.1 m"),("Material","CFRP"),("Recovery","Attempted")],
            bodyColor: Color(red:0.94,green:0.95,blue:0.96),
            highlightColor: Color(red:0.99,green:0.99,blue:1.00),
            shadowColor: Color(red:0.65,green:0.67,blue:0.70),
            relativeWidth: 0.93, height: 80, topCapHeight: 55, bottomCapHeight: 8,
            hasCone: true, hasEngines: false, engineCount: 0, bands: []),
    ]}

    static func lvm3() -> [RocketStageData] {[
        RocketStageData(
            name: "S200 Solid Strap-ons",
            description: "Two solid propellant strap-on boosters providing initial thrust.",
            specs: [("Type","Solid"),("Thrust","2 × 5,150 kN"),("Burn Time","128 s"),("Propellant","HTPB")],
            bodyColor: Color(red:0.92,green:0.52,blue:0.11),
            highlightColor: Color(red:0.99,green:0.72,blue:0.35),
            shadowColor: Color(red:0.62,green:0.32,blue:0.04),
            relativeWidth: 1.0, height: 120, topCapHeight: 30, bottomCapHeight: 24,
            hasCone: true, hasEngines: true, engineCount: 2,
            bands: [.init(y:0.72, height:0.06, color:Color.white.opacity(0.80))]),
        RocketStageData(
            name: "L110 Core Stage",
            description: "Liquid core with two Vikas engines using UDMH and N2O4.",
            specs: [("Engines","2 × Vikas"),("Thrust","1,598 kN"),("Propellant","UDMH / NTO"),("Burn Time","203 s")],
            bodyColor: Color(red:0.88,green:0.89,blue:0.92),
            highlightColor: Color(red:0.97,green:0.97,blue:0.99),
            shadowColor: Color(red:0.58,green:0.60,blue:0.63),
            relativeWidth: 0.88, height: 112, topCapHeight: 10, bottomCapHeight: 28,
            hasCone: false, hasEngines: true, engineCount: 2,
            bands: [.init(y:0.76, height:0.08, color:Color(red:0.12,green:0.34,blue:0.80).opacity(0.85))]),
        RocketStageData(
            name: "C25 Cryo Upper Stage",
            description: "Indigenous CE-20 engine burning LH₂/LOX.",
            specs: [("Engine","1 × CE-20"),("Thrust","200 kN"),("Propellant","LH₂ / LOX"),("Burn Time","643 s")],
            bodyColor: Color(red:0.54,green:0.72,blue:0.92),
            highlightColor: Color(red:0.74,green:0.88,blue:0.99),
            shadowColor: Color(red:0.30,green:0.50,blue:0.72),
            relativeWidth: 0.78, height: 88, topCapHeight: 8, bottomCapHeight: 20,
            hasCone: false, hasEngines: true, engineCount: 1, bands: []),
        RocketStageData(
            name: "Payload Fairing",
            description: "5 m composite ogive fairing.",
            specs: [("Diameter","5.0 m"),("Length","10.65 m"),("Material","CFRP"),("Mass","3,500 kg")],
            bodyColor: Color(red:0.93,green:0.94,blue:0.96),
            highlightColor: Color(red:0.99,green:0.99,blue:1.00),
            shadowColor: Color(red:0.63,green:0.65,blue:0.68),
            relativeWidth: 0.86, height: 75, topCapHeight: 52, bottomCapHeight: 6,
            hasCone: true, hasEngines: false, engineCount: 0, bands: []),
    ]}

    static func pslv() -> [RocketStageData] {[
        RocketStageData(
            name: "PS1 + 6 PSOM-XL", description: "Core solid first stage with six strap-on boosters.",
            specs: [("Type","Solid"),("Thrust","4,797 kN"),("Boosters","6 × PSOM-XL"),("Burn Time","103 s")],
            bodyColor: Color(red:0.87,green:0.87,blue:0.85), highlightColor: Color(red:0.96,green:0.96,blue:0.95),
            shadowColor: Color(red:0.58,green:0.58,blue:0.56),
            relativeWidth: 1.0, height: 120, topCapHeight: 10, bottomCapHeight: 24,
            hasCone: false, hasEngines: true, engineCount: 4,
            bands: [.init(y:0.10, height:0.08, color:Color(red:0.16,green:0.28,blue:0.65).opacity(0.80))]),
        RocketStageData(
            name: "PS2 Second Stage", description: "Vikas engine with UDMH/N₂O₄.",
            specs: [("Engine","Vikas"),("Thrust","799 kN"),("Propellant","UDMH / NTO"),("Burn Time","158 s")],
            bodyColor: Color(red:0.90,green:0.88,blue:0.82), highlightColor: Color(red:0.98,green:0.96,blue:0.92),
            shadowColor: Color(red:0.60,green:0.58,blue:0.52),
            relativeWidth: 0.82, height: 90, topCapHeight: 8, bottomCapHeight: 22,
            hasCone: false, hasEngines: true, engineCount: 1,
            bands: [.init(y:0.75, height:0.07, color:Color(red:0.88,green:0.28,blue:0.08).opacity(0.80))]),
        RocketStageData(
            name: "PS3 + PS4", description: "Solid PS3 + liquid PS4 with twin engines for sun-synchronous orbits.",
            specs: [("PS3","Solid"),("PS4 Engines","2 × L-2-5"),("Thrust","7.4 kN"),("Burn Time","425 s")],
            bodyColor: Color(red:0.80,green:0.76,blue:0.58), highlightColor: Color(red:0.92,green:0.90,blue:0.78),
            shadowColor: Color(red:0.50,green:0.46,blue:0.30),
            relativeWidth: 0.72, height: 95, topCapHeight: 42, bottomCapHeight: 14,
            hasCone: true, hasEngines: true, engineCount: 2, bands: []),
    ]}

    static func sls() -> [RocketStageData] {[
        RocketStageData(
            name: "Core Stage + 2 SRBs",
            description: "Metallic LH₂/LOX core with two 5-segment solid rocket boosters.",
            specs: [("Engines","4 × RS-25"),("SRB Thrust","2 × 16,000 kN"),("Core Thrust","7,449 kN"),("Propellant","LH₂ / LOX")],
            bodyColor: Color(red:0.94,green:0.54,blue:0.14), highlightColor: Color(red:0.99,green:0.75,blue:0.40),
            shadowColor: Color(red:0.64,green:0.28,blue:0.04),
            relativeWidth: 1.0, height: 165, topCapHeight: 12, bottomCapHeight: 38,
            hasCone: false, hasEngines: true, engineCount: 4,
            bands: [.init(y:0.65, height:0.06, color:Color.white.opacity(0.75))]),
        RocketStageData(
            name: "ICPS Upper Stage",
            description: "Interim Cryogenic Propulsion Stage with RL-10C-5.",
            specs: [("Engine","1 × RL-10C-5"),("Thrust","99.1 kN"),("Propellant","LH₂ / LOX"),("ISP","462 s")],
            bodyColor: Color(red:0.53,green:0.72,blue:0.92), highlightColor: Color(red:0.74,green:0.88,blue:0.99),
            shadowColor: Color(red:0.30,green:0.50,blue:0.72),
            relativeWidth: 0.80, height: 85, topCapHeight: 8, bottomCapHeight: 22,
            hasCone: false, hasEngines: true, engineCount: 1, bands: []),
        RocketStageData(
            name: "Orion Spacecraft",
            description: "Deep-space crew capsule with European Service Module.",
            specs: [("Crew","4"),("SM Engine","AJ10-190"),("Heat Shield","AVCOAT"),("Max V","11 km/s")],
            bodyColor: Color(red:0.88,green:0.87,blue:0.86), highlightColor: Color(red:0.97,green:0.96,blue:0.95),
            shadowColor: Color(red:0.60,green:0.58,blue:0.56),
            relativeWidth: 0.72, height: 100, topCapHeight: 46, bottomCapHeight: 10,
            hasCone: true, hasEngines: false, engineCount: 0, bands: []),
    ]}

    static func ariane5() -> [RocketStageData] {[
        RocketStageData(
            name: "EPC Core + 2 EAP",
            description: "Cryogenic core with Vulcain 2 engine plus two solid boosters.",
            specs: [("Engine","Vulcain 2"),("EAP Thrust","2 × 6,650 kN"),("Propellant","LH₂ / LOX"),("Burn Time","589 s")],
            bodyColor: Color(red:0.88,green:0.89,blue:0.91), highlightColor: Color(red:0.97,green:0.97,blue:0.99),
            shadowColor: Color(red:0.58,green:0.60,blue:0.63),
            relativeWidth: 1.0, height: 145, topCapHeight: 12, bottomCapHeight: 32,
            hasCone: false, hasEngines: true, engineCount: 3,
            bands: [.init(y:0.72, height:0.05, color:Color(red:0.0,green:0.38,blue:0.75).opacity(0.85))]),
        RocketStageData(
            name: "ESC-A Upper Stage",
            description: "Cryogenic upper stage with HM7B engine.",
            specs: [("Engine","HM7B"),("Thrust","67 kN"),("Propellant","LH₂ / LOX"),("ISP","446 s")],
            bodyColor: Color(red:0.53,green:0.70,blue:0.90), highlightColor: Color(red:0.72,green:0.86,blue:0.98),
            shadowColor: Color(red:0.30,green:0.48,blue:0.70),
            relativeWidth: 0.85, height: 80, topCapHeight: 7, bottomCapHeight: 20,
            hasCone: false, hasEngines: true, engineCount: 1, bands: []),
        RocketStageData(
            name: "Dual-Launch Fairing",
            description: "5.4 m fairing for two GTO payloads.",
            specs: [("Diameter","5.4 m"),("Length","17 m"),("Capacity","2 payloads"),("Material","CFRP")],
            bodyColor: Color(red:0.92,green:0.93,blue:0.95), highlightColor: Color(red:0.99,green:0.99,blue:1.00),
            shadowColor: Color(red:0.63,green:0.65,blue:0.67),
            relativeWidth: 0.96, height: 82, topCapHeight: 55, bottomCapHeight: 7,
            hasCone: true, hasEngines: false, engineCount: 0, bands: []),
    ]}

    static func hiia() -> [RocketStageData] {[
        RocketStageData(
            name: "First Stage + 2 SRB-A",
            description: "LOX/LH2 first stage with LE-7A plus two solid boosters.",
            specs: [("Engine","LE-7A"),("SRB","2 × 2,255 kN"),("Propellant","LH₂ / LOX"),("Burn Time","392 s")],
            bodyColor: Color(red:0.92,green:0.93,blue:0.95), highlightColor: Color(red:0.99,green:0.99,blue:1.00),
            shadowColor: Color(red:0.63,green:0.65,blue:0.68),
            relativeWidth: 1.0, height: 140, topCapHeight: 10, bottomCapHeight: 30,
            hasCone: false, hasEngines: true, engineCount: 3,
            bands: [.init(y:0.72, height:0.05, color:Color(red:0.82,green:0.08,blue:0.08).opacity(0.85))]),
        RocketStageData(
            name: "Second Stage (LE-5B)",
            description: "Cryogenic upper stage with multiple restarts.",
            specs: [("Engine","LE-5B"),("Thrust","137.2 kN"),("ISP","447 s"),("Restarts","Multiple")],
            bodyColor: Color(red:0.54,green:0.71,blue:0.90), highlightColor: Color(red:0.72,green:0.86,blue:0.97),
            shadowColor: Color(red:0.34,green:0.50,blue:0.72),
            relativeWidth: 0.85, height: 80, topCapHeight: 7, bottomCapHeight: 20,
            hasCone: false, hasEngines: true, engineCount: 1, bands: []),
        RocketStageData(
            name: "Payload Fairing",
            description: "4 m composite nose fairing.",
            specs: [("Diameter","4.0 m"),("Length","9.0 m"),("Material","CFRP"),("Mass","2,000 kg")],
            bodyColor: Color(red:0.92,green:0.93,blue:0.95), highlightColor: Color(red:0.99,green:0.99,blue:1.00),
            shadowColor: Color(red:0.63,green:0.65,blue:0.67),
            relativeWidth: 0.88, height: 72, topCapHeight: 48, bottomCapHeight: 6,
            hasCone: true, hasEngines: false, engineCount: 0, bands: []),
    ]}

    static func atlasV() -> [RocketStageData] {[
        RocketStageData(
            name: "CCB + 4 SRBs",
            description: "Common Core Booster with RD-180 and 4 solid rocket boosters.",
            specs: [("Engine","RD-180"),("SRBs","4 × AJ-60A"),("Core Thrust","3,827 kN"),("Propellant","RP-1 / LOX")],
            bodyColor: Color(red:0.88,green:0.90,blue:0.92), highlightColor: Color(red:0.97,green:0.98,blue:0.99),
            shadowColor: Color(red:0.58,green:0.62,blue:0.66),
            relativeWidth: 1.0, height: 140, topCapHeight: 10, bottomCapHeight: 30,
            hasCone: false, hasEngines: true, engineCount: 4,
            bands: [.init(y:0.72, height:0.05, color:Color(red:0.10,green:0.25,blue:0.60).opacity(0.85))]),
        RocketStageData(
            name: "Centaur Upper Stage",
            description: "Cryogenic upper stage with RL-10C engine.",
            specs: [("Engine","RL-10C-1"),("Thrust","99 kN"),("ISP","451 s"),("Propellant","LH₂ / LOX")],
            bodyColor: Color(red:0.54,green:0.70,blue:0.91), highlightColor: Color(red:0.74,green:0.88,blue:0.99),
            shadowColor: Color(red:0.30,green:0.48,blue:0.72),
            relativeWidth: 0.90, height: 85, topCapHeight: 8, bottomCapHeight: 22,
            hasCone: false, hasEngines: true, engineCount: 1, bands: []),
        RocketStageData(
            name: "Payload Fairing",
            description: "5.4 m large diameter composite fairing.",
            specs: [("Diameter","5.4 m"),("Length","12.2 m"),("Material","CFRP"),("Mass","2,340 kg")],
            bodyColor: Color(red:0.92,green:0.93,blue:0.96), highlightColor: Color(red:0.99,green:0.99,blue:1.00),
            shadowColor: Color(red:0.62,green:0.65,blue:0.68),
            relativeWidth: 0.95, height: 78, topCapHeight: 52, bottomCapHeight: 6,
            hasCone: true, hasEngines: false, engineCount: 0, bands: []),
    ]}

    static func genericStages() -> [RocketStageData] {[
        RocketStageData(
            name: "First Stage", description: "Main propulsion stage.",
            specs: [("Type","Liquid"),("Burn Time","~180 s")],
            bodyColor: Color(red:0.88,green:0.89,blue:0.90), highlightColor: Color(red:0.97,green:0.97,blue:0.98),
            shadowColor: Color(red:0.60,green:0.62,blue:0.64),
            relativeWidth: 1.0, height: 130, topCapHeight: 10, bottomCapHeight: 28,
            hasCone: false, hasEngines: true, engineCount: 3, bands: []),
        RocketStageData(
            name: "Upper Stage", description: "Orbital insertion stage.",
            specs: [("Type","Liquid"),("ISP","~420 s")],
            bodyColor: Color(red:0.54,green:0.70,blue:0.90), highlightColor: Color(red:0.74,green:0.86,blue:0.98),
            shadowColor: Color(red:0.34,green:0.50,blue:0.70),
            relativeWidth: 0.82, height: 85, topCapHeight: 7, bottomCapHeight: 20,
            hasCone: false, hasEngines: true, engineCount: 1, bands: []),
        RocketStageData(
            name: "Payload Fairing", description: "Composite fairing.",
            specs: [("Type","Composite")],
            bodyColor: Color(red:0.93,green:0.94,blue:0.96), highlightColor: Color(red:0.99,green:0.99,blue:1.00),
            shadowColor: Color(red:0.64,green:0.65,blue:0.68),
            relativeWidth: 0.86, height: 70, topCapHeight: 48, bottomCapHeight: 6,
            hasCone: true, hasEngines: false, engineCount: 0, bands: []),
    ]}
}
