//
//  CoffeeTimerTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 19/02/2023.
//

import XCTest
@testable import CoffeeTimer

protocol CountdownTimer {

}

final class CountdownTimerImpl: CountdownTimer {

	var isRunning: Bool {
		return timer != nil
	}

	private(set) var timeLeft: TimeInterval

	private var timer: Timer?
	
	init(timeLeft: TimeInterval) {
		self.timeLeft = timeLeft
	}

	func start() {

		guard canStart() else {
			return
		}

		let timer = Timer(timeInterval: 1, target: self, selector: #selector(timerDidFire), userInfo: nil, repeats: true)
		RunLoop.current.add(timer, forMode: .common)

		self.timer = timer
	}

	private func canStart() -> Bool {
		return timeLeft > 0
	}

	@objc private func timerDidFire() {
		timeLeft -= 1
	}
}

final class CoffeeTimerTests: XCTestCase {

	var sut: CountdownTimerImpl!

    override func setUpWithError() throws {

		sut = CountdownTimerImpl(timeLeft: 3)
    }

    func test_start_shouldStartRunning() {

		sut.start()

		XCTAssertTrue(sut.isRunning)
    }

	func test_start_whenTimeLeftIsZero_shouldNotStartRunning() {

		sut = CountdownTimerImpl(timeLeft: 0)

		sut.start()

		XCTAssertFalse(sut.isRunning)
	}

	func test_start_whenTimeLeftIsNegative_shouldNotStartRunning() {

		sut = CountdownTimerImpl(timeLeft: -5)

		sut.start()

		XCTAssertFalse(sut.isRunning)
	}
}
