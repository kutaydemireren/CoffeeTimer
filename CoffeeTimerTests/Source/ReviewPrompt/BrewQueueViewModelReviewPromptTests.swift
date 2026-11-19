//
//  BrewQueueViewModelReviewPromptTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 19/11/2026.
//

import XCTest
@testable import CoffeeTimer

final class BrewQueueViewModelReviewPromptTests: XCTestCase {
    var mockAnalyticsTracker: MockAnalyticsTracker!
    var mockRecipeRepository: MockRecipeRepository!
    var mockReviewPromptPolicy: MockReviewPromptPolicy!
    var mockDateProvider: MockDateProvider!
    var sut: BrewQueueViewModel!

    override func setUpWithError() throws {
        mockAnalyticsTracker = MockAnalyticsTracker()
        mockRecipeRepository = MockRecipeRepository()
        mockRecipeRepository.getSelectedRecipeReturnValue = .stubSingleV60
        mockReviewPromptPolicy = MockReviewPromptPolicy()
        mockDateProvider = MockDateProvider()

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

    // MARK: - End

    func test_endAction_whenShorterThanMeaningfulDuration_shouldNotPresentPostBrew() {
        endBrew(after: 5)

        XCTAssertFalse(sut.isPresentingPostBrew)
        XCTAssertFalse(sut.isActive)
        XCTAssertTrue(mockReviewPromptPolicy.recordedEvents.isEmpty)
        XCTAssertNil(mockAnalyticsTracker.trackedEvents.first { $0.name == "post_brew_shown" })
    }

    func test_endAction_whenMeaningfulDuration_shouldPresentPostBrew() {
        endBrew(after: 90)

        XCTAssertTrue(sut.isPresentingPostBrew)
        XCTAssertFalse(sut.isActive)
        XCTAssertEqual(mockReviewPromptPolicy.recordedEvents, [.brewEnded(duration: 90)])
        let event = mockAnalyticsTracker.trackedEvents.first { $0.name == "post_brew_shown" }
        XCTAssertEqual(event?.parameters?["source"] as? String, "ended")
    }

    func test_endAction_shouldTrackBrewCancelledWithElapsedSeconds() {
        endBrew(after: 42)

        let event = mockAnalyticsTracker.trackedEvents.first { $0.name == "brew_cancelled" }
        XCTAssertEqual(event?.parameters?["elapsed_seconds"] as? Int, 42)
        XCTAssertEqual(event?.parameters?["stage_index"] as? Int, 0)
    }

    func test_endAction_whenPolicyHasPendingTrigger_shouldSetReviewPromptTrigger() {
        mockReviewPromptPolicy._pendingTrigger = .brewEnded

        endBrew(after: 90)

        XCTAssertEqual(sut.reviewPromptTrigger, .brewEnded)
    }

    func test_endAction_whenShorterThanMeaningfulDuration_shouldNotTakePendingTrigger() {
        mockReviewPromptPolicy._pendingTrigger = .brewEnded

        endBrew(after: 5)

        XCTAssertNil(sut.reviewPromptTrigger)
        XCTAssertEqual(mockReviewPromptPolicy.takePendingTriggerCallCount, 0)
    }

    // MARK: - Complete

    func test_nextStage_whenLastStageCompleted_shouldPresentPostBrewAndRecordCompletedBrew() {
        completeBrew(after: 120)

        XCTAssertTrue(sut.isPresentingPostBrew)
        XCTAssertEqual(mockReviewPromptPolicy.recordedEvents, [.brewCompleted(duration: 120)])
        let event = mockAnalyticsTracker.trackedEvents.first { $0.name == "post_brew_shown" }
        XCTAssertEqual(event?.parameters?["source"] as? String, "completed")
        XCTAssertNotNil(mockAnalyticsTracker.trackedEvents.first { $0.name == "brew_completed" })
    }

    func test_nextStage_whenLastStageCompletedAndPolicyHasPendingTrigger_shouldSetReviewPromptTrigger() {
        mockReviewPromptPolicy._pendingTrigger = .brewCompleted

        completeBrew(after: 120)

        XCTAssertEqual(sut.reviewPromptTrigger, .brewCompleted)
    }

    // MARK: - confirmReviewRequest

    func test_confirmReviewRequest_whenPostBrewPresented_shouldRecordRequestAndTrack() {
        mockReviewPromptPolicy._pendingTrigger = .brewCompleted
        completeBrew(after: 120)

        let result = sut.confirmReviewRequest(.brewCompleted)

        XCTAssertTrue(result)
        XCTAssertNil(sut.reviewPromptTrigger)
        XCTAssertEqual(mockReviewPromptPolicy.didRequestReviewCallCount, 1)
        let event = mockAnalyticsTracker.trackedEvents.first { $0.name == "review_prompt_requested" }
        XCTAssertEqual(event?.parameters?["trigger"] as? String, "brew_completed")
    }

    func test_confirmReviewRequest_whenCalledTwice_shouldRequestOnce() {
        mockReviewPromptPolicy._pendingTrigger = .brewCompleted
        completeBrew(after: 120)

        XCTAssertTrue(sut.confirmReviewRequest(.brewCompleted))
        XCTAssertFalse(sut.confirmReviewRequest(.brewCompleted))
        XCTAssertEqual(mockReviewPromptPolicy.didRequestReviewCallCount, 1)
    }

    func test_confirmReviewRequest_whenPostBrewDismissed_shouldReturnFalse() {
        mockReviewPromptPolicy._pendingTrigger = .brewCompleted
        completeBrew(after: 120)

        sut.dismissPostBrew()

        XCTAssertFalse(sut.confirmReviewRequest(.brewCompleted))
        XCTAssertEqual(mockReviewPromptPolicy.didRequestReviewCallCount, 0)
    }

    func test_confirmPostBrew_shouldClearReviewPromptTrigger() {
        mockReviewPromptPolicy._pendingTrigger = .brewCompleted
        completeBrew(after: 120)

        sut.confirmPostBrew()

        XCTAssertNil(sut.reviewPromptTrigger)
    }
}
