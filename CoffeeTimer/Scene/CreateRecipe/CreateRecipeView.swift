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

	private var createRecipeFromContextUseCase: CreateRecipeFromContextUseCase
	private var recipeRepository: RecipeRepository // TODO: use case - no repo in vm!

	init(
		createRecipeFromContextUseCase: CreateRecipeFromContextUseCase = CreateRecipeFromContextUseCaseImp(),
		recipeRepository: RecipeRepository = RecipeRepositoryImp()
	) {
		self.createRecipeFromContextUseCase = createRecipeFromContextUseCase
		self.recipeRepository = recipeRepository
	}

	func nextPage() {
		selectedPage = (selectedPage % pageCount) + 1
	}

	func canCreate(from context: CreateRecipeContext) -> Bool {
		context.selectedBrewMethod != nil &&
		!context.recipeProfile.isEmpty &&
		!context.recipeProfile.name.isEmpty &&
		context.cupsCountAmount > 0
	}

	func create(from context: CreateRecipeContext) {
		if let recipe = createRecipeFromContextUseCase.create(from: context) {
			recipeRepository.save(recipe)
		} else {
			// TODO
		}
	}
}

struct CreateRecipeView: View {

	@ObservedObject var viewModel: CreateRecipeViewModel
	@EnvironmentObject var context: CreateRecipeContext
	var closeRequest: () -> Void

	let gridCache = GridCache(title: MockTitleStorage.randomTitle, recipeProfileIcons: MockStore.recipeProfileIcons)

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

				CreateRecipeProfileSelection(recipeProfile: $context.recipeProfile, gridCache: gridCache)
					.tag(2)

				CreateRecipeCoffeeWaterSelection(cupsCountAmount: $context.cupsCountAmount, ratio: $context.ratio)
					.tag(3)
			}
			.tabViewStyle(.page(indexDisplayMode: .never))
			.ignoresSafeArea()
		}
		.onChange(of: context.selectedBrewMethod, perform: didUpdate(_:))
		.onChange(of: context.recipeProfile, perform: didUpdate(_:))
		.onChange(of: context.cupsCountAmount, perform: didUpdate(_:))
		.onChange(of: context.ratio, perform: didUpdate(_:))
		.backgroundPrimary()
	}

	private func didUpdate(_ selectedBrewMethod: BrewMethod?) {
		checkIfCanCreate()
	}

	private func didUpdate(_ recipeProfile: RecipeProfile?) {
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
