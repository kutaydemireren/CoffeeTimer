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
    /// The method just deleted from the grid, while its Undo is offered.
    @Published private(set) var deletedMethod: BrewMethod?
    private var deletedMethodDismissTask: Task<Void, Never>?

    private var createRecipeFromContextUseCase: CreateRecipeFromContextUseCase
    private var recipeRepository: RecipeRepository // TODO: use case - no repo in vm!
    private var getBrewMethodsUseCase: GetBrewMethodsUseCase
    private var removeBrewMethodUseCase: RemoveBrewMethodUseCase
    private var analyticsTracker: AnalyticsTracker
    private var reviewPromptPolicy: ReviewPromptPolicy

    init(
        createRecipeFromContextUseCase: CreateRecipeFromContextUseCase = CreateRecipeFromContextUseCaseImp(),
        recipeRepository: RecipeRepository = RecipeRepositoryImp.shared,
        getBrewMethodsUseCase: GetBrewMethodsUseCase = GetBrewMethodsUseCaseImp(),
        removeBrewMethodUseCase: RemoveBrewMethodUseCase = RemoveBrewMethodUseCaseImp(),
        analyticsTracker: AnalyticsTracker = AnalyticsTrackerImp(),
        reviewPromptPolicy: ReviewPromptPolicy = ReviewPromptPolicyImp.shared
    ) {
        self.reviewPromptPolicy = reviewPromptPolicy
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
            await reloadBrewMethods()
        }
    }

    func reloadBrewMethods() async {
        if let brewMethods = try? await getBrewMethodsUseCase.getAll() {
            self.brewMethods = brewMethods
        }
    }

    /// After a method is saved: select it and carry on to cups, cup size and strength, with its own ratio selected.
    func continueWith(savedMethod: BrewMethod, in context: CreateRecipeContext) async {
        await reloadBrewMethods()
        let method = brewMethods.first { $0.id == savedMethod.id } ?? savedMethod
        if context.recipeProfile.name.trimmingCharacters(in: .whitespaces).isEmpty {
            context.recipeProfile = RecipeProfile(name: method.title, brewMethod: method)
        } else {
            context.selectedBrewMethod = method
        }
        allRatios = []
        didUpdate(context: context)
        withAnimation {
            selectedPage = pageCount
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
        let newRatios = context.selectedBrewMethod?.recipeRatios
        if let newRatios, newRatios != allRatios {
            self.allRatios = newRatios
            context.ratio = context.selectedBrewMethod?.defaultRatio
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
            reviewPromptPolicy.record(.recipeCreated)
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

    func remove(brewMethod: BrewMethod, in context: CreateRecipeContext) {
        if context.selectedBrewMethod?.id == brewMethod.id {
            context.selectedBrewMethod = nil
        }
        deletedMethod = brewMethod
        analyticsTracker.track(event: AnalyticsEvent(name: "method_deleted"))
        Task {
            await removeBrewMethodUseCase.remove(brewMethod: brewMethod)
            await reloadBrewMethods()
        }

        deletedMethodDismissTask?.cancel()
        deletedMethodDismissTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(6))
            guard !Task.isCancelled else { return }
            self?.deletedMethod = nil
        }
    }

    func undoDelete() {
        guard let brewMethod = deletedMethod else { return }
        deletedMethodDismissTask?.cancel()
        deletedMethod = nil
        analyticsTracker.track(event: AnalyticsEvent(name: "method_delete_undone"))
        Task {
            await removeBrewMethodUseCase.restore(brewMethod: brewMethod)
            await reloadBrewMethods()
        }
    }
}

struct CreateRecipeView: View {
    @StateObject var viewModel: CreateRecipeViewModel
    @EnvironmentObject var context: CreateRecipeContext

    var close: () -> Void
    var createMethod: () -> Void
    var makeItMine: (BrewMethod) -> Void = { _ in }
    var editMethod: (BrewMethod) -> Void = { _ in }

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
                        menuActions: BrewMethodMenuActions(
                            makeItMine: makeItMine,
                            edit: editMethod,
                            delete: { viewModel.remove(brewMethod: $0, in: context) }
                        ),
                        deletedMethod: viewModel.deletedMethod,
                        undoDelete: viewModel.undoDelete,
                        createMethod: createMethod
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
        .onChange(of: context.selectedBrewMethod) { _, newValue in didUpdateBrewMethod(newValue) }
        .onChange(of: context.recipeProfile) { _, newValue in didUpdate(newValue) }
        .onChange(of: context.cupsCount) { _, newValue in didUpdate(newValue) }
        .onChange(of: context.ratio) { _, newValue in didUpdate(newValue) }
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
