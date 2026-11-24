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

/// Schedules a repeating tick. Lets tests drive the countdown without waiting on real time.
protocol RepeatingTickScheduler {
    func scheduleRepeating(interval: TimeInterval, action: @escaping () -> Void) -> RepeatingTick
}

protocol RepeatingTick {
    func invalidate()
}

extension Timer: RepeatingTick {}

struct RepeatingTickSchedulerImp: RepeatingTickScheduler {
    func scheduleRepeating(interval: TimeInterval, action: @escaping () -> Void) -> RepeatingTick {
        let timer = Timer(timeInterval: interval, repeats: true) { _ in action() }
        RunLoop.current.add(timer, forMode: .common)
        return timer
    }
}

final class CountdownTimerImp: CountdownTimer {

    private let stepInterval: TimeInterval = 0.1

    var isRunning: Bool {
        return timer != nil
    }
    private var timer: RepeatingTick?

    var timeLeftPublisher: Published<TimeInterval>.Publisher {
        $timeLeft
    }
    @Published private(set) var timeLeft: TimeInterval

    private var endTime: Date?

    private let scheduler: RepeatingTickScheduler
    private let dateProvider: DateProvider

    init(
        timeLeft: TimeInterval,
        scheduler: RepeatingTickScheduler = RepeatingTickSchedulerImp(),
        dateProvider: DateProvider = DateProviderImp()
    ) {
        self.timeLeft = timeLeft
        self.scheduler = scheduler
        self.dateProvider = dateProvider
    }

    deinit {
        stop()
    }

    func start() throws {
        guard !isRunning else { throw CountdownTimerError.alreadyRunning }
        guard canStart() else { return }

        endTime = dateProvider.now.addingTimeInterval(timeLeft)
        // Strong capture on purpose: it matches the old target/selector Timer, which retained self until stop().
        timer = scheduler.scheduleRepeating(interval: stepInterval) {
            self.timerDidFire()
        }
    }

    private func canStart() -> Bool {
        return timeLeft > 0
    }

    private func timerDidFire() {
        guard let endTime else {
            stop()
            return
        }

        let newTimeLeft = max(0, endTime.timeIntervalSince(dateProvider.now))

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
