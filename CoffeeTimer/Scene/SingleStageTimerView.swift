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

class SingleStageTimerViewModel: ObservableObject {

	@Published var timeLeft: String

	private var timeIntervalLeft: TimeInterval {
		didSet {
			timeLeft = timeIntervalLeft.toRepresentableString
		}
	}

	private var countdownTimer: CountdownTimerImpl

	private var cancellables: [AnyCancellable] = []

	init(
		timeIntervalLeft: TimeInterval
	) {
		self.timeLeft = timeIntervalLeft.toRepresentableString
		self.timeIntervalLeft = timeIntervalLeft
		self.countdownTimer = CountdownTimerImpl(timeLeft: timeIntervalLeft)
	}

	func start() {
		try? countdownTimer.start()

		countdownTimer.$timeLeft
			.sink { timeIntervalLeft in
				self.timeIntervalLeft = timeIntervalLeft
			}
			.store(in: &cancellables)
	}
}

struct SingleStageTimerView: View {

	@ObservedObject var viewModel: SingleStageTimerViewModel

	var body: some View {

		Circle()
			.strokeBorder(Color.blue.opacity(0.6), lineWidth: 4)
			.overlay {
				Text(viewModel.timeLeft)
					.font(.largeTitle)
					.foregroundColor(.blue)
			}
			.padding(24)
			.background(Color.black.opacity(0.9))
			.onTapGesture {
				viewModel.start()
			}
	}
}

struct SingleStageTimerView_Previews: PreviewProvider {
	static var previews: some View {
		SingleStageTimerView(viewModel: .init(timeIntervalLeft: 10))
	}
}
