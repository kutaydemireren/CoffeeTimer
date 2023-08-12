//
//  RecipeRowView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 10/05/2023.
//

import SwiftUI

struct RecipeProfileIconView: View {
	let recipeProfileIcon: RecipeProfileIcon
	var isSelected = false

	var body: some View {
		if !recipeProfileIcon.imageName.isEmpty {
			Image(recipeProfileIcon.imageName)
				.resizable()
				.aspectRatio(contentMode: .fit)
				.foregroundColor(Color("foregroundPrimary"))
				.opacity(isSelected ? 1.0 : 0.4)
		}
	}
}

struct RecipeProfileView: View {
	let recipeProfile: RecipeProfile

	var body: some View {
		HStack {
			RecipeProfileIconView(recipeProfileIcon: recipeProfile.icon, isSelected: true)
				.frame(maxHeight: 25)
			Text(recipeProfile.name)
				.foregroundColor(Color("foregroundPrimary"))
				.bold()
		}
	}
}

struct RecipeRowView: View {

	let recipe: Recipe

	var body: some View {
		VStack {
			RecipeProfileView(recipeProfile: recipe.recipeProfile)
			Text(recipe.ingredients.toRepresentableString)
				.foregroundColor(Color("foregroundPrimary"))
				.padding(.leading)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
		.padding(.horizontal)
		.backgroundSecondary()
		.listRowSeparator(.hidden)
		.listRowBackground(Color.clear)
	}
}

struct RecipeRowView_Previews: PreviewProvider {
	static var previews: some View {
		VStack {
			RecipeRowView(recipe: .stubSingleV60)
		}
		.frame(height: 125)
	}
}
