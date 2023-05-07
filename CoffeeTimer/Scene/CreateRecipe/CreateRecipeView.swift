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

	var createRecipeFromContextUseCase: CreateRecipeFromContextUseCase

	init(createRecipeFromContextUseCase: CreateRecipeFromContextUseCase = CreateRecipeFromContextUseCaseImp(createV60SingleCupRecipeUseCase: CreateV60SingleCupRecipeUseCaseImp(), createV60SingleCupContextToInputsMapper: CreateV60SingleCupContextToInputsMapperImp())) {
		self.createRecipeFromContextUseCase = createRecipeFromContextUseCase
	}

	func nextPage() {
		selectedPage = (selectedPage % pageCount) + 1
	}

	func canCreate(from context: CreateRecipeContext) -> Bool {
		context.selectedBrewMethod != nil &&
		context.selectedRecipeProfile != nil &&
		!context.recipeName.isEmpty &&
		context.cupsCountAmount > 0
	}

	func create(from context: CreateRecipeContext) {
		let recipe = createRecipeFromContextUseCase.create(from: context)
		BrewQueueRepositoryImp.selectedRecipe = recipe
	}
}

struct CreateRecipeView: View {

	@ObservedObject var viewModel: CreateRecipeViewModel
	@EnvironmentObject var context: CreateRecipeContext
	var closeRequest: () -> Void

	let gridCache = GridCache(title: MockTitleStorage.randomTitle, recipeProfiles: MockStore.recipeProfiles)

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

				CreateRecipeProfileSelection(recipeName: $context.recipeName, selectedRecipeProfile: $context.selectedRecipeProfile, gridCache: gridCache)
					.tag(2)

				CreateRecipeCoffeeWaterSelection(cupsCountAmount: $context.cupsCountAmount, ratio: $context.ratio)
					.tag(3)
			}
			.tabViewStyle(.page(indexDisplayMode: .never))
			.ignoresSafeArea()
		}
		.onChange(of: context.selectedBrewMethod, perform: didUpdate(_:))
		.onChange(of: context.recipeName, perform: didUpdate(_:))
		.onChange(of: context.selectedRecipeProfile, perform: didUpdate(_:))
		.onChange(of: context.cupsCountAmount, perform: didUpdate(_:))
		.onChange(of: context.ratio, perform: didUpdate(_:))
		.backgroundPrimary()
	}

	private func didUpdate(_ selectedBrewMethod: BrewMethod?) {
		checkIfCanCreate()
	}

	private func didUpdate(_ recipeName: String) {
		checkIfCanCreate()
	}

	private func didUpdate(_ selectedRecipeProfile: RecipeProfile?) {
		checkIfCanCreate()
	}

	private func didUpdate(_ cupsCountAmount: Double) {
		checkIfCanCreate()
	}

	private func didUpdate(_ ratio: CoffeeToWaterRatio) {
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
