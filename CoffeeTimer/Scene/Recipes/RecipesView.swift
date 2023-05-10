//
//  RecipesView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 10/05/2023.
//

import SwiftUI
import Combine

final class RecipesViewModel: ObservableObject, Completable {
	var didComplete = PassthroughSubject<RecipesViewModel, Never>()
	var didCreate = PassthroughSubject<RecipesViewModel, Never>()

	@Published var recipes: [Recipe] = []

	private let repository: BrewQueueRepository

	init(repository: BrewQueueRepository = BrewQueueRepositoryImp()) {
		self.repository = repository
	}

	func create() {
		didCreate.send(self)
	}

	func close() {
		didComplete.send(self)
	}
}

struct RecipesView: View {

	@ObservedObject var viewModel: RecipesViewModel

	var body: some View {
		ZStack(alignment: .top) {
			List(viewModel.recipes) { recipe in
				RecipeProfileRowView(recipeProfile: recipe.recipeProfile)
			}
			.backgroundPrimary()
			.scrollIndicators(.hidden)
			.scrollContentBackground(.hidden)

			HStack {
				Button("Close") {
					viewModel.close()
				}
				.padding(.horizontal)
				Spacer()
				Button() {
					viewModel.create()
				} label: {
					Image(uiImage: .add)
				}
				.padding(.horizontal)
			}
		}
	}
}

struct RecipesView_Previews: PreviewProvider {
	static var previews: some View {
		let recipeVM = RecipesViewModel()
		recipeVM.recipes = MockStore.savedRecipes
		return RecipesView(viewModel: recipeVM)
	}
}

