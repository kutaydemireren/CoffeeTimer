//
//  CreateRecipeView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 05/04/2023.
//

import SwiftUI

enum CreateRecipeMissingField {
    case brewMethod
    case recipeProfile
    case cupsCount
    case ratio
}

@MainActor
final class CreateRecipeViewModel: ObservableObject {
    private let pageCount = 3

    @Published var selectedPage = 1
    @Published var brewMethods: [BrewMethod] = []
    @Published var allRatios: [CoffeeToWaterRatio] = []
    @Published var canCreate = false
    
    @Published var animateBrewMethod = false
    @Published var animateRecipeProfile = false
    @Published var animateCupsCount = false
    @Published var animateRatio = false

    private var createRecipeFromContextUseCase: CreateRecipeFromContextUseCase
    private var recipeRepository: RecipeRepository // TODO: use case - no repo in vm!
    private var getBrewMethodsUseCase: GetBrewMethodsUseCase
    private var removeBrewMethodUseCase: RemoveBrewMethodUseCase
    private var analyticsTracker: AnalyticsTracker

    init(
        createRecipeFromContextUseCase: CreateRecipeFromContextUseCase = CreateRecipeFromContextUseCaseImp(),
        recipeRepository: RecipeRepository = RecipeRepositoryImp.shared,
        getBrewMethodsUseCase: GetBrewMethodsUseCase = GetBrewMethodsUseCaseImp(),
        removeBrewMethodUseCase: RemoveBrewMethodUseCase = RemoveBrewMethodUseCaseImp(),
        analyticsTracker: AnalyticsTracker = AnalyticsTrackerImp()
    ) {
        self.createRecipeFromContextUseCase = createRecipeFromContextUseCase
        self.recipeRepository = recipeRepository
        self.getBrewMethodsUseCase = getBrewMethodsUseCase
        self.removeBrewMethodUseCase = removeBrewMethodUseCase
        self.analyticsTracker = analyticsTracker

        refreshBrewMethods()
        analyticsTracker.track(event: AnalyticsEvent(name: "create_recipe_opened"))
    }

    func refreshBrewMethods() {
        Task {
            self.brewMethods = try await getBrewMethodsUseCase.getAll()
        }
    }

    func nextPage(in context: CreateRecipeContext) {
        var newSelectedPage = 1
        var missingField: CreateRecipeMissingField?

        if selectedPage < pageCount {
            newSelectedPage = (selectedPage % pageCount) + 1
        } else {
            let result = getNextMissingPage(in: context)
            newSelectedPage = result.page
            missingField = result.missingField
        }

        selectedPage = newSelectedPage
        
        if let missingField = missingField {
            triggerAnimation(for: missingField)
        }
    }
    
    private func triggerAnimation(for field: CreateRecipeMissingField) {
        animateBrewMethod = false
        animateRecipeProfile = false
        animateCupsCount = false
        animateRatio = false
        
        // Small delay to wait for page transition
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            switch field {
            case .brewMethod:
                self?.animateBrewMethod = true
            case .recipeProfile:
                self?.animateRecipeProfile = true
            case .cupsCount:
                self?.animateCupsCount = true
            case .ratio:
                self?.animateRatio = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                switch field {
                case .brewMethod:
                    self?.animateBrewMethod = false
                case .recipeProfile:
                    self?.animateRecipeProfile = false
                case .cupsCount:
                    self?.animateCupsCount = false
                case .ratio:
                    self?.animateRatio = false
                }
            }
        }
    }

    private func getNextMissingPage(in context: CreateRecipeContext) -> (page: Int, missingField: CreateRecipeMissingField?) {
        do {
            let _ = try createRecipeFromContextUseCase.canCreate(from: context)
            analyticsTracker.track(event: AnalyticsEvent(
                name: "create_recipe_validated",
                parameters: ["result": "pass"]
            ))
            return (pageCount, nil)
        } catch let error as CreateRecipeFromContextUseCaseError {
            let missingField: CreateRecipeMissingField
            switch error {
            case .missingBrewMethod:
                missingField = .brewMethod
            case .missingRecipeProfile:
                missingField = .recipeProfile
            case .missingCupsCount:
                missingField = .cupsCount
            case .missingRatio:
                missingField = .ratio
            }
            analyticsTracker.track(event: AnalyticsEvent(
                name: "create_recipe_validated",
                parameters: [
                    "result": "fail",
                    "missing_field": fieldName(for: missingField)
                ]
            ))
            switch missingField {
            case .brewMethod:
                return (1, .brewMethod)
            case .recipeProfile:
                return (2, .recipeProfile)
            case .cupsCount:
                return (3, .cupsCount)
            case .ratio:
                return (3, .ratio)
            }
        } catch _ {
            // Unknown error
        }

        return (pageCount, nil)
    }
    
    private func fieldName(for field: CreateRecipeMissingField) -> String {
        switch field {
        case .brewMethod: return "brew_method"
        case .recipeProfile: return "recipe_profile"
        case .cupsCount: return "cups_count"
        case .ratio: return "ratio"
        }
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
            
            let brewMethodType = recipe.recipeProfile.brewMethod.path.hasPrefix("custom-method") ? "custom" : "built-in"
            let ratioId = context.ratio?.id ?? "unknown"
            let cupsCountBand = cupsCountBand(for: recipe.cupsCount)
            analyticsTracker.track(event: AnalyticsEvent(
                name: "recipe_created",
                parameters: [
                    "brew_method_type": brewMethodType,
                    "ratio_id": ratioId,
                    "cups_count_band": cupsCountBand,
                    "iced": recipe.recipeProfile.brewMethod.isIcedBrew
                ]
            ))
        }
    }
    
    private func cupsCountBand(for cupsCount: Double) -> String {
        switch cupsCount {
        case 0..<2: return "1"
        case 2..<4: return "2-3"
        case 4..<6: return "4-5"
        default: return "6+"
        }
    }

    func didUpdate(context: CreateRecipeContext) {
        resetRatiosIfNeeded(context)
        canCreate = canCreate(from: context)
    }
    
    func trackBrewMethodChosen(brewMethodType: String, methodId: String) {
        analyticsTracker.track(event: AnalyticsEvent(
            name: "brew_method_chosen",
            parameters: [
                "brew_method_type": brewMethodType,
                "method_id": methodId
            ]
        ))
    }

    func remove(brewMethod: BrewMethod) {
        Task {
            await removeBrewMethodUseCase.remove(brewMethod: brewMethod)
            refreshBrewMethods()
        }
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
                        animateSelection: $viewModel.animateBrewMethod,
                        createMethod: createMethod,
                        deleteMethod: viewModel.remove(brewMethod:)
                    )
                }
                .tag(1)

                ZStack {
                    CreateRecipeProfileSelection(
                        recipeProfile: $context.recipeProfile,
                        animateField: $viewModel.animateRecipeProfile
                    )
                }
                .tag(2)

                ZStack {
                    CreateRecipeCoffeeWaterSelection(
                        cupsCountAmount: $context.cupsCount,
                        cupSizeAmount: $context.cupSize,
                        selectedRatio: $context.ratio,
                        allRatios: $viewModel.allRatios,
                        animateCupsCount: $viewModel.animateCupsCount,
                        animateRatio: $viewModel.animateRatio
                    )
                }
                .tag(3)
            }
        )
        .onChange(of: context.selectedBrewMethod, perform: didUpdateBrewMethod(_:))
        .onChange(of: context.recipeProfile, perform: didUpdate(_:))
        .onChange(of: context.cupsCount, perform: didUpdate(_:))
        .onChange(of: context.ratio, perform: didUpdate(_:))
    }

    private func didUpdateBrewMethod(_ brewMethod: BrewMethod?) {
        if let brewMethod = brewMethod {
            let brewMethodType = brewMethod.path.hasPrefix("custom-method") ? "custom" : "built-in"
            viewModel.trackBrewMethodChosen(brewMethodType: brewMethodType, methodId: brewMethod.id)
        }
        viewModel.didUpdate(context: context)
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
