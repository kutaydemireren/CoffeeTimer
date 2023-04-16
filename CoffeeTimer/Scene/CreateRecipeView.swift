//
//  CreateRecipeView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 05/04/2023.
//

import SwiftUI

final class CreateRecipeViewModel: ObservableObject {

	@Published var recipeName: String = ""
	@Published var coffeeAmount = 0.0
	@Published var waterAmount = 0.0

	func canCreate() -> Bool {
		!recipeName.isEmpty && coffeeAmount > 0 && waterAmount > 0
	}
}

struct CreateRecipeView: View {

	@State private var selectedPage = 1
	@State private var canCreate = false

	@ObservedObject var viewModel: CreateRecipeViewModel

	var closeRequest: () -> Void

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
							name: viewModel.recipeName,
							coffee: .init(amount: UInt(viewModel.coffeeAmount), type: .gram),
							water: .init(amount: UInt(viewModel.waterAmount), type: .gram)
						)
						BrewQueueRepositoryImp.selectedRecipe = CreateV60SingleCupRecipeUseCaseImp().create(inputs: inputs)

						closeRequest()
					}
					.disabled(!canCreate)
					.foregroundColor(.white)
				}
			}
			.padding()

			TabView(selection: $selectedPage) {
				CreateRecipeNameSelection(recipeName: $viewModel.recipeName)
					.tag(1)

				CreateRecipeCoffeeWaterSelection(coffeeAmount: $viewModel.coffeeAmount, waterAmount: $viewModel.waterAmount)
					.tag(2)
			}
			.tabViewStyle(.page(indexDisplayMode: .never))
			.ignoresSafeArea()
		}
		.onChange(of: viewModel.recipeName, perform: didUpdate(recipe:))
		.onChange(of: viewModel.coffeeAmount, perform: didUpdate(coffeeAmount:))
		.onChange(of: viewModel.waterAmount, perform: didUpdate(waterAmount:))
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

	// TODO: Rename
	private func checkIfCanCreate() {
		canCreate = viewModel.canCreate()
	}
}

struct CreateRecipeView_Previews: PreviewProvider {
	static var previews: some View {
		CreateRecipeView(viewModel: .init(), closeRequest: { })
	}
}
