// TeslaWardenclyffeApp.swift

import SwiftUI
import Combine

@main
struct TeslaWardenclyffeApp: App {
    @StateObject private var appModel = AppModel()
    @StateObject private var locationManager = WardenclyffeLocationManager()

    // ✅ Interactivity layer
    @StateObject private var fx = InteractionKit.shared
    @StateObject private var progress = WardenclyffeProgressStore()
    @StateObject private var tower = TowerStateStore()
    @StateObject private var sparks = DailySparkStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appModel)
                .environmentObject(locationManager)

                // ✅ Inject interactivity everywhere
                .environmentObject(fx)
                .environmentObject(progress)
                .environmentObject(tower)
                .environmentObject(sparks)
        }
    }
}

// NOTE: No @MainActor here – keep it simple for now.
@MainActor
final class AppModel: ObservableObject {
    @Published var exhibits: [Exhibit]
    @Published var events: [TSCEvent]
    @Published var programCategories: [ProgramCategory]
    @Published var involvementOptions: [InvolvementOption]
    @Published var historyEntries: [HistoryEntry]
    @Published var quests: [Quest]

    // Designated initializer
    init(
        exhibits: [Exhibit],
        events: [TSCEvent],
        programCategories: [ProgramCategory],
        involvementOptions: [InvolvementOption],
        historyEntries: [HistoryEntry],
        quests: [Quest]
    ) {
        self.exhibits = exhibits
        self.events = events
        self.programCategories = programCategories
        self.involvementOptions = involvementOptions
        self.historyEntries = historyEntries
        self.quests = quests
    }

    // Convenience initializer for default sample data
    convenience init() {
        self.init(
            exhibits: Exhibit.sampleData,
            events: TSCEvent.sampleData,
            programCategories: ProgramCategory.sampleData,
            involvementOptions: InvolvementOption.sampleData,
            historyEntries: HistoryEntry.sampleTimeline,
            quests: Quest.sampleQuests
        )
    }

    func toggleQuestCompletion(_ quest: Quest) {
        guard let index = quests.firstIndex(where: { $0.id == quest.id }) else { return }
        quests[index].isCompleted.toggle()
    }
}
