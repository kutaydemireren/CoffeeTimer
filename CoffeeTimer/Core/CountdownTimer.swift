//
//  CountdownTimer.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 13/03/2023.
//

import Foundation

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
