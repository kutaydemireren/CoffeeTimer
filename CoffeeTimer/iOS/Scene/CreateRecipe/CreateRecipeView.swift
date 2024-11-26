//
//  CreateRecipeView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 05/04/2023.
//

import SwiftUI

@MainActor
final class CreateRecipeViewModel: ObservableObject {
    private let pageCount = 3

    @Published var selectedPage = 1
    @Published var brewMethods: [BrewMethod] = []
    @Published var allRatios: [CoffeeToWaterRatio] = []
    @Published var canCreate = false

    private var createRecipeFromContextUseCase: CreateRecipeFromContextUseCase
    private var recipeRepository: RecipeRepository // TODO: use case - no repo in vm!
    private var getBrewMethodsUseCase: GetBrewMethodsUseCase

    init(
        createRecipeFromContextUseCase: CreateRecipeFromContextUseCase = CreateRecipeFromContextUseCaseImp(),
        recipeRepository: RecipeRepository = RecipeRepositoryImp.shared,
        getBrewMethodsUseCase: GetBrewMethodsUseCase = GetBrewMethodsUseCaseImp()
    ) {
        self.createRecipeFromContextUseCase = createRecipeFromContextUseCase
        self.recipeRepository = recipeRepository
        self.getBrewMethodsUseCase = getBrewMethodsUseCase

        refreshBrewMethods()
    }

    func refreshBrewMethods() {
        Task {
            self.brewMethods = try await getBrewMethodsUseCase.getAll()
        }
    }

    func nextPage(in context: CreateRecipeContext) {
        var newSelectedPage = 1

        if selectedPage < pageCount {
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

        return pageCount
    }

    func canCreate(from context: CreateRecipeContext) -> Bool {
        do {
            return try createRecipeFromContextUseCase.canCreate(from: context)
        } catch {
            return false
        }
    }

    private func resetRatiosIfNeeded(_ context: CreateRecipeContext) {
        let newRatios = context.selectedBrewMethod?.ratios
        if let newRatios, newRatios != allRatios {
            self.allRatios = newRatios
            context.ratio = nil
        }
    }

    func create(from context: CreateRecipeContext) {
        Task {
            guard let recipe = await createRecipeFromContextUseCase.create(from: context) else {
                // TODO: throw and handle
                return
            }

            recipeRepository.save(recipe)
        }
    }

    func didUpdate(context: CreateRecipeContext) {
        resetRatiosIfNeeded(context)
        canCreate = canCreate(from: context)
    }
}

struct CreateRecipeView: View {
    @StateObject var viewModel: CreateRecipeViewModel
    @EnvironmentObject var context: CreateRecipeContext

    var close: () -> Void
    var createMethod: () -> Void

    var body: some View {
        PagerView(
            selectedPage: $viewModel.selectedPage,
            canCreate: $viewModel.canCreate,
            close: close,
            create: {
                viewModel.create(from: context)
            },
            nextPage: {
                withAnimation { viewModel.nextPage(in: context) }
            },
            content: {
                // Wrapping in ZStack helps with the scrolling animation amongst pages
                ZStack {
                    CreateRecipeBrewMethodSelection(
                        brewMethods: $viewModel.brewMethods,
                        selectedBrewMethod: $context.selectedBrewMethod,
                        createMethod: createMethod
                    )
                }
                .tag(1)

                ZStack {
                    CreateRecipeProfileSelection(
                        recipeProfile: $context.recipeProfile
                    )
                }
                .tag(2)

                ZStack {
                    CreateRecipeCoffeeWaterSelection(
                        cupsCountAmount: $context.cupsCount,
                        selectedRatio: $context.ratio,
                        allRatios: $viewModel.allRatios
                    )
                }
                .tag(3)
            }
        )
        .onChange(of: context.selectedBrewMethod, perform: didUpdate(_:))
        .onChange(of: context.recipeProfile, perform: didUpdate(_:))
        .onChange(of: context.cupsCount, perform: didUpdate(_:))
        .onChange(of: context.ratio, perform: didUpdate(_:))
    }

    private func didUpdate<T>(_ newValue: T) {
        viewModel.didUpdate(context: context)
    }
}

struct CreateRecipeView_Previews: PreviewProvider {
    static var previews: some View {
        CreateRecipeView(viewModel: .init(), close: { }, createMethod: { })
            .environmentObject(CreateRecipeContext())
    }
}
