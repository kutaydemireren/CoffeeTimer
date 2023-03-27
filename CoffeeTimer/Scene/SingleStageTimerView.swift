//
//  SingleStageTimerView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 13/03/2023.
//

import SwiftUI
import Combine

extension TimeInterval {

	var toRepresentableString: String {
		return "\(self)" // TODO: improve
	}
}

final class SingleStageTimerViewModel: ObservableObject {

	@Published private(set) var timeIntervalLeft: TimeInterval

	private var cancellables: [AnyCancellable] = []

	private var countdownTimer: CountdownTimerImpl

	init(
		timeIntervalLeft: TimeInterval
	) {
		self.timeIntervalLeft = timeIntervalLeft
		self.countdownTimer = CountdownTimerImpl(timeLeft: timeIntervalLeft)

		countdownTimer.$timeLeft
			.sink { timeIntervalLeft in
				self.timeIntervalLeft = timeIntervalLeft
			}
			.store(in: &cancellables)
	}

	func startOrStop() {
		if countdownTimer.isRunning {
			countdownTimer.stop()
		} else {
			try? countdownTimer.start()
		}
	}
}

struct SingleStageTimerView: View {

	@ObservedObject var viewModel: SingleStageTimerViewModel

	var body: some View {

		Circle()
			.strokeBorder(Color.blue.opacity(0.6), lineWidth: 4)
			.overlay {
				Text(viewModel.timeIntervalLeft.toRepresentableString)
					.font(.largeTitle)
					.foregroundColor(.blue)
			}
			.contentShape(Circle())
			.onTapGesture {
				viewModel.startOrStop()
			}
	}
}

struct SingleStageTimerView_Previews: PreviewProvider {
	static var previews: some View {
		SingleStageTimerView(viewModel: .init(timeIntervalLeft: 10))
			.background(Color.black)
	}
}
