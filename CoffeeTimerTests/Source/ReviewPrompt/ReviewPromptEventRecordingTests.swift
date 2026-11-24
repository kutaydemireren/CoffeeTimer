//
//  ReviewPromptEventRecordingTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 19/11/2026.
//

import XCTest
@testable import CoffeeTimer

/// Checks that the create and edit screens report their positive moments to the review prompt policy.
@MainActor
final class ReviewPromptEventRecordingTests: XCTestCase {
    var mockReviewPromptPolicy: MockReviewPromptPolicy!

    override func setUpWithError() throws {
        mockReviewPromptPolicy = MockReviewPromptPolicy()
    }

    func test_createRecipe_whenRecipeCreated_shouldRecordRecipeCreated() async {
        let mockCreateRecipeFromContextUseCase = MockCreateRecipeFromContextUseCase()
        mockCreateRecipeFromContextUseCase._recipe = .stubSingleV60
        let sut = CreateRecipeViewModel(
            createRecipeFromContextUseCase: mockCreateRecipeFromContextUseCase,
            recipeRepository: MockRecipeRepository(),
            analyticsTracker: MockAnalyticsTracker(),
            reviewPromptPolicy: mockReviewPromptPolicy
        )
        let recorded = expectation(description: "recorded")
        mockReviewPromptPolicy.onRecord = { _ in recorded.fulfill() }

        sut.create(from: CreateRecipeContext())

        await fulfillment(of: [recorded], timeout: 1)
        XCTAssertEqual(mockReviewPromptPolicy.recordedEvents, [.recipeCreated])
    }

    func test_createRecipe_whenRecipeNotCreated_shouldNotRecord() async {
        let mockCreateRecipeFromContextUseCase = MockCreateRecipeFromContextUseCase()
        mockCreateRecipeFromContextUseCase._recipe = nil
        let sut = CreateRecipeViewModel(
            createRecipeFromContextUseCase: mockCreateRecipeFromContextUseCase,
            recipeRepository: MockRecipeRepository(),
            analyticsTracker: MockAnalyticsTracker(),
            reviewPromptPolicy: mockReviewPromptPolicy
        )
        let recorded = expectation(description: "recorded")
        recorded.isInverted = true
        mockReviewPromptPolicy.onRecord = { _ in recorded.fulfill() }

        sut.create(from: CreateRecipeContext())

        await fulfillment(of: [recorded], timeout: 0.3)
        XCTAssertTrue(mockReviewPromptPolicy.recordedEvents.isEmpty)
    }

    @MainActor
    func test_createMethod_whenMethodCreated_shouldRecordCustomMethodCreated() async throws {
        var draft = MethodDraft.scratch()
        draft.name = "Kalita"
        draft.steps = [MethodStep(kind: .pour, amount: .rest)]
        let sut = MethodEditorViewModel(
            draft: draft,
            saveBrewMethodUseCase: MockSaveBrewMethodUseCase(),
            draftStore: MockMethodDraftStore(),
            analyticsTracker: MockAnalyticsTracker(),
            reviewPromptPolicy: mockReviewPromptPolicy
        )
        let recorded = expectation(description: "recorded")
        mockReviewPromptPolicy.onRecord = { _ in recorded.fulfill() }

        sut.save()

        await fulfillment(of: [recorded], timeout: 1)
        XCTAssertEqual(mockReviewPromptPolicy.recordedEvents, [.customMethodCreated])
    }

    func test_saveChanges_whenRecipeUpdated_shouldRecordAmountsEdited() async {
        let mockUpdateRecipeFromContextUseCase = MockUpdateRecipeFromContextUseCase()
        mockUpdateRecipeFromContextUseCase._recipe = .stubSingleV60
        let sut = EditRecipeAmountsViewModel(
            configureContextFromRecipeUseCase: MockConfigureContextFromRecipeUseCase(),
            updateRecipeFromContextUseCase: mockUpdateRecipeFromContextUseCase,
            analyticsTracker: MockAnalyticsTracker(),
            reviewPromptPolicy: mockReviewPromptPolicy
        )
        sut.configure(with: .stubSingleV60)

        await sut.saveChanges()

        XCTAssertEqual(mockReviewPromptPolicy.recordedEvents, [.recipeAmountsEdited])
    }

    func test_saveChanges_whenUpdateFails_shouldNotRecord() async {
        let mockUpdateRecipeFromContextUseCase = MockUpdateRecipeFromContextUseCase()
        mockUpdateRecipeFromContextUseCase._recipe = nil
        let sut = EditRecipeAmountsViewModel(
            configureContextFromRecipeUseCase: MockConfigureContextFromRecipeUseCase(),
            updateRecipeFromContextUseCase: mockUpdateRecipeFromContextUseCase,
            analyticsTracker: MockAnalyticsTracker(),
            reviewPromptPolicy: mockReviewPromptPolicy
        )
        sut.configure(with: .stubSingleV60)

        await sut.saveChanges()

        XCTAssertTrue(mockReviewPromptPolicy.recordedEvents.isEmpty)
    }
}
