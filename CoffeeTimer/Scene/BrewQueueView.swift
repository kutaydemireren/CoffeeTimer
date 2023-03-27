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

final class BrewQueueViewModel: ObservableObject {

	@Published var currentSingleStageTimerViewModel: SingleStageTimerViewModel
	@Published var canProceedToNextStep: Bool = false

	private var cancellables: [AnyCancellable] = []

	// TODO: Temporary for display purposes
	// Come up with queue implementation replicating the steps of brewing
	private var temporaryTimeLeft: TimeInterval = 2

	init() {
		self.currentSingleStageTimerViewModel = SingleStageTimerViewModel(timeIntervalLeft: temporaryTimeLeft)

		observeTimeIntervalLeft()
	}

	func nextStage() {

		temporaryTimeLeft += 2
		currentSingleStageTimerViewModel = SingleStageTimerViewModel(timeIntervalLeft: temporaryTimeLeft)
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
			SingleStageTimerView(viewModel: viewModel.currentSingleStageTimerViewModel)

			if viewModel.canProceedToNextStep {
				Text("Next")
					.foregroundColor(.blue)
					.onTapGesture { viewModel.nextStage() }
			}
		}
		.padding(24)
		.background(
			Rectangle()
				.fill(Gradient(colors: [.indigo, Color.black.opacity(1.0)]))
				.ignoresSafeArea()
		)
	}
}

struct BrewQueueView_Previews: PreviewProvider {
	static var previews: some View {
		BrewQueueView(viewModel: .init())
	}
}
