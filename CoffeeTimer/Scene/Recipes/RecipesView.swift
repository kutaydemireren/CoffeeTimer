//
//  RecipesView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 10/05/2023.
//

import SwiftUI

final class RecipesViewModel: ObservableObject {
	@Published var recipes: [Recipe] = []
}

struct RecipesView: View {

	@ObservedObject var viewModel: RecipesViewModel

	var body: some View {
		List(viewModel.recipes) { recipe in
			RecipeProfileRowView(recipeProfile: recipe.recipeProfile)
		}
		.backgroundPrimary()
		.scrollIndicators(.hidden)
		.scrollContentBackground(.hidden)
	}
}

struct RecipesView_Previews: PreviewProvider {
	static var previews: some View {
		let recipeVM = RecipesViewModel()
		recipeVM.recipes = MockStore.savedRecipes
		return RecipesView(viewModel: recipeVM)
	}
}

