// Models.swift

import Foundation

// MARK: - Exhibits

struct Exhibit: Identifiable {
    let id: UUID
    let title: String
    let subtitle: String
    let locationHint: String
    let description: String
    let isOnSiteOnly: Bool
}

extension Exhibit {
    static let sampleData: [Exhibit] = [
        Exhibit(
            id: UUID(),
            title: "Wardenclyffe Laboratory",
            subtitle: "Tesla’s last remaining lab",
            locationHint: "Historic brick lab building in Shoreham, NY",
            description: "Learn how this site became Tesla’s base for wireless communication experiments and how it is being transformed into a global science center.",
            isOnSiteOnly: true
        ),
        Exhibit(
            id: UUID(),
            title: "Tesla’s Wireless Power",
            subtitle: "From tower to global connectivity",
            locationHint: "History of Wardenclyffe",
            description: "Discover how Tesla envisioned using the Earth as part of a wireless communication and power system, decades ahead of modern wireless technology.",
            isOnSiteOnly: false
        )
    ]
}

// MARK: - Events

struct TSCEvent: Identifiable {
    let id: UUID
    let title: String
    let date: Date
    let location: String
    let category: String   // “Expo”, “Fair”, “Fundraiser”, etc.
    let url: URL?
}

extension TSCEvent {
    static let sampleData: [TSCEvent] = []
}

// MARK: - Programs

struct ProgramCategory: Identifiable {
    let id = UUID()
    let name: String
    let summary: String
    let isVirtual: Bool
    let url: URL?
}

extension ProgramCategory {
    static let sampleData: [ProgramCategory] = [
        ProgramCategory(
            name: "Education & Event Programs",
            summary: "Talks, workshops, and hands-on activities for learners of all ages, offered on site and online.",
            isVirtual: false,
            url: URL(string: "https://teslasciencecenter.org/programs/")
        ),
        ProgramCategory(
            name: "Tours of Wardenclyffe",
            summary: "Guided walking tours of the historic campus that share the story of Tesla, the tower, and today’s restoration.",
            isVirtual: false,
            url: URL(string: "https://teslasciencecenter.org/tours/")
        ),
        ProgramCategory(
            name: "Virtual Science Center",
            summary: "Online experiments, videos, and virtual STEAM camps you can join from anywhere.",
            isVirtual: true,
            url: URL(string: "https://teslasciencecenter.org/virtual-science-center/")
        ),
        ProgramCategory(
            name: "Tesla LEGO Challenge",
            summary: "A maker program that uses LEGO builds to explore Tesla-inspired inventions and creative problem solving.",
            isVirtual: false,
            url: URL(string: "https://teslasciencecenter.org/programs/")
        )
    ]
}

// MARK: - Get Involved

struct InvolvementOption: Identifiable {
    let id = UUID()
    let name: String
    let summary: String
    let url: URL?
}

extension InvolvementOption {
    static let sampleData: [InvolvementOption] = [
        InvolvementOption(
            name: "Donate",
            summary: "Support the restoration of Tesla’s lab and development of a world-class science center.",
            url: URL(string: "https://teslasciencecenter.org/donate/")
        ),
        InvolvementOption(
            name: "Capital Campaign",
            summary: "Help fund major renovations, exhibits, and the future Tesla museum and visitor center.",
            url: URL(string: "https://teslasciencecenter.org/capital-campaign/")
        ),
        InvolvementOption(
            name: "Membership",
            summary: "Join a global community dedicated to preserving Tesla’s legacy and advancing his vision.",
            url: URL(string: "https://teslasciencecenter.org/become-a-member/")
        ),
        InvolvementOption(
            name: "Corporate Opportunities",
            summary: "Partner as a company to support STEM education, programs, and innovation at Wardenclyffe.",
            url: URL(string: "https://teslasciencecenter.org/partnerships/")
        ),
        InvolvementOption(
            name: "Volunteer",
            summary: "Contribute your time as a docent, event helper, or behind-the-scenes supporter.",
            url: URL(string: "https://teslasciencecenter.org/support/")
        )
    ]
}

// MARK: - History Timeline

enum HistoryCategory: String, CaseIterable, Identifiable {
    case introduction = "Introduction"
    case tower = "The Tower"
    case architect = "The Architect"
    case journey = "The Journey"
    case wirelessPower = "Tesla’s Wireless Power"
    case renovations = "Renovations"
    case fire = "The Fire"

    var id: String { rawValue }
}

struct HistoryEntry: Identifiable {
    let id = UUID()
    let title: String
    let year: String
    let category: HistoryCategory
    let summary: String
    let order: Int
}

extension HistoryEntry {
    static let sampleTimeline: [HistoryEntry] = [
        HistoryEntry(
            title: "Tesla Envisions a Global Wireless System",
            year: "1890s",
            category: .wirelessPower,
            summary: "Tesla experiments with high-voltage transformers and Earth conduction, imagining a worldwide system for wireless communication and power.",
            order: 0
        ),
        HistoryEntry(
            title: "Site Purchased at Wardenclyffe",
            year: "1901",
            category: .introduction,
            summary: "Tesla acquires land in Shoreham, Long Island, to build a laboratory and transmitting station that could send signals and power across the Atlantic.",
            order: 1
        ),
        HistoryEntry(
            title: "Tower and Laboratory Rise",
            year: "1901–1903",
            category: .tower,
            summary: "Construction begins on a tall wooden tower with a large dome and a brick laboratory designed by architect Stanford White.",
            order: 2
        ),
        HistoryEntry(
            title: "The Architect: Stanford White",
            year: "Early 1900s",
            category: .architect,
            summary: "Renowned architect Stanford White designs the brick laboratory building that still stands at Wardenclyffe today.",
            order: 3
        ),
        HistoryEntry(
            title: "Demonstrations and Doubts",
            year: "1903–1906",
            category: .journey,
            summary: "Spectacular electrical displays thrill observers, but funding difficulties and competition from other wireless systems stall the project.",
            order: 4
        ),
        HistoryEntry(
            title: "Tower Demolished",
            year: "1917",
            category: .tower,
            summary: "The unfinished tower is dismantled for scrap, ending Tesla’s original Wardenclyffe project but not the site’s story.",
            order: 5
        ),
        HistoryEntry(
            title: "Industrial Era and Cleanup",
            year: "1920s–1990s",
            category: .renovations,
            summary: "The site is used for industrial purposes and later undergoes environmental cleanup, while Tesla’s lab building survives.",
            order: 6
        ),
        HistoryEntry(
            title: "Preservation Efforts Grow",
            year: "1990s–2010s",
            category: .journey,
            summary: "Historians and advocates work to recognize and save Wardenclyffe as Tesla’s last remaining laboratory and a future museum site.",
            order: 7
        ),
        HistoryEntry(
            title: "Crowdfunding Saves the Site",
            year: "2012–2013",
            category: .journey,
            summary: "Global supporters and an online campaign help purchase Wardenclyffe for Tesla Science Center, securing the property.",
            order: 8
        ),
        HistoryEntry(
            title: "National Historic Recognition",
            year: "2018",
            category: .renovations,
            summary: "Wardenclyffe is listed on the National Register of Historic Places, highlighting its importance in science and technology history.",
            order: 9
        ),
        HistoryEntry(
            title: "Groundbreaking for Visitor Center",
            year: "2023",
            category: .renovations,
            summary: "Tesla Science Center breaks ground on the Eugene Sayan Visitor Center, a new gateway for exhibits and programs.",
            order: 10
        ),
        HistoryEntry(
            title: "Fire at Wardenclyffe Laboratory",
            year: "Nov 21, 2023",
            category: .fire,
            summary: "A serious fire damages the historic lab building, but the community rallies to support recovery and restoration plans.",
            order: 11
        ),
        HistoryEntry(
            title: "Restoration and Renewal",
            year: "Today & Beyond",
            category: .renovations,
            summary: "Tesla Science Center works to restore the lab, build new facilities, and create a global science center inspired by Tesla’s bold ideas.",
            order: 12
        )
    ]
}

// MARK: - Kids’ Quest

struct Quest: Identifiable {
    let id = UUID()
    let title: String
    let clue: String
    let locationHint: String
    let relatedCategory: HistoryCategory
    let rewardBadgeName: String
    var isCompleted: Bool
}

extension Quest {
    static let sampleQuests: [Quest] = [
        Quest(
            title: "Find the Footprint of the Tower",
            clue: "Look for where the great wooden tower once stood behind the lab. What shape do you see on the ground?",
            locationHint: "Near the former tower foundation behind the brick lab building.",
            relatedCategory: .tower,
            rewardBadgeName: "Tower Tracker",
            isCompleted: false
        ),
        Quest(
            title: "Name the Architect",
            clue: "The lab building wasn’t just engineered; it was designed by a famous architect. Can you find his name on the signs?",
            locationHint: "Look near the lab entrance or historic markers that describe the building.",
            relatedCategory: .architect,
            rewardBadgeName: "Design Detective",
            isCompleted: false
        ),
        Quest(
            title: "Wireless World",
            clue: "Tesla wanted the whole planet to ‘quiver’ with energy. Can you find where the exhibits talk about his wireless power ideas?",
            locationHint: "Check panels and displays that talk about wireless communication and power.",
            relatedCategory: .wirelessPower,
            rewardBadgeName: "Wireless Wizard",
            isCompleted: false
        ),
        Quest(
            title: "Fire & Renewal",
            clue: "A recent fire damaged the lab but not the dream. Can you find anything that talks about recovery and restoration?",
            locationHint: "Look for information about the 2023 fire and today’s renovation work.",
            relatedCategory: .fire,
            rewardBadgeName: "Hope Builder",
            isCompleted: false
        )
    ]
}
