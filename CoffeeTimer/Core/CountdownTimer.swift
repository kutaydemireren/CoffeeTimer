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

// TODO: Extract to protocol `CountdownTimer`
// Skipped extracting to a protocol for speed.
// Must find out -> how to represent and expose `@Published var timeLeft` in a protocol
final class CountdownTimerImpl {

	var isRunning: Bool {
		return timer != nil
	}
	private var timer: Timer?

	@Published private(set) var timeLeft: TimeInterval {
		didSet {
			debugPrint("\(#function) -> time left = \(timeLeft)")
		}
	}

	init(timeLeft: TimeInterval) {
		self.timeLeft = timeLeft
	}

	deinit {
		stop()
	}

	func start() throws {

		guard !isRunning else { throw CountdownTimerError.alreadyRunning }
		guard canStart() else { return }

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
			stop()
		}

		self.timeLeft = newTimeLeft
	}

	func stop() {
		timer?.invalidate()
		timer = nil
	}
}
