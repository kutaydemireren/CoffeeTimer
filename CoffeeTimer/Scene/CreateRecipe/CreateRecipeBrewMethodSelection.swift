//
//  CreateRecipeBrewMethodSelection.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 16/04/2023.
//

import SwiftUI

struct BrewMethodView: View {
	let title: String
	var body: some View {
		VStack {
			RoundedRectangle(cornerRadius: 12)
				.fill(Color.white.opacity(0.3))
				.overlay {
					Text(title)
						.font(.title2)
				}
		}
	}
}

struct BrewMethod: Identifiable {
	let id = UUID()
	let title: String
}

// TODO: Obviously, temp
struct MockStore {
	static var brewMethods = [
		BrewMethod(title: "V60 For 1 Cup"),
		BrewMethod(title: "V60"),
		BrewMethod(title: "Chemex"),
		BrewMethod(title: "Melitta"),
		BrewMethod(title: "French Press")
	]
}

struct CreateRecipeBrewMethodSelection: View {

	let columns: [GridItem] = [
		GridItem(.flexible()),
		GridItem(.flexible()),
	]
	let height: CGFloat = 150
	let brewMethods: [BrewMethod] = MockStore.brewMethods

	var body: some View {
		ScrollView {
			// 4. Populate into grid
			LazyVGrid(columns: columns, spacing: 16) {
				ForEach(brewMethods) { brewMethod in
					BrewMethodView(title: brewMethod.title)
						.frame(height: height)
				}
			}
			.padding()
		}
	}
}

struct CreateRecipeBrewMethodSelection_Previews: PreviewProvider {
    static var previews: some View {
		CreateRecipeBrewMethodSelection()
			.backgroundPrimary()
    }
}
