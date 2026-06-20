//  RootView.swift

import SwiftUI

enum WardenclyffeTab: Hashable {
    case home
    case guide
    case experience
    case lab
    case events
    case support
}

struct RootView: View {
    @EnvironmentObject private var appModel: AppModel

    // Interactivity layer (injected in TeslaWardenclyffeApp.swift)
    @EnvironmentObject private var fx: InteractionKit
    @EnvironmentObject private var progress: WardenclyffeProgressStore
    @EnvironmentObject private var tower: TowerStateStore
    @EnvironmentObject private var sparks: DailySparkStore

    @State private var selectedTab: WardenclyffeTab = .home
    @State private var showProgressSheet: Bool = false
    @AppStorage("wardenclyffe.onboarding.complete") private var hasSeenOnboarding: Bool = false
    @State private var showOnboarding: Bool = false

    var body: some View {
        ZStack(alignment: .top) {
            TabView(selection: $selectedTab) {

                NavigationStack {
                    HomeView()
                        .toolbar { hudToolbarButtonIfNeeded }
                }
                .tabItem { Label("Home", systemImage: "sparkles") }
                .tag(WardenclyffeTab.home)

                NavigationStack {
                    OnSiteGuideView()
                        .toolbar { hudToolbarButtonIfNeeded }
                }
                .tabItem { Label("On Site", systemImage: "map") }
                .tag(WardenclyffeTab.guide)

                NavigationStack {
                    WardenclyffeARExperienceView()
                        .toolbar { hudToolbarButtonIfNeeded }
                }
                .tabItem { Label("Experience", systemImage: "arkit") }
                .tag(WardenclyffeTab.experience)

                NavigationStack {
                    VirtualLabView()
                        .toolbar { hudToolbarButtonIfNeeded }
                }
                .tabItem { Label("Lab", systemImage: "bolt.circle") }
                .tag(WardenclyffeTab.lab)

                NavigationStack {
                    EventsView()
                        .toolbar { hudToolbarButtonIfNeeded }
                }
                .tabItem { Label("Events", systemImage: "calendar") }
                .tag(WardenclyffeTab.events)

                NavigationStack {
                    SupportView()
                        .toolbar { hudToolbarButtonIfNeeded }
                }
                .tabItem { Label("Support", systemImage: "heart") }
                .tag(WardenclyffeTab.support)
            }
            .background(WardenclyffeTheme.background.ignoresSafeArea())
            .sensoryFeedback(.selection, trigger: selectedTab)
            .animation(.snappy, value: selectedTab)

            if selectedTab != .home {
                // Global HUD overlay (tap to open Progress sheet)
                WardenclyffeHUD(
                    power: progress.totalPower,
                    streak: sparks.currentStreak,
                    energized: tower.energyState == .energized
                ) {
                    fx.impact(.light)
                    showProgressSheet = true
                }
                .padding(.top, 8)
            }
        }
        .sheet(isPresented: $showProgressSheet) {
            NavigationStack {
                WardenclyffeProgressSheet()
            }
        }
        .onAppear {
            showOnboarding = !hasSeenOnboarding
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView {
                hasSeenOnboarding = true
                showOnboarding = false
            }
        }
    }

    // Optional: also offer a toolbar button (nice on iPad / when HUD is subtle)
    @ToolbarContentBuilder
    private var hudToolbarButtonIfNeeded: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                fx.impact(.light)
                showProgressSheet = true
            } label: {
                Image(systemName: "gauge.with.dots.needle.50percent")
            }
            .accessibilityLabel("Progress")
        }
    }
}

// MARK: - HUD

private struct WardenclyffeHUD: View {
    let power: Int
    let streak: Int
    let energized: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                Label("\(power)", systemImage: "bolt.fill")
                    .font(.caption.weight(.semibold))
                    .labelStyle(.titleAndIcon)
                    .monospacedDigit()

                Divider().frame(height: 14).opacity(0.5)

                Label("\(streak)", systemImage: "flame.fill")
                    .font(.caption.weight(.semibold))
                    .labelStyle(.titleAndIcon)
                    .monospacedDigit()

                Divider().frame(height: 14).opacity(0.5)

                HStack(spacing: 6) {
                    Circle()
                        .frame(width: 8, height: 8)
                        .opacity(energized ? 1 : 0.4)
                    Text(energized ? "Energized" : "Idle")
                        .font(.caption.weight(.semibold))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(Capsule().strokeBorder(.white.opacity(0.12)))
            .shadow(radius: 8, y: 4)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, alignment: .center)
        .accessibilityLabel("Power \(power), Streak \(streak), Tower \(energized ? "energized" : "idle")")
        .accessibilityHint("Opens progress and quick actions.")
    }
}

// MARK: - Progress Sheet

private struct WardenclyffeProgressSheet: View {
    @EnvironmentObject private var fx: InteractionKit
    @EnvironmentObject private var progress: WardenclyffeProgressStore
    @EnvironmentObject private var tower: TowerStateStore
    @EnvironmentObject private var sparks: DailySparkStore

    var body: some View {
        List {
            Section("Status") {
                HStack {
                    Label("Power", systemImage: "bolt.fill")
                    Spacer()
                    Text("\(progress.totalPower)").monospacedDigit().foregroundStyle(.secondary)
                }
                HStack {
                    Label("Streak", systemImage: "flame.fill")
                    Spacer()
                    Text("\(sparks.currentStreak)").monospacedDigit().foregroundStyle(.secondary)
                }
                HStack {
                    Label("Tower", systemImage: "antenna.radiowaves.left.and.right")
                    Spacer()
                    Text(tower.energyState == .energized ? "Energized" : "Idle")
                        .foregroundStyle(.secondary)
                }
            }

            Section("Quick Actions") {
                Button {
                    fx.impact(.light)
                    tower.toggleEnergy()
                    progress.addPower(2, reason: "Sheet Toggle Energy")
                    fx.notify(.success)
                } label: {
                    Label(tower.energyState == .energized ? "Set Tower Idle" : "Energize Tower", systemImage: "bolt.circle")
                }

                #if DEBUG
                Button {
                    fx.impact(.medium)
                    progress.addPower(10, reason: "Debug Power +10")
                    fx.notify(.success)
                } label: {
                    Label("Add +10 Power (testing)", systemImage: "plus.circle")
                }
                #endif
            }

            Section("Unlocked") {
                ForEach(WardenclyffeUnlock.allCases, id: \.self) { u in
                    HStack {
                        Text(u.rawValue)
                        Spacer()
                        Image(systemName: progress.isUnlocked(u) ? "checkmark.circle.fill" : "lock.circle")
                            .foregroundStyle(progress.isUnlocked(u) ? .primary : .secondary)
                    }
                }
            }
        }
        .navigationTitle("Progress")
        .navigationBarTitleDisplayMode(.inline)
    }
}
