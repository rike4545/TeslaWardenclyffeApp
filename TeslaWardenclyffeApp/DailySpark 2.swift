//
//  DailySpark 2.swift
//  TeslaWardenclyffeApp
//
//  Created by Bryan on 12/15/25.
//


import SwiftUI
import Combine

struct DailySpark: Identifiable, Hashable {
    let id: String
    let prompt: String
    let correct: String
    let choices: [String]
    let explanation: String
}

@MainActor
final class DailySparkStore: ObservableObject {
    @AppStorage("wardenclyffe.daily.lastClaimISO") private var lastClaimISO: String = ""
    @AppStorage("wardenclyffe.daily.streak") private var streak: Int = 0

    @Published private(set) var lastClaimDate: Date? = nil
    @Published private(set) var currentStreak: Int = 0
    private let bank: [DailySpark] = [
        DailySpark(
            id: "tower-purpose",
            prompt: "What was the main goal of Tesla’s Wardenclyffe Tower?",
            correct: "Wireless transmission of energy and data",
            choices: [
                "Wireless transmission of energy and data",
                "A radio telescope for deep space",
                "A hydroelectric dam",
                "An early wind farm"
            ],
            explanation: "Tesla envisioned Wardenclyffe as a global wireless system for power and communication."
        ),
        DailySpark(
            id: "tesla-field",
            prompt: "Tesla is most closely associated with which field?",
            correct: "Electricity and electromagnetism",
            choices: [
                "Electricity and electromagnetism",
                "Astronomy",
                "Geology",
                "Botany"
            ],
            explanation: "His inventions centered on AC power, motors, and wireless energy."
        ),
        DailySpark(
            id: "ac-power",
            prompt: "Which electrical system did Tesla champion?",
            correct: "Alternating current (AC)",
            choices: [
                "Alternating current (AC)",
                "Direct current (DC)",
                "Steam power",
                "Internal combustion"
            ],
            explanation: "Tesla’s AC system enabled efficient long-distance transmission."
        ),
        DailySpark(
            id: "wardenclyffe-location",
            prompt: "Where is the Wardenclyffe site located?",
            correct: "Shoreham, New York",
            choices: [
                "Shoreham, New York",
                "Palo Alto, California",
                "Chicago, Illinois",
                "Austin, Texas"
            ],
            explanation: "The Tesla Science Center at Wardenclyffe is in Shoreham, NY."
        )
    ]

    init() {
        lastClaimDate = ISO8601DateFormatter().date(from: lastClaimISO)
        currentStreak = streak
    }

    func canClaimToday(now: Date = Date()) -> Bool {
        guard let last = lastClaimDate else { return true }
        return !Calendar.current.isDate(last, inSameDayAs: now)
    }

    func claim(now: Date = Date()) {
        if let last = lastClaimDate,
           Calendar.current.isDate(last, inSameDayAs: Calendar.current.date(byAdding: .day, value: -1, to: now) ?? now) {
            streak += 1
        } else {
            streak = 1
        }
        currentStreak = streak
        lastClaimDate = now
        lastClaimISO = ISO8601DateFormatter().string(from: now)
    }

    func sparkForToday(now: Date = Date()) -> DailySpark {
        if bank.isEmpty {
            return DailySpark(
                id: "default",
                prompt: "Ready to explore Wardenclyffe today?",
                correct: "Yes",
                choices: ["Yes"],
                explanation: "Start with the AR Experience or the On-Site Guide."
            )
        }
        let day = Calendar.current.ordinality(of: .day, in: .year, for: now) ?? 1
        let index = max(0, (day - 1) % bank.count)
        return bank[index]
    }
}
