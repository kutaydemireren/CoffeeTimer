//
//  AppFlowViewModelReviewPromptTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 19/11/2026.
//

import XCTest
@testable import CoffeeTimer

final class AppFlowViewModelReviewPromptTests: XCTestCase {
    var mockAnalyticsTracker: MockAnalyticsTracker!
    var mockRecipeRepository: MockRecipeRepository!
    var mockReviewPromptPolicy: MockReviewPromptPolicy!
    var brewQueueViewModel: BrewQueueViewModel!
    var sut: AppFlowViewModel!

    override func setUpWithError() throws {
        mockAnalyticsTracker = MockAnalyticsTracker()
        mockRecipeRepository = MockRecipeRepository()
        mockRecipeRepository.getSelectedRecipeReturnValue = .stubSingleV60
        mockReviewPromptPolicy = MockReviewPromptPolicy()

        brewQueueViewModel = BrewQueueViewModel(
            recipeRepository: mockRecipeRepository,
            analyticsTracker: MockAnalyticsTracker(),
            reviewPromptPolicy: mockReviewPromptPolicy,
            dateProvider: MockDateProvider()
        )
        sut = AppFlowViewModel(
            brewQueueViewModel: brewQueueViewModel,
            reviewPromptPolicy: mockReviewPromptPolicy,
            analyticsTracker: mockAnalyticsTracker
        )
    }

    private func openAndCloseRecipes() {
        brewQueueViewModel.showRecipes()
        sut.makeRecipesFlowVM().close()
    }

    private func openAndCloseEditRecipe() {
        brewQueueViewModel.requestEdit()
        sut.makeEditRecipeFlowVM().close()
    }

    func test_closeRecipes_whenPolicyHasPendingTrigger_shouldSetReviewPromptTrigger() {
        mockReviewPromptPolicy._pendingTrigger = .recipeCreated

        openAndCloseRecipes()

        XCTAssertFalse(sut.isRecipesPresented)
        XCTAssertEqual(sut.reviewPromptTrigger, .recipeCreated)
    }

    func test_closeRecipes_whenPolicyHasNoPendingTrigger_shouldNotSetReviewPromptTrigger() {
        openAndCloseRecipes()

        XCTAssertNil(sut.reviewPromptTrigger)
        XCTAssertEqual(mockReviewPromptPolicy.takePendingTriggerCallCount, 1)
    }

    func test_closeEditRecipe_whenPolicyHasPendingTrigger_shouldSetReviewPromptTrigger() {
        mockReviewPromptPolicy._pendingTrigger = .recipeAmountsEdited

        openAndCloseEditRecipe()

        XCTAssertFalse(sut.isEditRecipePresented)
        XCTAssertEqual(sut.reviewPromptTrigger, .recipeAmountsEdited)
    }

    func test_confirmReviewRequest_whenMainScreenIdle_shouldRecordRequestAndTrack() {
        mockReviewPromptPolicy._pendingTrigger = .customMethodCreated
        openAndCloseRecipes()

        let result = sut.confirmReviewRequest(.customMethodCreated)

        XCTAssertTrue(result)
        XCTAssertNil(sut.reviewPromptTrigger)
        XCTAssertEqual(mockReviewPromptPolicy.didRequestReviewCallCount, 1)
        let event = mockAnalyticsTracker.trackedEvents.first { $0.name == "review_prompt_requested" }
        XCTAssertEqual(event?.parameters?["trigger"] as? String, "method_created")
    }

    func test_confirmReviewRequest_whenBrewStartedDuringDelay_shouldReturnFalse() {
        mockReviewPromptPolicy._pendingTrigger = .recipeCreated
        openAndCloseRecipes()

        brewQueueViewModel.primaryAction()

        XCTAssertFalse(sut.confirmReviewRequest(.recipeCreated))
        XCTAssertEqual(mockReviewPromptPolicy.didRequestReviewCallCount, 0)
        XCTAssertNil(mockAnalyticsTracker.trackedEvents.first { $0.name == "review_prompt_requested" })
    }

    func test_confirmReviewRequest_whenRecipesPresentedAgain_shouldReturnFalse() {
        mockReviewPromptPolicy._pendingTrigger = .recipeCreated
        openAndCloseRecipes()

        brewQueueViewModel.showRecipes()

        XCTAssertFalse(sut.confirmReviewRequest(.recipeCreated))
        XCTAssertEqual(mockReviewPromptPolicy.didRequestReviewCallCount, 0)
    }

    // MARK: - Tweak this brew

    private func completeBrew() {
        let dateProvider = MockDateProvider()
        brewQueueViewModel = BrewQueueViewModel(
            recipeRepository: mockRecipeRepository,
            analyticsTracker: MockAnalyticsTracker(),
            reviewPromptPolicy: mockReviewPromptPolicy,
            dateProvider: dateProvider
        )
        sut = AppFlowViewModel(
            brewQueueViewModel: brewQueueViewModel,
            tweakBrewViewModel: tweakBrewViewModel,
            reviewPromptPolicy: mockReviewPromptPolicy,
            analyticsTracker: mockAnalyticsTracker
        )
        brewQueueViewModel.primaryAction()
        dateProvider.advance(by: 120)
        for _ in 0..<brewQueueViewModel.brewQueue.stages.count {
            brewQueueViewModel.skipAction()
        }
    }

    private lazy var tweakBrewViewModel = TweakBrewViewModel(
        fetchRecipeInstructionsUseCase: MockFetchRecipeInstructionsUseCase(),
        saveBrewMethodUseCase: MockSaveBrewMethodUseCase(),
        getBrewMethodsUseCase: MockGetBrewMethodsUseCase(),
        analyticsTracker: MockAnalyticsTracker()
    )

    func test_tweakClosed_shouldKeepThePostBrewScreen() {
        completeBrew()
        brewQueueViewModel.tweakBrew()

        tweakBrewViewModel.didClose.send()

        XCTAssertTrue(brewQueueViewModel.isPresentingPostBrew)
        XCTAssertFalse(brewQueueViewModel.isTweakPresented)
    }

    func test_tweakFinished_shouldReturnToTheMainScreenAndTakePendingTrigger() {
        completeBrew()
        brewQueueViewModel.tweakBrew()
        mockReviewPromptPolicy._pendingTrigger = .customMethodCreated

        tweakBrewViewModel.didFinish.send()

        XCTAssertFalse(brewQueueViewModel.isPresentingPostBrew)
        XCTAssertFalse(brewQueueViewModel.isTweakPresented)
        XCTAssertEqual(sut.reviewPromptTrigger, .customMethodCreated)
    }
}
