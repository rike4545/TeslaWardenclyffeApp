import SwiftUI

struct DiscoverHubView: View {
    @State private var searchText = ""

    private var filteredItems: [DiscoverItem] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return DiscoverItem.allCases }

        return DiscoverItem.allCases.filter {
            $0.title.localizedCaseInsensitiveContains(query) ||
            $0.subtitle.localizedCaseInsensitiveContains(query) ||
            $0.keywords.contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }

    var body: some View {
        List {
            Section {
                WardenclyffeAssetBanner(
                    imageName: "WardenclyffeMuseum",
                    title: "Explore Wardenclyffe",
                    subtitle: "History, events, photos, patents, family activities, and ways to support the site.",
                    height: 180
                )
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }

            Section("Discover") {
                if filteredItems.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                } else {
                    ForEach(filteredItems) { item in
                        NavigationLink {
                            destination(for: item)
                        } label: {
                            DiscoverRow(item: item)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Discover")
        .searchable(text: $searchText, prompt: "History, events, patents, photos…")
    }

    @ViewBuilder
    private func destination(for item: DiscoverItem) -> some View {
        switch item {
        case .history:
            HistoryView()
        case .events:
            EventsView()
        case .photos:
            PhotoGalleryHubView()
        case .patents:
            TeslaPatentsView()
        case .kidsQuest:
            KidsQuestView()
        case .fundraising:
            OatmealFundraisingView()
        case .support:
            SupportView()
        }
    }
}

private enum DiscoverItem: String, CaseIterable, Identifiable {
    case history
    case events
    case photos
    case patents
    case kidsQuest
    case fundraising
    case support

    var id: String { rawValue }

    var title: String {
        switch self {
        case .history: "History"
        case .events: "Events"
        case .photos: "Photo Galleries"
        case .patents: "Tesla Patents"
        case .kidsQuest: "Kids’ Quest"
        case .fundraising: "How Wardenclyffe Was Saved"
        case .support: "Support Wardenclyffe"
        }
    }

    var subtitle: String {
        switch self {
        case .history: "Follow Wardenclyffe from Tesla’s experiments to restoration."
        case .events: "See programs and upcoming activities."
        case .photos: "Browse historic, restoration, and site imagery."
        case .patents: "Search key inventions and patent stories."
        case .kidsQuest: "Complete clues and collect achievement badges."
        case .fundraising: "Learn how crowdfunding and supporters preserved the site."
        case .support: "Find ways to donate, volunteer, join, or participate."
        }
    }

    var systemImage: String {
        switch self {
        case .history: "clock.arrow.circlepath"
        case .events: "calendar"
        case .photos: "photo.on.rectangle.angled"
        case .patents: "doc.text.magnifyingglass"
        case .kidsQuest: "figure.and.child.holdinghands"
        case .fundraising: "hands.sparkles"
        case .support: "heart"
        }
    }

    var keywords: [String] {
        switch self {
        case .history: ["timeline", "tower", "Stanford White", "fire", "restoration"]
        case .events: ["programs", "calendar", "tour"]
        case .photos: ["gallery", "images", "restoration"]
        case .patents: ["inventions", "wireless", "motor", "technology"]
        case .kidsQuest: ["children", "family", "badges", "clues"]
        case .fundraising: ["Oatmeal", "crowdfunding", "museum", "campaign"]
        case .support: ["donate", "volunteer", "membership", "partner"]
        }
    }
}

private struct DiscoverRow: View {
    let item: DiscoverItem

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: item.systemImage)
                .font(.title3.weight(.semibold))
                .foregroundStyle(WardenclyffeTheme.accent)
                .frame(width: 36, height: 36)
                .background(WardenclyffeTheme.accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(.headline)

                Text(item.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}
