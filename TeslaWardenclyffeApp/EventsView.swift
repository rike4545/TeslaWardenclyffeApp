//
//  EventsView.swift
//  TeslaWardenclyffeApp
//
//  Created by Bryan on 12/11/25.
//

import SwiftUI

struct EventsView: View {
    @EnvironmentObject private var appModel: AppModel
    @EnvironmentObject private var fx: InteractionKit
    @EnvironmentObject private var progress: WardenclyffeProgressStore
    @AppStorage("wardenclyffe.events.interestedTitles") private var interestedTitlesRaw = ""
    @State private var selectedCategory: String = "All"

    private var categories: [String] {
        ["All"] + Array(Set(appModel.events.map(\.category))).sorted()
    }

    private var filteredEvents: [TSCEvent] {
        guard selectedCategory != "All" else { return appModel.events }
        return appModel.events.filter { $0.category == selectedCategory }
    }

    private var interestedTitles: Set<String> {
        Set(interestedTitlesRaw.split(separator: "|").map(String.init))
    }

    private var interestedEvents: [TSCEvent] {
        appModel.events.filter { interestedTitles.contains($0.title) }
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                Text("Events")
                    .font(.largeTitle.bold())
                    .padding(.top, 8)

                WardenclyffeAssetBanner(
                    imageName: "WardenclyffeNight",
                    title: "Plan a Wardenclyffe Moment",
                    subtitle: "Save events, compare programs, and build a visit shortlist."
                )

                eventPlannerCard

                if appModel.events.isEmpty {
                    EmptyEventsCard()
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Highlighted Events")
                                .font(.headline)
                            Spacer()
                            Text("\(filteredEvents.count)")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                        }

                        Picker("Category", selection: $selectedCategory) {
                            ForEach(categories, id: \.self) { category in
                                Text(category).tag(category)
                            }
                        }
                        .pickerStyle(.segmented)

                        ForEach(filteredEvents) { event in
                            EventCard(
                                event: event,
                                isInterested: interestedTitles.contains(event.title)
                            ) {
                                toggleInterested(event)
                            }
                        }
                    }
                }

                OnlineEventsCard()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .background(WardenclyffeTheme.background.ignoresSafeArea())
        .navigationTitle("Events")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var eventPlannerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: interestedEvents.isEmpty ? "calendar.badge.plus" : "calendar.badge.checkmark")
                    .font(.title2.weight(.semibold))
                    .frame(width: 44, height: 44)
                    .background(WardenclyffeTheme.accent.opacity(0.16), in: Circle())
                    .foregroundStyle(WardenclyffeTheme.accent)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Event Planner")
                        .font(.headline)
                    Text(eventPlannerSummary)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            if !interestedEvents.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(interestedEvents) { event in
                        HStack {
                            Text(event.title)
                                .font(.caption.weight(.semibold))
                                .lineLimit(1)
                            Spacer()
                            Text(event.date, style: .date)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(12)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
        .wardenclyffeGlassCard()
    }

    private var eventPlannerSummary: String {
        if interestedEvents.isEmpty {
            return "Mark events you care about and build a lightweight visit shortlist."
        }
        return "\(interestedEvents.count) saved for your Wardenclyffe shortlist."
    }

    private func toggleInterested(_ event: TSCEvent) {
        var titles = interestedTitles
        if titles.contains(event.title) {
            titles.remove(event.title)
            fx.impact(.light)
        } else {
            titles.insert(event.title)
            progress.addPower(2, reason: "Saved Event")
            fx.notify(.success)
        }
        interestedTitlesRaw = titles.sorted().joined(separator: "|")
    }
}

// MARK: - Subviews

private struct EventCard: View {
    let event: TSCEvent
    let isInterested: Bool
    let onToggleInterested: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(event.title)
                    .font(.headline)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 8)

                Button(action: onToggleInterested) {
                    Image(systemName: isInterested ? "bookmark.fill" : "bookmark")
                        .font(.headline)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isInterested ? "Remove from shortlist" : "Save to shortlist")
            }

            Text(event.category)
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 10) {
                Label(event.location, systemImage: "mappin.and.ellipse")
                Text(event.date, style: .date)
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            if let url = event.url {
                Link("View on teslasciencecenter.org", destination: url)
                    .font(.caption.bold())
            }
        }
        .wardenclyffeGlassCard()
        .accessibilityElement(children: .combine)
    }
}

private struct OnlineEventsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("All Events Online")
                .font(.headline)

            if let eventsURL = URL(string: "https://teslasciencecenter.org/events/") {
                Link("Browse upcoming events", destination: eventsURL)
                    .font(.subheadline.bold())
            }

            if let programsURL = URL(string: "https://teslasciencecenter.org/programs/") {
                Link("Programs & tours overview", destination: programsURL)
                    .font(.subheadline.bold())
            }
        }
        .wardenclyffeGlassCard()
    }
}

private struct EmptyEventsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("No events listed yet")
                .font(.headline)

            Text("Check back soon or visit the full events calendar online.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .wardenclyffeGlassCard()
    }
}
