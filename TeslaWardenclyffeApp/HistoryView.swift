// HistoryView.swift

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var selectedCategory: HistoryCategory?

    init(initialCategory: HistoryCategory? = nil) {
        _selectedCategory = State(initialValue: initialCategory)
    }

    private var filteredEntries: [HistoryEntry] {
        let base = appModel.historyEntries.sorted { $0.order < $1.order }
        guard let selectedCategory else { return base }
        return base.filter { $0.category == selectedCategory }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                categoryChips
                timeline
            }
            .padding()
        }
        .background(WardenclyffeTheme.background.ignoresSafeArea())
        .navigationTitle("History of Wardenclyffe")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("From Visionary Tower to Science Center")
                .font(.title2.bold())

            Text("Follow the story of Nikola Tesla’s Wardenclyffe site—from his wireless experiments to today’s restoration and future museum.")
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                CategoryChip(
                    label: "All",
                    isSelected: selectedCategory == nil
                ) {
                    selectedCategory = nil
                }

                ForEach(HistoryCategory.allCases) { category in
                    CategoryChip(
                        label: category.rawValue,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }

    private var timeline: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(filteredEntries) { entry in
                HistoryRow(
                    entry: entry,
                    isLast: entry.id == filteredEntries.last?.id
                )
            }
        }
    }
}

struct CategoryChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.caption.bold())
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? WardenclyffeTheme.accent : Color(.tertiarySystemBackground))
                )
                .foregroundStyle(isSelected ? Color.white : .primary)
        }
        .buttonStyle(.plain)
    }
}

struct HistoryRow: View {
    let entry: HistoryEntry
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack {
                Circle()
                    .frame(width: 10, height: 10)
                    .foregroundStyle(WardenclyffeTheme.accent)

                if !isLast {
                    Rectangle()
                        .frame(width: 2)
                        .foregroundStyle(Color(.quaternaryLabel))
                        .padding(.top, 2)
                }
            }
            .padding(.top, 4)

            VStack(alignment: .leading, spacing: 6) {
                Text(entry.year.uppercased())
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)

                Text(entry.title)
                    .font(.headline)

                Text(entry.category.rawValue)
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Text(entry.summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
