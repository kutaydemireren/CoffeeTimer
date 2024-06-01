//
//  CreateRecipeView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 05/04/2023.
//

import SwiftUI

// TODO: move

protocol GetBrewMethodsUseCase {
    func getAll() -> [BrewMethod]
}

struct GetBrewMethodsUseCaseImp: GetBrewMethodsUseCase {
    func getAll() -> [BrewMethod] {
        BrewMethodStorage.brewMethods
    }
}

//

@MainActor
final class CreateRecipeViewModel: ObservableObject {
    private let pageCount = 3

    @Published var selectedPage = 1
    @Published var brewMethods: [BrewMethod] = []
    @Published var allRatios: [CoffeeToWaterRatio] = []

    private var createRecipeFromContextUseCase: CreateRecipeFromContextUseCase
    private var getRatiosUseCase: GetRatiosUseCase
    private var recipeRepository: RecipeRepository // TODO: use case - no repo in vm!

    init(
        createRecipeFromContextUseCase: CreateRecipeFromContextUseCase = CreateRecipeFromContextUseCaseImp(),
        recipeRepository: RecipeRepository = RecipeRepositoryImp.shared,
        getBrewMethodsUseCase: GetBrewMethodsUseCase = GetBrewMethodsUseCaseImp(),
        getRatiosUseCase: GetRatiosUseCase = GetRatiosUseCaseImp() // TODO: remove, no longer needed
    ) {
        self.createRecipeFromContextUseCase = createRecipeFromContextUseCase
        self.recipeRepository = recipeRepository
        self.getRatiosUseCase = getRatiosUseCase
        self.brewMethods = getBrewMethodsUseCase.getAll()
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
        let newRatios = context.selectedBrewMethod?.ratios
        if let newRatios, newRatios != allRatios {
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
        Task {
            guard let recipe = await createRecipeFromContextUseCase.create(from: context) else {
                // TODO: throw and handle
                return
            }

            recipeRepository.save(recipe)
        }
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

                CreateRecipeBrewMethodSelection(brewMethods: $viewModel.brewMethods, selectedBrewMethod: $context.selectedBrewMethod)
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

    private func didUpdate<T>(_ context: T?) {
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
