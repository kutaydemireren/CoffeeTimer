//
//  CountdownTimer.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 13/03/2023.
//

import Foundation
import Combine

enum CountdownTimerError: Error {
    case alreadyRunning
}

protocol CountdownTimer {
    var isRunning: Bool { get }
    var timeLeft: TimeInterval { get }
    var timeLeftPublisher: Published<TimeInterval>.Publisher { get }

    func start() throws
    func stop()
}

final class CountdownTimerImp: CountdownTimer {

    private let stepInterval: TimeInterval = 0.1

    var isRunning: Bool {
        return timer != nil
    }
    private var timer: Timer?

    var timeLeftPublisher: Published<TimeInterval>.Publisher {
        $timeLeft
    }
    @Published private(set) var timeLeft: TimeInterval

    private var endTime: Date?

    init(timeLeft: TimeInterval) {
        self.timeLeft = timeLeft
    }

    deinit {
        stop()
    }

    func start() throws {
        guard !isRunning else { throw CountdownTimerError.alreadyRunning }
        guard canStart() else { return }

        endTime = Date().addingTimeInterval(timeLeft)
        let timer = Timer(timeInterval: stepInterval, target: self, selector: #selector(timerDidFire), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: .common)
        self.timer = timer
    }

    private func canStart() -> Bool {
        return timeLeft > 0
    }

    @objc private func timerDidFire() {
        guard let endTime else {
            stop()
            return
        }

        let newTimeLeft = max(0, endTime.timeIntervalSinceNow)

        if newTimeLeft == 0 {
            stop()
        }

        self.timeLeft = newTimeLeft
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        endTime = nil
    }
}
