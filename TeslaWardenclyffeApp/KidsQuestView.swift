// KidsQuestView.swift

import SwiftUI

struct KidsQuestView: View {
    @EnvironmentObject private var appModel: AppModel
    @EnvironmentObject private var locationManager: WardenclyffeLocationManager
    @State private var showCertificate = false

    private var completedCount: Int {
        appModel.quests.filter { $0.isCompleted }.count
    }

    private var totalCount: Int {
        appModel.quests.count
    }

    private var completionFraction: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header

                WardenclyffeAssetBanner(
                    imageName: "QuestPassport",
                    title: "Badge Passport",
                    subtitle: "Collect clues, earn seals, and unlock your Junior Inventor certificate."
                )

                progressSummary

                badgePassport

                VStack(alignment: .leading, spacing: 16) {
                    ForEach(appModel.quests) { quest in
                        QuestCard(quest: quest)
                    }
                }
            }
            .padding()
        }
        .background(WardenclyffeTheme.background.ignoresSafeArea())
        .navigationTitle("Kids’ Quest")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showCertificate) {
            QuestCertificateView(completedCount: completedCount, totalCount: totalCount)
                .presentationDetents([.medium])
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Junior Inventor Quest")
                .wardenclyffeSectionHeader()

            Text("Solve clues around Tesla’s last lab, learn the history of Wardenclyffe, and earn badges inspired by his inventions.")
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            if locationManager.isOnSite {
                Label(
                    "You’re at Wardenclyffe! Some quests unlock extra fun when you’re on the grounds.",
                    systemImage: "location.fill"
                )
                .font(.caption)
                .foregroundStyle(.green)
                .accessibilityHint("You are currently near the science center; clues may refer to places around you.")
            } else {
                Label(
                    "You’re exploring from home. Try the clues and read the history, then complete quests when you visit.",
                    systemImage: "house"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
    }

    private var progressSummary: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Progress")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)

            Text("\(completedCount) of \(totalCount) quests completed")
                .font(.subheadline)

            ProgressView(value: completionFraction)
                .accessibilityLabel("Quest progress")
                .accessibilityValue("\(completedCount) of \(totalCount) quests complete")
        }
    }

    private var badgePassport: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("Badge Passport")
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)

                Spacer()

                Text("\(Int(completionFraction * 100))%")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(appModel.quests) { quest in
                    QuestBadgeTile(quest: quest)
                }
            }

            Button {
                showCertificate = true
            } label: {
                Label(completedCount == totalCount ? "Open inventor certificate" : "Preview certificate", systemImage: "seal")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .wardenclyffeGlassCard()
    }
}

struct QuestCard: View {
    @EnvironmentObject private var appModel: AppModel
    @EnvironmentObject private var fx: InteractionKit
    @EnvironmentObject private var progress: WardenclyffeProgressStore
    let quest: Quest

    private var relatedHistorySnippet: String? {
        appModel.historyEntries
            .sorted { $0.order < $1.order }
            .first(where: { $0.category == quest.relatedCategory })?
            .summary
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(quest.title)
                    .font(.headline)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 8)

                Text(quest.rewardBadgeName)
                    .font(.caption2.bold())
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(quest.isCompleted ? WardenclyffeTheme.accent : Color(.tertiarySystemBackground))
                    )
                    .foregroundStyle(quest.isCompleted ? Color.white : .primary)
                    .accessibilityLabel("Badge: \(quest.rewardBadgeName)")
                    .accessibilityHint(quest.isCompleted ? "You have earned this badge." : "Complete the quest to earn this badge.")
            }

            Text("Clue: \(quest.clue)")
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)

            Text("Where to look: \(quest.locationHint)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            if let snippet = relatedHistorySnippet {
                Divider()

                VStack(alignment: .leading, spacing: 4) {
                    Text("History connection")
                        .font(.caption.bold())

                    Text(snippet)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                NavigationLink {
                    HistoryView()
                } label: {
                    Label("View more in the timeline", systemImage: "clock.arrow.circlepath")
                        .font(.caption.bold())
                }
                .padding(.top, 4)
            }

            HStack {
                Button {
                    let wasCompleted = quest.isCompleted
                    appModel.toggleQuestCompletion(quest)
                    fx.impact(.medium)
                    if !wasCompleted {
                        progress.addPower(8, reason: "Quest Completed")
                        fx.notify(.success)
                    }
                } label: {
                    Label(
                        quest.isCompleted ? "Mark as not done" : "Mark quest completed",
                        systemImage: quest.isCompleted ? "checkmark.circle.fill" : "checkmark.circle"
                    )
                }
                .font(.caption)
                .buttonStyle(.borderedProminent)
                .tint(WardenclyffeTheme.accent)

                Spacer()
            }
            .padding(.top, 6)
        }
        .wardenclyffeGlassCard()
        .accessibilityElement(children: .combine)
        .accessibilityHint("Double-tap to toggle completion and explore connected history.")
    }
}

private struct QuestBadgeTile: View {
    let quest: Quest

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: quest.isCompleted ? "seal.fill" : "seal")
                .font(.title2.weight(.semibold))
                .foregroundStyle(quest.isCompleted ? WardenclyffeTheme.accent : .secondary)
                .accessibilityHidden(true)

            Text(quest.rewardBadgeName)
                .font(.caption.weight(.semibold))
                .lineLimit(2)
                .minimumScaleFactor(0.85)

            Text(quest.isCompleted ? "Earned" : "Locked")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(.white.opacity(0.08)))
        .accessibilityElement(children: .combine)
    }
}

private struct QuestCertificateView: View {
    let completedCount: Int
    let totalCount: Int
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                Image(systemName: completedCount == totalCount ? "seal.fill" : "seal")
                    .font(.system(size: 54, weight: .semibold))
                    .foregroundStyle(WardenclyffeTheme.accent)

                Text(completedCount == totalCount ? "Junior Inventor" : "Inventor in Training")
                    .font(.title2.bold())

                Text("Completed \(completedCount) of \(totalCount) Wardenclyffe quests.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Text(completedCount == totalCount ? "Certificate unlocked. Keep exploring the tower, lab, and invention trail." : "Finish every quest to fully unlock this certificate.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(WardenclyffeTheme.background.ignoresSafeArea())
            .navigationTitle("Certificate")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
