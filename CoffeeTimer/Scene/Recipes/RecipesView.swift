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

			VStack {
				Spacer(minLength: 4)

				RecipeProfileView(recipeProfile: recipe.recipeProfile)
					.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
					.padding(.horizontal)
					.padding(.vertical, 12)
					.backgroundSecondary()

				Spacer(minLength: 4)
			}
			.listRowSeparator(.hidden)
			.listRowBackground(Color.clear)
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

