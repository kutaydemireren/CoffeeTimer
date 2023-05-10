//
//  RecipesFlowView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 10/05/2023.
//

import SwiftUI
import Combine

final class RecipesFlowViewModel: ObservableObject, Completable {
	@Published var navigationPath: [Screen] = []

	var didComplete = PassthroughSubject<RecipesFlowViewModel, Never>()

	private var cancellables: [AnyCancellable] = []

	func makeVM() -> RecipesViewModel {
		let viewModel = RecipesViewModel()
		viewModel.didComplete
			.sink(receiveValue: didComplete(_:))
			.store(in: &cancellables)
		viewModel.didCreate
			.sink(receiveValue: didCreate(_:))
			.store(in: &cancellables)
		viewModel.recipes = MockStore.savedRecipes
		return viewModel
	}

	func make2() -> CreateRecipeFlowViewModel {
		let viewModel = CreateRecipeFlowViewModel()
		viewModel.didComplete
			.sink(receiveValue: didComplete)
			.store(in: &cancellables)
		return viewModel
	}

	func close() {
		didComplete.send(self)
	}

	private func didComplete(_ recipesViewModel: RecipesViewModel) {
		self.close()
	}

	private func didCreate(_ recipesViewModel: RecipesViewModel) {
		navigationPath.append(.createRecipe)
	}

	private func didComplete(viewModel: CreateRecipeFlowViewModel) {
		navigationPath.removeAll { $0 == .createRecipe }
	}
}

struct RecipesFlowView: View {

	@StateObject var viewModel: RecipesFlowViewModel

	var body: some View {
		NavigationStack(path: $viewModel.navigationPath) {
			recipes
				.navigationDestination(for: Screen.self) { screen in
					switch screen {
					case .brewQueue:
						EmptyView()
					case .createRecipe:
						createRecipe()
					case .recipesFlowView:
						EmptyView()
					}
				}
		}
	}

	var recipes: some View {
		return RecipesView(viewModel: viewModel.makeVM())
	}

	func createRecipe() -> some View {
		CreateRecipeFlowView(viewModel: viewModel.make2())
	}
}

struct RecipesFlowView_Previews: PreviewProvider {
	static var previews: some View {
		return RecipesFlowView(viewModel: RecipesFlowViewModel())
	}
}
