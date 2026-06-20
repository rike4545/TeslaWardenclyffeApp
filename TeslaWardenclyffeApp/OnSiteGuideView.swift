// OnSiteGuideView.swift

import SwiftUI
import CoreLocation

struct OnSiteGuideView: View {
    @EnvironmentObject private var appModel: AppModel
    @EnvironmentObject private var locationManager: WardenclyffeLocationManager
    @EnvironmentObject private var progress: WardenclyffeProgressStore
    @State private var selectedVisitPace: VisitPace = .highlights

    private var onSitePrograms: [ProgramCategory] {
        appModel.programCategories.filter { !$0.isVirtual }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("On-Site at Wardenclyffe")
                    .wardenclyffeSectionHeader()
                    .padding(.horizontal)
                    .padding(.top)

                quickActionsSection
                    .padding(.horizontal)

                visitReadinessSection
                    .padding(.horizontal)

                visitPlanSection
                    .padding(.horizontal)

                if let tours = onSitePrograms.first(where: { $0.name.contains("Tours") }) {
                    ProgramHighlightCard(program: tours)
                        .padding(.horizontal)
                }

                // HISTORY
                VStack(alignment: .leading, spacing: 12) {
                    Text("History of Wardenclyffe")
                        .font(.headline)
                        .accessibilityAddTraits(.isHeader)

                    Text("Walk the grounds where Tesla built his wireless transmitting tower and laboratory, and see how the site has changed over more than a century.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    NavigationLink {
                        HistoryView()
                    } label: {
                        Label("View interactive timeline", systemImage: "clock.arrow.circlepath")
                            .font(.subheadline.bold())
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(.thinMaterial)
                            )
                    }
                    .accessibilityHint("Opens a chronological history of Wardenclyffe.")
                }
                .padding(.horizontal)

                // PROGRAMS
                if !onSitePrograms.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("On-Site Programs")
                            .font(.headline)
                            .accessibilityAddTraits(.isHeader)
                            .padding(.bottom, 4)

                        VStack(spacing: 12) {
                            ForEach(onSitePrograms) { program in
                                ProgramRow(program: program)
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // LOCATION
                VStack(alignment: .leading, spacing: 8) {
                    Text("Location & Hours")
                        .font(.headline)
                        .accessibilityAddTraits(.isHeader)

                    Text("Tesla Science Center at Wardenclyffe is located in Shoreham, New York. Access and hours may vary while restoration and construction continue.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    if let url = URL(string: "https://teslasciencecenter.org/contact-us/") {
                        Link("Learn more and get directions", destination: url)
                            .font(.subheadline.bold())
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .background(WardenclyffeTheme.background.ignoresSafeArea())
        .navigationTitle("On Site")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            locationManager.requestAccessIfNeeded()
        }
    }

    // MARK: - Quick actions

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Explore On-Site")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)

            VStack(spacing: 12) {
                NavigationLink {
                    KidsQuestView()
                } label: {
                    quickActionTile(
                        title: "Kids’ Quest",
                        subtitle: "Solve clues, learn history, and earn Junior Inventor badges.",
                        systemImage: "figure.and.child.holdinghands"
                    )
                }

                NavigationLink {
                    ARWardenclyffeView()
                } label: {
                    quickActionTile(
                        title: "AR Wardenclyffe Tower",
                        subtitle: "See a virtual tower rise where Tesla’s original tower once stood.",
                        systemImage: "viewfinder.circle"
                    )
                }

                NavigationLink {
                    HistoryView()
                } label: {
                    quickActionTile(
                        title: "History Timeline",
                        subtitle: "Follow the story from Tesla’s tower to today’s science center.",
                        systemImage: "clock.arrow.circlepath"
                    )
                }
            }
        }
    }

    private var visitReadinessSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(locationManager.isOnSite ? "Wardenclyffe detected" : "Visit readiness")
                        .font(.headline)
                        .accessibilityAddTraits(.isHeader)

                    Text(locationStatusSummary)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Image(systemName: locationManager.isOnSite ? "location.fill" : "location")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(locationManager.isOnSite ? WardenclyffeTheme.accent : .secondary)
                    .accessibilityHidden(true)
            }

            if locationManager.authorizationStatus == .notDetermined {
                Button("Enable Location", systemImage: "location") {
                    locationManager.requestAccessIfNeeded()
                }
                .buttonStyle(.borderedProminent)
                .tint(WardenclyffeTheme.accent)
            } else if locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .restricted {
                Text(locationManager.lastErrorDescription ?? "Location access is off, so on-site experiences won't auto-adapt yet.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else if let currentLocation = locationManager.currentLocation {
                Text("Approximate distance update received at \(currentLocation.timestamp.formatted(date: .omitted, time: .shortened)).")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .wardenclyffeGlassCard()
    }

    private var visitPlanSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Visit Plan")
                        .font(.headline)
                        .accessibilityAddTraits(.isHeader)
                    Text(selectedVisitPace.summary)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("\(visitCompletionCount)/\(visitSteps.count)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }

            Picker("Visit pace", selection: $selectedVisitPace) {
                ForEach(VisitPace.allCases) { pace in
                    Text(pace.title).tag(pace)
                }
            }
            .pickerStyle(.segmented)

            VStack(spacing: 10) {
                ForEach(visitSteps) { step in
                    VisitStepRow(step: step)
                }
            }

            NavigationLink {
                KidsQuestView()
            } label: {
                Label("Continue with quests", systemImage: "checklist")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .wardenclyffeGlassCard()
    }

    private var visitCompletionCount: Int {
        visitSteps.filter(\.isReady).count
    }

    private var visitSteps: [VisitStep] {
        let baseSteps = [
            VisitStep(
                title: "Orient at the lab",
                detail: "Start with the surviving brick laboratory and the site story.",
                systemImage: "building.columns",
                isReady: true
            ),
            VisitStep(
                title: "Find a story thread",
                detail: "Use the timeline to connect Tesla's tower, wireless power, and restoration.",
                systemImage: "clock.arrow.circlepath",
                isReady: progress.isUnlocked(.timelineScrubber)
            ),
            VisitStep(
                title: "Run a quest",
                detail: "Pick one clue and earn a badge while you walk the grounds.",
                systemImage: "sparkle.magnifyingglass",
                isReady: appModel.quests.contains(where: { $0.isCompleted })
            ),
            VisitStep(
                title: "Raise the tower in AR",
                detail: "Place a virtual tower and compare it with the present-day site.",
                systemImage: "viewfinder.circle",
                isReady: progress.isUnlocked(.arEnergize)
            )
        ]

        switch selectedVisitPace {
        case .quick:
            return Array(baseSteps.prefix(2))
        case .highlights:
            return Array(baseSteps.prefix(3))
        case .deepDive:
            return baseSteps
        }
    }

    private var locationStatusSummary: String {
        if locationManager.isOnSite {
            return "You're close enough to the site for location-aware prompts and guided exploration."
        }

        switch locationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            return "You're currently away from Wardenclyffe, but you can still preview the visit flow and jump in when you arrive."
        case .denied, .restricted:
            return "Turn location back on in Settings if you want the app to recognize when you've reached the site."
        case .notDetermined:
            return "Allow location to help the guide switch into on-site mode automatically when you're at Wardenclyffe."
        @unknown default:
            return "The guide can still be browsed remotely while location settles."
        }
    }

    private func quickActionTile(
        title: String,
        subtitle: String,
        systemImage: String
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.title2)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(WardenclyffeTheme.accent.opacity(0.2))
                )
                .foregroundStyle(WardenclyffeTheme.accent)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundStyle(.primary)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
        }
        .wardenclyffeGlassCard()
        .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

// MARK: - Subviews

private enum VisitPace: String, CaseIterable, Identifiable {
    case quick
    case highlights
    case deepDive

    var id: String { rawValue }

    var title: String {
        switch self {
        case .quick:
            "Quick"
        case .highlights:
            "Highlights"
        case .deepDive:
            "Deep"
        }
    }

    var summary: String {
        switch self {
        case .quick:
            "A short orientation for first-time visitors."
        case .highlights:
            "A balanced route through story, place, and quests."
        case .deepDive:
            "The fuller visit path with AR and deeper history."
        }
    }
}

private struct VisitStep: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let systemImage: String
    let isReady: Bool
}

private struct VisitStepRow: View {
    let step: VisitStep

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: step.isReady ? "checkmark.circle.fill" : step.systemImage)
                .font(.title3.weight(.semibold))
                .frame(width: 34, height: 34)
                .foregroundStyle(step.isReady ? .green : WardenclyffeTheme.accent)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text(step.title)
                    .font(.subheadline.weight(.semibold))
                Text(step.detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(.white.opacity(0.08)))
        .accessibilityElement(children: .combine)
    }
}

struct ProgramHighlightCard: View {
    let program: ProgramCategory

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(program.name)
                .font(.title3.bold())
                .minimumScaleFactor(0.9)

            Text(program.summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            if let url = program.url {
                Link("View details on teslasciencecenter.org", destination: url)
                    .font(.subheadline.bold())
            }
        }
        .wardenclyffeGlassCard()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(program.name). \(program.summary)")
    }
}

struct ProgramRow: View {
    let program: ProgramCategory

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(program.name)
                    .font(.subheadline.bold())
                Text(program.summary)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            if program.url != nil {
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
            }
        }
        .wardenclyffeGlassCard()
        .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
