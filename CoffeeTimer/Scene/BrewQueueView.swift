//
//  BrewQueueView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 13/03/2023.
//

import SwiftUI
import Combine

extension View {

	@ViewBuilder
	func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {

		if condition {
			transform(self)
		} else {
			self
		}
	}
}

extension BrewQueue {
	static var tempQueue1: BrewQueue {
		BrewQueue(id: UUID(), stages: [
			.welcome,
			.tempStep1,
			.tempStep2
		])
	}
}

extension BrewStage {
	static var welcome: BrewStage {
		BrewStage(id: UUID(), header: "Welcome!", title: "You can start brewing", timeIntervalLeft: 0)
	}

	static var tempStep1: BrewStage {
		BrewStage(id: UUID(), header: "", title: "Wet the filtering paper", timeIntervalLeft: 2.0)
	}

	static var tempStep2: BrewStage {
		BrewStage(id: UUID(), header: "", title: "Pour %20 on coffee", timeIntervalLeft: 3.0)
	}
}

final class BrewQueueViewModel: ObservableObject {

	@Published var stageHeader: String
	@Published var stageTitle: String
	@Published var currentSingleStageTimerViewModel: SingleStageTimerViewModel
	@Published var canProceedToNextStep: Bool = false

	var currentStage: BrewStage {
		didSet {
			stageHeader = currentStage.header
			stageTitle = currentStage.title
			currentSingleStageTimerViewModel = SingleStageTimerViewModel(timeIntervalLeft: currentStage.timeIntervalLeft)
		}
	}

	private var cancellables: [AnyCancellable] = []

	// TODO: Temporary for display purposes
	// Come up with queue implementation replicating the steps of brewing
	private var temporaryTimeLeft: TimeInterval = 0

	// TODO: Create a real queue data structure for getting the next stage from.
	// This BrewQueue here is essentially an 'Entity'. But we are still using here anyway.
	// This must change in any case.
	private var currentStageIndex: UInt = 0 {
		didSet {
			currentStage = brewQueue.stages[Int(currentStageIndex)]
		}
	}

	private let brewQueue: BrewQueue

	init(brewQueue: BrewQueue) {
		self.brewQueue = brewQueue
		self.currentStage = brewQueue.stages[Int(currentStageIndex)]
		self.stageHeader = currentStage.header
		self.stageTitle = currentStage.title
		self.currentSingleStageTimerViewModel = SingleStageTimerViewModel(timeIntervalLeft: temporaryTimeLeft)

		observeTimeIntervalLeft()
	}

	func nextStage() {

		temporaryTimeLeft += 2
		var tempCurrentStageIndex = currentStageIndex + 1
		if tempCurrentStageIndex >= brewQueue.stages.count {
			tempCurrentStageIndex = 0
		}
		currentStageIndex = tempCurrentStageIndex
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
		BrewQueueView(viewModel: .init(brewQueue: .tempQueue1))
	}
}
