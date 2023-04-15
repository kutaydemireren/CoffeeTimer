//
//  CreateRecipeView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 05/04/2023.
//

import SwiftUI

struct CreateRecipeView: View {

	var closeRequest: () -> Void

	@State var recipeName: String = ""
	@State var coffeeAmount = 0.0
	@State var waterAmount = 0.0

	@State private var selectedPage = 1
	@State private var done = false

	var body: some View {

		VStack {
			HStack {
				Button("Close", action: closeRequest)
					.frame(alignment: .topLeading)
					.foregroundColor(.white)

				Spacer()

				if selectedPage < 2 {
					Button("Next") {
						withAnimation { selectedPage = 2 }
					}
					.foregroundColor(.white)
				} else {
					Button("Done") {
						// TODO: Temp
						let inputs = CreateV60SingleCupRecipeInputs(
							name: recipeName,
							coffee: .init(amount: UInt(coffeeAmount), type: .gram),
							water: .init(amount: UInt(waterAmount), type: .gram)
						)
						BrewQueueRepositoryImp.selectedRecipe = CreateV60SingleCupRecipeUseCaseImp().create(inputs: inputs)

						closeRequest()
					}
					.disabled(!done)
					.foregroundColor(.white)
				}
			}
			.padding()

			TabView(selection: $selectedPage) {
				CreateRecipeNameSelection(recipeName: $recipeName)
					.tag(1)

				CreateRecipeCoffeeWaterSelection(coffeeAmount: $coffeeAmount, waterAmount: $waterAmount)
					.tag(2)
			}
			.tabViewStyle(.page(indexDisplayMode: .never))
			.ignoresSafeArea()
		}
		.onChange(of: recipeName, perform: didUpdate(recipe:))
		.onChange(of: coffeeAmount, perform: didUpdate(coffeeAmount:))
		.onChange(of: waterAmount, perform: didUpdate(waterAmount:))
		.backgroundPrimary()
	}

	private func didUpdate(recipe: String) {
		check()
	}

	private func didUpdate(coffeeAmount: Double) {
		check()
	}

	private func didUpdate(waterAmount: Double) {
		check()
	}

	// TODO: Rename
	private func check() {
		done = !recipeName.isEmpty && coffeeAmount > 0 && waterAmount > 0
	}
}

struct CreateRecipeView_Previews: PreviewProvider {
	static var previews: some View {
		CreateRecipeView(closeRequest: { })
	}
}
