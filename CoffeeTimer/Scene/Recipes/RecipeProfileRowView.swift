//
//  RecipeProfileRowView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 10/05/2023.
//

import SwiftUI

struct RecipeProfileRowView: View {

	let recipeProfile: RecipeProfile

	var body: some View {
		VStack {
			Spacer(minLength: 4)

			RecipeProfileView(recipeProfile: recipeProfile)
				.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
				.padding(.horizontal)
				.padding(.vertical, 12)
				.backgroundSecondary()

			Spacer(minLength: 4)
		}
		.listRowSeparator(.hidden)
		.listRowBackground(Color.clear)
	}
}

struct RecipeProfileRowView_Previews: PreviewProvider {
	static var previews: some View {
		RecipeProfileRowView(recipeProfile: .stub)
	}
}
