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
		VStack {
			RoundedRectangle(cornerRadius: 12)
				.fill(isSelected ? .white.opacity(0.8) : .white.opacity(0.2))
				.overlay {
					if let image = recipeProfile.image {
						Image(uiImage: image)
							.foregroundColor(isSelected ? .black.opacity(0.8) : .white.opacity(0.8))
					}
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
		RecipeProfile(title: "planet", color: .green),
		RecipeProfile(title: "moon",color: .blue),
		RecipeProfile(title: "nuclear",color: .yellow),
		RecipeProfile(title: "rocket",color: .purple)
	]
}

struct CreateRecipeProfileSelection: View {

	@Binding var recipeName: String
	@Binding var selectedRecipeProfile: RecipeProfile?

	let columns: [GridItem] = [
		GridItem(.flexible()),
		GridItem(.flexible()),
	]
	let height: CGFloat = 150
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
						.frame(height: height)
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
		CreateRecipeProfileSelection(recipeName: .constant(""), selectedRecipeProfile: .constant(MockStore.recipeProfiles.first!))
			.backgroundPrimary()
	}
}
