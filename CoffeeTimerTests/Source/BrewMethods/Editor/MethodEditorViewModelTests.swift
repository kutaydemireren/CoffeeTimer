//
//  MethodEditorViewModelTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 24/11/2026.
//

import XCTest
import Combine
@testable import CoffeeTimer

@MainActor
final class MethodEditorViewModelTests: XCTestCase {
    private var saveUseCase: MockSaveBrewMethodUseCase!
    private var draftStore: MockMethodDraftStore!
    private var analytics: MockAnalyticsTracker!
    private var reviewPrompt: MockReviewPromptPolicy!
    private var cancellables: [AnyCancellable] = []

    override func setUp() async throws {
        saveUseCase = MockSaveBrewMethodUseCase()
        draftStore = MockMethodDraftStore()
        analytics = MockAnalyticsTracker()
        reviewPrompt = MockReviewPromptPolicy()
        cancellables = []
    }

    private func makeSUT(_ draft: MethodDraft = .scratch()) -> MethodEditorViewModel {
        MethodEditorViewModel(
            draft: draft,
            saveBrewMethodUseCase: saveUseCase,
            draftStore: draftStore,
            analyticsTracker: analytics,
            reviewPromptPolicy: reviewPrompt
        )
    }

    private func validDraft() -> MethodDraft {
        var draft = MethodDraft.scratch()
        draft.name = "Kalita"
        draft.steps = [MethodStep(kind: .pour, amount: .rest)]
        return draft
    }

    func test_init_shouldTrackOpenedWithOrigin() {
        _ = makeSUT()

        XCTAssertEqual(analytics.trackedEvents.first?.name, "create_method_opened")
        XCTAssertEqual(analytics.trackedEvents.first?.parameters?["origin"] as? String, "scratch")
    }

    func test_save_whenMissingName_shouldExplainAndNotSave() {
        let sut = makeSUT()

        sut.save()

        XCTAssertEqual(sut.validationMessage, "Add a name")
        XCTAssertTrue(saveUseCase.saveCalls.isEmpty)
        let event = analytics.trackedEvents.last
        XCTAssertEqual(event?.name, "create_method_validated")
        XCTAssertEqual(event?.parameters?["result"] as? String, "fail")
        XCTAssertEqual(event?.parameters?["missing_field"] as? String, "method_title")
    }

    func test_save_whenNew_shouldSaveAsNewRecordReviewEventAndClearDraft() async {
        let sut = makeSUT(validDraft())
        let saved = expectation(description: "saved")
        sut.didSave.sink { _ in saved.fulfill() }.store(in: &cancellables)

        sut.save()
        await fulfillment(of: [saved], timeout: 1)

        XCTAssertEqual(saveUseCase.saveCalls.map(\.mode), [.asNew])
        XCTAssertEqual(reviewPrompt.recordedEvents, [.customMethodCreated])
        XCTAssertEqual(draftStore.clearCount, 1)
        XCTAssertTrue(analytics.trackedEvents.contains { $0.name == "method_created" })
    }

    func test_save_whenEditingAMethodRecipesUse_shouldAskUpdateEverywhereOrSaveAsNew() {
        var draft = validDraft()
        draft.origin = .edit(BrewMethodSnapshot(brewMethod: .oldCustom))
        saveUseCase._recipesUsing = [.stubSingleV60, .stubFrenchPress]
        let sut = makeSUT(draft)

        sut.save()

        XCTAssertTrue(sut.isSaveChoicePresented)
        XCTAssertEqual(sut.recipesUsingCount, 2)
        XCTAssertTrue(saveUseCase.saveCalls.isEmpty)
    }

    func test_save_whenEditingAMethodNoRecipeUses_shouldUpdateInPlace() async {
        var draft = validDraft()
        draft.origin = .edit(BrewMethodSnapshot(brewMethod: .oldCustom))
        let sut = makeSUT(draft)
        let saved = expectation(description: "saved")
        sut.didSave.sink { _ in saved.fulfill() }.store(in: &cancellables)

        sut.save()
        await fulfillment(of: [saved], timeout: 1)

        XCTAssertEqual(saveUseCase.saveCalls.map(\.mode), [.updateEverywhere])
        XCTAssertTrue(reviewPrompt.recordedEvents.isEmpty)
    }

    func test_close_whenNothingChanged_shouldCloseWithoutAsking() {
        let sut = makeSUT()
        var closed = false
        sut.didClose.sink { closed = true }.store(in: &cancellables)

        sut.close()

        XCTAssertTrue(closed)
        XCTAssertFalse(sut.isClosePromptPresented)
    }

    func test_close_whenChanged_shouldAskAndKeepTheDraft() {
        let sut = makeSUT()
        sut.draft.name = "Kalita"

        sut.close()

        XCTAssertTrue(sut.isClosePromptPresented)
        XCTAssertEqual(draftStore.stored?.name, "Kalita", "drafts save automatically")
    }

    func test_discardAndClose_shouldClearTheDraft() {
        let sut = makeSUT()
        sut.draft.name = "Kalita"

        sut.discardAndClose()

        XCTAssertNil(draftStore.stored)
    }

    func test_deleteAndUndo_shouldPutTheStepBackInPlace() {
        var draft = validDraft()
        draft.steps = [MethodStep(kind: .addCoffee, amount: .add(15)), MethodStep(kind: .swirl), MethodStep(kind: .pour, amount: .rest)]
        let sut = makeSUT(draft)
        let swirl = draft.steps[1]

        sut.delete(stepID: swirl.id)
        XCTAssertEqual(sut.draft.steps.map(\.kind), [.addCoffee, .pour])

        sut.undoDeleteStep()
        XCTAssertEqual(sut.draft.steps.map(\.id), draft.steps.map(\.id))
    }

    func test_duplicate_shouldInsertACopyAfterTheStep() {
        let sut = makeSUT(validDraft())
        let original = sut.draft.steps[0]

        sut.duplicate(stepID: original.id)

        XCTAssertEqual(sut.draft.steps.count, 2)
        XCTAssertEqual(sut.draft.steps[1].amount, original.amount)
        XCTAssertNotEqual(sut.draft.steps[1].id, original.id)
    }

    func test_bindingForStep_whenAKeptStepIsEdited_shouldStopKeepingItAsStored() {
        let draft = MethodDraftFactory().draft(editing: .oldCustom, instructions: loadOldEditorV60Instructions())
        let sut = makeSUT(draft)
        let bloom = draft.steps[3]
        XCTAssertNotNil(bloom.legacy)

        let binding = sut.binding(forStep: bloom.id)
        binding?.wrappedValue.amount = .add(40)

        XCTAssertNil(sut.draft.steps[3].legacy)
        XCTAssertEqual(sut.preview.steps[3].addedGrams, 40)
    }

    func test_updateDose_shouldUpdatePreviewTotals() {
        let sut = makeSUT(validDraft())

        sut.updateDose(coffee: 30, water: 500, ice: nil, scaleSteps: true)

        XCTAssertEqual(sut.preview.pouredWater, 500)
        XCTAssertEqual(sut.writtenForText, "30 g coffee \u{00B7} 500 g water")
        XCTAssertEqual(sut.ratioText, "1:16.7")
    }

    func test_dryRunRecipe_shouldShortenTimersButKeepTheText() {
        var draft = validDraft()
        draft.steps = [MethodStep(kind: .wait, time: .takes(45))]
        let sut = makeSUT(draft)

        let recipe = sut.dryRunRecipe()

        XCTAssertEqual(recipe.brewQueue.stages.first?.requirement, .countdown(5))
        XCTAssertEqual(recipe.brewQueue.stages.first?.message, "Wait 45 s")
    }
}
