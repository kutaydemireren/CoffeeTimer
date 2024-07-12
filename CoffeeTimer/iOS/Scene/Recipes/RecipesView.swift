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
    var savedRecipes: AnyPublisher<[Recipe], Never> { get }
}

final class GetSavedRecipesUseCaseImp: GetSavedRecipesUseCase {
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
    
    @Published var recipes: [Recipe] = []
    
    private var cancellables: [AnyCancellable] = []
    
    private let getSavedRecipesUseCase: GetSavedRecipesUseCase
    private let updateSelectedRecipeUseCase: UpdateSelectedRecipeUseCase
    private let removeRecipeUseCase: RemoveRecipeUseCase
    
    init(
        getSavedRecipesUseCase: GetSavedRecipesUseCase = GetSavedRecipesUseCaseImp(),
        updateSelectedRecipeUseCase: UpdateSelectedRecipeUseCase = UpdateSelectedRecipeUseCaseImp(),
        removeRecipeUseCase: RemoveRecipeUseCase = RemoveRecipeUseCaseImp()
    ) {
        self.getSavedRecipesUseCase = getSavedRecipesUseCase
        self.updateSelectedRecipeUseCase = updateSelectedRecipeUseCase
        self.removeRecipeUseCase = removeRecipeUseCase
        
        self.getSavedRecipesUseCase.savedRecipes
            .assign(to: &$recipes)
    }
    
    func select(recipe: Recipe) {
        updateSelectedRecipeUseCase.update(selectedRecipe: recipe)
        close()
    }
    
    func removeRecipes(at indices: IndexSet) {
        indices
            .compactMap { recipes[safe: $0] }
            .forEach(remove(recipe:))
    }
    
    private func remove(recipe: Recipe) {
        removeRecipeUseCase.remove(recipe: recipe)
    }
    
    func create() {
        didCreate.send(self)
    }
    
    func close() {
        didComplete.send(self)
    }
}

struct RecipesView: View {
    
    @ObservedObject var viewModel: RecipesViewModel
    
    var body: some View {
        ZStack(alignment: .top) {
            content
                .padding(.top, 20)
            
            HStack {
                Button("Close") {
                    viewModel.close()
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .foregroundColor(Color("backgroundSecondary"))
            
            VStack {
                
                Spacer()
                
                HStack {
                    
                    Spacer()
                    
                    Button() {
                        viewModel.create()
                    } label: {
                        Image(uiImage: .add)
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 60, height: 60)
                            .padding(.horizontal, 32)
                            .shadow(color: .black.opacity(0.3), radius: 16, x: 8, y: 12)
                    }
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
                RecipeRowView(recipe: recipe)
                    .onTapGesture {
                        viewModel.select(recipe: recipe)
                    }
            }
            .onDelete { indexSet in
                viewModel.removeRecipes(at: indexSet)
            }
        }
        .scrollIndicators(.hidden)
        .scrollContentBackground(.hidden)
    }
}

struct RecipesView_Previews: PreviewProvider {
    static var previews: some View {
        let recipeVM = RecipesViewModel()
        return RecipesView(viewModel: recipeVM)
    }
}

