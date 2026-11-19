//
//  ReviewPromptPolicyImpTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 19/11/2026.
//

import XCTest
@testable import CoffeeTimer

final class ReviewPromptPolicyImpTests: XCTestCase {
    private let meaningful = BrewSessionRules.meaningfulDuration
    private let day: TimeInterval = 24 * 60 * 60

    var mockStorage: MockStorage!
    var mockDateProvider: MockDateProvider!
    var sut: ReviewPromptPolicyImp!

    override func setUpWithError() throws {
        mockStorage = MockStorage()
        mockDateProvider = MockDateProvider()
        sut = makeSUT(appVersion: "1.0")
    }

    private func makeSUT(appVersion: String) -> ReviewPromptPolicyImp {
        ReviewPromptPolicyImp(storage: mockStorage, dateProvider: mockDateProvider, appVersion: appVersion)
    }

    private var storedState: ReviewPromptState? {
        mockStorage.storageDictionary[ReviewPromptPolicyImp.storageKey] as? ReviewPromptState
    }

    // MARK: - Brews

    func test_record_whenFirstCompletedBrew_shouldNotTrigger() {
        sut.record(.brewCompleted(duration: meaningful))

        XCTAssertNil(sut.takePendingTrigger())
        XCTAssertEqual(storedState?.meaningfulBrewCount, 1)
    }

    func test_record_whenSecondCompletedBrew_shouldTriggerBrewCompleted() {
        sut.record(.brewCompleted(duration: meaningful))
        sut.record(.brewCompleted(duration: meaningful))

        XCTAssertEqual(sut.takePendingTrigger(), .brewCompleted)
    }

    func test_record_whenCompletedBrewIsShorterThanMeaningfulDuration_shouldNotCount() {
        sut.record(.brewCompleted(duration: meaningful))
        sut.record(.brewCompleted(duration: meaningful - 1))

        XCTAssertNil(sut.takePendingTrigger())
        XCTAssertEqual(storedState?.meaningfulBrewCount, 1)
    }

    func test_record_whenSecondBrewIsEnded_shouldNotTrigger() {
        sut.record(.brewCompleted(duration: meaningful))
        sut.record(.brewEnded(duration: meaningful))

        XCTAssertNil(sut.takePendingTrigger())
        XCTAssertEqual(storedState?.meaningfulBrewCount, 2)
    }

    func test_record_whenThirdBrewIsEnded_shouldTriggerBrewEnded() {
        sut.record(.brewEnded(duration: meaningful))
        sut.record(.brewEnded(duration: meaningful))
        sut.record(.brewEnded(duration: meaningful))

        XCTAssertEqual(sut.takePendingTrigger(), .brewEnded)
    }

    func test_record_whenEndedBrewIsShorterThanMeaningfulDuration_shouldNotCount() {
        sut.record(.brewEnded(duration: 5))

        XCTAssertNil(storedState)
    }

    // MARK: - Recipes, methods, amounts

    func test_record_whenFirstCustomMethodCreated_shouldTriggerMethodCreated() {
        sut.record(.customMethodCreated)

        XCTAssertEqual(sut.takePendingTrigger(), .customMethodCreated)
    }

    func test_record_whenFirstRecipeCreated_shouldNotTrigger() {
        sut.record(.recipeCreated)

        XCTAssertNil(sut.takePendingTrigger())
    }

    func test_record_whenSecondRecipeCreated_shouldTriggerRecipeCreated() {
        sut.record(.recipeCreated)
        sut.record(.recipeCreated)

        XCTAssertEqual(sut.takePendingTrigger(), .recipeCreated)
    }

    func test_record_whenThirdRecipeCreatedAfterNoRequest_shouldTriggerRecipeCreated() {
        sut.record(.recipeCreated)
        sut.record(.recipeCreated)
        _ = sut.takePendingTrigger()

        sut.record(.recipeCreated)

        XCTAssertEqual(sut.takePendingTrigger(), .recipeCreated)
    }

    func test_record_whenFirstAmountsEdited_shouldNotTrigger() {
        sut.record(.recipeAmountsEdited)

        XCTAssertNil(sut.takePendingTrigger())
    }

    func test_record_whenSecondAmountsEdited_shouldTriggerAmountsEdited() {
        sut.record(.recipeAmountsEdited)
        sut.record(.recipeAmountsEdited)

        XCTAssertEqual(sut.takePendingTrigger(), .recipeAmountsEdited)
    }

    func test_record_whenCountsStored_shouldContinueFromStoredState() {
        sut.record(.recipeCreated)

        sut = makeSUT(appVersion: "1.0")
        sut.record(.recipeCreated)

        XCTAssertEqual(sut.takePendingTrigger(), .recipeCreated)
    }

    // MARK: - takePendingTrigger

    func test_takePendingTrigger_whenTaken_shouldClearPendingTrigger() {
        sut.record(.customMethodCreated)

        XCTAssertEqual(sut.takePendingTrigger(), .customMethodCreated)
        XCTAssertNil(sut.takePendingTrigger())
    }

    func test_takePendingTrigger_whenAlreadyRequestedInThisVersion_shouldReturnNil() {
        sut.didRequestReview()
        mockDateProvider.advance(by: 365 * day)

        sut.record(.customMethodCreated)

        XCTAssertNil(sut.takePendingTrigger())
    }

    func test_takePendingTrigger_whenNewVersionWithinCooldown_shouldReturnNil() {
        sut.didRequestReview()
        mockDateProvider.advance(by: 29 * day)

        sut = makeSUT(appVersion: "1.1")
        sut.record(.customMethodCreated)

        XCTAssertNil(sut.takePendingTrigger())
    }

    func test_takePendingTrigger_whenNewVersionAfterCooldown_shouldReturnTrigger() {
        sut.didRequestReview()
        mockDateProvider.advance(by: 30 * day)

        sut = makeSUT(appVersion: "1.1")
        sut.record(.customMethodCreated)

        XCTAssertEqual(sut.takePendingTrigger(), .customMethodCreated)
    }

    // MARK: - didRequestReview

    func test_didRequestReview_shouldStoreDateAndVersion() {
        sut.didRequestReview()

        XCTAssertEqual(storedState?.lastRequestDate, mockDateProvider.now)
        XCTAssertEqual(storedState?.lastRequestAppVersion, "1.0")
    }
}
