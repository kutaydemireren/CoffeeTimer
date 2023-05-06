//
//  CreateRecipeView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 05/04/2023.
//

import SwiftUI

final class CreateRecipeViewModel: ObservableObject {
	private let pageCount = 3

	@Published var selectedPage = 1

	func nextPage() {
		selectedPage = (selectedPage % pageCount) + 1
	}

	func canCreate(from context: CreateRecipeContext) -> Bool {
		context.selectedBrewMethod != nil &&
		!context.recipeName.isEmpty &&
		context.coffeeAmount > 0 &&
		context.waterAmount > 0
	}

	func create(from context: CreateRecipeContext) {
		let inputs = CreateV60SingleCupRecipeInputs(
			name: context.recipeName,
			coffee: .init(amount: UInt(context.coffeeAmount), type: .gram),
			water: .init(amount: UInt(context.waterAmount), type: .gram)
		)
		BrewQueueRepositoryImp.selectedRecipe = CreateV60SingleCupRecipeUseCaseImp().create(inputs: inputs)
	}
}

struct CreateRecipeView: View {

	@ObservedObject var viewModel: CreateRecipeViewModel
	@EnvironmentObject var context: CreateRecipeContext
	var closeRequest: () -> Void

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
						withAnimation { viewModel.nextPage() }
					}
					.foregroundColor(.white)
				} else {
					Button("Done") {
						viewModel.create(from: context)
						closeRequest()
					}
					.foregroundColor(.white)
				}
			}
			.padding()

			TabView(selection: $viewModel.selectedPage) {

				CreateRecipeBrewMethodSelection(selectedBrewMethod: $context.selectedBrewMethod)
					.tag(1)

				CreateRecipeNameSelection(recipeName: $context.recipeName)
					.tag(2)

				CreateRecipeCoffeeWaterSelection(coffeeAmount: $context.coffeeAmount, waterAmount: $context.waterAmount)
					.tag(3)
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
