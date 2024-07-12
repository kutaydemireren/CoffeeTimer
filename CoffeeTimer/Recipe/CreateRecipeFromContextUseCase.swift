//
//  CreateRecipeFromContextUseCase.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 06/05/2023.
//

import Foundation

enum CreateRecipeFromContextUseCaseError: Error {
    case missingBrewMethod
    case missingRecipeProfile
    case missingCupsCount
    case missingRatio
}

protocol CreateRecipeFromContextUseCase {
    func canCreate(from context: CreateRecipeContext) throws -> Bool
    func create(from context: CreateRecipeContext) async -> Recipe?
}

/*
 TODO: removing context dependency
 `context` used here is essentially a UI component.
 this needs to be addressed so that it can be scoped to only presentation layer.
 (use CreateRecipeInput instead?)
 */
struct CreateRecipeFromContextUseCaseImp: CreateRecipeFromContextUseCase {
    private let createContextToInputMapper: CreateContextToInputMapper
    private let fetchRecipeInstructionsUseCase: FetchRecipeInstructionsUseCase
    private let createRecipeFromInputUseCase: CreateRecipeFromInputUseCase

    init(
        createContextToInputMapper: CreateContextToInputMapper = CreateContextToInputMapperImp(),
        fetchRecipeInstructionsUseCase: FetchRecipeInstructionsUseCase = FetchRecipeInstructionsUseCaseImp(),
        createRecipeFromInputUseCase: CreateRecipeFromInputUseCase = CreateRecipeFromInputUseCaseImp()
    ) {
        self.createContextToInputMapper = createContextToInputMapper
        self.fetchRecipeInstructionsUseCase = fetchRecipeInstructionsUseCase
        self.createRecipeFromInputUseCase = createRecipeFromInputUseCase
    }

    func canCreate(from context: CreateRecipeContext) throws  -> Bool {
        guard context.selectedBrewMethod != nil else {
            throw CreateRecipeFromContextUseCaseError.missingBrewMethod
        }
        
        guard context.recipeProfile.hasContent else {
            throw CreateRecipeFromContextUseCaseError.missingRecipeProfile
        }

        guard context.cupsCount > 0 else {
            throw CreateRecipeFromContextUseCaseError.missingCupsCount
        }

        guard context.ratio != nil else {
            throw CreateRecipeFromContextUseCaseError.missingRatio
        }

        return true
    }

    func create(from context: CreateRecipeContext) async -> Recipe? {
        guard let selectedBrewMethod = context.selectedBrewMethod else { return nil }
        guard let input = try? createContextToInputMapper.map(context: context) else { return nil }
        guard let instructions = try? await fetchRecipeInstructionsUseCase.fetch(brewMethod: selectedBrewMethod) else { return nil }

        return createRecipeFromInputUseCase.create(from: input, instructions: instructions)
    }
}
