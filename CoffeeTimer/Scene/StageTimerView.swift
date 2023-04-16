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

protocol BrewStageViewModel: ObservableObject {
	var text: String { get }
}

final class BrewStageConstantViewModel: BrewStageViewModel {

	@Published var text: String

	init(text: String) {
		self.text = text
	}
}

final class BrewStageTimerViewModel: BrewStageViewModel {

	@Published var text: String = ""
	@Published private(set) var timeIntervalLeft: TimeInterval {
		didSet {
			text = timeIntervalLeft.toRepresentableString
		}
	}

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

	func stop() {
		countdownTimer.stop()
	}
}

struct BrewStageView<ViewModel>: View where ViewModel: BrewStageViewModel {

	@ObservedObject var viewModel: ViewModel

	var body: some View {

		Circle()
			.strokeBorder(Color.blue.opacity(0.6), lineWidth: 4)
			.overlay {
				Text(viewModel.text)
					.font(.largeTitle)
					.foregroundColor(.blue)
			}
			.contentShape(Circle())
	}
}

struct BrewStageView_Previews: PreviewProvider {
	static var previews: some View {
		BrewStageView(viewModel: BrewStageTimerViewModel(timeIntervalLeft: 10))
			.background(Color.black)
	}
}
