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

    let expectedStepInterval: TimeInterval = 0.1
    let defaultInitialTimeLeft = 10.0

    var sut: CountdownTimerImp!

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

        XCTAssertThrowsError(try sut.start()) { error in
            XCTAssertEqual(error as? CountdownTimerError, .alreadyRunning)
        }
    }

    func test_start_shouldCountdownByOneInterval() {
        let expectedTime = sut.timeLeft - expectedStepInterval

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
        XCTAssertEqual(resultedTime!, expectedTime, accuracy: 0.01)
    }

    func test_start_shouldCountdownBeExpectedAfterWaiting() {
        let initialTimeLeft = 5.0
        sut = CountdownTimerImp(timeLeft: initialTimeLeft)

        try? sut.start()

        let waitTime: TimeInterval = 2.0
        let exp = expectation(description: "time left should be updated correctly after waiting")

        DispatchQueue.global().asyncAfter(deadline: .now() + waitTime) {
            DispatchQueue.main.async {
                XCTAssertEqual(self.sut.timeLeft, max(0, initialTimeLeft - waitTime), accuracy: 0.1)
                exp.fulfill()
            }
        }

        wait(for: [exp], timeout: waitTime + 0.5)
    }

    func test_start_whenTimeLeftReachEnd_shouldAutoStop() {
        let expectedTime = 3.0
        sut = CountdownTimerImp(timeLeft: expectedTime)

        let exp = expectation(description: "time left should reach to 0 in 3 seconds after start")

        try? sut.start()

        let subs = sut.timeLeftPublisher
            .sink { timeInterval in
                if timeInterval <= 0 {
                    exp.fulfill()
                }
            }

        wait(for: [exp], timeout: expectedTime + 0.1)

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
