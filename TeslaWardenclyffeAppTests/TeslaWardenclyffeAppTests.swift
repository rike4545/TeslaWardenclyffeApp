//
//  TeslaWardenclyffeAppTests.swift
//  TeslaWardenclyffeAppTests
//
//  Created by Bryan on 12/11/25.
//

import Testing
@testable import TeslaWardenclyffeApp

struct TeslaWardenclyffeAppTests {

    @Test @MainActor func defaultModelDoesNotPublishFakeDatedEvents() {
        let model = AppModel()

        #expect(model.events.isEmpty)
    }

    @Test @MainActor func togglingQuestCompletionChangesOnlyMatchingQuest() {
        let firstQuest = Quest.sampleQuests[0]
        let model = AppModel(
            exhibits: [],
            events: [],
            programCategories: [],
            involvementOptions: [],
            historyEntries: [],
            quests: Quest.sampleQuests
        )

        model.toggleQuestCompletion(firstQuest)

        #expect(model.quests.first(where: { $0.id == firstQuest.id })?.isCompleted == true)
    }

}
