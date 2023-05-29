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
		String(format: "%d", Int(self))
	}
}

protocol BrewStageViewModel: ObservableObject {
	var text: String { get }
	var progress: Double { get }
}

final class BrewStageConstantViewModel: BrewStageViewModel {

	@Published var text: String
	let progress = 1.0

	init(text: String) {
		self.text = text
	}
}

final class BrewStageTimerViewModel: BrewStageViewModel {

	@Published var text: String = ""
	@Published var progress: Double = 0.0
	@Published private(set) var timeIntervalLeft: TimeInterval {
		didSet {
			withAnimation(.linear(duration: 1.0)) { progress = (duration - timeIntervalLeft) / duration }
			text = timeIntervalLeft.toRepresentableString
		}
	}
	private let duration: TimeInterval

	private var cancellables: [AnyCancellable] = []

	private var countdownTimer: CountdownTimerImpl

	init(
		timeIntervalLeft: TimeInterval
	) {
		self.duration = timeIntervalLeft
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

		ZStack {
			Circle()
				.trim(from: 0, to: viewModel.progress)
				.stroke(.white.opacity(0.8), style: .init(lineWidth: 4))
				.contentShape(Circle())

			Circle()
				.trim(from: viewModel.progress, to: 1.0)
				.stroke(.white.opacity(0.3), style: .init(lineWidth: 4))
			.contentShape(Circle())
		}
		.rotationEffect(.degrees(-90))
		.overlay {
			Text(viewModel.text)
				.font(.largeTitle)
				.foregroundColor(.white.opacity(0.8))
		}
	}
}

struct BrewStageView_Previews: PreviewProvider {
	static var previews: some View {
		BrewStageView(viewModel: BrewStageTimerViewModel(timeIntervalLeft: 10))
			.background(Color.black)
	}
}
