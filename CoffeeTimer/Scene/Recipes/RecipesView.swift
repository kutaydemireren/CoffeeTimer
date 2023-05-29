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

	private let recipeRepository: RecipeRepository // TODO: use case - no repo in vm!

	init(repository: RecipeRepository = RecipeRepositoryImp()) {
		self.recipeRepository = repository

		recipes = repository.getSavedRecipes()
	}

	func select(recipe: Recipe) {
		recipeRepository.update(selectedRecipe: recipe)
		close()
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
			content
				.padding(.top, 20)

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
						.renderingMode(.template)
				}
				.padding(.horizontal)
			}
			.foregroundColor(.white)
		}
		.backgroundPrimary()
	}

	@ViewBuilder
	var content: some View {
		if viewModel.recipes.isEmpty {
			noRecipes
		} else {
			recipesList
		}
	}

	var noRecipes: some View {
		ZStack {
			VStack {
				Spacer()

				Text("Please add a new recipe to get started")
					.multilineTextAlignment(.center)
					.foregroundColor(.white)
					.font(.title)

				Spacer()
			}
		}
	}

	var recipesList: some View {
		List(viewModel.recipes) { recipe in
			RecipeProfileRowView(recipeProfile: recipe.recipeProfile)
				.onTapGesture {
					viewModel.select(recipe: recipe)
				}
		}
		.scrollIndicators(.hidden)
		.scrollContentBackground(.hidden)
	}
}

struct RecipesView_Previews: PreviewProvider {
	static var previews: some View {
		let recipeVM = RecipesViewModel()
		return RecipesView(viewModel: recipeVM)
	}
}

