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

    @StateObject var viewModel: CreateRecipeViewModel
    @EnvironmentObject var context: CreateRecipeContext
    var close: () -> Void
    var createMethod: () -> Void

    @State private var canCreate = false

    var body: some View {

        VStack {
            HStack {
                Button("Close", action: close)
                    .frame(alignment: .topLeading)

                Spacer()

                if canCreate {
                    Button("Save") {
                        viewModel.create(from: context)
                        close()
                    }
                } else {
                    Button("Next") {
                        withAnimation { viewModel.nextPage(in: context) }
                    }
                }
            }
            .padding()
            .foregroundColor(Color("backgroundSecondary"))

            TabView(selection: $viewModel.selectedPage) {

                ZStack {
                    CreateRecipeBrewMethodSelection(brewMethods: $viewModel.brewMethods, selectedBrewMethod: $context.selectedBrewMethod)

                    customMethodAction()
                }
                .tag(1)

                CreateRecipeProfileSelection(recipeProfile: $context.recipeProfile)
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

    @ViewBuilder
    private func customMethodAction() -> some View {

        HStack {
            VStack {
                Spacer()

                Button(action: createMethod) {
                    HStack {
                        Image(uiImage: .add)
                            .renderingMode(.template)

                        Text("Create your own method")
                    }
                    .foregroundColor(Color("foregroundPrimary"))
                }
                .padding()
                .backgroundSecondary(opacity: 0.6)
            }
        }
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
        CreateRecipeView(viewModel: .init(), close: { }, createMethod: { })
            .environmentObject(CreateRecipeContext())
    }
}
