//
//  RecipesView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 10/05/2023.
//

import SwiftUI
import Combine

protocol RemoveRecipeUseCase {
    func remove(recipe: Recipe)
}

final class RemoveRecipeUseCaseImp: RemoveRecipeUseCase {
    private let recipeRepository: RecipeRepository
    
    init(recipeRepository: RecipeRepository = RecipeRepositoryImp.shared) {
        self.recipeRepository = recipeRepository
    }
    
    func remove(recipe: Recipe) {
        recipeRepository.remove(recipe: recipe)
    }
}

protocol GetSavedRecipesUseCase {
    var selectedRecipe: Recipe? { get }
    var savedRecipes: AnyPublisher<[Recipe], Never> { get }
}

final class GetSavedRecipesUseCaseImp: GetSavedRecipesUseCase {
    var selectedRecipe: Recipe? {
        recipeRepository.getSelectedRecipe()
    }

    var savedRecipes: AnyPublisher<[Recipe], Never> {
        recipeRepository.recipesPublisher
    }
    
    private let recipeRepository: RecipeRepository
    
    private var cancellables: [AnyCancellable] = []
    
    init(recipeRepository: RecipeRepository = RecipeRepositoryImp.shared) {
        self.recipeRepository = recipeRepository
    }
}

protocol UpdateSelectedRecipeUseCase {
    func update(selectedRecipe: Recipe)
}

final class UpdateSelectedRecipeUseCaseImp: UpdateSelectedRecipeUseCase {
    private let recipeRepository: RecipeRepository
    
    init(recipeRepository: RecipeRepository = RecipeRepositoryImp.shared) {
        self.recipeRepository = recipeRepository
    }
    
    func update(selectedRecipe: Recipe) {
        recipeRepository.update(selectedRecipe: selectedRecipe)
    }
}

final class RecipesViewModel: ObservableObject, Completable {
    var didComplete = PassthroughSubject<RecipesViewModel, Never>()
    var didCreate = PassthroughSubject<RecipesViewModel, Never>()

    @Published var selectedRecipe: Recipe?
    @Published var recipes: [Recipe] = []
    
    private var cancellables: [AnyCancellable] = []
    
    private let getSavedRecipesUseCase: GetSavedRecipesUseCase
    private let updateSelectedRecipeUseCase: UpdateSelectedRecipeUseCase
    private let removeRecipeUseCase: RemoveRecipeUseCase
    private let analyticsTracker: AnalyticsTracker
    
    init(
        getSavedRecipesUseCase: GetSavedRecipesUseCase = GetSavedRecipesUseCaseImp(),
        updateSelectedRecipeUseCase: UpdateSelectedRecipeUseCase = UpdateSelectedRecipeUseCaseImp(),
        removeRecipeUseCase: RemoveRecipeUseCase = RemoveRecipeUseCaseImp(),
        analyticsTracker: AnalyticsTracker = AnalyticsTrackerImp()
    ) {
        self.getSavedRecipesUseCase = getSavedRecipesUseCase
        self.updateSelectedRecipeUseCase = updateSelectedRecipeUseCase
        self.removeRecipeUseCase = removeRecipeUseCase
        self.analyticsTracker = analyticsTracker

        self.getSavedRecipesUseCase.savedRecipes
            .assign(to: &$recipes)
        refresh()
        analyticsTracker.track(event: AnalyticsEvent(name: "recipes_opened"))
    }
    
    func select(recipe: Recipe) {
        let brewMethodType = recipe.recipeProfile.brewMethod.path.hasPrefix("custom-method") ? "custom" : "built-in"
        analyticsTracker.track(event: AnalyticsEvent(
            name: "recipe_selected",
            parameters: ["brew_method_type": brewMethodType]
        ))
        updateSelectedRecipeUseCase.update(selectedRecipe: recipe)
        refresh()
        close()
    }

    private func refresh() {
        selectedRecipe = getSavedRecipesUseCase.selectedRecipe
    }

    func removeRecipes(at indices: IndexSet) {
        indices
            .compactMap { recipes[safe: $0] }
            .forEach(remove(recipe:))
    }
    
    private func remove(recipe: Recipe) {
        let brewMethodType = recipe.recipeProfile.brewMethod.path.hasPrefix("custom-method") ? "custom" : "built-in"
        analyticsTracker.track(event: AnalyticsEvent(
            name: "recipe_deleted",
            parameters: ["brew_method_type": brewMethodType]
        ))
        removeRecipeUseCase.remove(recipe: recipe)
    }
    
    func create() {
        analyticsTracker.track(event: AnalyticsEvent(name: "recipe_create_started"))
        didCreate.send(self)
    }
}

struct RecipesView: View {
    @ObservedObject var viewModel: RecipesViewModel
    
    var body: some View {
        VStack {
            HStack {
                Button("Close") {
                    viewModel.close()
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top)
            .foregroundColor(Color("backgroundSecondary"))

            content
                .padding(.top, 20)
                .overlay(alignment: .bottomTrailing) {
                    Button() {
                        viewModel.create()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 60, height: 60)
                            .padding(.horizontal, 32)
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 0)
                    }
                    .foregroundColor(Color("backgroundSecondary"))
                }
        }
        .backgroundPrimary()
    }

    @ViewBuilder
    var content: some View {
        if viewModel.recipes.isEmpty {
            noRecipes
        } else {
            recipesList
        }
    }
    
    var noRecipes: some View {
        ZStack {
            VStack {
                Spacer()
                
                Text("Please add a new recipe to get started")
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color("foregroundPrimary"))
                    .font(.title)
                
                Spacer()
            }
        }
    }
    
    var recipesList: some View {
        List {
            ForEach(viewModel.recipes) { recipe in
                RecipeRowView(
                    recipe: recipe,
                    isSelected: viewModel.selectedRecipe?.id == recipe.id
                )
                .onTapGesture {
                    viewModel.select(recipe: recipe)
                }
            }
            .onDelete { indexSet in
                viewModel.removeRecipes(at: indexSet)
            }
        }
        .listStyle(.plain)
        .listRowSpacing(12)
        .scrollIndicators(.hidden)
        .scrollContentBackground(.hidden)
        .padding(.horizontal)
    }
}

struct RecipesView_Previews: PreviewProvider {
    static var previews: some View {
        let recipeVM = RecipesViewModel()
        return RecipesView(viewModel: recipeVM)
    }
}

