//
//  MockDateProvider.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 19/11/2026.
//

import Foundation
@testable import CoffeeTimer

final class MockDateProvider: DateProvider {
    var now: Date = Date(timeIntervalSince1970: 1_700_000_000)

    func advance(by interval: TimeInterval) {
        now = now.addingTimeInterval(interval)
    }
}
