import SwiftUI

// space organisation model
struct SpaceOrg: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let abbr: String
    let sfSymbol: String       // sf symbol representing the agency
    let imageName: String
    let heroImageName: String
    let color: Color
    let founded: String
    let headquarters: String
    let director: String
    let overview: String
    let totalLaunches: Int
    let successRate: String
    let activeRockets: [String]
    let notableAchievements: [String]

    // filter launches belonging to this org
    var orgLaunches: [Launch] {
        MockData.launches.filter { $0.agencyAbbr == abbr }
    }

    // filter missions belonging to this org
    var orgMissions: [Mission] {
        MockData.allMissions.filter { $0.agencyAbbr == abbr }
    }

    var completedMissions: [Mission] {
        orgMissions.filter { $0.status == .completed }
    }

    var upcomingMissions: [Mission] {
        orgMissions.filter { $0.status == .upcoming || $0.status == .active }
    }

    static func == (lhs: SpaceOrg, rhs: SpaceOrg) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static let allOrgs: [SpaceOrg] = [
        SpaceOrg(
            name: "National Aeronautics and Space Administration",
            abbr: "NASA",
            sfSymbol: "globe.americas.fill",   // blue marble / earth
            imageName: "nasa_logo",
            heroImageName: "nasa_hero",
            color: SpaceTheme.electricBlue,
            founded: "July 29, 1958",
            headquarters: "Washington, D.C., USA",
            director: "Bill Nelson",
            overview: "The US government agency responsible for aerospace research, aeronautics, and the civilian space program. Responsible for the Apollo Moon landings, Space Shuttle, ISS, and Artemis program.",
            totalLaunches: 1500,
            successRate: "96%",
            activeRockets: ["SLS Block 1", "Falcon 9 (contract)", "Falcon Heavy (contract)"],
            notableAchievements: [
                "First humans on the Moon — Apollo 11 (1969)",
                "Mars rover exploration — Curiosity & Perseverance",
                "Hubble & James Webb Space Telescopes",
                "Voyager 1 & 2 — farthest human-made objects"
            ]
        ),
        SpaceOrg(
            name: "Indian Space Research Organisation",
            abbr: "ISRO",
            sfSymbol: "moon.stars.fill",        // moon missions (chandrayaan)
            imageName: "isro_logo",
            heroImageName: "isro_hero",
            color: SpaceTheme.electricBlue,
            founded: "August 15, 1969",
            headquarters: "Bengaluru, India",
            director: "S. Somanath",
            overview: "India's national space agency responsible for space science research and planetary exploration. Known for cost-effective missions like Chandrayaan and Mars Orbiter Mission (Mangalyaan).",
            totalLaunches: 127,
            successRate: "94%",
            activeRockets: ["PSLV", "GSLV Mk II", "LVM3 (GSLV Mk III)", "SSLV"],
            notableAchievements: [
                "First nation to reach Mars orbit on maiden attempt (2014)",
                "Launched 104 satellites in a single mission (2017)",
                "Most cost-effective Mars mission — $74M total"
            ]
        ),
        SpaceOrg(
            name: "Space Exploration Technologies",
            abbr: "SpaceX",
            sfSymbol: "arrow.down.to.line",     // booster landing
            imageName: "spacex_logo",
            heroImageName: "spacex_hero",
            color: SpaceTheme.electricBlue,
            founded: "March 14, 2002",
            headquarters: "Hawthorne, California, USA",
            director: "Elon Musk",
            overview: "Private aerospace manufacturer and space transportation company. Revolutionised spaceflight with reusable rockets, Falcon 9 booster landings, and the Starlink satellite constellation.",
            totalLaunches: 350,
            successRate: "98%",
            activeRockets: ["Falcon 9 Block 5", "Falcon Heavy", "Starship / Super Heavy"],
            notableAchievements: [
                "First privately-funded spacecraft to reach orbit (2008)",
                "First orbital-class rocket landing (2015)",
                "Crew Dragon — first commercial crew to ISS",
                "Starlink — 6,000+ satellites in orbit"
            ]
        ),
        SpaceOrg(
            name: "European Space Agency",
            abbr: "ESA",
            sfSymbol: "star.circle.fill",       // stars (european union stars)
            imageName: "esa_logo",
            heroImageName: "esa_hero",
            color: SpaceTheme.electricBlue,
            founded: "May 30, 1975",
            headquarters: "Paris, France",
            director: "Josef Aschbacher",
            overview: "Intergovernmental organisation of 22 member states dedicated to space exploration. Known for Ariane rockets, Rosetta comet mission, and contributions to ISS and Hubble.",
            totalLaunches: 260,
            successRate: "95%",
            activeRockets: ["Ariane 6", "Vega C"],
            notableAchievements: [
                "Rosetta — first spacecraft to orbit a comet (2014)",
                "Huygens probe landing on Titan (2005)",
                "Gaia — mapping 1.8 billion stars",
                "Contributed Columbus module to ISS"
            ]
        ),
        SpaceOrg(
            name: "Japan Aerospace Exploration Agency",
            abbr: "JAXA",
            sfSymbol: "sparkles",               // hayabusa sparks / japan
            imageName: "jaxa_logo",
            heroImageName: "hayabusa",
            color: SpaceTheme.electricBlue,
            founded: "October 1, 2003",
            headquarters: "Tokyo, Japan",
            director: "Hiroshi Yamakawa",
            overview: "Japan's national space agency formed from the merger of three organisations. Known for asteroid sample return missions (Hayabusa) and innovative space exploration technology.",
            totalLaunches: 95,
            successRate: "97%",
            activeRockets: ["H3", "Epsilon S"],
            notableAchievements: [
                "Hayabusa2 — asteroid sample return from Ryugu (2020)",
                "SLIM — precision Moon landing (2024)",
                "Kibo module — Japanese lab on ISS",
                "First asteroid sample return (Hayabusa, 2010)"
            ]
        ),
        SpaceOrg(
            name: "Roscosmos",
            abbr: "ROSCOS",
            sfSymbol: "capsule.fill",           // soyuz capsule
            imageName: "roscos_logo",
            heroImageName: "soyuz",
            color: SpaceTheme.electricBlue,
            founded: "February 25, 1992",
            headquarters: "Moscow, Russia",
            director: "Yuri Borisov",
            overview: "Russia's governmental space corporation responsible for space flights and aerospace research. Successor to the Soviet space program that launched Sputnik and Vostok.",
            totalLaunches: 3200,
            successRate: "94%",
            activeRockets: ["Soyuz-2", "Angara A5", "Proton-M"],
            notableAchievements: [
                "First satellite in orbit — Sputnik 1 (1957)",
                "First human in space — Yuri Gagarin (1961)",
                "First space station — Salyut 1 (1971)",
                "Soyuz — most-flown crewed spacecraft in history"
            ]
        ),
        SpaceOrg(
            name: "China National Space Administration",
            abbr: "CNSA",
            sfSymbol: "moon.fill",              // chang'e moon missions
            imageName: "cnsa_logo",
            heroImageName: "long_march",
            color: SpaceTheme.electricBlue,
            founded: "April 22, 1993",
            headquarters: "Beijing, China",
            director: "Zhang Kejian",
            overview: "China's national space agency responsible for space program planning and development. Operates the Tiangong space station and has conducted successful lunar and Mars missions.",
            totalLaunches: 520,
            successRate: "96%",
            activeRockets: ["Long March 5", "Long March 7", "Long March 8"],
            notableAchievements: [
                "First landing on far side of Moon — Chang'e 4 (2019)",
                "Tiangong space station operational (2022)",
                "Zhurong rover on Mars (2021)",
                "Chang'e 5 — lunar sample return (2020)"
            ]
        ),
        SpaceOrg(
            name: "Canadian Space Agency",
            abbr: "CSA",
            sfSymbol: "figure.arms.open",       // canadarm / robotics
            imageName: "csa_logo",
            heroImageName: "csa_hero",
            color: SpaceTheme.electricBlue,
            founded: "March 1, 1989",
            headquarters: "Longueuil, Quebec, Canada",
            director: "Lisa Campbell",
            overview: "Canada's space agency focused on space science, satellite communications, and robotics. Famous for the Canadarm robotic arm used on the Space Shuttle and ISS.",
            totalLaunches: 12,
            successRate: "92%",
            activeRockets: [],
            notableAchievements: [
                "Canadarm — robotic arm on Space Shuttle",
                "Canadarm2 — ISS robotic arm still in use",
                "RADARSAT constellation for Earth observation",
                "Jeremy Hansen — first Canadian on Artemis II"
            ]
        ),
    ]
}
