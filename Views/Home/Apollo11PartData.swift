import SwiftUI

// apollo 11 part insight
struct Apollo11PartInsight: Identifiable {
    let id = UUID()
    let partKey: String
    let name: String
    let subtitle: String
    let icon: String
    let accentColor: Color
    let description: String
    let insights: [String]
    let specs: [(String, String)]
    let subComponents: [Apollo11SubComponent]
}

struct Apollo11SubComponent: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let description: String
    let specs: [(String, String)]
}

// apollo 11 part data provider
struct Apollo11PartDataProvider {

    // match a tapped scnnode name to a part key
    static func matchPart(nodeName: String) -> Apollo11PartInsight? {
        let lo = nodeName.lowercased()

        // try exact match first
        if let exact = allParts.first(where: { $0.partKey.lowercased() == lo }) {
            return exact
        }

        // fuzzy keyword matching
        for part in allParts {
            let keys = partKeywords[part.partKey] ?? [part.partKey.lowercased()]
            for keyword in keys {
                if lo.contains(keyword) { return part }
            }
        }

        return nil
    }

    // keywords for fuzzy matching usdz node names
    private static let partKeywords: [String: [String]] = [
        "s_ic":     ["s-ic", "s_ic", "sic", "first_stage", "firststage", "stage_1", "stage1", "booster"],
        "f1_engine": ["f-1", "f1", "engine", "nozzle", "bell", "thrust"],
        "s_ii":     ["s-ii", "s_ii", "sii", "second_stage", "secondstage", "stage_2", "stage2"],
        "j2_engine": ["j-2", "j2"],
        "s_ivb":    ["s-ivb", "s_ivb", "sivb", "third_stage", "thirdstage", "stage_3", "stage3"],
        "iu":       ["instrument_unit", "iu", "instrument"],
        "lm_adapter": ["sla", "adapter", "spacecraft_lunar", "lm_adapter"],
        "lm":       ["lunar_module", "lm", "eagle", "lunar"],
        "sm":       ["service_module", "sm", "service"],
        "cm":       ["command_module", "cm", "command", "capsule", "columbia"],
        "les":      ["launch_escape", "les", "escape", "tower", "las"],
        "fairing":  ["fairing", "nose", "cone", "shroud"],
    ]

    static let allParts: [Apollo11PartInsight] = [

        // ── s-ic first stage ──────────────────────────────────────
        Apollo11PartInsight(
            partKey: "s_ic",
            name: "S-IC First Stage",
            subtitle: "Boeing · Michoud Assembly Facility",
            icon: "flame.fill",
            accentColor: Color(red: 0.95, green: 0.45, blue: 0.05),
            description: "The S-IC was the first stage of the Saturn V, the largest production launch vehicle ever built. Standing 42 meters tall with a diameter of 10.1 meters, it provided the enormous thrust needed to lift the 2,970-tonne vehicle off the pad.",
            insights: [
                "Burned 15 tonnes of propellant per second — emptying Olympic-size pools in seconds",
                "Five F-1 engines produced 7.5 million pounds of thrust at liftoff",
                "Built by Boeing at NASA's Michoud Assembly Facility in New Orleans",
                "Transported from New Orleans to Cape Kennedy by barge on the specially built vessel 'Poseidon'",
                "S-IC burn lasted only 150 seconds before separation at 67 km altitude"
            ],
            specs: [
                ("Height", "42.1 m (138 ft)"),
                ("Diameter", "10.1 m (33 ft)"),
                ("Dry Mass", "130,000 kg"),
                ("Propellant Mass", "2,160,000 kg"),
                ("Fuel", "RP-1 (Kerosene)"),
                ("Oxidizer", "Liquid Oxygen (LOX)"),
                ("Engines", "5 × F-1"),
                ("Total Thrust", "34,020 kN"),
                ("Burn Time", "150 seconds"),
                ("Sep. Altitude", "67 km")
            ],
            subComponents: [
                Apollo11SubComponent(name: "S-IC LOX Tank", icon: "drop.fill",
                    description: "Liquid oxygen oxidiser tank for the S-IC first stage, feeding the five F-1 engines.",
                    specs: [("Capacity", "1,311,100 liters"), ("Temperature", "-183°C"), ("Oxidizer", "LOX")]),
                Apollo11SubComponent(name: "S-IC RP-1 Tank", icon: "fuelpump.fill",
                    description: "Fuel tank holding kerosene for the massive S-IC first stage.",
                    specs: [("Capacity", "770,000 liters"), ("Fuel Type", "RP-1 Kerosene")]),
                Apollo11SubComponent(name: "S-IC Stage", icon: "flame.fill",
                    description: "The first stage powered by five F-1 engines, providing 34 MN of thrust to lift the 2,900 ton rocket.",
                    specs: [("Engines", "5 × F-1"), ("Total Thrust", "34 MN")]),
                Apollo11SubComponent(name: "Stabilizer Fins", icon: "triangle.fill",
                    description: "Four aerodynamic fins at the base of the S-IC to provide stability during atmospheric flight.",
                    specs: [("Count", "4"), ("Purpose", "Stability")])
            ]
        ),

        // ── f-1 engine ──────────────────────────────────────
        Apollo11PartInsight(
            partKey: "f1_engine",
            name: "F-1 Engine",
            subtitle: "Rocketdyne · Canoga Park, CA",
            icon: "flame.fill",
            accentColor: Color(red: 0.90, green: 0.72, blue: 0.20),
            description: "The Rocketdyne F-1 remains the most powerful single-chamber, single-nozzle liquid-fueled rocket engine ever developed. Five F-1 engines powered the Saturn V's first stage.",
            insights: [
                "Each F-1 produced 1.5 million pounds of thrust — more than three Space Shuttle Main Engines combined",
                "The turbopump alone generated 55,000 horsepower — equivalent to 30 locomotive engines",
                "Fuel flow rate: 1,789 kg/sec through the nozzle",
                "Engineers solved catastrophic combustion instability through 2,000+ test firings",
                "The exhaust velocity reached 2,580 m/s (9,300 km/h)"
            ],
            specs: [
                ("Thrust (SL)", "6,670 kN"),
                ("Thrust (Vac)", "7,740 kN"),
                ("Specific Impulse", "263 s (SL)"),
                ("Chamber Pressure", "70 bar"),
                ("Mass Flow", "1,789 kg/s"),
                ("Nozzle Ratio", "16:1"),
                ("Height", "5.79 m"),
                ("Diameter", "3.76 m"),
                ("Weight", "8,391 kg"),
                ("Turbopump Power", "41 MW")
            ],
            subComponents: [
                Apollo11SubComponent(name: "Combustion Chamber", icon: "flame.circle.fill",
                    description: "Regeneratively-cooled combustion chamber where RP-1 and LOX ignite.",
                    specs: [("Pressure", "70 bar"), ("Temperature", "3,300°C")]),
                Apollo11SubComponent(name: "Turbopump Assembly", icon: "gear.circle.fill",
                    description: "Gas-generator driven turbopump feeding propellants at extreme rates.",
                    specs: [("Speed", "5,500 RPM"), ("Power", "41 MW"), ("Flow Rate", "1,789 kg/s")]),
                Apollo11SubComponent(name: "Nozzle Extension", icon: "cone.fill",
                    description: "Bell-shaped nozzle extension directing exhaust for thrust.",
                    specs: [("Expansion Ratio", "16:1"), ("Exit Diameter", "3.76 m")])
            ]
        ),

        // ── s-ii second stage ──────────────────────────────────────
        Apollo11PartInsight(
            partKey: "s_ii",
            name: "S-II Second Stage",
            subtitle: "North American Rockwell · Seal Beach, CA",
            icon: "cylinder.fill",
            accentColor: Color(red: 0.55, green: 0.72, blue: 0.92),
            description: "The S-II was the second stage of the Saturn V, using five J-2 engines burning liquid hydrogen and liquid oxygen. It was the most technically complex stage to manufacture.",
            insights: [
                "Used the first large-scale liquid hydrogen tank ever built — revolutionary at the time",
                "Common bulkhead between LOX and LH₂ tanks saved 3,600 kg — a daring engineering choice",
                "Five J-2 engines provided 5,141 kN of thrust in vacuum",
                "Manufacturing the common bulkhead required welding two different metals at different temperatures",
                "Burned for 6 minutes, accelerating the stack to 24,600 km/h"
            ],
            specs: [
                ("Height", "24.8 m (81.5 ft)"),
                ("Diameter", "10.1 m (33 ft)"),
                ("Dry Mass", "36,200 kg"),
                ("Propellant Mass", "451,650 kg"),
                ("Fuel", "Liquid Hydrogen (LH₂)"),
                ("Oxidizer", "Liquid Oxygen (LOX)"),
                ("Engines", "5 × J-2"),
                ("Total Thrust", "5,141 kN (vac)"),
                ("Burn Time", "360 seconds"),
                ("Sep. Altitude", "185 km")
            ],
            subComponents: [
                Apollo11SubComponent(name: "S-II LOX Tank", icon: "drop.fill",
                    description: "Liquid oxygen oxidiser tank for the S-II second stage.",
                    specs: [("Oxidizer", "LOX"), ("Location", "Bottom half")]),
                Apollo11SubComponent(name: "S-II LH2 Tank", icon: "drop.fill",
                    description: "Liquid hydrogen fuel tank for the S-II second stage.",
                    specs: [("Volume", "331,000 liters"), ("Temperature", "-253°C")]),
                Apollo11SubComponent(name: "S-II Stage", icon: "flame.fill",
                    description: "The second stage powered by five J-2 engines, pushing Apollo into orbit after S-IC separation.",
                    specs: [("Engines", "5 × J-2"), ("Total Thrust", "5,141 kN")])
            ]
        ),

        // ── s-ivb third stage ──────────────────────────────────────
        Apollo11PartInsight(
            partKey: "s_ivb",
            name: "S-IVB Third Stage",
            subtitle: "Douglas Aircraft · Huntington Beach, CA",
            icon: "circle.grid.3x3.fill",
            accentColor: Color(red: 0.40, green: 0.65, blue: 0.95),
            description: "The S-IVB served as the third stage and performed the critical Trans-Lunar Injection (TLI) burn that sent Apollo 11 to the Moon. Its single J-2 engine was restartable.",
            insights: [
                "Performed the Trans-Lunar Injection (TLI) — the burn that sent Apollo 11 toward the Moon",
                "J-2 engine restarted in space — first time a cryogenic engine was re-ignited in orbit",
                "After TLI, the S-IVB was jettisoned into solar orbit where it remains today",
                "Housed the Lunar Module (Eagle) inside the Spacecraft-Lunar Module Adapter",
                "Required precise navigation — a 1° error at TLI would miss the Moon by thousands of km"
            ],
            specs: [
                ("Height", "17.8 m (58.4 ft)"),
                ("Diameter", "6.6 m (21.7 ft)"),
                ("Dry Mass", "11,500 kg"),
                ("Propellant Mass", "107,100 kg"),
                ("Engine", "1 × J-2 (restartable)"),
                ("Thrust", "1,033 kN (vacuum)"),
                ("First Burn", "150 s (orbit insertion)"),
                ("Second Burn", "350 s (TLI)"),
                ("Isp", "421 s (vacuum)")
            ],
            subComponents: [
                Apollo11SubComponent(name: "S-IVB LOX Tank", icon: "drop.fill",
                    description: "Liquid oxygen oxidiser tank for the S-IVB third stage.",
                    specs: [("Oxidizer", "LOX")]),
                Apollo11SubComponent(name: "S-IVB Stage", icon: "flame.fill",
                    description: "The third stage powered by a single J-2 engine, used for Earth orbit insertion and trans-lunar injection.",
                    specs: [("Engine", "1 × J-2"), ("Thrust", "1,033 kN")])
            ]
        ),

        // ── instrument unit ──────────────────────────────────────
        Apollo11PartInsight(
            partKey: "iu",
            name: "Instrument Unit",
            subtitle: "IBM · Huntsville, AL",
            icon: "cpu.fill",
            accentColor: Color(red: 0.55, green: 0.20, blue: 0.90),
            description: "The Instrument Unit was the brain of the Saturn V — a 3-foot tall ring packed with the guidance computer, inertial navigation platform, and telemetry systems that controlled the entire flight.",
            insights: [
                "Contained the LVDC (Launch Vehicle Digital Computer) built by IBM — one of the first airborne computers",
                "The ST-124M Inertial Platform kept the rocket oriented with gyroscopic precision",
                "Processed navigation data and sent correction commands 25 times per second",
                "Weighed only 2,041 kg despite containing 15+ subsystems",
                "Had to survive vibrations of 34 million newtons of thrust from below"
            ],
            specs: [
                ("Height", "0.91 m (3 ft)"),
                ("Diameter", "6.6 m (21.7 ft)"),
                ("Mass", "2,041 kg"),
                ("Computer", "IBM LVDC"),
                ("Clock Speed", "2 MHz"),
                ("Memory", "128 KB"),
                ("Guidance", "ST-124M Inertial Platform"),
                ("Update Rate", "25 Hz")
            ],
            subComponents: []
        ),

        // ── spacecraft-lunar module adapter ──────────────────────────────────────
        Apollo11PartInsight(
            partKey: "lm_adapter",
            name: "SLA (Spacecraft-LM Adapter)",
            subtitle: "North American Rockwell",
            icon: "cone.fill",
            accentColor: Color(red: 0.75, green: 0.78, blue: 0.82),
            description: "The Spacecraft-Lunar Module Adapter (SLA) was a truncated cone that housed the Lunar Module during launch and connected the S-IVB to the Service Module. Its four panels opened like flower petals during transposition and docking.",
            insights: [
                "Four aluminum panels opened like flower petals to release the Lunar Module",
                "Panels were jettisoned by explosive charges — pyrotechnic separation system",
                "Protected the delicate Lunar Module from aerodynamic forces during ascent",
                "Transposition and docking maneuver was one of the most critical phases of the mission"
            ],
            specs: [
                ("Height", "8.5 m"),
                ("Upper Diameter", "3.9 m"),
                ("Lower Diameter", "6.6 m"),
                ("Material", "Aluminum alloy"),
                ("Panels", "4 segments"),
                ("Separation", "Pyrotechnic")
            ],
            subComponents: []
        ),

        // ── lunar module ──────────────────────────────────────
        Apollo11PartInsight(
            partKey: "lm",
            name: "Lunar Module (Eagle)",
            subtitle: "Grumman Aerospace · Bethpage, NY",
            icon: "moon.fill",
            accentColor: Color(red: 0.95, green: 0.85, blue: 0.30),
            description: "The Lunar Module 'Eagle' (LM-5) was the spacecraft that carried Neil Armstrong and Buzz Aldrin to the lunar surface on July 20, 1969. It separated into a descent stage for landing and an ascent stage for return to orbit.",
            insights: [
                "'The Eagle has landed' — Armstrong's words at 20:17 UTC, July 20, 1969",
                "Only 25 seconds of fuel remained when Eagle touched down in the Sea of Tranquility",
                "Built by Grumman — designers had to shave every gram, even removing astronaut seats",
                "Descent guidance computer alarm '1202' nearly caused a mission abort during landing",
                "The ascent stage was intentionally crashed into the Moon after crew returned to Columbia"
            ],
            specs: [
                ("Height", "7.0 m"),
                ("Width", "9.4 m (legs deployed)"),
                ("Mass (total)", "15,200 kg"),
                ("Descent Engine", "43.9 kN (throttleable)"),
                ("Ascent Engine", "15.6 kN"),
                ("Crew", "2 astronauts"),
                ("Surface Stay", "21 h 36 min"),
                ("Landing Site", "Sea of Tranquility"),
                ("Landing Coord", "0.6741°N, 23.4730°E")
            ],
            subComponents: []
        ),

        // ── service module ──────────────────────────────────────
        Apollo11PartInsight(
            partKey: "sm",
            name: "Service Module",
            subtitle: "North American Rockwell · Downey, CA",
            icon: "cylinder.fill",
            accentColor: Color(red: 0.60, green: 0.65, blue: 0.72),
            description: "The Service Module (SM) provided propulsion, electrical power, and life support to the Command Module throughout the mission. Its Service Propulsion System engine performed critical burns for lunar orbit insertion and trans-Earth injection.",
            insights: [
                "The SPS engine had to work perfectly — no backup existed for the burns to leave lunar orbit",
                "Three fuel cells generated electricity by combining hydrogen and oxygen, producing water as a byproduct",
                "Contained the high-gain antenna for deep space communication with Earth",
                "Jettisoned just before re-entry — one of the last mission events before splashdown",
                "Six sectors contained fuel, oxidizer, fuel cells, and scientific instruments"
            ],
            specs: [
                ("Height", "7.56 m"),
                ("Diameter", "3.91 m"),
                ("Mass", "24,523 kg"),
                ("SPS Thrust", "97.9 kN"),
                ("SPS Propellant", "NTO / Aerozine 50"),
                ("Power", "3 × Fuel Cells"),
                ("Electricity", "28V DC, 2.3 kW"),
                ("Water Output", "14 kg/day"),
                ("Sectors", "6")
            ],
            subComponents: []
        ),

        // ── command module ──────────────────────────────────────
        Apollo11PartInsight(
            partKey: "cm",
            name: "Command Module (Columbia)",
            subtitle: "North American Rockwell · Downey, CA",
            icon: "capsule.fill",
            accentColor: Color(red: 0.92, green: 0.88, blue: 0.82),
            description: "The Command Module 'Columbia' (CM-107) was the only part of the Saturn V that returned to Earth. It housed all three astronauts during launch, transit, and re-entry, splashing down in the Pacific Ocean on July 24, 1969.",
            insights: [
                "Named 'Columbia' by Michael Collins — he orbited the Moon while Armstrong and Aldrin walked on it",
                "The AVCOAT ablative heat shield endured 2,760°C during re-entry at 39,900 km/h",
                "Contained over 2 million functional parts and 15 miles of wiring",
                "The Apollo Guidance Computer had less processing power than a modern calculator",
                "Columbia is now on display at the National Air and Space Museum in Washington, D.C."
            ],
            specs: [
                ("Height", "3.47 m"),
                ("Diameter", "3.91 m"),
                ("Mass", "5,809 kg"),
                ("Habitable Vol", "6.17 m³"),
                ("Heat Shield", "AVCOAT ablative"),
                ("Re-entry Speed", "39,900 km/h"),
                ("Re-entry Temp", "2,760°C"),
                ("Crew", "3 astronauts"),
                ("Computer", "AGC (74 KB)"),
                ("Current Location", "NASM, Washington DC")
            ],
            subComponents: []
        ),

        // ── launch escape system ──────────────────────────────────────
        Apollo11PartInsight(
            partKey: "les",
            name: "Launch Escape System",
            subtitle: "Lockheed Propulsion · Redlands, CA",
            icon: "arrow.up.to.line",
            accentColor: Color(red: 0.88, green: 0.15, blue: 0.10),
            description: "The Launch Escape System (LES) sat atop the Command Module and could pull the crew capsule away from a failing rocket in milliseconds. It was jettisoned 30 seconds after S-II ignition when no longer needed.",
            insights: [
                "Could accelerate the Command Module from 0 to 900 km/h in 3 seconds — 15g acceleration",
                "Never used during any Apollo mission but was tested extensively and proved crucial for crew safety design",
                "The tower contained three solid-fuel rocket motors of different sizes",
                "Jettisoned at T+3:17 (30 seconds after second stage ignition)",
                "Weighed 4,173 kg — significant mass removed early in flight"
            ],
            specs: [
                ("Height", "10.1 m"),
                ("Mass", "4,173 kg"),
                ("Main Motor Thrust", "689 kN"),
                ("Burn Time", "3 seconds"),
                ("Acceleration", "15g"),
                ("Jettison Time", "T+3:17"),
                ("Motors", "3 (launch, pitch, jettison)")
            ],
            subComponents: []
        ),
    ]
}
