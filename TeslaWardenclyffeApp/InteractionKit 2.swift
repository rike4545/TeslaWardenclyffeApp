//
//  InteractionKit 2.swift
//  TeslaWardenclyffeApp
//
//  Created by Bryan on 12/15/25.
//


import SwiftUI
import Combine
import AVFoundation

@MainActor
final class InteractionKit: ObservableObject {
    static let shared = InteractionKit()

    @Published var soundEnabled: Bool = true
    @Published var hapticsEnabled: Bool = true

    private var audioPlayer: AVAudioPlayer?

    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        guard hapticsEnabled else { return }
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }

    func notify(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard hapticsEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }

    /// Safe no-op if asset is missing
    func playSound(named name: String, ext: String = "wav", volume: Float = 0.35) {
        guard soundEnabled else { return }
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.volume = volume
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            // ignore
        }
    }
}
