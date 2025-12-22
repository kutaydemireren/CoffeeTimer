//
//  MockAnalyticsTracker.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on [Date].
//

@testable import CoffeeTimer

final class MockAnalyticsTracker: AnalyticsTracker {
    var trackedEvents: [AnalyticsEvent] = []
    var trackCallCount = 0
    
    func track(event: AnalyticsEvent) {
        trackCallCount += 1
        trackedEvents.append(event)
    }
}

