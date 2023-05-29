//
//  CountdownTimerImpTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 13/03/2023.
//

import XCTest
import Combine
@testable import CoffeeTimer

final class CountdownTimerImpTests: XCTestCase {

	var sut: CountdownTimerImp!

	let defaultInitialTimeLeft = 10.0

	override func setUpWithError() throws {

		sut = CountdownTimerImp(timeLeft: defaultInitialTimeLeft)
	}

	func test_start_shouldStartRunning() {
		try? sut.start()

		XCTAssertTrue(sut.isRunning)
	}

	func test_start_whenTimeLeftIsZero_shouldNotStartRunning() {
		sut = CountdownTimerImp(timeLeft: 0)

		try? sut.start()

		XCTAssertFalse(sut.isRunning)
	}

	func test_start_whenTimeLeftIsNegative_shouldNotStartRunning() {
		sut = CountdownTimerImp(timeLeft: -5)

		try? sut.start()

		XCTAssertFalse(sut.isRunning)
	}

	func test_start_whenRunning_shouldNotStartSecondTime() {
		try? sut.start()

		var thrownError: Error?
		do {
			try sut.start()
		} catch {
			thrownError = error
		}

		XCTAssertEqual(thrownError?.localizedDescription, CountdownTimerError.alreadyRunning.localizedDescription)
	}

	func test_start_shouldCountdownByOne() {
		let expectedTime = sut.timeLeft - 1

		let exp = expectation(description: "time left should be updated 1 second after start")

		try? sut.start()

		var resultedTime: Double?
		let subs = sut.timeLeftPublisher
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
		sut = CountdownTimerImp(timeLeft: expectedTime)

		let exp = expectation(description: "time left should reach to 0 in 3 seconds after start")

		try? sut.start()

		let subs = sut.timeLeftPublisher
			.sink { timeInterval in
				if timeInterval == 0 {
					exp.fulfill()
				}
			}

		wait(for: [exp], timeout: expectedTime)

		subs.cancel()
		XCTAssertFalse(sut.isRunning)
	}

	func test_stop_shouldStop() {

		sut.stop()

		XCTAssertFalse(sut.isRunning)
	}

	func test_stop_whenAfterStarted_shouldStop() {

		try? sut.start()

		sut.stop()

		XCTAssertFalse(sut.isRunning)
	}
}

