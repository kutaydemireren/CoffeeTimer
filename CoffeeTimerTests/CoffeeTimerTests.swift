//
//  CoffeeTimerTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 19/02/2023.
//

import XCTest
import Combine
@testable import CoffeeTimer

protocol CountdownTimer {

}

final class CountdownTimerImpl: CountdownTimer {

	var isRunning: Bool {
		return timer != nil
	}
	private var timer: Timer?

	@Published private(set) var timeLeft: TimeInterval

	init(timeLeft: TimeInterval) {
		self.timeLeft = timeLeft
	}

	deinit {
		timer?.invalidate()
		timer = nil
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

		let newTimeLeft = timeLeft - 1

		if newTimeLeft < 1 {
			timer?.invalidate()
			timer = nil
		}

		self.timeLeft = newTimeLeft
	}
}

final class CoffeeTimerTests: XCTestCase {

	var sut: CountdownTimerImpl!

	let defaultInitialTimeLeft = 10.0

	var cancellables: [AnyCancellable] = []

    override func setUpWithError() throws {

		sut = CountdownTimerImpl(timeLeft: defaultInitialTimeLeft)
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

	func test_start_shouldCountdownByOne() {
		let expectedTime = sut.timeLeft - 1

		let exp = expectation(description: "time left should be updated 1 second after start")

		sut.start()

		var resultedTime: Double?
		let subs = sut.$timeLeft
			.dropFirst() // skip receiving initial value
			.sink { timeInterval in
				resultedTime = timeInterval
				exp.fulfill()
			}

		wait(for: [exp], timeout: 1.0)

		subs.cancel()
		XCTAssertEqual(resultedTime, expectedTime)
	}

	func test_start_whenTimeLeftReachEnd_shouldStop() {
		let expectedTime = 3.0
		sut = CountdownTimerImpl(timeLeft: expectedTime)

		let exp = expectation(description: "time left should reach to 0 in 3 seconds after start")

		sut.start()

		let subs = sut.$timeLeft
			.sink { timeInterval in
				if timeInterval == 0 {
					exp.fulfill()
				}
			}

		wait(for: [exp], timeout: expectedTime)

		subs.cancel()
		XCTAssertFalse(sut.isRunning)
	}
}
