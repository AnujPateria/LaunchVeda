import Foundation
import SwiftUI

struct MockData {

    // mission control roles 
    static let billets: [Billet] = [
        Billet(
            id: "flight_director",
            title: "Flight Director",
            icon: "star.circle.fill",
            controls: ["Entire mission execution", "Final Go/No-Go"],
            activePhases: ["Pre-Launch", "Launch", "Orbit", "Landing", "Recovery"],
            authority: .high,
            reportsTo: "Mission Director",
            handlesFailures: ["Any critical anomaly", "Crew safety decisions"]
        ),
        Billet(
            id: "propulsion",
            title: "Propulsion Lead",
            icon: "flame.circle.fill",
            controls: ["Main engines", "Fuel & Oxidizer systems", "Thrusters"],
            activePhases: ["Launch", "Orbit Insertion", "De-orbit"],
            authority: .medium,
            reportsTo: "Flight Director",
            handlesFailures: ["Engine failure", "Propellant leaks"]
        ),
        Billet(
            id: "gnc",
            title: "GNC Officer",
            icon: "location.north.circle.fill",
            controls: ["Navigation computer", "Attitude control", "Trajectory"],
            activePhases: ["Launch", "Orbit", "Landing"],
            authority: .medium,
            reportsTo: "Flight Director",
            handlesFailures: ["Sensor failure", "Off-course deviation"]
        ),
        Billet(
            id: "eecom",
            title: "EECOM",
            icon: "bolt.batteryblock.fill",
            controls: ["Electrical power", "Life support", "Thermal control"],
            activePhases: ["Pre-Launch", "Launch", "Orbit", "Landing"],
            authority: .medium,
            reportsTo: "Flight Director",
            handlesFailures: ["Power loss", "Oxygen depletion", "Overheating"]
        ),
        Billet(
            id: "capcom",
            title: "CAPCOM",
            icon: "mic.circle.fill",
            controls: ["Spacecraft communications", "Crew instructions"],
            activePhases: ["Launch", "Orbit", "Landing", "Recovery"],
            authority: .low,
            reportsTo: "Flight Director",
            handlesFailures: ["Loss of signal (LOS)"]
        ),
        Billet(
            id: "range_safety",
            title: "Range Safety",
            icon: "exclamationmark.shield.fill",
            controls: ["Flight termination system", "Exclusion zone monitoring"],
            activePhases: ["Launch"],
            authority: .high,
            reportsTo: "Range Commander",
            handlesFailures: ["Vehicle destruct on trajectory deviation"]
        )
    ]

    // saturn v rocket parts
    static let saturnVParts: [RocketPart] = [
        RocketPart(
            id: "les",
            name: "Launch Escape System",
            icon: "arrow.up.to.line",
            description: "The LES was a safety system that could pull the Command Module away from the Saturn V in case of an emergency during launch. It contained three solid-fuelled motors.",
            colorName: "red",
            specs: [
                RocketSpec(label: "Height", value: "10 m"),
                RocketSpec(label: "Mass", value: "4,173 kg"),
                RocketSpec(label: "Thrust", value: "689 kN"),
                RocketSpec(label: "Motors", value: "3 solid-fuel")
            ],
            subparts: [],
            partImageName: "saturn_v_les",
            controlledBy: ["propulsion", "range_safety"]
        ),
        RocketPart(
            id: "cm",
            name: "Command Module",
            icon: "capsule.fill",
            description: "The crew cabin where the three astronauts lived throughout the mission. After separation, the CM re-entered Earth's atmosphere and parachuted to splashdown.",
            colorName: "cream",
            specs: [
                RocketSpec(label: "Crew", value: "3 astronauts"),
                RocketSpec(label: "Mass", value: "5,809 kg"),
                RocketSpec(label: "Volume", value: "6.17 m³"),
                RocketSpec(label: "Heat shield", value: "AVCOAT ablative")
            ],
            subparts: [],
            partImageName: "saturn_v_cm",
            controlledBy: ["flight_director", "capcom"]
        ),
        RocketPart(
            id: "sm",
            name: "Service Module",
            icon: "cylinder.fill",
            description: "Provided propulsion, electrical power, and environmental control for the mission. The SPS engine performed critical burns to enter and exit lunar orbit.",
            colorName: "lightgray",
            specs: [
                RocketSpec(label: "Mass", value: "24,523 kg"),
                RocketSpec(label: "SPS Thrust", value: "97.9 kN"),
                RocketSpec(label: "Propellant", value: "NTO / UDMH"),
                RocketSpec(label: "Power", value: "3 × Fuel Cells")
            ],
            subparts: [],
            partImageName: "saturn_v_sm",
            controlledBy: ["eecom", "propulsion"]
        ),
        RocketPart(
            id: "lm",
            name: "Lunar Module (Eagle)",
            icon: "moon.fill",
            description: "The lander that carried Armstrong and Aldrin to the lunar surface. The descent stage used a throttleable engine, and the ascent stage returned the crew to Columbia.",
            colorName: "gold",
            specs: [
                RocketSpec(label: "Mass (total)", value: "15,095 kg"),
                RocketSpec(label: "Crew", value: "2 astronauts"),
                RocketSpec(label: "Descent engine", value: "45.7 kN throttleable"),
                RocketSpec(label: "Ascent engine", value: "15.6 kN fixed")
            ],
            subparts: [],
            stageImageName: "apollo_lm_satellite",
            partImageName: "saturn_v_lm"
        ),
        RocketPart(
            id: "sivb",
            name: "S-IVB Third Stage",
            icon: "circle.grid.3x3.fill",
            description: "Single J-2 engine stage that performed Trans-Lunar Injection (TLI) — the burn that set Apollo 11 on its trajectory to the Moon.",
            colorName: "white",
            specs: [
                RocketSpec(label: "Height", value: "17.8 m"),
                RocketSpec(label: "Diameter", value: "6.6 m"),
                RocketSpec(label: "Mass (full)", value: "119,900 kg"),
                RocketSpec(label: "Engine", value: "1× J-2")
            ],
            subparts: [
                RocketPart(id: "sivb_lox_tank", name: "S-IVB LOX Tank", icon: "drop.fill", description: "Liquid oxygen oxidiser tank for the S-IVB third stage.", colorName: "blue", specs: [RocketSpec(label: "Oxidizer", value: "LOX")], subparts: []),
                RocketPart(id: "sivb_stage", name: "S-IVB Stage", icon: "flame.fill", description: "The third stage powered by a single J-2 engine, used for Earth orbit insertion and trans-lunar injection.", colorName: "orange", specs: [RocketSpec(label: "Engine", value: "1 × J-2"), RocketSpec(label: "Thrust", value: "1,033 kN")], subparts: [])
            ],
            partImageName: "saturn_v_sivb",
            internalParts: [
                SatellitePart(
                    id: "sivb_lh2_inner",
                    name: "LH₂ Tank",
                    description: "Liquid Hydrogen fuel tank.",
                    icon: "drop.fill",
                    shape: .cylinder,
                    width: 6.4, height: 8.0, length: 6.4,
                    color: .orange,
                    position: [0, 2.0, 0],
                    subparts: [], specs: []
                ),
                SatellitePart(
                    id: "sivb_lox_inner",
                    name: "LOX Tank",
                    description: "Liquid Oxygen oxidizer tank.",
                    icon: "snowflake",
                    shape: .sphere,
                    width: 5.0, height: 4.0, length: 5.0,
                    color: .blue,
                    position: [0, -4.0, 0],
                    subparts: [], specs: []
                )
            ]
        ),
        RocketPart(
            id: "sii",
            name: "S-II Second Stage",
            icon: "cylinder",
            description: "Second stage powered by five J-2 engines. Burned liquid hydrogen and liquid oxygen to push the spacecraft to orbital velocity.",
            colorName: "lightgray",
            specs: [
                RocketSpec(label: "Height", value: "24.9 m"),
                RocketSpec(label: "Diameter", value: "10 m"),
                RocketSpec(label: "Mass (full)", value: "490,778 kg"),
                RocketSpec(label: "Engines", value: "5× J-2")
            ],
            subparts: [
                RocketPart(id: "sii_lox_tank", name: "S-II LOX Tank", icon: "drop.fill", description: "Liquid oxygen oxidiser tank for the S-II second stage.", colorName: "blue", specs: [RocketSpec(label: "Oxidizer", value: "LOX")], subparts: []),
                RocketPart(id: "sii_lh2_tank", name: "S-II LH2 Tank", icon: "drop.fill", description: "Liquid hydrogen fuel tank for the S-II second stage.", colorName: "purple", specs: [RocketSpec(label: "Volume", value: "331,000 L"), RocketSpec(label: "Temperature", value: "-253°C")], subparts: []),
                RocketPart(id: "sii_stage", name: "S-II Stage", icon: "flame.fill", description: "The second stage powered by five J-2 engines, pushing Apollo into orbit after S-IC separation.", colorName: "orange", specs: [RocketSpec(label: "Engines", value: "5 × J-2"), RocketSpec(label: "Total Thrust", value: "5,141 kN")], subparts: [])
            ],
            partImageName: "saturn_v_sii",
            internalParts: [
                SatellitePart(
                    id: "sii_lh2_inner",
                    name: "LH₂ Tank",
                    description: "Liquid Hydrogen fuel tank.",
                    icon: "drop.fill",
                    shape: .cylinder,
                    width: 9.5, height: 12.0, length: 9.5,
                    color: .orange,
                    position: [0, 3.0, 0],
                    subparts: [], specs: []
                ),
                SatellitePart(
                    id: "sii_lox_inner",
                    name: "LOX Tank",
                    description: "Liquid Oxygen oxidizer tank.",
                    icon: "snowflake",
                    shape: .sphere,
                    width: 8.0, height: 6.0, length: 8.0,
                    color: .blue,
                    position: [0, -7.0, 0],
                    subparts: [], specs: []
                )
            ]
        ),
        RocketPart(
            id: "sic",
            name: "S-IC First Stage",
            icon: "flame.fill",
            description: "The immense first stage of the Saturn V powered by five F-1 engines — still the most powerful rocket engines ever flown. Lifted the entire Saturn V off the launch pad.",
            colorName: "white",
            specs: [
                RocketSpec(label: "Height", value: "42.1 m"),
                RocketSpec(label: "Diameter", value: "10 m"),
                RocketSpec(label: "Mass (full)", value: "2,286,217 kg"),
                RocketSpec(label: "Engines", value: "5× F-1"),
                RocketSpec(label: "Total thrust", value: "34,020 kN")
            ],
            subparts: [
                RocketPart(id: "sic_lox_tank", name: "S-IC LOX Tank", icon: "drop.fill", description: "Liquid oxygen oxidiser tank for the S-IC first stage, feeding the five F-1 engines.", colorName: "blue", specs: [RocketSpec(label: "Capacity", value: "1,311,100 L"), RocketSpec(label: "Temperature", value: "-183°C"), RocketSpec(label: "Oxidizer", value: "LOX")], subparts: []),
                RocketPart(id: "sic_rp1_tank", name: "S-IC RP-1 Tank", icon: "fuelpump.fill", description: "Fuel tank holding kerosene for the massive S-IC first stage.", colorName: "brown", specs: [RocketSpec(label: "Capacity", value: "770,000 L"), RocketSpec(label: "Fuel Type", value: "RP-1 Kerosene")], subparts: []),
                RocketPart(id: "sic_stage", name: "S-IC Stage", icon: "flame.fill", description: "The first stage powered by five F-1 engines, providing 34 MN of thrust to lift the 2,900 ton rocket.", colorName: "red", specs: [RocketSpec(label: "Engines", value: "5 × F-1"), RocketSpec(label: "Total Thrust", value: "34 MN")], subparts: []),
                RocketPart(id: "sic_fins", name: "Stabilizer Fins", icon: "triangle.fill", description: "Four aerodynamic fins at the base of the S-IC to provide stability during atmospheric flight.", colorName: "darkgray", specs: [RocketSpec(label: "Count", value: "4"), RocketSpec(label: "Purpose", value: "Stability")], subparts: [])
            ],
            partImageName: "saturn_v_sic",
            internalParts: [
                SatellitePart(
                    id: "sic_lox_inner",
                    name: "LOX Tank",
                    description: "Liquid Oxygen oxidizer tank (Top).",
                    icon: "snowflake",
                    shape: .cylinder,
                    width: 9.0, height: 14.0, length: 9.0,
                    color: .blue,
                    position: [0, 8.0, 0],
                    subparts: [], specs: []
                ),
                SatellitePart(
                    id: "sic_fuel_inner",
                    name: "RP-1 Fuel Tank",
                    description: "Kerosene fuel tank (Bottom).",
                    icon: "drop.fill",
                    shape: .cylinder,
                    width: 9.0, height: 10.0, length: 9.0,
                    color: .orange,
                    position: [0, -6.0, 0],
                    subparts: [], specs: []
                )
            ]
        )
    ]

    // falcon 9 rocket parts
    static let falcon9Parts: [RocketPart] = [
        RocketPart(
            id: "fairing",
            name: "Payload Fairing",
            icon: "capsule",
            description: "Two-part aerodynamic fairing that protects the payload during ascent through Earth's atmosphere. SpaceX recovers fairing halves using parafoils and catch boats.",
            colorName: "white",
            specs: [
                RocketSpec(label: "Height", value: "13.1 m"),
                RocketSpec(label: "Diameter", value: "5.2 m"),
                RocketSpec(label: "Mass", value: "1,900 kg"),
                RocketSpec(label: "Recovered?", value: "Yes — net/water")
            ],
            subparts: [
                RocketPart(id: "fairing_half1", name: "Fairing Half 1", icon: "square.split.diagonal", description: "First half of the composite fairing. Separates using pneumatic push-off mechanisms.", colorName: "white", specs: [RocketSpec(label: "Material", value: "CFRP composite"), RocketSpec(label: "Separation", value: "Pneumatic")], subparts: []),
                RocketPart(id: "fairing_half2", name: "Fairing Half 2", icon: "square.split.diagonal.2x2", description: "Second half of the composite fairing with embedded thermal sensors.", colorName: "white", specs: [RocketSpec(label: "Material", value: "CFRP composite")], subparts: [])
            ]
        ),
        RocketPart(
            id: "s2",
            name: "Second Stage (S2)",
            icon: "cylinder.split.1x2",
            description: "Upper stage that carries the payload to its target orbit after first stage separation. Powered by a single Merlin Vacuum engine optimised for performance in vacuum.",
            colorName: "white",
            specs: [
                RocketSpec(label: "Height", value: "12.6 m"),
                RocketSpec(label: "Diameter", value: "3.7 m"),
                RocketSpec(label: "Engine", value: "1× Merlin Vacuum (MVac)"),
                RocketSpec(label: "Thrust", value: "934 kN (vac)")
            ],
            subparts: [
                RocketPart(id: "mvac", name: "Merlin Vacuum Engine", icon: "flame.fill", description: "Optimised for vacuum with a large expansion nozzle. Restartable for complex orbital manoeuvres.", colorName: "silver", specs: [RocketSpec(label: "Thrust", value: "934 kN"), RocketSpec(label: "Isp", value: "348 s"), RocketSpec(label: "Restartable", value: "Yes"), RocketSpec(label: "Nozzle diam.", value: "2.7 m")], subparts: [
                    RocketPart(id: "mvac_turbopump", name: "Turbopump Assembly", icon: "gear", description: "Single-shaft turbopump delivering propellants at high pressure. Driven by turbine exhaust gases.", colorName: "silver", specs: [RocketSpec(label: "Speed", value: "36,000 RPM"), RocketSpec(label: "Mass flow", value: "287 kg/s")], subparts: []),
                    RocketPart(id: "mvac_chamber", name: "Combustion Chamber", icon: "circle.fill", description: "Pintle-injector combustion chamber. RP-1 and LOX combust at very high mixture ratio.", colorName: "gold", specs: [RocketSpec(label: "Pressure", value: "9.7 MPa"), RocketSpec(label: "Injector", value: "Pintle type")], subparts: [])
                ]),
                RocketPart(id: "s2_prop", name: "Propellant Tanks", icon: "drop.fill", description: "RP-1 and LOX tanks feeding the MVac engine. Aluminium-lithium alloy construction.", colorName: "lightgray", specs: [RocketSpec(label: "LOX", value: "~75,200 kg"), RocketSpec(label: "RP-1", value: "~28,300 kg")], subparts: [])
            ]
        ),
        RocketPart(
            id: "interstage",
            name: "Interstage",
            icon: "circle.hexagonpath",
            description: "Composite carbon-fibre structure connecting first and second stages. Contains stage separation hardware including pneumatic separation system.",
            colorName: "darkgray",
            specs: [
                RocketSpec(label: "Material", value: "CFRP composite"),
                RocketSpec(label: "Separation", value: "Cold gas / pneumatic"),
                RocketSpec(label: "Height", value: "~2 m")
            ],
            subparts: [
                RocketPart(id: "interstage_sep", name: "Stage Separation System", icon: "arrow.up.and.down.circle.fill", description: "Pneumatic separation system releasing the first stage, allowing S2 ignition before separation.", colorName: "silver", specs: [RocketSpec(label: "Method", value: "Pneumatic push"), RocketSpec(label: "Separation time", value: "<1 s")], subparts: [])
            ]
        ),
        RocketPart(
            id: "s1",
            name: "First Stage Booster",
            icon: "flame.fill",
            description: "The reusable core booster carrying 9 Merlin 1D engines. Lands autonomously on a droneship or land pad, then is refurbished and flown again.",
            colorName: "white",
            specs: [
                RocketSpec(label: "Height", value: "41.2 m"),
                RocketSpec(label: "Engines", value: "9× Merlin 1D"),
                RocketSpec(label: "Thrust (SL)", value: "7,607 kN"),
                RocketSpec(label: "Reuses", value: "Up to 18× flown")
            ],
            subparts: [
                RocketPart(
                    id: "merlin9",
                    name: "Merlin 1D Engine Cluster (×9)",
                    icon: "flame.fill",
                    description: "Nine Merlin 1D engines in an octagon+centre 'Octaweb' arrangement. Three centre engines perform the landing burn.",
                    colorName: "silver",
                    specs: [
                        RocketSpec(label: "Thrust each", value: "854 kN (SL)"),
                        RocketSpec(label: "Total thrust", value: "7,607 kN"),
                        RocketSpec(label: "Propellant", value: "RP-1 / LOX"),
                        RocketSpec(label: "Isp (SL)", value: "282 s"),
                        RocketSpec(label: "Throttle range", value: "40–100%")
                    ],
                    subparts: [
                        RocketPart(id: "m1d_chamber", name: "Combustion Chamber", icon: "circle.fill", description: "High-pressure regeneratively cooled combustion chamber. Uses pintle-type injection.", colorName: "gold", specs: [RocketSpec(label: "Pressure", value: "9.7 MPa"), RocketSpec(label: "Propellants", value: "RP-1 / LOX")], subparts: []),
                        RocketPart(id: "m1d_turbopump", name: "Turbopump", icon: "gear", description: "Single-shaft turbopump driving both RP-1 and LOX pumps at 36,000 RPM.", colorName: "silver", specs: [RocketSpec(label: "Speed", value: "36,000 RPM"), RocketSpec(label: "Shared shaft", value: "LOX + RP-1")], subparts: []),
                        RocketPart(id: "m1d_nozzle", name: "Exhaust Nozzle", icon: "funnel.fill", description: "Heat-shielded nozzle enabling reuse with minimal refurbishment.", colorName: "darkgray", specs: [RocketSpec(label: "Expansion ratio", value: "16:1"), RocketSpec(label: "Reusable", value: "Yes, up to 18× ")], subparts: [])
                    ],
                    stageImageName: "merlin_engine"
                ),
                RocketPart(id: "gridfins", name: "Grid Fins (×4)", icon: "square.grid.2x2.fill", description: "Titanium lattice control surfaces deployed after stage separation to steer the booster through re-entry.", colorName: "darkgray", specs: [RocketSpec(label: "Material", value: "Titanium alloy"), RocketSpec(label: "Span", value: "1.1 m wide"), RocketSpec(label: "Control", value: "Actuated hydraulically")], subparts: [
                    RocketPart(id: "gridfin_actuator", name: "Hydraulic Actuator", icon: "arrow.triangle.2.circlepath", description: "Each grid fin is driven by a hydraulic actuator powered by the TEA-TEB ignition system.", colorName: "silver", specs: [RocketSpec(label: "Type", value: "Hydraulic"), RocketSpec(label: "Response time", value: "<100 ms")], subparts: [])
                ]),
                RocketPart(id: "landinglegs", name: "Landing Legs (×4)", icon: "arrow.down.to.line", description: "Four fold-out legs made of carbon-fibre and aluminium honeycomb. Deploy seconds before touchdown.", colorName: "white", specs: [RocketSpec(label: "Count", value: "4"), RocketSpec(label: "Span deployed", value: "18 m"), RocketSpec(label: "Material", value: "CFRP / Al honeycomb")], subparts: [
                    RocketPart(id: "leg_deployarm", name: "Deploy Arm", icon: "arrow.down.circle.fill", description: "Pneumatic deploy mechanism that extends legs in under 2 seconds using high-pressure helium.", colorName: "silver", specs: [RocketSpec(label: "Deploy time", value: "<2 s"), RocketSpec(label: "Gas", value: "High-pressure He")], subparts: [])
                ]),
                RocketPart(id: "s1_octaweb", name: "Octaweb Engine Mount", icon: "circle.grid.3x3", description: "Structural ring that holds all nine Merlin 1D engines and distributes thrust loads to the booster airframe.", colorName: "darkgray", specs: [RocketSpec(label: "Engines mounted", value: "9"), RocketSpec(label: "Configuration", value: "8 outer + 1 centre"), RocketSpec(label: "Material", value: "Aluminium alloy")], subparts: [])
            ]
        )
    ]

    // upcoming launches
    static let launches: [Launch] = [
        Launch(
            missionName: "Chandrayaan-4",
            rocketName: "LVM3 (GSLV Mk III)",
            agency: "Indian Space Research Organisation",
            agencyAbbr: "ISRO",
            launchDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())!,
            launchSite: "Satish Dhawan Space Centre, Sriharikota",
            status: .upcoming,
            description: "India's next lunar mission to demonstrate sample return capability from the Moon.",
            trajectory: [
                TrajectoryPhase(name: "Liftoff", altitude: "0 km", velocity: "0 km/h", duration: "0s", icon: "flame.fill"),
                TrajectoryPhase(name: "Fairing Sep", altitude: "115 km", velocity: "6,500 km/h", duration: "~T+4m", icon: "arrow.up.circle.fill"),
                TrajectoryPhase(name: "Parking Orbit", altitude: "170 km", velocity: "28,200 km/h", duration: "~T+16m", icon: "circle.circle.fill"),
                TrajectoryPhase(name: "Trans-Lunar", altitude: "200 km", velocity: "40,300 km/h", duration: "~T+30m", icon: "moon.stars.fill"),
                TrajectoryPhase(name: "Lunar Orbit", altitude: "100 km (Lunar)", velocity: "5,830 km/h", duration: "Day 5", icon: "moon.fill"),
                TrajectoryPhase(name: "Landing", altitude: "0 km (Surface)", velocity: "0 km/h", duration: "Day 7", icon: "mappin.circle.fill")
            ],
            orbitType: "Trans-Lunar Injection → Lunar Orbit", maxAltitude: "385,000 km", targetDestination: "Moon (South Pole)",
            imageName: "chandrayaan4_upcoming",
            missionOverview: [
                "Demonstrate end-to-end lunar sample return capability for India",
                "Collect ~3 kg of lunar regolith from the south polar region",
                "Deploy next-gen Pragyan-2 rover with enhanced mobility",
                "Test autonomous docking in lunar orbit between ascender and orbiter",
                "Validate indigenous cryogenic propulsion for deep-space missions"
            ]
        ),
        Launch(
            missionName: "Artemis III",
            rocketName: "SLS Block 1",
            agency: "National Aeronautics and Space Administration",
            agencyAbbr: "NASA",
            launchDate: Calendar.current.date(byAdding: .day, value: 14, to: Date())!,
            launchSite: "Kennedy Space Center, LC-39B",
            status: .upcoming,
            description: "First crewed lunar landing since Apollo 17, targeting the lunar south pole.",
            trajectory: [
                TrajectoryPhase(name: "Liftoff", altitude: "0 km", velocity: "0 km/h", duration: "0s", icon: "flame.fill"),
                TrajectoryPhase(name: "Max Aerodynamic", altitude: "13 km", velocity: "1,500 km/h", duration: "~T+80s", icon: "gauge.high"),
                TrajectoryPhase(name: "Core Stage Sep", altitude: "160 km", velocity: "21,000 km/h", duration: "~T+8m", icon: "arrow.up.and.down.circle.fill"),
                TrajectoryPhase(name: "ICPS Burn", altitude: "185 km", velocity: "39,600 km/h", duration: "~T+2h", icon: "bolt.fill"),
                TrajectoryPhase(name: "Lunar Flyby", altitude: "100 km (Lunar)", velocity: "8,580 km/h", duration: "Day 4", icon: "moon.stars.fill"),
                TrajectoryPhase(name: "Lunar Landing", altitude: "0 km (South Pole)", velocity: "0 km/h", duration: "Day 6", icon: "mappin.circle.fill")
            ],
            orbitType: "Trans-Lunar Injection → Lunar Orbit", maxAltitude: "385,000 km", targetDestination: "Moon (South Pole)",
            imageName: "artemis3_upcoming",
            missionOverview: [
                "Land the first woman and first person of colour on the Moon",
                "Explore the lunar south pole for the first time in history",
                "Conduct ~6.5 days of surface operations with 2+ EVAs",
                "Use SpaceX Starship HLS as the crewed lunar lander",
                "Search for water ice deposits in permanently shadowed craters",
                "Demonstrate sustainable exploration technologies for Mars"
            ]
        )
    ]

    // all missions (full detail)
    static let allMissions: [Mission] = [
        // nasa
        Mission(
            name: "Apollo 11",
            date: "July 16, 1969",
            description: "The first crewed mission to land on the Moon. On July 20, 1969, Commander Neil Armstrong and Lunar Module Pilot Buzz Aldrin became the first humans to walk on the Moon.",
            status: .completed,
            agencyName: "NASA",
            agencyAbbr: "NASA",
            sfSymbol: "moon.fill",
            imageName: "apollo11",
            rocketModel: "Saturn V",
            crew: ["Neil Armstrong (CDR)", "Edwin 'Buzz' Aldrin (LMP)", "Michael Collins (CMP)"],
            duration: "8 days, 3 hours, 18 minutes",
            orbit: "Lunar Surface — Sea of Tranquility",
            launchSiteStr: "Kennedy Space Center, LC-39A, Florida",
            keyFacts: [
                "First humans to walk on the Moon",
                "Landed in the Sea of Tranquility, July 20, 1969",
                "Armstrong and Aldrin spent 2h 31m on the lunar surface",
                "Returned 21.5 kg of lunar samples to Earth",
                "Watched by an estimated 650 million people worldwide"
            ],
            missionPhases: [
                MissionPhase(name: "Launch", day: "July 16", description: "Saturn V lifts off from Kennedy Space Center Pad 39A.", icon: "flame.fill"),
                MissionPhase(name: "Translunar Injection", day: "July 16", description: "S-IVB stage fires for ~6 min to set spacecraft on Moon trajectory.", icon: "moon.stars.fill"),
                MissionPhase(name: "Lunar Orbit Insertion", day: "July 19", description: "SPS engine fires to enter 114 × 111 km lunar orbit.", icon: "circle.circle.fill"),
                MissionPhase(name: "Lunar Landing", day: "July 20 — 20:17 UTC", description: "Eagle lands in the Sea of Tranquility. Armstrong: 'The Eagle has landed.'", icon: "mappin.circle.fill"),
                MissionPhase(name: "Moonwalk (EVA)", day: "July 21 — 02:56 UTC", description: "Armstrong steps onto the Moon, followed by Aldrin. 2h 31m of surface activity.", icon: "person.fill"),
                MissionPhase(name: "Lunar Ascent", day: "July 21", description: "Eagle ascent stage lifts off from the lunar surface.", icon: "arrow.up.circle.fill"),
                MissionPhase(name: "Trans-Earth Injection", day: "July 22", description: "SPS engine fires behind the Moon to begin return journey.", icon: "globe.asia.australia.fill"),
                MissionPhase(name: "Splashdown", day: "July 24", description: "Command Module recovers in Pacific Ocean. Crew quarantined for 21 days.", icon: "water.waves")
            ]
        ),
        // isro
        Mission(
            name: "Chandrayaan-2",
            date: "July 22, 2019",
            description: "India's second lunar exploration mission containing an orbiter, lander (Vikram), and rover (Pragyan). Though the lander crashed, the orbiter continues to provide high-resolution science data.",
            status: .completed,
            agencyName: "ISRO",
            agencyAbbr: "ISRO",
            sfSymbol: "moon.stars.fill",
            imageName: "chandrayaan2_sat",
            rocketModel: "LVM3 (GSLV Mk III)",
            crew: [],
            duration: "Ongoing (Orbiter)",
            orbit: "Lunar Polar Orbit",
            launchSiteStr: "Satish Dhawan Space Centre, Sriharikota",
            keyFacts: [
                "Most complex ISRO mission to date",
                "Orbiter carries 8 scientific instruments",
                "Mapped lunar surface with highest resolution camera (0.3m)",
                "Confirmed presence of water-ice in permanently shadowed craters",
                "Vikram lander lost contact at 2.1km altitude"
            ],
            missionPhases: [
                MissionPhase(name: "Launch", day: "July 22", description: "LVM3 M1 lifts off from Sriharikota.", icon: "flame.fill"),
                MissionPhase(name: "Earth Orbit", day: "July 22 - Aug 13", description: "Series of Earth-bound orbit raising manoeuvres.", icon: "globe.asia.australia.fill"),
                MissionPhase(name: "Translunar Injection", day: "Aug 13", description: "Final burn to set spacecraft on lunar trajectory.", icon: "arrow.up.right.circle.fill"),
                MissionPhase(name: "Lunar Orbit Insertion", day: "Aug 20", description: "Liquid Apogee Motor fires to enter lunar orbit.", icon: "circle.circle.fill"),
                MissionPhase(name: "Lander Separation", day: "Sep 2", description: "Vikram lander separates from the orbiter.", icon: "square.split.diagonal.2x2.fill"),
                MissionPhase(name: "Descent Phase", day: "Sep 7", description: "Rough and fine braking phases. Communication lost at 2.1km altitude.", icon: "exclamationmark.triangle.fill")
            ]
        )
    ]


    // backwards compatibility
    static var missions: [Mission] {
        allMissions.filter { $0.status == .completed }
    }

    // lvm3 (gslv mk iii) rocket parts
    static let lvm3Parts: [RocketPart] = [
        RocketPart(
            id: "lvm3_ogive",
            name: "Payload Fairing",
            icon: "capsule",
            description: "Aerodynamic nosecone protecting the payload during ascent. Jettisoned after the vehicle exits the dense atmosphere.",
            colorName: "white",
            specs: [
                RocketSpec(label: "Height", value: "10.7 m"),
                RocketSpec(label: "Diameter", value: "5.0 m"),
                RocketSpec(label: "Material", value: "Aluminium alloy")
            ],
            subparts: [
                RocketPart(id: "lvm3_ogive_half1", name: "Fairing Half A", icon: "square.split.diagonal", description: "First half of the bi-conic payload fairing.", colorName: "white", specs: [RocketSpec(label: "Separation", value: "Pyrotechnic")], subparts: []),
                RocketPart(id: "lvm3_ogive_half2", name: "Fairing Half B", icon: "square.split.diagonal.2x2", description: "Second half of the bi-conic payload fairing.", colorName: "white", specs: [RocketSpec(label: "Material", value: "Al alloy + CFRP")], subparts: [])
            ],
            partImageName: "lvm3_payload"
        ),
        RocketPart(
            id: "lvm3_c25",
            name: "C25 Cryogenic Upper Stage",
            icon: "snowflake",
            description: "India's first indigenous cryogenic upper stage. Powered by the CE-20 engine burning liquid hydrogen and liquid oxygen.",
            colorName: "blue",
            specs: [
                RocketSpec(label: "Height", value: "13.5 m"),
                RocketSpec(label: "Diameter", value: "4.0 m"),
                RocketSpec(label: "Engine", value: "1× CE-20"),
                RocketSpec(label: "Thrust", value: "186 kN"),
                RocketSpec(label: "Propellant", value: "LH₂ / LOX")
            ],
            subparts: [
                RocketPart(id: "lvm3_ce20", name: "CE-20 Cryogenic Engine", icon: "flame.fill", description: "Indigenous gas-generator cycle cryogenic engine. Develops 186 kN thrust using staged combustion of LH₂/LOX.", colorName: "silver", specs: [RocketSpec(label: "Thrust", value: "186 kN"), RocketSpec(label: "Isp", value: "443 s"), RocketSpec(label: "Burn time", value: "580 s")], subparts: [
                    RocketPart(id: "ce20_turbo", name: "Turbopump", icon: "gear", description: "Dual turbopump assembly driving LH₂ and LOX propellants.", colorName: "silver", specs: [RocketSpec(label: "Speed", value: "40,000 RPM")], subparts: []),
                    RocketPart(id: "ce20_nozzle", name: "Expansion Nozzle", icon: "funnel.fill", description: "High-expansion-ratio nozzle optimised for vacuum performance.", colorName: "darkgray", specs: [RocketSpec(label: "Expansion ratio", value: "100:1")], subparts: [])
                ], stageImageName: "ce20_engine", partImageName: "ce20_engine"),
                RocketPart(id: "lvm3_c25_tank", name: "Cryogenic Propellant Tanks", icon: "drop.fill", description: "Insulated tanks holding LH₂ at -253°C and LOX at -183°C.", colorName: "blue", specs: [RocketSpec(label: "LH₂ mass", value: "5,100 kg"), RocketSpec(label: "LOX mass", value: "22,200 kg")], subparts: [])
            ],
            partImageName: "lvm3_c25"
        ),
        RocketPart(
            id: "lvm3_l110",
            name: "L110 Core Stage (Liquid)",
            icon: "cylinder.fill",
            description: "Twin-engine liquid core stage using Vikas engines burning UH25 fuel and N₂O₄ oxidiser. Primary thrust during the first ~200 seconds of flight.",
            colorName: "cream",
            specs: [
                RocketSpec(label: "Height", value: "21.3 m"),
                RocketSpec(label: "Diameter", value: "4.0 m"),
                RocketSpec(label: "Engines", value: "2× Vikas"),
                RocketSpec(label: "Thrust", value: "1,598 kN"),
                RocketSpec(label: "Propellant", value: "UH25 / N₂O₄")
            ],
            subparts: [
                RocketPart(id: "lvm3_vikas", name: "Vikas Engine (×2)", icon: "flame.fill", description: "Improved version of the French Viking engine, licence-produced by ISRO. Regeneratively cooled.", colorName: "gold", specs: [RocketSpec(label: "Thrust each", value: "799 kN"), RocketSpec(label: "Isp", value: "293 s"), RocketSpec(label: "Gimbal", value: "±4°")], subparts: [
                    RocketPart(id: "vikas_chamber", name: "Combustion Chamber", icon: "circle.fill", description: "Regeneratively-cooled chamber operating at high pressure.", colorName: "gold", specs: [RocketSpec(label: "Pressure", value: "5.85 MPa")], subparts: []),
                    RocketPart(id: "vikas_turbopump", name: "Turbopump", icon: "gear", description: "Single-shaft turbopump assembly.", colorName: "silver", specs: [RocketSpec(label: "Type", value: "Gas-generator")], subparts: [])
                ]),
                RocketPart(id: "lvm3_l110_tank", name: "Propellant Tanks", icon: "drop.fill", description: "UH25 fuel and N₂O₄ oxidiser tanks for the core stage.", colorName: "cream", specs: [RocketSpec(label: "Total propellant", value: "110,000 kg")], subparts: [])
            ],
            partImageName: "lvm3_l110"
        ),
        RocketPart(
            id: "lvm3_s200",
            name: "S200 Solid Boosters (×2)",
            icon: "flame.fill",
            description: "Two large S200 solid rocket boosters strapped to the core. Each is the third-largest solid booster ever built. They provide most of the liftoff thrust.",
            colorName: "orange",
            specs: [
                RocketSpec(label: "Height", value: "25.0 m"),
                RocketSpec(label: "Diameter", value: "3.2 m"),
                RocketSpec(label: "Thrust each", value: "5,150 kN"),
                RocketSpec(label: "Total thrust", value: "10,300 kN"),
                RocketSpec(label: "Propellant", value: "HTPB (solid)"),
                RocketSpec(label: "Burn time", value: "130 s")
            ],
            subparts: [
                RocketPart(id: "s200_grain", name: "Propellant Grain", icon: "circle.grid.3x3.fill", description: "Three segments of HTPB-based composite solid propellant. Star-shaped bore for controlled burn.", colorName: "orange", specs: [RocketSpec(label: "Segments", value: "3"), RocketSpec(label: "Mass each booster", value: "207,000 kg")], subparts: []),
                RocketPart(id: "s200_nozzle", name: "Flex-Seal Nozzle", icon: "funnel.fill", description: "Submerged flex-seal vectorable nozzle providing thrust vector control.", colorName: "darkgray", specs: [RocketSpec(label: "Gimbal range", value: "±3°"), RocketSpec(label: "Type", value: "Submerged nozzle")], subparts: []),
                RocketPart(id: "s200_igniter", name: "Pyrogen Igniter", icon: "bolt.fill", description: "Igniter system that initiates combustion of the solid propellant grain.", colorName: "red", specs: [RocketSpec(label: "Type", value: "Pyrogen")], subparts: [])
            ],
            partImageName: "lvm3_s200"
        )
    ]

    // pslv-xl rocket parts
    static let pslvXLParts: [RocketPart] = [
        RocketPart(
            id: "pslv_fairing",
            name: "Payload Fairing",
            icon: "capsule",
            description: "Heat shield protecting spacecraft during launch. PSLV uses a 3.2 m or 2.65 m diameter fairing.",
            colorName: "white",
            specs: [
                RocketSpec(label: "Diameter", value: "3.2 m"),
                RocketSpec(label: "Material", value: "Composite")
            ],
            subparts: []
        ),
        RocketPart(
            id: "pslv_ps4",
            name: "PS4 — Fourth Stage (Liquid)",
            icon: "drop.fill",
            description: "Twin-engine pressure-fed liquid upper stage using MMH/MON-3. Can restart for multi-orbit injection.",
            colorName: "gold",
            specs: [
                RocketSpec(label: "Engines", value: "2× L-2-5"),
                RocketSpec(label: "Thrust", value: "14.6 kN"),
                RocketSpec(label: "Propellant", value: "MMH / MON-3"),
                RocketSpec(label: "Restartable", value: "Yes")
            ],
            subparts: [
                RocketPart(id: "ps4_l25", name: "L-2-5 Engine (×2)", icon: "flame.fill", description: "Small pressure-fed bi-propellant engine used for precise orbital injection.", colorName: "gold", specs: [RocketSpec(label: "Thrust each", value: "7.3 kN"), RocketSpec(label: "Isp", value: "308 s")], subparts: [])
            ]
        ),
        RocketPart(
            id: "pslv_ps3",
            name: "PS3 — Third Stage (Solid)",
            icon: "circle.grid.3x3.fill",
            description: "High-performance solid motor providing exo-atmospheric acceleration. Uses HEF-20 propellant.",
            colorName: "lightgray",
            specs: [
                RocketSpec(label: "Thrust", value: "240 kN"),
                RocketSpec(label: "Mass", value: "7,560 kg"),
                RocketSpec(label: "Propellant", value: "HEF-20 solid"),
                RocketSpec(label: "Burn time", value: "83 s")
            ],
            subparts: []
        ),
        RocketPart(
            id: "pslv_ps2",
            name: "PS2 — Second Stage (Liquid)",
            icon: "cylinder.fill",
            description: "Liquid-fuelled stage powered by the Vikas engine. Carries the vehicle through the upper atmosphere.",
            colorName: "cream",
            specs: [
                RocketSpec(label: "Engine", value: "1× Vikas"),
                RocketSpec(label: "Thrust", value: "799 kN"),
                RocketSpec(label: "Propellant", value: "UH25 / N₂O₄"),
                RocketSpec(label: "Burn time", value: "133 s")
            ],
            subparts: [
                RocketPart(id: "pslv_vikas", name: "Vikas Engine", icon: "flame.fill", description: "Regeneratively-cooled liquid engine. French Viking heritage.", colorName: "gold", specs: [RocketSpec(label: "Thrust", value: "799 kN"), RocketSpec(label: "Isp", value: "293 s")], subparts: [])
            ]
        ),
        RocketPart(
            id: "pslv_ps1",
            name: "PS1 — First Stage (Solid) + Boosters",
            icon: "flame.fill",
            description: "Large solid-fuel core stage with 6 XL strap-on solid boosters providing combined 6,380 kN of liftoff thrust.",
            colorName: "orange",
            specs: [
                RocketSpec(label: "Core thrust", value: "4,860 kN"),
                RocketSpec(label: "Strap-ons", value: "6× PSOM-XL"),
                RocketSpec(label: "Total thrust", value: "~6,380 kN"),
                RocketSpec(label: "Propellant", value: "HTPB (solid)"),
                RocketSpec(label: "Burn time", value: "109 s")
            ],
            subparts: [
                RocketPart(id: "pslv_core", name: "S139 Core Motor", icon: "flame.fill", description: "One of the largest solid rocket cores in the world. 139-tonne propellant load.", colorName: "orange", specs: [RocketSpec(label: "Propellant mass", value: "139,000 kg"), RocketSpec(label: "Thrust", value: "4,860 kN")], subparts: []),
                RocketPart(id: "pslv_strap", name: "PSOM-XL Boosters (×6)", icon: "flame.fill", description: "Six extended-length ground-lit strap-on motors. Four ignite at liftoff, two at altitude.", colorName: "orange", specs: [RocketSpec(label: "Thrust each", value: "~720 kN"), RocketSpec(label: "Burn time", value: "49 s"), RocketSpec(label: "Ground-lit", value: "4; Air-lit: 2")], subparts: [])
            ]
        )
    ]

    // atlas v 541 rocket parts
    static let atlasV541Parts: [RocketPart] = [
        RocketPart(
            id: "atlas_fairing",
            name: "5-Metre Payload Fairing",
            icon: "capsule",
            description: "Large composite fairing providing volume for the Mars 2020 rover and its entry capsule.",
            colorName: "white",
            specs: [
                RocketSpec(label: "Diameter", value: "5.4 m"),
                RocketSpec(label: "Length", value: "20.7 m (short) / 26.5 m (long)"),
                RocketSpec(label: "Material", value: "Composite sandwich")
            ],
            subparts: []
        ),
        RocketPart(
            id: "atlas_centaur",
            name: "Centaur III Upper Stage",
            icon: "snowflake",
            description: "Cryogenic second stage powered by the RL-10C engine. One of the most reliable upper stages ever flown.",
            colorName: "blue",
            specs: [
                RocketSpec(label: "Engine", value: "1× RL-10C"),
                RocketSpec(label: "Thrust", value: "101.8 kN"),
                RocketSpec(label: "Propellant", value: "LH₂ / LOX"),
                RocketSpec(label: "Isp", value: "450 s"),
                RocketSpec(label: "Restarts", value: "Multiple")
            ],
            subparts: [
                RocketPart(id: "atlas_rl10", name: "RL-10C Engine", icon: "flame.fill", description: "Aerojet Rocketdyne expander-cycle engine. Heritage dates back to the 1960s with continuous improvement.", colorName: "silver", specs: [RocketSpec(label: "Thrust", value: "101.8 kN"), RocketSpec(label: "Isp", value: "450 s"), RocketSpec(label: "Cycle", value: "Expander")], subparts: [
                    RocketPart(id: "rl10_nozzle", name: "Extendable Nozzle", icon: "funnel.fill", description: "Carbon-carbon extendable nozzle that deploys after stage separation for maximum Isp.", colorName: "darkgray", specs: [RocketSpec(label: "Expansion ratio", value: "130:1")], subparts: [])
                ]),
                RocketPart(id: "atlas_centaur_tank", name: "Propellant Tanks", icon: "drop.fill", description: "Common bulkhead LH₂/LOX tanks. Steel balloon structure.", colorName: "blue", specs: [RocketSpec(label: "LOX", value: "15,700 kg"), RocketSpec(label: "LH₂", value: "2,460 kg")], subparts: [])
            ]
        ),
        RocketPart(
            id: "atlas_ccb",
            name: "Common Core Booster (CCB)",
            icon: "cylinder.fill",
            description: "Main booster stage powered by the Russian-designed RD-180 engine. Structurally uses isogrid aluminium alloy.",
            colorName: "cream",
            specs: [
                RocketSpec(label: "Height", value: "32.5 m"),
                RocketSpec(label: "Diameter", value: "3.81 m"),
                RocketSpec(label: "Engine", value: "1× RD-180"),
                RocketSpec(label: "Thrust", value: "3,827 kN"),
                RocketSpec(label: "Propellant", value: "RP-1 / LOX")
            ],
            subparts: [
                RocketPart(id: "atlas_rd180", name: "RD-180 Engine", icon: "flame.fill", description: "Twin-chamber, twin-nozzle staged-combustion engine. Derived from the Soviet RD-170. Among the most powerful kerosene engines.", colorName: "gold", specs: [RocketSpec(label: "Thrust", value: "3,827 kN"), RocketSpec(label: "Isp", value: "311 s (SL)"), RocketSpec(label: "Chambers", value: "2"), RocketSpec(label: "Throttle", value: "47–100%")], subparts: [
                    RocketPart(id: "rd180_preburner", name: "Pre-Burner", icon: "bolt.fill", description: "Oxygen-rich pre-burner driving the turbopump assembly.", colorName: "orange", specs: [RocketSpec(label: "Type", value: "O₂-rich staged combustion")], subparts: []),
                    RocketPart(id: "rd180_turbopump", name: "Turbopump Assembly", icon: "gear", description: "High-pressure turbopump running at extreme RPM.", colorName: "silver", specs: [RocketSpec(label: "Pressure", value: "26.7 MPa")], subparts: [])
                ])
            ]
        ),
        RocketPart(
            id: "atlas_srb",
            name: "Solid Rocket Boosters (×4)",
            icon: "flame.fill",
            description: "Four AJ-60A solid rocket boosters augmenting first-stage thrust. Jettisoned at ~94 seconds after liftoff.",
            colorName: "orange",
            specs: [
                RocketSpec(label: "Thrust each", value: "1,270 kN"),
                RocketSpec(label: "Total", value: "5,080 kN"),
                RocketSpec(label: "Burn time", value: "94 s"),
                RocketSpec(label: "Manufacturer", value: "Aerojet Rocketdyne")
            ],
            subparts: [
                RocketPart(id: "atlas_aj60a", name: "AJ-60A Motor", icon: "flame.fill", description: "Monolithic solid motor with HTPB propellant.", colorName: "orange", specs: [RocketSpec(label: "Propellant", value: "HTPB"), RocketSpec(label: "Mass each", value: "46,697 kg")], subparts: [])
            ]
        )
    ]

    // ariane 5 rocket parts
    static let ariane5Parts: [RocketPart] = [
        RocketPart(
            id: "ar5_fairing",
            name: "Payload Fairing / SPELTRA",
            icon: "capsule",
            description: "5.4 m diameter fairing or SPELTRA dual-launch adapter. For JWST, a specially-designed long fairing was used.",
            colorName: "white",
            specs: [
                RocketSpec(label: "Diameter", value: "5.4 m"),
                RocketSpec(label: "Length", value: "17 m (long)"),
                RocketSpec(label: "Material", value: "CFRP composite")
            ],
            subparts: []
        ),
        RocketPart(
            id: "ar5_esc",
            name: "ESC-A Upper Stage",
            icon: "snowflake",
            description: "Cryogenic upper stage powered by the HM7B engine. Burns LH₂/LOX to deliver payloads to their final orbit.",
            colorName: "blue",
            specs: [
                RocketSpec(label: "Engine", value: "1× HM7B"),
                RocketSpec(label: "Thrust", value: "64.8 kN"),
                RocketSpec(label: "Propellant", value: "LH₂ / LOX"),
                RocketSpec(label: "Isp", value: "446 s"),
                RocketSpec(label: "Burn time", value: "960 s")
            ],
            subparts: [
                RocketPart(id: "ar5_hm7b", name: "HM7B Engine", icon: "flame.fill", description: "Expander-cycle hydrogen/oxygen engine with reliable flight heritage since 1979.", colorName: "silver", specs: [RocketSpec(label: "Thrust", value: "64.8 kN"), RocketSpec(label: "Chambers", value: "1"), RocketSpec(label: "Cycle", value: "Gas generator")], subparts: [])
            ]
        ),
        RocketPart(
            id: "ar5_epc",
            name: "EPC Core Stage (Cryogenic)",
            icon: "cylinder.fill",
            description: "Main cryogenic core stage powered by the Vulcain 2 engine. Largest LH₂/LOX stage in European launch history.",
            colorName: "cream",
            specs: [
                RocketSpec(label: "Height", value: "30.5 m"),
                RocketSpec(label: "Diameter", value: "5.4 m"),
                RocketSpec(label: "Engine", value: "1× Vulcain 2"),
                RocketSpec(label: "Thrust", value: "1,359 kN"),
                RocketSpec(label: "Propellant", value: "LH₂ / LOX")
            ],
            subparts: [
                RocketPart(id: "ar5_vulcain", name: "Vulcain 2 Engine", icon: "flame.fill", description: "Gas-generator cycle cryogenic engine. Successor to Vulcain 1 with improved performance.", colorName: "gold", specs: [RocketSpec(label: "Thrust", value: "1,359 kN"), RocketSpec(label: "Isp", value: "431 s"), RocketSpec(label: "Chamber pressure", value: "11.7 MPa")], subparts: [
                    RocketPart(id: "vulcain_turbo", name: "Turbopump Assembly", icon: "gear", description: "Two separate turbopumps for LH₂ and LOX, driven by exhaust gas from the gas generator.", colorName: "silver", specs: [RocketSpec(label: "LH₂ pump speed", value: "33,000 RPM"), RocketSpec(label: "LOX pump speed", value: "13,000 RPM")], subparts: []),
                    RocketPart(id: "vulcain_nozzle", name: "Regeneratively Cooled Nozzle", icon: "funnel.fill", description: "Extended nozzle with hydrogen film cooling for thermal protection.", colorName: "darkgray", specs: [RocketSpec(label: "Expansion ratio", value: "58:1")], subparts: [])
                ]),
                RocketPart(id: "ar5_epc_tank", name: "Propellant Tanks", icon: "drop.fill", description: "Large aluminium alloy tanks. LOX tank is above the LH₂ tank.", colorName: "blue", specs: [RocketSpec(label: "LOX mass", value: "132,300 kg"), RocketSpec(label: "LH₂ mass", value: "25,800 kg")], subparts: [])
            ]
        ),
        RocketPart(
            id: "ar5_eap",
            name: "EAP Solid Boosters (×2)",
            icon: "flame.fill",
            description: "Two P241 solid rocket boosters providing 92% of liftoff thrust. Largest solid boosters in Europe.",
            colorName: "orange",
            specs: [
                RocketSpec(label: "Height", value: "31.6 m"),
                RocketSpec(label: "Diameter", value: "3.05 m"),
                RocketSpec(label: "Thrust each", value: "6,470 kN"),
                RocketSpec(label: "Total thrust", value: "12,940 kN"),
                RocketSpec(label: "Burn time", value: "130 s")
            ],
            subparts: [
                RocketPart(id: "ar5_eap_grain", name: "Propellant Segments", icon: "circle.grid.3x3.fill", description: "Three propellant segments cast into the booster casing. HTPB-based, 238 tonnes each.", colorName: "orange", specs: [RocketSpec(label: "Mass each", value: "238,450 kg"), RocketSpec(label: "Segments", value: "3")], subparts: []),
                RocketPart(id: "ar5_eap_nozzle", name: "Flexible Bearing Nozzle", icon: "funnel.fill", description: "Gimballed nozzle for thrust vector control during booster phase.", colorName: "darkgray", specs: [RocketSpec(label: "Gimbal range", value: "±6°")], subparts: [])
            ]
        )
    ]

    // h-iia rocket parts
    static let hIIAParts: [RocketPart] = [
        RocketPart(
            id: "h2a_fairing",
            name: "Payload Fairing",
            icon: "capsule",
            description: "4S or 5S fairing protecting the payload. Made of composite material with acoustic blankets.",
            colorName: "white",
            specs: [
                RocketSpec(label: "Diameter", value: "4.07 m"),
                RocketSpec(label: "Options", value: "4S (short) / 5S (long)"),
                RocketSpec(label: "Material", value: "CFRP composite")
            ],
            subparts: []
        ),
        RocketPart(
            id: "h2a_second",
            name: "Second Stage",
            icon: "snowflake",
            description: "Cryogenic upper stage powered by the LE-5B engine. LH₂/LOX propellant. Capable of multiple restarts.",
            colorName: "blue",
            specs: [
                RocketSpec(label: "Engine", value: "1× LE-5B"),
                RocketSpec(label: "Thrust", value: "137 kN"),
                RocketSpec(label: "Propellant", value: "LH₂ / LOX"),
                RocketSpec(label: "Isp", value: "447 s")
            ],
            subparts: [
                RocketPart(id: "h2a_le5b", name: "LE-5B Engine", icon: "flame.fill", description: "Expander bleed cycle engine. Highly efficient and restartable. Used for precise orbit insertion.", colorName: "silver", specs: [RocketSpec(label: "Thrust", value: "137 kN"), RocketSpec(label: "Isp", value: "447 s"), RocketSpec(label: "Cycle", value: "Expander bleed"), RocketSpec(label: "Restarts", value: "Multiple")], subparts: [
                    RocketPart(id: "le5b_nozzle", name: "Extended Nozzle", icon: "funnel.fill", description: "Regeneratively cooled nozzle extension for vacuum efficiency.", colorName: "darkgray", specs: [RocketSpec(label: "Expansion ratio", value: "110:1")], subparts: [])
                ])
            ]
        ),
        RocketPart(
            id: "h2a_first",
            name: "First Stage",
            icon: "cylinder.fill",
            description: "Main cryogenic core stage powered by the LE-7A engine. Burns LH₂ and LOX. Forms the structural backbone of the vehicle.",
            colorName: "cream",
            specs: [
                RocketSpec(label: "Height", value: "37.2 m"),
                RocketSpec(label: "Diameter", value: "4.0 m"),
                RocketSpec(label: "Engine", value: "1× LE-7A"),
                RocketSpec(label: "Thrust", value: "1,098 kN"),
                RocketSpec(label: "Propellant", value: "LH₂ / LOX")
            ],
            subparts: [
                RocketPart(id: "h2a_le7a", name: "LE-7A Engine", icon: "flame.fill", description: "Staged-combustion cycle cryogenic engine. Japan's most powerful rocket engine.", colorName: "gold", specs: [RocketSpec(label: "Thrust", value: "1,098 kN"), RocketSpec(label: "Isp", value: "440 s (vac)"), RocketSpec(label: "Cycle", value: "Staged combustion"), RocketSpec(label: "Chamber pressure", value: "12.1 MPa")], subparts: [
                    RocketPart(id: "le7a_preburner", name: "Fuel-Rich Pre-Burner", icon: "bolt.fill", description: "Fuel-rich pre-burner driving the main turbopump assembly.", colorName: "orange", specs: [RocketSpec(label: "Type", value: "H₂-rich")], subparts: []),
                    RocketPart(id: "le7a_turbo", name: "Turbopump", icon: "gear", description: "High-pressure dual turbopump assembly.", colorName: "silver", specs: [RocketSpec(label: "LOX pump pressure", value: "19 MPa")], subparts: [])
                ]),
                RocketPart(id: "h2a_first_tank", name: "Propellant Tanks", icon: "drop.fill", description: "Common bulkhead LH₂/LOX tank assembly.", colorName: "blue", specs: [RocketSpec(label: "LOX", value: "65,000 kg"), RocketSpec(label: "LH₂", value: "12,000 kg")], subparts: [])
            ]
        ),
        RocketPart(
            id: "h2a_srb",
            name: "SRB-A3 Solid Boosters (×2)",
            icon: "flame.fill",
            description: "Two solid rocket boosters providing additional liftoff thrust. Composite casing with HTPB propellant.",
            colorName: "orange",
            specs: [
                RocketSpec(label: "Thrust each", value: "2,305 kN"),
                RocketSpec(label: "Total thrust", value: "4,610 kN"),
                RocketSpec(label: "Burn time", value: "100 s"),
                RocketSpec(label: "Propellant", value: "HTPB composite")
            ],
            subparts: [
                RocketPart(id: "h2a_srb_grain", name: "Propellant Grain", icon: "circle.grid.3x3.fill", description: "Monolithic HTPB/AP composite propellant grain.", colorName: "orange", specs: [RocketSpec(label: "Mass", value: "65,000 kg")], subparts: []),
                RocketPart(id: "h2a_srb_nozzle", name: "Movable Nozzle", icon: "funnel.fill", description: "Flexible-bearing gimballed nozzle for thrust vector control.", colorName: "darkgray", specs: [RocketSpec(label: "Gimbal", value: "±5°")], subparts: [])
            ]
        )
    ]

    // sls block 1 rocket parts
    static let slsParts: [RocketPart] = [
        RocketPart(
            id: "sls_les",
            name: "Launch Abort System",
            icon: "arrow.up.to.line",
            description: "Abort tower for the Orion crew capsule. Provides escape capability during launch using three motors.",
            colorName: "red",
            specs: [
                RocketSpec(label: "Height", value: "14 m"),
                RocketSpec(label: "Thrust", value: "1,760 kN"),
                RocketSpec(label: "Motors", value: "3 solid-fuel")
            ],
            subparts: [
                RocketPart(id: "sls_les_abort", name: "Abort Motor", icon: "flame.fill", description: "Provides high-thrust escape force for the Orion capsule.", colorName: "red", specs: [RocketSpec(label: "Thrust", value: "1,760 kN"), RocketSpec(label: "Burn time", value: "3.5 s")], subparts: []),
                RocketPart(id: "sls_les_jettison", name: "Jettison Motor", icon: "arrow.up.circle.fill", description: "Separates the LAS from the crew module after it's no longer needed.", colorName: "orange", specs: [RocketSpec(label: "Burn time", value: "1.5 s")], subparts: [])
            ]
        ),
        RocketPart(
            id: "sls_orion",
            name: "Orion Crew Module",
            icon: "capsule.fill",
            description: "Multi-purpose crew vehicle designed for deep-space missions. Houses 4 astronauts for up to 21 days.",
            colorName: "cream",
            specs: [
                RocketSpec(label: "Crew", value: "4 astronauts"),
                RocketSpec(label: "Mass", value: "26,520 kg (total)"),
                RocketSpec(label: "Habitable volume", value: "9 m³"),
                RocketSpec(label: "Heat shield", value: "AVCOAT ablative")
            ],
            subparts: [
                RocketPart(id: "sls_orion_cm", name: "Crew Capsule", icon: "person.3.fill", description: "Pressurised crew module with life support, computers, and avionics.", colorName: "cream", specs: [RocketSpec(label: "Diameter", value: "5.02 m"), RocketSpec(label: "Height", value: "3.3 m")], subparts: []),
                RocketPart(id: "sls_orion_sm", name: "European Service Module", icon: "cylinder.fill", description: "ESA-built service module providing propulsion, power, and thermal control.", colorName: "silver", specs: [RocketSpec(label: "Engine", value: "1× AJ10 (33 kN)"), RocketSpec(label: "Solar arrays", value: "4 wings (11.2 kW)")], subparts: [])
            ]
        ),
        RocketPart(
            id: "sls_icps",
            name: "ICPS (Interim Cryogenic Propulsion Stage)",
            icon: "snowflake",
            description: "Modified Delta Cryogenic Second Stage providing Trans-Lunar Injection. Single RL-10B-2 engine.",
            colorName: "blue",
            specs: [
                RocketSpec(label: "Engine", value: "1× RL-10B-2"),
                RocketSpec(label: "Thrust", value: "110 kN"),
                RocketSpec(label: "Propellant", value: "LH₂ / LOX"),
                RocketSpec(label: "Isp", value: "462 s")
            ],
            subparts: [
                RocketPart(id: "sls_rl10", name: "RL-10B-2 Engine", icon: "flame.fill", description: "High-performance expander-cycle engine. Modified and uprated from the classic RL-10.", colorName: "silver", specs: [RocketSpec(label: "Thrust", value: "110 kN"), RocketSpec(label: "Expansion ratio", value: "285:1")], subparts: [])
            ]
        ),
        RocketPart(
            id: "sls_core",
            name: "Core Stage",
            icon: "cylinder.fill",
            description: "Largest rocket stage ever built. 64.6 m tall, powered by four RS-25 engines (Space Shuttle Main Engines).",
            colorName: "cream",
            specs: [
                RocketSpec(label: "Height", value: "64.6 m"),
                RocketSpec(label: "Diameter", value: "8.4 m"),
                RocketSpec(label: "Engines", value: "4× RS-25"),
                RocketSpec(label: "Thrust (vac)", value: "8,800 kN"),
                RocketSpec(label: "Propellant", value: "LH₂ / LOX (733,000 kg)")
            ],
            subparts: [
                RocketPart(id: "sls_rs25", name: "RS-25 Engine Cluster (×4)", icon: "flame.fill", description: "Re-used Space Shuttle Main Engines. Staged-combustion cycle. Among the most tested rocket engines in history.", colorName: "gold", specs: [RocketSpec(label: "Thrust each", value: "2,279 kN (vac)"), RocketSpec(label: "Isp", value: "452 s"), RocketSpec(label: "Throttle", value: "67–109%"), RocketSpec(label: "Cycle", value: "Staged combustion")], subparts: [
                    RocketPart(id: "rs25_hpftp", name: "High-Pressure Fuel Turbopump", icon: "gear", description: "Pumps LH₂ at 70,000+ RPM. Generates the power equivalent of 7 locomotives.", colorName: "silver", specs: [RocketSpec(label: "Speed", value: "35,360 RPM"), RocketSpec(label: "Power", value: "55 MW")], subparts: []),
                    RocketPart(id: "rs25_chamber", name: "Main Combustion Chamber", icon: "circle.fill", description: "Regeneratively cooled chamber operating at 20.7 MPa.", colorName: "gold", specs: [RocketSpec(label: "Pressure", value: "20.7 MPa"), RocketSpec(label: "Temperature", value: "3,315 °C")], subparts: []),
                    RocketPart(id: "rs25_nozzle", name: "Bell Nozzle", icon: "funnel.fill", description: "Regeneratively cooled nozzle with hydrogen film cooling.", colorName: "darkgray", specs: [RocketSpec(label: "Expansion ratio", value: "77.5:1"), RocketSpec(label: "Exit diameter", value: "2.3 m")], subparts: [])
                ]),
                RocketPart(id: "sls_core_tank", name: "Propellant Tanks", icon: "drop.fill", description: "LOX tank forward, LH₂ tank aft. Aluminium-lithium alloy construction.", colorName: "blue", specs: [RocketSpec(label: "LOX", value: "225,000 kg"), RocketSpec(label: "LH₂", value: "508,000 kg"), RocketSpec(label: "Total", value: "733,000 kg")], subparts: [])
            ]
        ),
        RocketPart(
            id: "sls_srb",
            name: "Solid Rocket Boosters (×2)",
            icon: "flame.fill",
            description: "Two 5-segment solid rocket boosters derived from Space Shuttle SRBs. Provide 75% of liftoff thrust.",
            colorName: "orange",
            specs: [
                RocketSpec(label: "Height", value: "54 m"),
                RocketSpec(label: "Diameter", value: "3.71 m"),
                RocketSpec(label: "Thrust each", value: "14,700 kN"),
                RocketSpec(label: "Total thrust", value: "29,400 kN"),
                RocketSpec(label: "Segments", value: "5"),
                RocketSpec(label: "Burn time", value: "126 s")
            ],
            subparts: [
                RocketPart(id: "sls_srb_grain", name: "Propellant Segments (×5)", icon: "circle.grid.3x3.fill", description: "Five PBAN/AP propellant segments producing 14,700 kN per booster.", colorName: "orange", specs: [RocketSpec(label: "Mass each booster", value: "726,000 kg"), RocketSpec(label: "Propellant", value: "PBAN (solid)")], subparts: []),
                RocketPart(id: "sls_srb_nozzle", name: "Vectorable Nozzle", icon: "funnel.fill", description: "Gimballed nozzle providing roll, pitch, and yaw control during boost phase.", colorName: "darkgray", specs: [RocketSpec(label: "Gimbal range", value: "±8°")], subparts: [])
            ]
        )
    ]

    // satellite data (procedural 3d)
    

    
    static let marsOrbiterSatellite = SatellitePart(
        id: "mom_bus",
        name: "Mars Orbiter Mission",
        description: "India's first interplanetary mission. Features a cuboid bus with composite structure.",
        icon: "circle.grid.cross.fill",
        shape: .box,
        width: 1.5, height: 1.5, length: 1.5,
        color: .yellow, // gold foil
        position: .zero,
        subparts: [
            // high gain antenna
            SatellitePart(
                id: "mom_antenna",
                name: "High Gain Antenna",
                description: "2.2m parabolic dish for communicating with Earth from Mars orbit.",
                icon: "antenna.radiowaves.left.and.right",
                shape: .dish,
                width: 2.2, height: 0.5, length: 2.2,
                color: .gray,
                position: [0.8, 0, 0], // side mounted
                subparts: [],
                specs: [RocketSpec(label: "Band", value: "S-band")]
            ),
            // solar panels
            SatellitePart(
                id: "mom_panels",
                name: "Solar Arrays",
                description: "Three-panel solar array generating 840W of power.",
                icon: "sun.max.fill",
                shape: .panel,
                width: 1.8, height: 0.1, length: 4.0, // wing
                color: .blue,
                position: [-1.5, 0, 0], // opposite side
                subparts: [],
                specs: [RocketSpec(label: "Power", value: "840 W")]
            )
        ],
        specs: [RocketSpec(label: "Dry Mass", value: "500 kg"), RocketSpec(label: "Propellant", value: "852 kg")]
    )

    static func satellite(for missionModel: String) -> SatellitePart? {
        // simplified mapping based on rocket model or mission name
        // in a real app we'd map by mission id

        if missionModel.contains("PSLV-XL") && missionModel.contains("C25") { return marsOrbiterSatellite } // mom was c25
        return nil
    }
    
    // helper: get rocket parts for a given rocket model name
    static func rocketParts(for model: String) -> [RocketPart] {
        switch model {
        case "Saturn V": return saturnVParts
        case "Falcon 9 Block 5", "Falcon 9": return falcon9Parts
        case "LVM3", "LVM3-G1": return lvm3Parts
        case "PSLV-XL": return pslvXLParts
        case "Atlas V 541": return atlasV541Parts
        case "Ariane 5 ECA", "Ariane 5 G+", "Ariane 5": return ariane5Parts
        case "H-IIA": return hIIAParts
        case "SLS Block 1": return slsParts
        default: return []
        }
    }

    // rocket overview data (real-life specs)
    static func rocketOverview(for model: String) -> RocketOverview? {
        switch model {
        case "Saturn V":
            return RocketOverview(name: "Saturn V", agency: "NASA", agencyIcon: "building.columns.fill", country: "United States", height: "110.6 m", diameter: "10.1 m", liftoffMass: "2,970,000 kg", liftoffThrust: "35,100 kN", payloadLEO: "140,000 kg", payloadGTO: "48,600 kg (TLI)", stages: 3, firstFlight: "Nov 9, 1967", successRate: "92%", totalLaunches: "13", status: "Retired", description: "The Saturn V was a super-heavy-lift launch vehicle developed by NASA for the Apollo program. Standing 110.6 meters tall, it remains the tallest, heaviest, and most powerful rocket ever brought to operational status. It launched astronauts to the Moon during six successful Apollo missions and also launched Skylab, America's first space station.")
        case "Falcon 9 Block 5", "Falcon 9":
            return RocketOverview(name: "Falcon 9 Block 5", agency: "SpaceX", agencyIcon: "airplane.departure", country: "United States", height: "70.0 m", diameter: "3.7 m", liftoffMass: "549,054 kg", liftoffThrust: "7,607 kN", payloadLEO: "22,800 kg", payloadGTO: "8,300 kg", stages: 2, firstFlight: "May 11, 2018", successRate: "99%", totalLaunches: "300+", status: "Active", description: "Falcon 9 Block 5 is SpaceX's workhorse orbital-class rocket featuring a reusable first stage. It is the world's first orbital-class rocket capable of reflight and has revolutionized spaceflight economics. The booster can land autonomously and has been reflown 20+ times.")
        case "LVM3", "LVM3-G1":
            return RocketOverview(name: "LVM3", agency: "ISRO", agencyIcon: "globe.asia.australia.fill", country: "India", height: "43.43 m", diameter: "4.0 m", liftoffMass: "640,000 kg", liftoffThrust: "11,458 kN", payloadLEO: "10,000 kg", payloadGTO: "4,000 kg", stages: 3, firstFlight: "Jun 5, 2017", successRate: "100%", totalLaunches: "7", status: "Active", description: "The Launch Vehicle Mark-3 (LVM3) is ISRO's heaviest operational launch vehicle, featuring two S200 solid strap-on boosters, an L110 liquid core stage with twin Vikas engines, and a C25 cryogenic upper stage.")
        case "PSLV-XL":
            return RocketOverview(name: "PSLV-XL", agency: "ISRO", agencyIcon: "globe.asia.australia.fill", country: "India", height: "44.4 m", diameter: "2.8 m", liftoffMass: "320,000 kg", liftoffThrust: "6,908 kN", payloadLEO: "3,250 kg", payloadGTO: "1,425 kg", stages: 4, firstFlight: "Oct 15, 2008", successRate: "96%", totalLaunches: "50+", status: "Active", description: "The Polar Satellite Launch Vehicle (PSLV) is ISRO's most reliable rocket, the workhorse of the Indian space program. PSLV-XL uses six extended strap-on boosters. It launched Mars Orbiter Mission (Mangalyaan) and Chandrayaan-1 lunar orbiter.")
        case "Atlas V 541":
            return RocketOverview(name: "Atlas V 541", agency: "ULA", agencyIcon: "shield.checkered", country: "United States", height: "62.2 m", diameter: "3.81 m", liftoffMass: "590,000 kg", liftoffThrust: "9,580 kN", payloadLEO: "18,810 kg", payloadGTO: "8,900 kg", stages: 2, firstFlight: "Aug 21, 2002", successRate: "99%", totalLaunches: "100+", status: "Active", description: "The Atlas V 541 is a medium-to-heavy lift vehicle from United Launch Alliance featuring a 5-meter fairing, 4 solid boosters, and a single RD-180 powered Centaur upper stage. It has launched Curiosity, Perseverance Mars rovers, and crewed Starliner missions.")
        case "Ariane 5 ECA", "Ariane 5 G+", "Ariane 5":
            return RocketOverview(name: "Ariane 5", agency: "Arianespace / ESA", agencyIcon: "star.circle.fill", country: "Europe", height: "52.0 m", diameter: "5.4 m", liftoffMass: "780,000 kg", liftoffThrust: "14,800 kN", payloadLEO: "21,000 kg", payloadGTO: "10,500 kg", stages: 2, firstFlight: "Jun 4, 1996", successRate: "95%", totalLaunches: "117", status: "Retired", description: "Ariane 5 was the ESA's flagship heavy-lift vehicle, operating from Kourou, French Guiana. It launched the James Webb Space Telescope with exceptional precision. Ariane 5 was retired in 2023 after 27 years of service.")
        case "H-IIA":
            return RocketOverview(name: "H-IIA", agency: "JAXA / MHI", agencyIcon: "sun.max.fill", country: "Japan", height: "53.0 m", diameter: "4.0 m", liftoffMass: "445,000 kg", liftoffThrust: "5,738 kN", payloadLEO: "15,000 kg", payloadGTO: "6,000 kg", stages: 2, firstFlight: "Aug 29, 2001", successRate: "98%", totalLaunches: "50", status: "Active", description: "The H-IIA is Japan's primary launch vehicle by JAXA and Mitsubishi Heavy Industries, featuring cryogenic LE-7A and LE-5B engines. It has launched SLIM lunar lander, Hayabusa2 asteroid explorer, and multiple Earth observation satellites.")
        case "SLS Block 1":
            return RocketOverview(name: "SLS Block 1", agency: "NASA", agencyIcon: "building.columns.fill", country: "United States", height: "98.1 m", diameter: "8.4 m", liftoffMass: "2,608,000 kg", liftoffThrust: "39,144 kN", payloadLEO: "95,000 kg", payloadGTO: "27,000 kg (TLI)", stages: 2, firstFlight: "Nov 16, 2022", successRate: "100%", totalLaunches: "1", status: "Active", description: "The Space Launch System (SLS) is NASA's super-heavy-lift vehicle for the Artemis program. Powered by four RS-25 engines and two 5-segment solid boosters, it is the most powerful rocket ever flown. Artemis I successfully sent an uncrewed Orion capsule around the Moon.")
        default:
            return nil
        }
    }
}
