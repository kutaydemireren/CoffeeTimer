//
//  BrewQueueViewModelTweakTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 24/11/2026.
//

import XCTest
import Combine
@testable import CoffeeTimer

final class BrewQueueViewModelTweakTests: XCTestCase {
    var mockAnalyticsTracker: MockAnalyticsTracker!
    var mockRecipeRepository: MockRecipeRepository!
    var mockReviewPromptPolicy: MockReviewPromptPolicy!
    var mockDateProvider: MockDateProvider!
    var sut: BrewQueueViewModel!
    var cancellables: [AnyCancellable] = []

    override func setUpWithError() throws {
        mockAnalyticsTracker = MockAnalyticsTracker()
        mockRecipeRepository = MockRecipeRepository()
        mockRecipeRepository.getSelectedRecipeReturnValue = .stubSingleV60
        mockReviewPromptPolicy = MockReviewPromptPolicy()
        mockDateProvider = MockDateProvider()
        cancellables = []

        sut = BrewQueueViewModel(
            recipeRepository: mockRecipeRepository,
            analyticsTracker: mockAnalyticsTracker,
            reviewPromptPolicy: mockReviewPromptPolicy,
            dateProvider: mockDateProvider
        )
    }

    private func completeBrew(after duration: TimeInterval) {
        sut.primaryAction()
        mockDateProvider.advance(by: duration)
        for _ in 0..<sut.brewQueue.stages.count {
            sut.skipAction()
        }
    }

    private func endBrew(after duration: TimeInterval) {
        sut.primaryAction()
        mockDateProvider.advance(by: duration)
        sut.endAction()
    }

    private func requestedTweaks() -> () -> [Recipe] {
        var recipes: [Recipe] = []
        sut.didRequestTweak.sink { recipes.append($0) }.store(in: &cancellables)
        return { recipes }
    }

    func test_tweakBrew_whenAfterCompletedBrew_shouldRequestTweakOfTheBrewedRecipe() {
        let requested = requestedTweaks()
        completeBrew(after: 120)

        sut.tweakBrew()

        XCTAssertEqual(requested(), [.stubSingleV60])
        XCTAssertTrue(sut.isTweakPresented)
        XCTAssertTrue(sut.isPresentingPostBrew)
        let event = mockAnalyticsTracker.trackedEvents.first { $0.name == "tweak_brew_opened" }
        XCTAssertEqual(event?.parameters?["brew_method_type"] as? String, "built-in")
    }

    func test_tweakBrew_whenAfterEndedBrewOfOwnMethod_shouldTrackCustomType() {
        let ownRecipe = Recipe(
            recipeProfile: RecipeProfile(name: "Mine", brewMethod: .oldCustom),
            ingredients: .stubSingleV60,
            brewQueue: .stubSingleV60,
            cupsCount: 1,
            cupSize: 250
        )
        mockRecipeRepository.getSelectedRecipeReturnValue = ownRecipe
        let requested = requestedTweaks()
        endBrew(after: 90)

        sut.tweakBrew()

        XCTAssertEqual(requested(), [ownRecipe])
        let event = mockAnalyticsTracker.trackedEvents.first { $0.name == "tweak_brew_opened" }
        XCTAssertEqual(event?.parameters?["brew_method_type"] as? String, "custom")
    }

    func test_tweakBrew_whenPostBrewNotPresented_shouldDoNothing() {
        let requested = requestedTweaks()

        sut.tweakBrew()

        XCTAssertTrue(requested().isEmpty)
        XCTAssertFalse(sut.isTweakPresented)
    }

    func test_tweakDidClose_shouldKeepThePostBrewScreen() {
        completeBrew(after: 120)
        sut.tweakBrew()

        sut.tweakDidClose()

        XCTAssertFalse(sut.isTweakPresented)
        XCTAssertTrue(sut.isPresentingPostBrew)
    }

    func test_tweakBrew_shouldNotChangeTheReviewPromptTrigger() {
        mockReviewPromptPolicy._pendingTrigger = .brewCompleted
        completeBrew(after: 120)

        sut.tweakBrew()

        XCTAssertEqual(sut.reviewPromptTrigger, .brewCompleted)
        XCTAssertEqual(mockReviewPromptPolicy.recordedEvents, [.brewCompleted(duration: 120)])
    }

    func test_confirmReviewRequest_whenTweakEditorOpen_shouldNotRequest() {
        mockReviewPromptPolicy._pendingTrigger = .brewCompleted
        completeBrew(after: 120)
        sut.tweakBrew()

        XCTAssertFalse(sut.confirmReviewRequest(.brewCompleted))
        XCTAssertEqual(mockReviewPromptPolicy.didRequestReviewCallCount, 0)
    }

    func test_dismissPostBrew_whenTweakOpen_shouldResetTweak() {
        completeBrew(after: 120)
        sut.tweakBrew()

        sut.dismissPostBrew()

        XCTAssertFalse(sut.isTweakPresented)
        XCTAssertFalse(sut.isPresentingPostBrew)
    }
}
