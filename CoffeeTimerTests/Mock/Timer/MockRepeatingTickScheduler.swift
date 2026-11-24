//
//  MockRepeatingTickScheduler.swift
//  CoffeeTimerTests
//

import Foundation
@testable import CoffeeTimer

final class MockRepeatingTick: RepeatingTick {
    private(set) var isInvalidated = false

    func invalidate() {
        isInvalidated = true
    }
}

final class MockRepeatingTickScheduler: RepeatingTickScheduler {
    private(set) var scheduledInterval: TimeInterval?
    private var action: (() -> Void)?
    private var tick: MockRepeatingTick?

    func scheduleRepeating(interval: TimeInterval, action: @escaping () -> Void) -> RepeatingTick {
        scheduledInterval = interval
        self.action = action
        let tick = MockRepeatingTick()
        self.tick = tick
        return tick
    }

    /// Fires one tick, unless the scheduled tick was invalidated.
    func fire() {
        guard let tick, !tick.isInvalidated else { return }
        action?()
    }
}
