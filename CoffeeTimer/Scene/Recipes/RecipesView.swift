//
//  RecipesView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 10/05/2023.
//

import SwiftUI
import Combine

// TODO: Move

extension UIColor {
	var hexString: String? {
		return Color(uiColor: self).hexString
	}
}

extension Color {
	var hexString: String? {

		guard let components = UIColor(self).cgColor.components else {
			return nil
		}

		let red = Int(components[0] * 255.0)
		let green = Int(components[1] * 255.0)
		let blue = Int(components[2] * 255.0)

		return String(format: "#%02X%02X%02X", red, green, blue)
	}

	init?(hexString: String) {
		var formattedHex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
		if formattedHex.count == 6 {
			formattedHex = "FF" + formattedHex
		}

		var hexValue: UInt64 = 0
		guard Scanner(string: formattedHex).scanHexInt64(&hexValue) else {
			return nil
		}

		let red = Double((hexValue & 0xFF0000) >> 16) / 255.0
		let green = Double((hexValue & 0x00FF00) >> 8) / 255.0
		let blue = Double(hexValue & 0x0000FF) / 255.0

		self.init(red: red, green: green, blue: blue)
	}
}

// TODO: Move

extension Recipe: Identifiable {
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

//

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

