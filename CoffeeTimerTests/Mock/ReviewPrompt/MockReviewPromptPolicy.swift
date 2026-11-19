//
//  MockReviewPromptPolicy.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 19/11/2026.
//

@testable import CoffeeTimer

final class MockReviewPromptPolicy: ReviewPromptPolicy {
    var recordedEvents: [ReviewPromptEvent] = []
    var onRecord: ((ReviewPromptEvent) -> Void)?

    var _pendingTrigger: ReviewPromptTrigger?
    var takePendingTriggerCallCount = 0

    var didRequestReviewCallCount = 0

    func record(_ event: ReviewPromptEvent) {
        recordedEvents.append(event)
        onRecord?(event)
    }

    func takePendingTrigger() -> ReviewPromptTrigger? {
        takePendingTriggerCallCount += 1
        defer { _pendingTrigger = nil }
        return _pendingTrigger
    }

    func didRequestReview() {
        didRequestReviewCallCount += 1
    }
}
