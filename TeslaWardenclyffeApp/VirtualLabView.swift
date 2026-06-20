//
//  VirtualLabView.swift
//  TeslaWardenclyffeApp
//
//  Created by Bryan on 12/11/25.
//


// VirtualLabView.swift

import SwiftUI

struct VirtualLabView: View {
    @EnvironmentObject private var appModel: AppModel
    @EnvironmentObject private var fx: InteractionKit
    @EnvironmentObject private var progress: WardenclyffeProgressStore
    @EnvironmentObject private var tower: TowerStateStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var coilTurns = 55.0
    @State private var tuning = 0.62
    @State private var transmission = 0.48
    @State private var hasLoggedExperiment = false

    private var virtualPrograms: [ProgramCategory] {
        appModel.programCategories.filter { $0.isVirtual }
    }

    private var resonanceScore: Int {
        let coilTarget = 68.0
        let tuningTarget = 0.72
        let transmissionTarget = 0.58
        let coilFit = 1 - min(abs(coilTurns - coilTarget) / 70, 1)
        let tuningFit = 1 - min(abs(tuning - tuningTarget) / 0.72, 1)
        let transmissionFit = 1 - min(abs(transmission - transmissionTarget) / 0.58, 1)
        return Int(((coilFit * 0.34) + (tuningFit * 0.38) + (transmissionFit * 0.28)) * 100)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Virtual Science Center")
                    .font(.largeTitle.bold())
                    .padding(.horizontal)
                    .padding(.top)

                WardenclyffeAssetBanner(
                    imageName: "LabResonance",
                    title: "Tune the Signal",
                    subtitle: "Use the bench to balance coil turns, tuning, and transmission."
                )
                .padding(.horizontal)

                experimentBench
                    .padding(.horizontal)

                labNotebook
                    .padding(.horizontal)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Explore from Anywhere")
                        .font(.headline)

                    Text("Join online experiments, virtual STEAM camps, and other activities inspired by Tesla’s work in electricity, magnetism, and wireless technology.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Featured Virtual Programs")
                        .font(.headline)
                        .padding(.horizontal)

                    ForEach(virtualPrograms) { program in
                        ProgramRow(program: program)
                            .padding(.horizontal)
                    }

                    if let url = URL(string: "https://teslasciencecenter.org/virtual-science-center/") {
                        Link("Visit the full Virtual Science Center", destination: url)
                            .font(.subheadline.bold())
                            .padding(.horizontal)
                            .padding(.top, 4)
                    }
                }

                Spacer(minLength: 24)
            }
        }
        .background(WardenclyffeTheme.background.ignoresSafeArea())
        .navigationTitle("Virtual Lab")
    }

    private var experimentBench: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Resonance Bench")
                        .font(.headline)
                    Text(resonanceHint)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("\(resonanceScore)")
                    .font(.largeTitle.weight(.bold))
                    .monospacedDigit()
                    .foregroundStyle(resonanceScore > 82 ? .green : WardenclyffeTheme.accent)
                    .accessibilityLabel("Resonance score \(resonanceScore)")
            }

            ResonanceVisualizer(score: resonanceScore, reduceMotion: reduceMotion)
                .frame(height: 120)
                .accessibilityHidden(true)

            LabSliderRow(
                title: "Coil Turns",
                value: "\(Int(coilTurns))",
                systemImage: "circle.hexagongrid",
                slider: {
                    Slider(value: $coilTurns, in: 20...120, step: 1)
                }
            )

            LabSliderRow(
                title: "Tuning",
                value: "\(Int(tuning * 100))%",
                systemImage: "dial.medium",
                slider: {
                    Slider(value: $tuning, in: 0...1)
                }
            )

            LabSliderRow(
                title: "Transmission",
                value: "\(Int(transmission * 100))%",
                systemImage: "antenna.radiowaves.left.and.right",
                slider: {
                    Slider(value: $transmission, in: 0...1)
                }
            )

            Button {
                fx.impact(.medium)
                hasLoggedExperiment = true
                tower.setIntensity(max(tower.intensity, Double(resonanceScore) / 100))
                progress.addPower(resonanceScore > 82 ? 6 : 3, reason: "Virtual Lab Experiment")
                fx.notify(resonanceScore > 82 ? .success : .warning)
            } label: {
                Label(resonanceScore > 82 ? "Log Breakthrough" : "Log Experiment", systemImage: "checkmark.seal.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(WardenclyffeTheme.accent)
        }
        .padding(16)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 26, style: .continuous).strokeBorder(.white.opacity(0.08)))
        .animation(reduceMotion ? nil : .snappy, value: resonanceScore)
    }

    private var labNotebook: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Lab Notebook")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)

            LabNoteRow(
                title: "Observation",
                detail: "A cleaner signal appears when coil turns, tuning, and transmission are balanced instead of maxed out.",
                systemImage: "eye"
            )

            LabNoteRow(
                title: "Tower Link",
                detail: hasLoggedExperiment ? "Experiment logged. The tower console now reflects your strongest signal." : "Log an experiment to push the tower console intensity upward.",
                systemImage: hasLoggedExperiment ? "bolt.badge.checkmark" : "bolt"
            )

            NavigationLink {
                TeslaPatentsView()
            } label: {
                Label("Explore related Tesla patents", systemImage: "doc.text.magnifyingglass")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .padding(16)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 26, style: .continuous).strokeBorder(.white.opacity(0.08)))
    }

    private var resonanceHint: String {
        switch resonanceScore {
        case 86...100:
            "The signal is beautifully tuned. Log it as a breakthrough."
        case 65...85:
            "Close. Try a little more tuning and a steadier transmission level."
        default:
            "Start by tuning toward balance. More power is not always a cleaner signal."
        }
    }
}

private struct ResonanceVisualizer: View {
    let score: Int
    let reduceMotion: Bool

    var body: some View {
        TimelineView(.animation(minimumInterval: reduceMotion ? 1 : 0.05)) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate
                let midY = size.height / 2
                let amplitude = CGFloat(score) / 100 * (size.height * 0.34)
                let glowColor = score > 82 ? Color.green : WardenclyffeTheme.glow

                var path = Path()
                path.move(to: CGPoint(x: 0, y: midY))

                for x in stride(from: 0, through: size.width, by: 3) {
                    let phase = reduceMotion ? 0 : time * 2.4
                    let progress = x / max(size.width, 1)
                    let wave = sin((progress * .pi * 4) + phase)
                    let y = midY + CGFloat(wave) * amplitude
                    path.addLine(to: CGPoint(x: x, y: y))
                }

                context.stroke(
                    path,
                    with: .linearGradient(
                        Gradient(colors: [WardenclyffeTheme.accent, glowColor]),
                        startPoint: CGPoint(x: 0, y: 0),
                        endPoint: CGPoint(x: size.width, y: 0)
                    ),
                    lineWidth: 4
                )

                let baseline = Path { path in
                    path.move(to: CGPoint(x: 0, y: midY))
                    path.addLine(to: CGPoint(x: size.width, y: midY))
                }
                context.stroke(baseline, with: .color(.secondary.opacity(0.18)), lineWidth: 1)
            }
        }
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).strokeBorder(.white.opacity(0.08)))
    }
}

private struct LabSliderRow<SliderContent: View>: View {
    let title: String
    let value: String
    let systemImage: String
    @ViewBuilder let slider: SliderContent

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .foregroundStyle(WardenclyffeTheme.accent)
                    .accessibilityHidden(true)
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(value)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }

            slider
        }
    }
}

private struct LabNoteRow: View {
    let title: String
    let detail: String
    let systemImage: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: systemImage)
                .font(.title3.weight(.semibold))
                .frame(width: 34, height: 34)
                .foregroundStyle(WardenclyffeTheme.accent)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(.white.opacity(0.08)))
    }
}
