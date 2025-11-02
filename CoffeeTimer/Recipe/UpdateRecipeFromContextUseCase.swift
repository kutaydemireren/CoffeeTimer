//
//  UpdateRecipeFromContextUseCase.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 24/10/2025.
//

import Foundation

protocol UpdateRecipeFromContextUseCase {
    func update(recipeId: UUID, from context: CreateRecipeContext) async -> Recipe?
}

struct UpdateRecipeFromContextUseCaseImp: UpdateRecipeFromContextUseCase {
    private let createContextToInputMapper: CreateContextToInputMapper
    private let fetchRecipeInstructionsUseCase: FetchRecipeInstructionsUseCase
    private let createRecipeFromInputUseCase: CreateRecipeFromInputUseCase
    private let recipeRepository: RecipeRepository
    
    init(
        createContextToInputMapper: CreateContextToInputMapper = CreateContextToInputMapperImp(),
        fetchRecipeInstructionsUseCase: FetchRecipeInstructionsUseCase = FetchRecipeInstructionsUseCaseImp(),
        createRecipeFromInputUseCase: CreateRecipeFromInputUseCase = CreateRecipeFromInputUseCaseImp(),
        recipeRepository: RecipeRepository = RecipeRepositoryImp.shared
    ) {
        self.createContextToInputMapper = createContextToInputMapper
        self.fetchRecipeInstructionsUseCase = fetchRecipeInstructionsUseCase
        self.createRecipeFromInputUseCase = createRecipeFromInputUseCase
        self.recipeRepository = recipeRepository
    }
    
    func update(recipeId: UUID, from context: CreateRecipeContext) async -> Recipe? {
        guard let selectedBrewMethod = context.selectedBrewMethod else { return nil }
        guard let input = try? createContextToInputMapper.map(context: context) else { return nil }
        guard let instructions = try? await fetchRecipeInstructionsUseCase.fetch(brewMethod: selectedBrewMethod) else { return nil }
        
        let inputWithId = CreateRecipeInput(
            recipeProfile: input.recipeProfile,
            coffee: input.coffee,
            water: input.water,
            ice: input.ice,
            cupsCount: input.cupsCount,
            cupSize: input.cupSize,
            id: recipeId
        )
        
        let updatedRecipe = createRecipeFromInputUseCase.create(from: inputWithId, instructions: instructions)
        
        recipeRepository.update(selectedRecipe: updatedRecipe)
        recipeRepository.update(savedRecipe: updatedRecipe)
        
        return updatedRecipe
    }
}
