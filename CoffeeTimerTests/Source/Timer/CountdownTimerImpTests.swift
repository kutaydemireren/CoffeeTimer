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

    var mockScheduler: MockRepeatingTickScheduler!
    var mockDateProvider: MockDateProvider!
    var sut: CountdownTimerImp!

    override func setUpWithError() throws {
        mockScheduler = MockRepeatingTickScheduler()
        mockDateProvider = MockDateProvider()
        sut = makeSUT(timeLeft: defaultInitialTimeLeft)
    }

    override func tearDownWithError() throws {
        sut?.stop()
        sut = nil
        mockScheduler = nil
        mockDateProvider = nil
    }

    private func makeSUT(timeLeft: TimeInterval) -> CountdownTimerImp {
        CountdownTimerImp(timeLeft: timeLeft, scheduler: mockScheduler, dateProvider: mockDateProvider)
    }

    /// Moves the fake clock forward one step and fires one tick.
    private func tick(times: Int = 1) {
        for _ in 0..<times {
            mockDateProvider.advance(by: expectedStepInterval)
            mockScheduler.fire()
        }
    }

    func test_start_shouldStartRunning() {
        try? sut.start()

        XCTAssertTrue(sut.isRunning)
    }

    func test_start_shouldScheduleExpectedStepInterval() {
        try? sut.start()

        XCTAssertEqual(mockScheduler.scheduledInterval, expectedStepInterval)
    }

    func test_start_whenTimeLeftIsZero_shouldNotStartRunning() {
        sut = makeSUT(timeLeft: 0)

        try? sut.start()

        XCTAssertFalse(sut.isRunning)
    }

    func test_start_whenTimeLeftIsNegative_shouldNotStartRunning() {
        sut = makeSUT(timeLeft: -5)

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

        try? sut.start()

        var resultedTime: Double?
        let subs = sut.timeLeftPublisher
            .dropFirst() // skip receiving initial value
            .sink { resultedTime = $0 }

        tick()

        subs.cancel()
        XCTAssertEqual(resultedTime!, expectedTime, accuracy: 0.0001)
    }

    func test_start_shouldCountdownBeExpectedAfterWaiting() {
        let initialTimeLeft = 5.0
        sut = makeSUT(timeLeft: initialTimeLeft)

        try? sut.start()

        tick(times: 20) // 2 seconds

        XCTAssertEqual(sut.timeLeft, initialTimeLeft - 2.0, accuracy: 0.0001)
    }

    func test_start_whenTicksAreLate_shouldUseElapsedClockTime() {
        try? sut.start()

        mockDateProvider.advance(by: 1.5)
        mockScheduler.fire()

        XCTAssertEqual(sut.timeLeft, defaultInitialTimeLeft - 1.5, accuracy: 0.0001)
    }

    func test_start_whenTimeLeftReachEnd_shouldAutoStop() {
        sut = makeSUT(timeLeft: 3.0)

        try? sut.start()

        var reachedZero = false
        let subs = sut.timeLeftPublisher
            .sink { if $0 <= 0 { reachedZero = true } }

        tick(times: 31)

        subs.cancel()
        XCTAssertTrue(reachedZero)
        XCTAssertEqual(sut.timeLeft, 0)
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

    func test_stop_whenAfterStarted_shouldNotCountdownAnymore() {
        try? sut.start()
        sut.stop()

        tick()

        XCTAssertEqual(sut.timeLeft, defaultInitialTimeLeft)
    }
}
