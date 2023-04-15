//
//  CreateRecipeView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 05/04/2023.
//

import SwiftUI

struct CreateRecipeView: View {

	@State private var selectedPage = 1

	var body: some View {

		TabView(selection: $selectedPage) {

			CreateRecipeNameSelection {
				withAnimation { selectedPage = 2 }
			}
			.tag(1)

			CreateRecipeCoffeeWaterSelection()
				.tag(2)
		}
		.tabViewStyle(.page(indexDisplayMode: .never))
		.ignoresSafeArea()
	}
}

struct CreateRecipeView_Previews: PreviewProvider {
	static var previews: some View {
		CreateRecipeView()
	}
}
