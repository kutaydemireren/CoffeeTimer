//
//  CreateRecipeProfileSelection.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 16/04/2023.
//

import SwiftUI

struct RecipeProfileView: View {
	let recipeProfile: RecipeProfile

	var isSelected = false

	var body: some View {
		if let image = recipeProfile.image {
			VStack {
				Image(uiImage: image)
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(width: 35)
			}
			.padding()
			.foregroundColor(.white.opacity(0.8))
			.background {
				Circle()
					.fill(Color(recipeProfile.color.withAlphaComponent(isSelected ? 0.8 : 0.4)))
			}
		}
	}
}

struct RecipeProfile: Identifiable, Equatable {
	let id = UUID()
	let title: String
	let color: UIColor
	let image: UIImage?

	init(title: String, color: UIColor) {
		self.title = title
		self.color = color
		self.image = UIImage(named: "recipe-profile-\(title)")
	}
}

// TODO: Obviously, temp
extension MockStore {
	static var recipeProfiles = [
		RecipeProfile(title: "planet", color: .magenta),
		RecipeProfile(title: "moon", color: .brown),
		RecipeProfile(title: "nuclear", color: .orange),
		RecipeProfile(title: "rocket", color: .purple)
	]
}

struct CreateRecipeProfileSelection: View {

	@Binding var recipeName: String
	@Binding var selectedRecipeProfile: RecipeProfile?

	let columns: [GridItem] = [
		GridItem(.flexible()),
		GridItem(.flexible()),
		GridItem(.flexible()),
	]
	let recipeProfiles: [RecipeProfile] = MockStore.recipeProfiles

	var body: some View {
		VStack {

			VStack {
				LazyVGrid(columns: columns, spacing: 16) {
					ForEach(recipeProfiles) { recipeProfile in
						RecipeProfileView(
							recipeProfile: recipeProfile,
							isSelected: selectedRecipeProfile == recipeProfile
						)
						.onTapGesture {
							selectedRecipeProfile = recipeProfile
						}
					}
				}

				Separator()

				AlphanumericTextField(title: "Name your recipe", placeholder: "V60 Magic", text: $recipeName)
					.multilineTextAlignment(.center)
					.clearButton(text: $recipeName)
			}

			Spacer()
		}
		.padding(.horizontal, 32)
		.contentShape(Rectangle())
		.onTapGesture {
			hideKeyboard()
		}
	}
}

struct CreateRecipeProfileSelection_Previews: PreviewProvider {
	static var previews: some View {
		CreateRecipeProfileSelection(recipeName: .constant(""), selectedRecipeProfile: .constant(MockStore.recipeProfiles[0]))
			.backgroundPrimary()
	}
}
