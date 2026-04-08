import Foundation
import SwiftUI

// calendar event category
enum SpaceEventCategory: String, CaseIterable {
    case mission = "Mission"
    case launch = "Launch"
    case milestone = "Milestone"

    var icon: String {
        switch self {
        case .mission: return "globe.americas.fill"
        case .launch: return "flame.fill"
        case .milestone: return "star.fill"
        }
    }

    var color: Color {
        switch self {
        case .mission: return SpaceTheme.electricBlue
        case .launch: return .orange
        case .milestone: return SpaceTheme.nebulaPurple
        }
    }
}

// space calendar event
struct SpaceCalendarEvent: Identifiable {
    let id = UUID()
    let title: String
    let date: Date
    let description: String
    let icon: String
    let color: Color
    let category: SpaceEventCategory
    let launch: Launch?
    let mission: Mission?
    
    init(title: String, date: Date, description: String, icon: String, color: Color, category: SpaceEventCategory, launch: Launch? = nil, mission: Mission? = nil) {
        self.title = title
        self.date = date
        self.description = description
        self.icon = icon
        self.color = color
        self.category = category
        self.launch = launch
        self.mission = mission
    }

    /// helper to create a date from components
    static func makeDate(year: Int, month: Int, day: Int) -> Date {
        var comps = DateComponents()
        comps.year = year; comps.month = month; comps.day = day
        return Calendar.current.date(from: comps) ?? Date()
    }
}

// built-in historic events
extension SpaceCalendarEvent {
    static let historicEvents: [SpaceCalendarEvent] = [
        // 1957
        SpaceCalendarEvent(
            title: "Sputnik 1 — First Satellite",
            date: makeDate(year: 1957, month: 10, day: 4),
            description: "The Soviet Union launched the first artificial satellite into low Earth orbit, marking the dawn of the Space Age.",
            icon: "antenna.radiowaves.left.and.right",
            color: .red,
            category: .milestone
        ),
        // 1961
        SpaceCalendarEvent(
            title: "Yuri Gagarin — First Human in Space",
            date: makeDate(year: 1961, month: 4, day: 12),
            description: "Soviet cosmonaut Yuri Gagarin became the first human to journey into outer space aboard Vostok 1.",
            icon: "person.fill",
            color: SpaceTheme.nebulaPurple,
            category: .milestone
        ),
        // 1962
        SpaceCalendarEvent(
            title: "John Glenn Orbits Earth",
            date: makeDate(year: 1962, month: 2, day: 20),
            description: "John Glenn became the first American to orbit the Earth aboard Friendship 7.",
            icon: "globe.americas.fill",
            color: SpaceTheme.electricBlue,
            category: .milestone
        ),
        // 1969
        SpaceCalendarEvent(
            title: "Apollo 11 — Moon Landing",
            date: makeDate(year: 1969, month: 7, day: 20),
            description: "Neil Armstrong and Buzz Aldrin became the first humans to walk on the Moon.",
            icon: "moon.fill",
            color: .cyan,
            category: .mission
        ),
        // 1971
        SpaceCalendarEvent(
            title: "Salyut 1 — First Space Station",
            date: makeDate(year: 1971, month: 4, day: 19),
            description: "The Soviet Union launched the world's first space station into low Earth orbit.",
            icon: "building.2.fill",
            color: .red,
            category: .milestone
        ),
        // 1981
        SpaceCalendarEvent(
            title: "First Space Shuttle Launch (STS-1)",
            date: makeDate(year: 1981, month: 4, day: 12),
            description: "Columbia lifted off from Kennedy Space Center, inaugurating the Space Shuttle era.",
            icon: "airplane",
            color: .white,
            category: .launch
        ),
        // 1990
        SpaceCalendarEvent(
            title: "Hubble Space Telescope Deployed",
            date: makeDate(year: 1990, month: 4, day: 25),
            description: "The Hubble Space Telescope was deployed from the Space Shuttle Discovery, revolutionizing astronomy.",
            icon: "camera.fill",
            color: SpaceTheme.nebulaPurple,
            category: .milestone
        ),
        // 1998
        SpaceCalendarEvent(
            title: "ISS First Module — Zarya",
            date: makeDate(year: 1998, month: 11, day: 20),
            description: "Russia launched the Zarya module, the first component of the International Space Station.",
            icon: "building.2.fill",
            color: SpaceTheme.electricBlue,
            category: .milestone
        ),
        // 2004
        SpaceCalendarEvent(
            title: "SpaceShipOne — First Private Spaceflight",
            date: makeDate(year: 2004, month: 6, day: 21),
            description: "SpaceShipOne became the first privately funded craft to reach space.",
            icon: "sparkles",
            color: .orange,
            category: .milestone
        ),
        // 2008
        SpaceCalendarEvent(
            title: "Chandrayaan-1 — India's First Lunar Probe",
            date: makeDate(year: 2008, month: 10, day: 22),
            description: "ISRO launched India's first mission to the Moon, which confirmed the presence of water molecules on the lunar surface.",
            icon: "globe.asia.australia.fill",
            color: .orange,
            category: .mission
        ),
        // 2012
        SpaceCalendarEvent(
            title: "Curiosity Rover Lands on Mars",
            date: makeDate(year: 2012, month: 8, day: 6),
            description: "NASA's Curiosity rover successfully landed on Mars using a sky crane maneuver.",
            icon: "car.fill",
            color: .red,
            category: .mission
        ),
        // 2015
        SpaceCalendarEvent(
            title: "Falcon 9 First Landing",
            date: makeDate(year: 2015, month: 12, day: 22),
            description: "SpaceX successfully landed a Falcon 9 first stage booster for the first time, ushering in reusable rockets.",
            icon: "arrow.down.to.line",
            color: SpaceTheme.electricBlue,
            category: .milestone
        ),
        // 2019
        SpaceCalendarEvent(
            title: "First Image of a Black Hole",
            date: makeDate(year: 2019, month: 4, day: 10),
            description: "The Event Horizon Telescope captured the first-ever image of a black hole in galaxy M87.",
            icon: "circle.fill",
            color: .orange,
            category: .milestone
        ),
        // 2020
        SpaceCalendarEvent(
            title: "Crew Dragon Demo-2",
            date: makeDate(year: 2020, month: 5, day: 30),
            description: "SpaceX Crew Dragon carried NASA astronauts to the ISS, the first crewed orbital flight from US soil since 2011.",
            icon: "person.2.fill",
            color: SpaceTheme.electricBlue,
            category: .launch
        ),
        // 2021
        SpaceCalendarEvent(
            title: "James Webb Space Telescope Launch",
            date: makeDate(year: 2021, month: 12, day: 25),
            description: "JWST launched from French Guiana, destined for the L2 Lagrange point to observe the earliest galaxies.",
            icon: "sparkles",
            color: .yellow,
            category: .launch
        ),

    ]
    static var allEvents: [SpaceCalendarEvent] {
        var events = historicEvents

        // add missions
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "MMMM d, yyyy"

        for mission in MockData.allMissions {
            if let missionDate = dateFormatter.date(from: mission.date) {
                let event = SpaceCalendarEvent(
                    title: mission.name,
                    date: missionDate,
                    description: mission.description,
                    icon: mission.sfSymbol,
                    color: SpaceTheme.electricBlue,
                    category: .mission,
                    mission: mission
                )
                // avoid duplicates by title
                if !events.contains(where: { $0.title.localizedCaseInsensitiveContains(mission.name) }) {
                    events.append(event)
                }
            }
        }

        // add launches
        for launch in MockData.launches {
            let event = SpaceCalendarEvent(
                title: launch.missionName,
                date: launch.launchDate,
                description: launch.description,
                icon: "flame.fill",
                color: .orange,
                category: .launch,
                launch: launch
            )
            events.append(event)
        }

        return events.sorted { $0.date < $1.date }
    }
}
