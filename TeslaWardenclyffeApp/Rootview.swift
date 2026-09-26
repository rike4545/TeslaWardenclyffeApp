//  RootView.swift

import SwiftUI

enum WardenclyffeTab: Hashable {
    case home
    case guide
    case experience
    case lab
    case discover
}

struct RootView: View {
    @EnvironmentObject private var fx: InteractionKit
    @EnvironmentObject private var progress: WardenclyffeProgressStore
    @EnvironmentObject private var tower: TowerStateStore
    @EnvironmentObject private var sparks: DailySparkStore

    @State private var selectedTab: WardenclyffeTab = .home
    @State private var showProgressSheet = false
    @AppStorage("wardenclyffe.onboarding.complete") private var hasSeenOnboarding = false
    @State private var showOnboarding = false

    var body: some View {
        ZStack(alignment: .top) {
            TabView(selection: $selectedTab) {
                tab(.home, title: "Home", systemImage: "sparkles") {
                    HomeView()
                }

                tab(.guide, title: "On Site", systemImage: "map") {
                    OnSiteGuideView()
                }

                tab(.experience, title: "Experience", systemImage: "arkit") {
                    WardenclyffeARExperienceView()
                }

                tab(.lab, title: "Lab", systemImage: "bolt.circle") {
                    VirtualLabView()
                }

                tab(.discover, title: "Discover", systemImage: "square.grid.2x2") {
                    DiscoverHubView()
                }
            }
            .background(WardenclyffeTheme.background.ignoresSafeArea())
            .sensoryFeedback(.selection, trigger: selectedTab)

            if selectedTab != .home {
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

    private func tab<Content: View>(
        _ tab: WardenclyffeTab,
        title: String,
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        NavigationStack {
            content()
                .wardenclyffeModernNavigationChrome()
                .toolbar { progressToolbarContent }
        }
        .tabItem { Label(title, systemImage: systemImage) }
        .tag(tab)
    }

    // Xcode 27 unifies SwiftUI result builders under ContentBuilder.
    @ContentBuilder
    private var progressToolbarContent: some ToolbarContent {
        if #available(iOS 27.0, *) {
            ToolbarItem(placement: .topBarPinnedTrailing) {
                progressButton
            }
            .visibilityPriority(.high)
        } else {
            ToolbarItem(placement: .topBarTrailing) {
                progressButton
            }
        }
    }

    private var progressButton: some View {
        Button {
            fx.impact(.light)
            showProgressSheet = true
        } label: {
            Image(systemName: "gauge.with.dots.needle.50percent")
        }
        .accessibilityLabel("Progress")
        .accessibilityHint("Shows your power, streak, tower state, and unlocks.")
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
                LabeledContent("Power", value: "\(progress.totalPower)")
                    .monospacedDigit()
                LabeledContent("Streak", value: "\(sparks.currentStreak)")
                    .monospacedDigit()
                LabeledContent("Tower", value: tower.energyState == .energized ? "Energized" : "Idle")
            }

            Section("Quick Actions") {
                Button {
                    fx.impact(.light)
                    tower.toggleEnergy()
                    progress.addPower(2, reason: "Sheet Toggle Energy")
                    fx.notify(.success)
                } label: {
                    Label(
                        tower.energyState == .energized ? "Set Tower Idle" : "Energize Tower",
                        systemImage: "bolt.circle"
                    )
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
                ForEach(WardenclyffeUnlock.allCases, id: \.self) { unlock in
                    LabeledContent {
                        Image(systemName: progress.isUnlocked(unlock) ? "checkmark.circle.fill" : "lock.circle")
                            .foregroundStyle(progress.isUnlocked(unlock) ? .primary : .secondary)
                    } label: {
                        Text(unlock.rawValue)
                    }
                }
            }
        }
        .navigationTitle("Progress")
        .navigationBarTitleDisplayMode(.inline)
    }
}
