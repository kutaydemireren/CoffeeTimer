//
//  CountdownTimerImplTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 13/03/2023.
//

import XCTest
import Combine
@testable import CoffeeTimer

final class CountdownTimerImplTests: XCTestCase {

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

