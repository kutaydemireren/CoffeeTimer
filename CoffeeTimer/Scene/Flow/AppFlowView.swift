//
//  FlowView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 11/04/2023.
//

import Foundation
import Combine
import SwiftUI

final class FlowViewModel: ObservableObject {

	@Published var navigationPath: [Screen] = []
	@Published var isCreateRecipePresented = false

	private var cancellables: [AnyCancellable] = []

	func make1() -> BrewQueueViewModel {
		let viewModel = BrewQueueViewModel(brewQueue: BrewQueueRepositoryImp.selectedRecipe.brewQueue)
		viewModel.didRequestCreate
			.sink(receiveValue: didRequestCreate)
			.store(in: &cancellables)
		return viewModel
	}

	private func didRequestCreate(viewModel: BrewQueueViewModel) {
		isCreateRecipePresented = true
	}
}

struct AppFlowView: View {

	@StateObject var viewModel: FlowViewModel

	var body: some View {
		NavigationStack(path: $viewModel.navigationPath) {
			VStack() {
				brewQueue()
			}
			.navigationDestination(for: Screen.self) { screen in
				switch screen {
				case .brewQueue:
					brewQueue()
				case .createRecipe:
					createRecipe()
				}
			}
		}
		.textFieldStyle(RoundedBorderTextFieldStyle())
		.fullScreenCover(isPresented: $viewModel.isCreateRecipePresented) {
			createRecipe()
		}
	}

	func brewQueue() -> some View {
		BrewQueueView(viewModel: viewModel.make1())
	}

	func createRecipe() -> some View {
		CreateRecipeFlowView(viewModel: CreateRecipeFlowViewModel()) {
			viewModel.isCreateRecipePresented = false
		}
	}
}

struct FlowView_Previews: PreviewProvider {
	static var previews: some View {
		AppFlowView(viewModel: .init())
	}
}
