//
//  WardenclyffeUnlock 2.swift
//  TeslaWardenclyffeApp
//
//  Created by Bryan on 12/15/25.
//


import SwiftUI
import Combine

enum WardenclyffeUnlock: String, CaseIterable, Codable {
    case hotspotsBasics
    case timelineScrubber
    case patentsExplorer
    case arEnergize
    case buildMode
    case postcardStudio
    case dailySparkStreak
}

struct UnlockMilestone: Identifiable, Equatable {
    let unlock: WardenclyffeUnlock
    let requiredPower: Int
    let title: String
    let detail: String

    var id: WardenclyffeUnlock { unlock }
}

extension WardenclyffeUnlock {
    var title: String {
        switch self {
        case .hotspotsBasics:
            "Hotspot Basics"
        case .timelineScrubber:
            "Timeline Scrubber"
        case .patentsExplorer:
            "Patents Explorer"
        case .arEnergize:
            "AR Energize"
        case .buildMode:
            "Build Mode"
        case .postcardStudio:
            "Postcard Studio"
        case .dailySparkStreak:
            "Daily Spark Streak"
        }
    }
}

@MainActor
final class WardenclyffeProgressStore: ObservableObject {
    @AppStorage("wardenclyffe.powerPoints") private var powerPoints: Int = 0
    @AppStorage("wardenclyffe.unlocked") private var unlockedRaw: String = ""
    @AppStorage("wardenclyffe.lastActionISO") private var lastActionISO: String = ""

    @Published private(set) var unlocked: Set<WardenclyffeUnlock> = []
    @Published private(set) var totalPower: Int = 0
    @Published var lastActionDate: Date? = nil

    private let milestones: [UnlockMilestone] = [
        UnlockMilestone(
            unlock: .hotspotsBasics,
            requiredPower: 10,
            title: "Hotspot Basics",
            detail: "Reveal the first on-site clues and discovery prompts."
        ),
        UnlockMilestone(
            unlock: .timelineScrubber,
            requiredPower: 20,
            title: "Timeline Scrubber",
            detail: "Dig deeper into the Wardenclyffe story with richer history controls."
        ),
        UnlockMilestone(
            unlock: .patentsExplorer,
            requiredPower: 30,
            title: "Patents Explorer",
            detail: "Unlock more of Tesla's invention trail."
        ),
        UnlockMilestone(
            unlock: .arEnergize,
            requiredPower: 40,
            title: "AR Energize",
            detail: "Place and energize the Wardenclyffe tower in AR."
        ),
        UnlockMilestone(
            unlock: .postcardStudio,
            requiredPower: 55,
            title: "Postcard Studio",
            detail: "Create shareable Wardenclyffe moments."
        ),
        UnlockMilestone(
            unlock: .buildMode,
            requiredPower: 70,
            title: "Build Mode",
            detail: "Push the tower further with advanced interactions."
        )
    ]

    init() {
        totalPower = powerPoints
        unlocked = decodeUnlocks(unlockedRaw)
        lastActionDate = ISO8601DateFormatter().date(from: lastActionISO)
        applyAutoUnlockRules()
    }

    func addPower(_ amount: Int, reason: String? = nil) {
        let delta = max(0, amount)
        powerPoints += delta
        totalPower = powerPoints
        lastActionDate = Date()
        lastActionISO = ISO8601DateFormatter().string(from: lastActionDate ?? Date())
        applyAutoUnlockRules()
    }

    func isUnlocked(_ item: WardenclyffeUnlock) -> Bool { unlocked.contains(item) }

    var nextMilestone: UnlockMilestone? {
        milestones.first(where: { totalPower < $0.requiredPower })
    }

    var progressToNextMilestone: Double {
        guard let nextMilestone else { return 1 }
        let previousRequirement = milestones
            .last(where: { $0.requiredPower < nextMilestone.requiredPower && totalPower >= $0.requiredPower })?
            .requiredPower ?? 0
        let span = max(1, nextMilestone.requiredPower - previousRequirement)
        let current = min(max(totalPower - previousRequirement, 0), span)
        return Double(current) / Double(span)
    }

    var powerNeededForNextMilestone: Int {
        guard let nextMilestone else { return 0 }
        return max(0, nextMilestone.requiredPower - totalPower)
    }

    func unlock(_ item: WardenclyffeUnlock) {
        unlocked.insert(item)
        unlockedRaw = encodeUnlocks(unlocked)
    }

    private func applyAutoUnlockRules() {
        if totalPower >= 10 { unlock(.hotspotsBasics) }
        if totalPower >= 20 { unlock(.timelineScrubber) }
        if totalPower >= 30 { unlock(.patentsExplorer) }
        if totalPower >= 40 { unlock(.arEnergize) }
        if totalPower >= 55 { unlock(.postcardStudio) }
        if totalPower >= 70 { unlock(.buildMode) }
    }

    private func decodeUnlocks(_ raw: String) -> Set<WardenclyffeUnlock> {
        guard let data = raw.data(using: .utf8) else { return [] }
        let arr = (try? JSONDecoder().decode([WardenclyffeUnlock].self, from: data)) ?? []
        return Set(arr)
    }

    private func encodeUnlocks(_ set: Set<WardenclyffeUnlock>) -> String {
        let arr = Array(set)
        guard let data = try? JSONEncoder().encode(arr),
              let str = String(data: data, encoding: .utf8) else { return "" }
        return str
    }
}
