//
//  BrewQueueView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 13/03/2023.
//

import SwiftUI
import Combine

extension String {

	struct BrewQueue {

		func stageHeader(for action: BrewStageAction) -> String {
			return "It is time to"
		}

		func stageTitle(for action: BrewStageAction) -> String {
			switch action {
			case .boil(let water):
				return "Boil at least \(water.amount) \(water.type) of water"
			case .put(let coffee):
				return "Put \(coffee.amount) \(coffee.type) of coffee"
			case .pour(let water):
				return "Pour \(water.amount) \(water.type) of water"
			case .wet:
				return "Wet your filter under hot sink water"
			case .swirl:
				return "Gently swirl your brewer"
			case .pause:
				return "Wait for a short while"
			case .finish:
				return "Let your coffee breathe for a min or two.\nEnjoy!"
			}
		}
	}

	static let brewQueue = BrewQueue()
}

final class BrewQueueViewModel: ObservableObject, Completable {

	let didComplete = PassthroughSubject<BrewQueueViewModel, Never>()

	var stageHeader = "Welcome"
	var stageTitle = "All set to go!"
	var currentSingleStageTimerViewModel = SingleStageTimerViewModel(timeIntervalLeft: 0.0)
	@Published private(set) var canProceedToNextStep = false {
		didSet {
			if canProceedToNextStep && currentStage.passMethod == .auto {
				nextStage()
			}
		}
	}

	var currentStage: BrewStage {
		didSet {
			loadStage()
		}
	}

	private(set) var isActive = false

	private var cancellables: [AnyCancellable] = []

	// TODO: Create a real queue data structure for getting the next stage from.
	// This BrewQueue here is essentially an 'Entity'. But we are still using here anyway.
	// This must change in any case.
	// + The 'play' around the stages[] is tedious & dangerous. That better is encapsulated.
	private var currentStageIndex: UInt = 0 {
		didSet {
			currentStage = brewQueue.stages[Int(currentStageIndex)]
		}
	}

	private let brewQueue: BrewQueue

	init(brewQueue: BrewQueue) {
		self.brewQueue = brewQueue
		self.currentStage = brewQueue.stages[Int(currentStageIndex)]

		observeTimeIntervalLeft()
	}

	private func observeTimeIntervalLeft() {
		currentSingleStageTimerViewModel.$timeIntervalLeft
			.sink(receiveValue: didSinkNewTimeInterval(_:))
			.store(in: &cancellables)
	}

	private func didSinkNewTimeInterval(_ timeInterval: TimeInterval) {
		canProceedToNextStep = timeInterval <= 0
	}

	func nextStage() {

		if isActive {
			var tempCurrentStageIndex = currentStageIndex + 1
			if tempCurrentStageIndex >= brewQueue.stages.count {
				tempCurrentStageIndex = 0
			}
			currentStageIndex = tempCurrentStageIndex
		} else {
			loadStage()
			isActive = true
		}
	}

	private func loadStage() {
		self.stageHeader = .brewQueue.stageHeader(for: currentStage.action)
		self.stageTitle = .brewQueue.stageTitle(for: currentStage.action)

		switch currentStage.requirement {
		case .none:
			self.currentSingleStageTimerViewModel = SingleStageTimerViewModel(timeIntervalLeft: 0.0)
		case .countdown(let timeLeft):
			self.currentSingleStageTimerViewModel = SingleStageTimerViewModel(timeIntervalLeft: TimeInterval(timeLeft))
		}

		observeTimeIntervalLeft()

		if currentStage.startMethod == .auto {
			currentSingleStageTimerViewModel.startOrStop()
		}
	}
}

struct BrewQueueView: View {

	@ObservedObject var viewModel: BrewQueueViewModel

	var body: some View {

		VStack {

			Group {

				Text(viewModel.stageHeader)
					.foregroundColor(.blue)
					.font(.title3)
				Spacer(minLength: 0).fixedSize(horizontal: false, vertical: true)
				Text(viewModel.stageTitle)
					.foregroundColor(.blue)
					.font(.title)
					.minimumScaleFactor(0.5)
			}
			.multilineTextAlignment(.center)

			SingleStageTimerView(viewModel: viewModel.currentSingleStageTimerViewModel)
				.onTapGesture {
					if viewModel.canProceedToNextStep {
						viewModel.nextStage()
					} else {
						viewModel.currentSingleStageTimerViewModel.startOrStop()
					}
				}

			if !viewModel.isActive {
				Button {
					viewModel.didComplete.send(viewModel)
				} label: {
					Text("+")
				}
				.padding()
				.foregroundColor(.white)
				.background(Color.blue)
				.clipShape(Circle())
			}
		}
		.padding(24)
		.background(
			Rectangle()
				.fill(Gradient(colors: [.indigo, Color.black]))
				.ignoresSafeArea()
		)
	}
}

struct BrewQueueView_Previews: PreviewProvider {
	static var previews: some View {
		BrewQueueView(viewModel: .init(brewQueue: .stub))
	}
}
