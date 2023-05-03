//
//  CreateRecipeView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 05/04/2023.
//

import SwiftUI

final class CreateRecipeViewModel: ObservableObject {
	func canCreate(from context: CreateRecipeContext) -> Bool {
		!context.recipeName.isEmpty && context.coffeeAmount > 0 && context.waterAmount > 0
	}
}

struct CreateRecipeView: View {
	@ObservedObject var viewModel: CreateRecipeViewModel
	@EnvironmentObject var context: CreateRecipeContext
	var closeRequest: () -> Void

	@State private var selectedPage = 1
	@State private var canCreate = false

	var body: some View {

		VStack {
			HStack {
				Button("Close", action: closeRequest)
					.frame(alignment: .topLeading)
					.foregroundColor(.white)

				Spacer()

				if !canCreate {
					Button("Next") {
						withAnimation { selectedPage = 2 }
					}
					.foregroundColor(.white)
				} else {
					Button("Done") {
						// TODO: Temp
						let inputs = CreateV60SingleCupRecipeInputs(
							name: context.recipeName,
							coffee: .init(amount: UInt(context.coffeeAmount), type: .gram),
							water: .init(amount: UInt(context.waterAmount), type: .gram)
						)
						BrewQueueRepositoryImp.selectedRecipe = CreateV60SingleCupRecipeUseCaseImp().create(inputs: inputs)

						closeRequest()
					}
					.foregroundColor(.white)
				}
			}
			.padding()

			TabView(selection: $selectedPage) {
				CreateRecipeNameSelection(recipeName: $context.recipeName)
					.tag(1)

				CreateRecipeCoffeeWaterSelection(coffeeAmount: $context.coffeeAmount, waterAmount: $context.waterAmount)
					.tag(2)
			}
			.tabViewStyle(.page(indexDisplayMode: .never))
			.ignoresSafeArea()
		}
		.onChange(of: context.recipeName, perform: didUpdate(recipe:))
		.onChange(of: context.coffeeAmount, perform: didUpdate(coffeeAmount:))
		.onChange(of: context.waterAmount, perform: didUpdate(waterAmount:))
		.backgroundPrimary()
	}

	private func didUpdate(recipe: String) {
		checkIfCanCreate()
	}

	private func didUpdate(coffeeAmount: Double) {
		checkIfCanCreate()
	}

	private func didUpdate(waterAmount: Double) {
		checkIfCanCreate()
	}

	private func checkIfCanCreate() {
		canCreate = viewModel.canCreate(from: context)
	}
}

struct CreateRecipeView_Previews: PreviewProvider {
	static var previews: some View {
		CreateRecipeView(viewModel: .init(), closeRequest: { })
			.environmentObject(CreateRecipeContext())
	}
}
