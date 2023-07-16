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
	@Published var allRatios: [CoffeeToWaterRatio] = []

	private var createRecipeFromContextUseCase: CreateRecipeFromContextUseCase
	private var getRatiosUseCase: GetRatiosUseCase
	private var recipeRepository: RecipeRepository // TODO: use case - no repo in vm!

	init(
		createRecipeFromContextUseCase: CreateRecipeFromContextUseCase = CreateRecipeFromContextUseCaseImp(),
		recipeRepository: RecipeRepository = RecipeRepositoryImp(),
		getRatiosUseCase: GetRatiosUseCase = GetRatiosUseCaseImp()
	) {
		self.createRecipeFromContextUseCase = createRecipeFromContextUseCase
		self.recipeRepository = recipeRepository
		self.getRatiosUseCase = getRatiosUseCase
	}

	func nextPage(in context: CreateRecipeContext) {
		var newSelectedPage = 1

		if selectedPage < 3 {
			newSelectedPage = (selectedPage % pageCount) + 1
		} else {
			newSelectedPage = getNextMissingPage(in: context)
		}

		selectedPage = newSelectedPage
	}

	private func getNextMissingPage(in context: CreateRecipeContext) -> Int {
		do {
			let _ = try createRecipeFromContextUseCase.canCreate(from: context)
		} catch let error as CreateRecipeFromContextUseCaseError {
			switch error {
			case .missingBrewMethod:
				return 1
			case .missingRecipeProfile:
				return 2
			case .missingCupsCount, .missingRatio:
				return 3
			}
		} catch _ {
			// Unknown error
		}

		// No missing, return last page
		return 3
	}

	func canCreate(from context: CreateRecipeContext) -> Bool {
		// TODO: Extract below to separate functionality
		let newRatios = getRatiosUseCase.ratios(for: context.selectedBrewMethod)
		if newRatios != allRatios {
			self.allRatios = newRatios
			context.ratio = nil
		}

		do {
			return try createRecipeFromContextUseCase.canCreate(from: context)
		} catch {
			return false
		}
	}

	func create(from context: CreateRecipeContext) {
		guard let recipe = createRecipeFromContextUseCase.create(from: context) else {
			// TODO: `throw` from create(?) or handle by having nil(?)
			return
		}

		recipeRepository.save(recipe)
	}
}

struct CreateRecipeView: View {

	@ObservedObject var viewModel: CreateRecipeViewModel
	@EnvironmentObject var context: CreateRecipeContext
	var closeRequest: () -> Void

	let gridCache = GridCache(title: TitleStorage.randomFunTitle, recipeProfileIcons: ProfileIconStorage.recipeProfileIcons)

	@State private var canCreate = false

	var body: some View {

		VStack {
			HStack {
				Button("Close", action: closeRequest)
					.frame(alignment: .topLeading)

				Spacer()

				if !canCreate {
					Button("Next") {
						withAnimation { viewModel.nextPage(in: context) }
					}
				} else {
					Button("Done") {
						viewModel.create(from: context)
						closeRequest()
					}
				}
			}
			.padding()
			.foregroundColor(Color("backgroundSecondary"))

			TabView(selection: $viewModel.selectedPage) {

				CreateRecipeBrewMethodSelection(selectedBrewMethod: $context.selectedBrewMethod)
					.tag(1)

				CreateRecipeProfileSelection(recipeProfile: $context.recipeProfile, gridCache: gridCache)
					.tag(2)

				CreateRecipeCoffeeWaterSelection(cupsCountAmount: $context.cupsCount, selectedRatio: $context.ratio, allRatios: $viewModel.allRatios)
					.tag(3)
			}
			.tabViewStyle(.page(indexDisplayMode: .never))
			.ignoresSafeArea()
		}
		.onChange(of: context.selectedBrewMethod, perform: didUpdate(_:))
		.onChange(of: context.recipeProfile, perform: didUpdate(_:))
		.onChange(of: context.cupsCount, perform: didUpdate(_:))
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

	private func didUpdate(_ ratio: CoffeeToWaterRatio?) {
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
