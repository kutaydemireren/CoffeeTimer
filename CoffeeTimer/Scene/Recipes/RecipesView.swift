//
//  RecipesView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 10/05/2023.
//

import SwiftUI
import Combine

extension Recipe: Identifiable{
	var id: String {
		recipeProfile.id
	}
}

extension RecipeProfile: Identifiable {
	var id: String {
		name + "_" + icon.id
	}
}

extension RecipeProfileIcon: Identifiable {
	var id: String {
		title
	}
}

final class RecipesViewModel: ObservableObject, Completable {
	var didComplete = PassthroughSubject<RecipesViewModel, Never>()
	var didCreate = PassthroughSubject<RecipesViewModel, Never>()

	@Published var recipes: [Recipe] = []

	private let repository: RecipeRepository

	init(repository: RecipeRepository = RecipeRepositoryImp()) {
		self.repository = repository

		recipes = repository.getSavedRecipes()
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
		return RecipesView(viewModel: recipeVM)
	}
}

