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
				return "Let your coffee breathe for a minute or two\nEnjoy!"
			}
		}
	}

	static let brewQueue = BrewQueue()
}

final class BrewQueueViewModel: ObservableObject, Completable {

	let didRequestCreate = PassthroughSubject<BrewQueueViewModel, Never>()

	var stageHeader = "Welcome"
	var stageTitle = "All set to go!"

	@Published var currentStageViewModel: any BrewStageViewModel = BrewStageConstantViewModel(text: "")

	var currentStageTimerViewModel: BrewStageTimerViewModel? {
		currentStageViewModel as? BrewStageTimerViewModel
	}

	var currentStageConstantViewModel: BrewStageConstantViewModel? {
		currentStageViewModel as? BrewStageConstantViewModel
	}

	@Published private(set) var canProceedToNextStep = true {
		didSet {
			if canProceedToNextStep && currentStage.passMethod == .auto {
				DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
					self.nextStage()
				}
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

		loadInitialStage()
	}

	func primaryAction() {
		if canProceedToNextStep {
			nextStage()
		} else {
			currentStageTimerViewModel?.startOrStop()
		}
	}

	func skipAction() {
		nextStage()
	}

	private func nextStage() {

		if isActive {
			var tempCurrentStageIndex = currentStageIndex + 1
			if tempCurrentStageIndex >= brewQueue.stages.count {
				isActive = false
				tempCurrentStageIndex = 0
			}
			currentStageIndex = tempCurrentStageIndex
		} else {
			isActive = true
			loadStage()
		}
	}

	private func loadInitialStage() {
		stageHeader = "Welcome"
		stageTitle = "All set to go!"
		currentStageViewModel = BrewStageConstantViewModel(text: "Begin")
	}

	private func loadStage() {

		currentStageTimerViewModel?.stop()

		guard isActive else {
			loadInitialStage()
			return
		}

		stageHeader = .brewQueue.stageHeader(for: currentStage.action)
		stageTitle = .brewQueue.stageTitle(for: currentStage.action)

		switch currentStage.requirement {
		case .none:
			currentStageViewModel = BrewStageConstantViewModel(text: "Done")
			canProceedToNextStep = true
		case .countdown(let timeLeft):
			currentStageViewModel = BrewStageTimerViewModel(timeIntervalLeft: TimeInterval(timeLeft))
		}

		observeTimeIntervalLeft()

		if currentStage.startMethod == .auto {
			currentStageTimerViewModel?.startOrStop()
		}
	}

	private func observeTimeIntervalLeft() {
		currentStageTimerViewModel?.$timeIntervalLeft
			.sink(receiveValue: didSinkNewTimeInterval(_:))
			.store(in: &cancellables)
	}

	private func didSinkNewTimeInterval(_ timeInterval: TimeInterval) {
		canProceedToNextStep = timeInterval <= 0
	}
}

struct BrewQueueView: View {

	@ObservedObject var viewModel: BrewQueueViewModel

	var body: some View {

		GeometryReader { proxy in
			ZStack {

				backgroundView
					.padding(24)

				Group {
					brewStageView()
						.shadow(color: .black.opacity(0.6), radius: 8, x: -2, y: -2)
						.onTapGesture {
							viewModel.primaryAction()
						}
						.position(x: (proxy.size.width / 2) - 24, y: (proxy.size.height / 2) - 24)
				}
				.padding(24)
			}
			.backgroundPrimary()
		}
	}

	private var backgroundView: some View {

		HStack {
			Spacer()

			VStack {

				headerGroup

				Spacer()

				actionButton()
			}

			Spacer()
		}
	}

	private var headerGroup: some View {
		Group {
			Text(viewModel.stageHeader)
				.foregroundColor(.white.opacity(0.6))
				.font(.title3)

			Spacer(minLength: 0).fixedSize(horizontal: false, vertical: true)

			Text(viewModel.stageTitle)
				.foregroundColor(.white.opacity(0.8))
				.font(.title)
				.minimumScaleFactor(0.5)
		}
		.shadow(color: .black.opacity(0.6), radius: 8, x: -2, y: -2)
		.multilineTextAlignment(.center)
	}

	private var createButton: some View {
		Button {
			viewModel.didRequestCreate.send(viewModel)
		} label: {
			Text("+")
		}
		.padding()
		.foregroundColor(.white)
		.background(Gradient(stops:[
			.init(color: .indigo.opacity(0.4), location: 0.2),
			.init(color: .indigo, location: 0.8)
		]))
		.clipShape(Circle())
		.shadow(color: .indigo.opacity(0.4), radius: 8, x: -2, y: -2)
	}

	private var skipButton: some View {
		Button {
			viewModel.skipAction()
		} label: {
			Text("Skip")
		}
		.padding()
		.foregroundColor(.white.opacity(0.8))
	}

	@ViewBuilder
	private func actionButton() -> some View {

		if !viewModel.isActive {
			createButton
		} else {
			skipButton
		}
	}

	@ViewBuilder
	private func brewStageView() -> some View {
		if let currentStageTimerViewModel = viewModel.currentStageTimerViewModel {
			BrewStageView(viewModel: currentStageTimerViewModel)
		} else if let currentStageConstantViewModel = viewModel.currentStageConstantViewModel {
			BrewStageView(viewModel: currentStageConstantViewModel)
		} else {
			EmptyView()
		}
	}
}

struct BrewQueueView_Previews: PreviewProvider {
	static var previews: some View {
		BrewQueueView(viewModel: .init(brewQueue: .stubMini))
	}
}
