//
//  TowerEnergyState 2.swift
//  TeslaWardenclyffeApp
//
//  Created by Bryan on 12/15/25.
//


import SwiftUI
import Combine

enum TowerEnergyState: String, Codable {
    case idle
    case energized
}

@MainActor
final class TowerStateStore: ObservableObject {
    @AppStorage("wardenclyffe.tower.energyState") private var energyStateRaw: String = TowerEnergyState.idle.rawValue
    @AppStorage("wardenclyffe.tower.intensity") private var intensityRaw: Double = 0.25
    @AppStorage("wardenclyffe.tower.frequency") private var frequencyRaw: Double = 0.5

    @Published var energyState: TowerEnergyState = .idle
    @Published var intensity: Double = 0.25     // 0...1
    @Published var frequency: Double = 0.5      // 0...1

    init() {
        energyState = TowerEnergyState(rawValue: energyStateRaw) ?? .idle
        intensity = min(max(intensityRaw, 0), 1)
        frequency = min(max(frequencyRaw, 0), 1)
    }

    func toggleEnergy() {
        energyState = (energyState == .idle) ? .energized : .idle
        energyStateRaw = energyState.rawValue
    }

    func setIntensity(_ v: Double) {
        intensity = min(max(v, 0), 1)
        intensityRaw = intensity
    }

    func setFrequency(_ v: Double) {
        frequency = min(max(v, 0), 1)
        frequencyRaw = frequency
    }
}
