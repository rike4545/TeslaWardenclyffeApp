//
//  HomeView.swift
//  TeslaWardenclyffeApp
//
//  ✅ Image-first HomeView (no overlap) + ✅ end-user “How to use” explanations built-in
//  - NO floating HUD pill (status is inside the hero only)
//  - ScrollView has bottom safe-area padding so TabBar never covers content
//  - Hero uses images (with safe fallback if assets are missing)
//  - Includes a collapsible “How to Use” section for end users
//
//  Optional Assets (recommended):
//  - WardenclyffeHero
//  - WardenclyffeTower
//  - WardenclyffeMuseum
//  - WardenclyffeBlueprint
//  - WardenclyffeNight
//

import SwiftUI
import CoreLocation

struct HomeView: View {
    @EnvironmentObject private var appModel: AppModel
    @EnvironmentObject private var fx: InteractionKit
    @EnvironmentObject private var progress: WardenclyffeProgressStore
    @EnvironmentObject private var tower: TowerStateStore
    @EnvironmentObject private var sparks: DailySparkStore
    @EnvironmentObject private var locationManager: WardenclyffeLocationManager
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var showPostcardStudio = false
    @State private var dailySparkSelection: String? = nil
    @State private var dailySparkFeedback: String? = nil
    @State private var selectedMissionIndex = 0

    // End-user help controls
    @State private var showHowToUse = true
    @State private var showWhatIsPower = false
    @State private var showWhatIsStreak = false
    @State private var showWhatIsEnergized = false
    @State private var showHowARWorks = false
    @State private var showHowGuideWorks = false
    @State private var showHowExploreWorks = false
    @State private var showHowConsoleWorks = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 18) {
                heroHeader

                missionControlSection

                visitStatusSection

                nextUnlockSection

                dailySparkSection

                howToUseSection

                startHereSection

                exploreSection

                towerConsole
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .safeAreaPadding(.bottom, 140) // ✅ prevents TabBar overlap
        }
        .navigationTitle("Wardenclyffe")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    fx.impact(.light)
                    progress.addPower(1, reason: "Home Spark")
                    fx.notify(.success)
                } label: {
                    Image(systemName: "sparkle")
                        .font(.system(size: 16, weight: .semibold))
                        .padding(10)
                        .background(.ultraThinMaterial, in: Circle())
                        .overlay(Circle().strokeBorder(.white.opacity(0.12)))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Add a spark")
            }
        }
        .sheet(isPresented: $showPostcardStudio) {
            NavigationStack { PostcardStudio(capturedImage: nil) }
        }
        .onAppear {
            locationManager.requestAccessIfNeeded()
        }
    }

    // MARK: - HERO (image + status + one primary action)

    private var heroHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .bottomLeading) {
                HomeAssetImage(name: "WardenclyffeHero",
                               fallbackSystemImage: "antenna.radiowaves.left.and.right")
                .frame(height: 240)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .overlay(
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.25), .black.opacity(0.62)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .strokeBorder(.white.opacity(0.10))
                )

                VStack(alignment: .leading, spacing: 10) {
                    Text("Tesla’s Wardenclyffe")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.white)

                    Text("Explore the site, trigger AR, and collect Sparks.\nMake the tower feel alive.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.85))
                        .lineLimit(3)

                    telemetryStrip
                }
                .padding(16)
            }

            NavigationLink {
                WardenclyffeARExperienceView()
            } label: {
                heroCTA
            }
            .buttonStyle(.plain)
        }
    }

    private var telemetryStrip: some View {
        HStack(spacing: 10) {
            telemetryButton(
                icon: "bolt.fill",
                text: "\(progress.totalPower)",
                accessibilityLabel: "Power \(progress.totalPower). Shows how close you are to your next unlock."
            ) {
                showWhatIsPower.toggle()
            }

            dot

            telemetryButton(
                icon: "flame.fill",
                text: "\(sparks.currentStreak)",
                accessibilityLabel: "Streak \(sparks.currentStreak). Shows your daily return streak."
            ) {
                showWhatIsStreak.toggle()
            }

            dot

            telemetryButton(
                icon: "dot.radiowaves.left.and.right",
                text: tower.energyState == .energized ? "Energized" : "Idle",
                accessibilityLabel: "Tower is \(tower.energyState == .energized ? "energized" : "idle"). Shows the current tower mode."
            ) {
                showWhatIsEnergized.toggle()
            }

            Spacer()

            Button("How to use", systemImage: "info.circle") {
                showHowToUse.toggle()
            }
            .labelStyle(.iconOnly)
            .foregroundStyle(.white.opacity(0.85))
            .accessibilityHint("Shows or hides the how to use guide.")
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(.white.opacity(0.90))
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.black.opacity(0.18), in: Capsule())
        .overlay(Capsule().strokeBorder(.white.opacity(0.18)))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Power \(progress.totalPower). Streak \(sparks.currentStreak). \(tower.energyState == .energized ? "Energized" : "Idle").")
    }

    private func telemetryButton(
        icon: String,
        text: String,
        accessibilityLabel: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(text).monospacedDigit()
            }
            .lineLimit(1)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }

    private var dot: some View {
        Circle()
            .frame(width: 3, height: 3)
            .foregroundStyle(.white.opacity(0.65))
            .padding(.horizontal, 2)
    }

    private var heroCTA: some View {
        HStack(spacing: 12) {
            Image(systemName: "arkit")
                .font(.system(size: 18, weight: .semibold))

            VStack(alignment: .leading, spacing: 2) {
                Text("Start AR Experience")
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)

                Text(progress.isUnlocked(.arEnergize) ? "Place & energize the tower" : "Locked — earn access with Sparks")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.thinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(.white.opacity(progress.isUnlocked(.arEnergize) ? 0.18 : 0.10))
        )
    }

    // MARK: - Daily Spark

    private var missionControlSection: some View {
        let missions = homeMissions
        let selectedMission = missions[min(selectedMissionIndex, missions.count - 1)]

        return VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Mission Control")
                        .font(.headline)
                    Text(missionControlSummary)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                readinessGauge
            }

            Picker("Mission", selection: $selectedMissionIndex) {
                ForEach(missions.indices, id: \.self) { index in
                    Text(missions[index].shortTitle).tag(index)
                }
            }
            .pickerStyle(.segmented)

            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: selectedMission.systemImage)
                        .font(.title3.weight(.semibold))
                        .frame(width: 42, height: 42)
                        .background(WardenclyffeTheme.accent.opacity(0.16), in: Circle())
                        .foregroundStyle(WardenclyffeTheme.accent)
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(selectedMission.title)
                            .font(.subheadline.weight(.semibold))
                        Text(selectedMission.subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 8)
                }

                HStack(spacing: 8) {
                    MissionMetric(label: "Time", value: selectedMission.duration)
                    MissionMetric(label: "Reward", value: selectedMission.reward)
                    MissionMetric(label: "Mode", value: selectedMission.mode)
                }

                NavigationLink {
                    missionDestination(for: selectedMission.destination)
                } label: {
                    Label(selectedMission.actionTitle, systemImage: "arrow.right.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(WardenclyffeTheme.accent)
                .simultaneousGesture(TapGesture().onEnded {
                    fx.impact(.light)
                    progress.addPower(1, reason: "Mission Started")
                })
            }
            .padding(14)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).strokeBorder(.white.opacity(0.08)))
        }
        .padding(16)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 26, style: .continuous).strokeBorder(.white.opacity(0.08)))
        .animation(reduceMotion ? nil : .snappy, value: selectedMissionIndex)
    }

    private var readinessGauge: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text("\(missionReadiness)%")
                .font(.title3.weight(.bold))
                .monospacedDigit()
            Text("Ready")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .accessibilityLabel("Mission readiness \(missionReadiness) percent")
    }

    private var missionReadiness: Int {
        var score = min(55, progress.totalPower)
        if tower.energyState == .energized { score += 15 }
        if sparks.currentStreak > 0 { score += min(20, sparks.currentStreak * 5) }
        if locationManager.isOnSite { score += 10 }
        return min(100, max(12, score))
    }

    private var missionControlSummary: String {
        if locationManager.isOnSite {
            return "You are close to the site. Prioritize guide prompts and AR."
        }
        if progress.totalPower < 20 {
            return "Build momentum with one short activity, then unlock deeper tools."
        }
        return "Pick a route and keep the tower moving."
    }

    private var homeMissions: [HomeMission] {
        [
            HomeMission(
                shortTitle: "Visit",
                title: locationManager.isOnSite ? "On-site discovery route" : "Plan the Wardenclyffe visit",
                subtitle: "Use the guide to connect location cues, history, quests, and tour details in one flow.",
                systemImage: "map.fill",
                duration: "8 min",
                reward: "+6",
                mode: locationManager.isOnSite ? "On site" : "Preview",
                actionTitle: locationManager.isOnSite ? "Open live guide" : "Preview guide",
                destination: .guide
            ),
            HomeMission(
                shortTitle: "Learn",
                title: "Run a wireless power lab",
                subtitle: "Tune frequency and intensity, then compare your signal against Tesla-inspired experiment goals.",
                systemImage: "waveform.path.ecg",
                duration: "5 min",
                reward: "+4",
                mode: "Lab",
                actionTitle: "Open virtual lab",
                destination: .lab
            ),
            HomeMission(
                shortTitle: "Story",
                title: "Trace the invention trail",
                subtitle: "Move from Wardenclyffe history into Tesla's patents and see how the big ideas connect.",
                systemImage: "book.pages.fill",
                duration: "10 min",
                reward: "+5",
                mode: "Timeline",
                actionTitle: "Start timeline",
                destination: .history
            )
        ]
    }

    @ViewBuilder
    private func missionDestination(for destination: HomeMission.Destination) -> some View {
        switch destination {
        case .guide:
            OnSiteGuideView()
        case .lab:
            VirtualLabView()
        case .history:
            HistoryView()
        }
    }

    private var visitStatusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(locationManager.isOnSite ? "You're On Site" : "Plan Your Visit")
                        .font(.headline)

                    Text(visitStatusMessage)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: locationManager.isOnSite ? "location.fill" : "location.slash")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(locationManager.isOnSite ? WardenclyffeTheme.accent : .secondary)
                    .accessibilityHidden(true)
            }

            NavigationLink {
                OnSiteGuideView()
            } label: {
                Label(locationManager.isOnSite ? "Open on-site guide" : "Preview on-site guide", systemImage: "map")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(WardenclyffeTheme.accent)

            if !locationManager.isOnSite, locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .restricted {
                Text(locationManager.lastErrorDescription ?? "Location access is unavailable right now.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 26, style: .continuous).strokeBorder(.white.opacity(0.08)))
    }

    private var visitStatusMessage: String {
        if locationManager.isOnSite {
            return "Hotspots and AR-ready experiences should feel more immediate while you explore the grounds."
        }

        switch locationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            return "You can still explore remotely, then switch to the on-site guide when you arrive at Wardenclyffe."
        case .denied, .restricted:
            return "Enable location in Settings if you want the app to recognize when you've arrived at the site."
        case .notDetermined:
            return "Allow location to help the app recognize when you're at Wardenclyffe and highlight on-site experiences."
        @unknown default:
            return "Explore remotely now, and the app can adapt when location becomes available."
        }
    }

    private var nextUnlockSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Progress Path")
                    .font(.headline)
                Spacer()
                Text("\(progress.totalPower) Power")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            if let milestone = progress.nextMilestone {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Next unlock: \(milestone.title)")
                                .font(.subheadline.weight(.semibold))
                            Text(milestone.detail)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text("\(progress.powerNeededForNextMilestone) to go")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(WardenclyffeTheme.accent)
                    }

                    ProgressView(value: progress.progressToNextMilestone)
                        .tint(WardenclyffeTheme.accent)

                    Text(nextUnlockPrompt(for: milestone.unlock))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else {
                Text("You've unlocked the current feature set. Try AR, the on-site guide, or Postcard Studio to enjoy the full experience.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 26, style: .continuous).strokeBorder(.white.opacity(0.08)))
    }

    private var dailySparkSection: some View {
        let spark = sparks.sparkForToday()
        let claimed = !sparks.canClaimToday()

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Daily Spark")
                    .font(.headline)
                Spacer()
                if claimed {
                    Label("Claimed", systemImage: "checkmark.seal.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                } else {
                    Text("Answer to claim +5 Power")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Text(spark.prompt)
                .font(.subheadline.weight(.semibold))

            VStack(spacing: 8) {
                ForEach(spark.choices, id: \.self) { choice in
                    Button {
                        guard !claimed else { return }
                        dailySparkSelection = choice
                        if choice == spark.correct {
                            sparks.claim()
                            progress.addPower(5, reason: "Daily Spark")
                            fx.notify(.success)
                            dailySparkFeedback = spark.explanation
                        } else {
                            fx.notify(.warning)
                            dailySparkFeedback = "Not quite. Try again for today’s Spark."
                        }
                    } label: {
                        HStack {
                            Text(choice)
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                            Spacer()
                            if dailySparkSelection == choice {
                                Image(systemName: choice == spark.correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundStyle(choice == spark.correct ? .green : .red)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(.white.opacity(0.10))
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(claimed)
                }
            }

            if let feedback = dailySparkFeedback {
                Text(feedback)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 26, style: .continuous).strokeBorder(.white.opacity(0.08)))
        .animation(reduceMotion ? nil : .snappy, value: dailySparkFeedback)
    }

    private func nextUnlockPrompt(for unlock: WardenclyffeUnlock) -> String {
        switch unlock {
        case .hotspotsBasics:
            "Open the on-site guide and today's spark to start building momentum."
        case .timelineScrubber:
            "History and guide interactions are a quick way to keep climbing."
        case .patentsExplorer:
            "Keep exploring the story side of the app to unlock Tesla's invention trail."
        case .arEnergize:
            "A few more Sparks will unlock the full AR energize moment."
        case .buildMode:
            "You're close to the advanced tower interactions."
        case .postcardStudio:
            "Sharing and exploration are about to open up more creative tools."
        case .dailySparkStreak:
            "Keep returning daily to strengthen your streak."
        }
    }

    // MARK: - HOW TO USE (end user explanations)

    private var howToUseSection: some View {
        VStack(spacing: 10) {
            HStack {
                Text("How to Use")
                    .font(.headline)
                Spacer()
                Button {
                    withAnimation(.snappy) { showHowToUse.toggle() }
                    fx.impact(.light)
                } label: {
                    Image(systemName: showHowToUse ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .padding(8)
                        .background(.ultraThinMaterial, in: Circle())
                        .overlay(Circle().strokeBorder(.white.opacity(0.10)))
                }
                .buttonStyle(.plain)
            }

            if showHowToUse {
                VStack(alignment: .leading, spacing: 10) {

                    HelpCard(
                        title: "What do the numbers mean?",
                        subtitle: "Tap each badge in the hero for a quick definition.",
                        systemImage: "gauge"
                    ) {
                        DisclosureGroup("⚡ Power (your score & unlocks)", isExpanded: $showWhatIsPower) {
                            HelpText("Power is your in-app progress score. You earn it by exploring, completing quests, discharging the tower, or using AR features. Some experiences can be gated by Power.")
                        }

                        DisclosureGroup("🔥 Streak (daily return)", isExpanded: $showWhatIsStreak) {
                            HelpText("Your streak grows when you complete the Daily Spark. Streaks encourage returning, and can unlock cosmetics or bonuses depending on how you configure your app.")
                        }

                        DisclosureGroup("Energized / Idle (tower mode)", isExpanded: $showWhatIsEnergized) {
                            HelpText("Energized means the tower’s signal is “active”. In Energized mode, the app can show stronger effects (animations, haptics, sound cues, AR visuals). Idle is a calmer state.")
                        }
                    }

                    HelpCard(
                        title: "AR Experience",
                        subtitle: "The main interactive mode.",
                        systemImage: "arkit"
                    ) {
                        DisclosureGroup("How AR works", isExpanded: $showHowARWorks) {
                            HelpText("""
                            1) Tap Start AR Experience.
                            2) Move your phone to detect a surface.
                            3) Place the tower.
                            4) Interact: tap/double-tap/press-and-hold to trigger effects and earn Power.
                            """)
                        }
                    }

                    HelpCard(
                        title: "On-Site Guide",
                        subtitle: "Best when you’re physically at the museum.",
                        systemImage: "map"
                    ) {
                        DisclosureGroup("How the guide works", isExpanded: $showHowGuideWorks) {
                            HelpText("""
                            Use the map and hotspot hints to navigate the site. When you get close to a hotspot, the app can reveal extra information, quests, and AR prompts.
                            """)
                        }
                    }

                    HelpCard(
                        title: "Explore",
                        subtitle: "Extra features you can dip into anytime.",
                        systemImage: "rectangle.stack"
                    ) {
                        DisclosureGroup("What’s inside Explore", isExpanded: $showHowExploreWorks) {
                            HelpText("""
                            • Virtual Lab: interactive learning and demos.
                            • Events: what’s happening at/around the site.
                            • Postcard Studio: make and share a Wardenclyffe moment.
                            • Quests: guided tasks that earn Power.
                            """)
                        }
                    }

                    HelpCard(
                        title: "Tower Console",
                        subtitle: "A control panel for the tower’s state.",
                        systemImage: "dial.high"
                    ) {
                        DisclosureGroup("How the console works", isExpanded: $showHowConsoleWorks) {
                            HelpText("""
                            • Energize: toggles tower mode (Energized/Idle).
                            • Intensity: how strong the effects feel.
                            • Frequency: how fast the “pulse” feels.
                            • Discharge: a satisfying action that rewards Power and feedback.
                            """)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 26, style: .continuous).strokeBorder(.white.opacity(0.08)))
    }

    // MARK: - Start Here (image-backed tiles)

    private var startHereSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Start Here")
                .font(.headline)

            VStack(spacing: 12) {
                NavigationLink { WardenclyffeARExperienceView() } label: {
                    HomeImageTile(
                        imageName: "WardenclyffeTower",
                        fallbackSystemImage: "arkit",
                        title: "AR Experience",
                        subtitle: "Place the tower, energize it, and explore interactive states",
                        badge: progress.isUnlocked(.arEnergize) ? "READY" : "LOCKED"
                    )
                }
                .buttonStyle(.plain)

                NavigationLink { OnSiteGuideView() } label: {
                    HomeImageTile(
                        imageName: "WardenclyffeMuseum",
                        fallbackSystemImage: "map",
                        title: "On-Site Guide",
                        subtitle: "Map, hints, and hotspots near you",
                        badge: nil
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Explore (carousel)

    private var exploreSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Explore").font(.headline)
                Spacer()
                Text("\(appModel.events.count) events")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    NavigationLink { VirtualLabView() } label: {
                        HomeMiniImageCard(
                            imageName: "WardenclyffeBlueprint",
                            fallbackSystemImage: "bolt.circle",
                            title: "Virtual Lab",
                            subtitle: "Experiments & demos"
                        )
                        .frame(width: 240)
                    }
                    .buttonStyle(.plain)

                    NavigationLink { EventsView() } label: {
                        HomeMiniImageCard(
                            imageName: "WardenclyffeNight",
                            fallbackSystemImage: "calendar",
                            title: "Events",
                            subtitle: "\(appModel.events.count) listed"
                        )
                        .frame(width: 220)
                    }
                    .buttonStyle(.plain)

                    Button {
                        fx.impact(.light)
                        showPostcardStudio = true
                        progress.addPower(1, reason: "Open Postcard Studio")
                    } label: {
                        HomeMiniImageCard(
                            imageName: "WardenclyffeHero",
                            fallbackSystemImage: "photo.on.rectangle",
                            title: "Postcard Studio",
                            subtitle: "Share a moment"
                        )
                        .frame(width: 260)
                    }
                    .buttonStyle(.plain)

                    Button {
                        fx.impact(.light)
                        progress.addPower(1, reason: "Quests Nudge")
                    } label: {
                        HomeMiniImageCard(
                            imageName: "WardenclyffeTower",
                            fallbackSystemImage: "checklist",
                            title: "Quests",
                            subtitle: "\(appModel.quests.filter { !$0.isCompleted }.count) remaining"
                        )
                        .frame(width: 220)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.vertical, 2)
            }
        }
    }

    // MARK: - Tower Console

    private var towerConsole: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Tower Console")
                        .font(.headline)
                    Text(tower.energyState == .energized ? "Signal active" : "Signal idle")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    fx.impact(.medium)
                    tower.toggleEnergy()
                    progress.addPower(2, reason: "Home Toggle Energy")
                    fx.notify(.success)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "bolt.fill")
                        Text(tower.energyState == .energized ? "Energized" : "Energize")
                    }
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 9)
                    .background(.ultraThinMaterial, in: Capsule())
                    .overlay(Capsule().strokeBorder(.white.opacity(0.12)))
                }
                .buttonStyle(.plain)
            }

            sliderRow("Intensity", value: "\(Int(tower.intensity * 100))%") {
                Slider(value: Binding(get: { tower.intensity }, set: { tower.setIntensity($0) }), in: 0...1)
            }

            sliderRow("Frequency", value: String(format: "%.2f", tower.frequency)) {
                Slider(value: Binding(get: { tower.frequency }, set: { tower.setFrequency($0) }), in: 0...1)
            }

            Button {
                fx.impact(.light)
                progress.addPower(3, reason: "Home Discharge")
                fx.notify(.success)
            } label: {
                Label("Discharge +3 Power", systemImage: "bolt.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .padding(16)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 26, style: .continuous).strokeBorder(.white.opacity(0.08)))
    }

    private func sliderRow(_ title: String, value: String, slider: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                Spacer()
                Text(value).monospacedDigit().foregroundStyle(.secondary)
            }
            slider()
        }
    }
}

// MARK: - Small help UI components (namespaced to avoid collisions)

private struct HelpCard<Content: View>: View {
    let title: String
    let subtitle: String
    let systemImage: String
    @ViewBuilder let content: Content

    init(title: String, subtitle: String, systemImage: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .semibold))
                    .padding(10)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(.white.opacity(0.10)))

                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.subheadline.weight(.semibold))
                    Text(subtitle).font(.caption).foregroundStyle(.secondary)
                }

                Spacer()
            }

            content
                .font(.subheadline)
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).strokeBorder(.white.opacity(0.08)))
    }
}

private struct HelpText: View {
    let text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text)
            .foregroundStyle(.secondary)
            .padding(.top, 6)
    }
}

private struct HomeMission {
    enum Destination {
        case guide
        case lab
        case history
    }

    let shortTitle: String
    let title: String
    let subtitle: String
    let systemImage: String
    let duration: String
    let reward: String
    let mode: String
    let actionTitle: String
    let destination: Destination
}

private struct MissionMetric: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(.white.opacity(0.08)))
    }
}

// MARK: - Image helpers (safe if asset missing)

private struct HomeAssetImage: View {
    let name: String
    let fallbackSystemImage: String

    var body: some View {
        if let ui = UIImage(named: name) {
            Image(uiImage: ui)
                .resizable()
                .scaledToFill()
        } else {
            ZStack {
                LinearGradient(
                    colors: [Color.white.opacity(0.08), Color.white.opacity(0.02), .clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                Image(systemName: fallbackSystemImage)
                    .font(.system(size: 46, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.32))
            }
        }
    }
}

private struct HomeImageTile: View {
    let imageName: String
    let fallbackSystemImage: String
    let title: String
    let subtitle: String
    let badge: String?

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            HomeAssetImage(name: imageName, fallbackSystemImage: fallbackSystemImage)
                .frame(height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))

            LinearGradient(
                colors: [.clear, .black.opacity(0.45), .black.opacity(0.72)],
                startPoint: .top,
                endPoint: .bottom
            )
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))

            HStack(alignment: .bottom, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.82))
                        .lineLimit(2)

                    if let badge {
                        Text(badge)
                            .font(.caption2.weight(.semibold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(.black.opacity(0.22), in: Capsule())
                            .overlay(Capsule().strokeBorder(.white.opacity(0.20)))
                            .padding(.top, 2)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.75))
                    .padding(.bottom, 2)
            }
            .padding(16)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .strokeBorder(.white.opacity(0.10))
        )
    }
}

private struct HomeMiniImageCard: View {
    let imageName: String
    let fallbackSystemImage: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                HomeAssetImage(name: imageName, fallbackSystemImage: fallbackSystemImage)
                    .frame(height: 112)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

                LinearGradient(
                    colors: [.clear, .black.opacity(0.25), .black.opacity(0.55)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            }
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(.white.opacity(0.10))
            )

            Text(title)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)

            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(14)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 26, style: .continuous).strokeBorder(.white.opacity(0.08)))
    }
}
