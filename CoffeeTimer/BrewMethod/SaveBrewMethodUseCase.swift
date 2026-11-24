//
//  SaveBrewMethodUseCase.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 24/11/2026.
//

import Foundation
import Combine

// TODO: move

struct CustomMethodPathGenerator {
    static let customMethodKey = "custom-method"

    static func generate(id: String) -> String {
        return "\(customMethodKey)://\(id)"
    }

    static func parseID(path: String) -> String? {
        guard path.starts(with: "\(customMethodKey)://") else {
            return nil
        }

        return String(path.dropFirst("\(customMethodKey)://".count))
    }
}

struct StaticCoffeetoWaterRatioGenerator {
    static func hotBrew() -> [CoffeeToWaterRatio] {
        return [
            .init(id: "1:16", value: 16, title: "1:16 - Strong"),
            .init(id: "1:17", value: 17, title: "1:17 - Robust"),
            .init(id: "1:18", value: 18, title: "1:18 - Medium"),
            .init(id: "1:19", value: 19, title: "1:19 - Mild"),
            .init(id: "1:20", value: 20, title: "1:20 - Delicate"),
        ]
    }

    static func icedBrew() -> [CoffeeToWaterRatio] {
        return [
            .init(id: "1:15", value: 15, title: "1:15 - Delicate"),
            .init(id: "1:16", value: 16, title: "1:16 - Strong"),
            .init(id: "1:17", value: 17, title: "1:17 - Robust"),
            .init(id: "1:18", value: 18, title: "1:18 - Medium"),
            .init(id: "1:19", value: 19, title: "1:19 - Mild")
        ]
    }
}

//

enum MethodSaveMode: Equatable {
    /// A new method with a new id. Recipes made from the edited method keep it.
    case asNew
    /// The edited method's id. Recipes made from it are rebuilt with the new steps and keep their amounts.
    case updateEverywhere
}

enum SaveBrewMethodUseCaseError: Error, Equatable {
    case invalid([MethodValidationIssue])
}

protocol SaveBrewMethodUseCase {
    /// Saved recipes made from the method with `methodId`.
    func recipesUsing(methodId: String) -> [Recipe]
    func save(_ draft: MethodDraft, mode: MethodSaveMode) async throws -> BrewMethod
}

struct SaveBrewMethodUseCaseImp: SaveBrewMethodUseCase {
    private let factory: MethodDraftFactory
    private let compiler: MethodDraftCompiler
    private let recipeInstructionsRepository: RecipeInstructionsRepository
    private let brewMethodRepository: BrewMethodRepository
    private let recipeRepository: RecipeRepository
    private let createRecipeFromInputUseCase: CreateRecipeFromInputUseCase
    private let idGenerator: () -> String

    init(
        factory: MethodDraftFactory = MethodDraftFactory(),
        compiler: MethodDraftCompiler = MethodDraftCompiler(),
        recipeInstructionsRepository: RecipeInstructionsRepository = RecipeInstructionsRepositoryImp(),
        brewMethodRepository: BrewMethodRepository = BrewMethodRepositoryImp(),
        recipeRepository: RecipeRepository = RecipeRepositoryImp.shared,
        createRecipeFromInputUseCase: CreateRecipeFromInputUseCase = CreateRecipeFromInputUseCaseImp(),
        idGenerator: @escaping () -> String = { UUID().uuidString }
    ) {
        self.factory = factory
        self.compiler = compiler
        self.recipeInstructionsRepository = recipeInstructionsRepository
        self.brewMethodRepository = brewMethodRepository
        self.recipeRepository = recipeRepository
        self.createRecipeFromInputUseCase = createRecipeFromInputUseCase
        self.idGenerator = idGenerator
    }

    func recipesUsing(methodId: String) -> [Recipe] {
        var recipes: [Recipe] = []
        let cancellable = recipeRepository.recipesPublisher.sink { recipes = $0 }
        cancellable.cancel()
        var using = recipes.filter { $0.recipeProfile.brewMethod.id == methodId }
        if let selected = recipeRepository.getSelectedRecipe(),
           selected.recipeProfile.brewMethod.id == methodId,
           !using.contains(where: { $0.id == selected.id }) {
            using.append(selected)
        }
        return using
    }

    func save(_ draft: MethodDraft, mode: MethodSaveMode) async throws -> BrewMethod {
        let issues = draft.validationIssues
        guard issues.isEmpty else { throw SaveBrewMethodUseCaseError.invalid(issues) }

        let id: String
        if mode == .updateEverywhere, let editedId = draft.editedMethodId {
            id = editedId
        } else {
            id = idGenerator()
        }

        let brewMethod = factory.brewMethod(from: draft, id: id)
        let instructions = RecipeInstructions(identifier: id, steps: compiler.instructionSteps(for: draft))

        try await recipeInstructionsRepository.save(instructions: instructions)
        try await brewMethodRepository.save(brewMethod: brewMethod)

        if id == draft.editedMethodId {
            rebuildRecipes(using: brewMethod, instructions: instructions)
        }

        return brewMethod
    }

    /// Recipes store their brew steps, so recipes made from an updated method are rebuilt with its new steps.
    /// Their name, cups and amounts stay the same.
    private func rebuildRecipes(using brewMethod: BrewMethod, instructions: RecipeInstructions) {
        let selectedRecipeId = recipeRepository.getSelectedRecipe()?.id
        for recipe in recipesUsing(methodId: brewMethod.id) {
            let rebuilt = rebuild(recipe, brewMethod: brewMethod, instructions: instructions)
            recipeRepository.update(savedRecipe: rebuilt)
            if recipe.id == selectedRecipeId {
                recipeRepository.update(selectedRecipe: rebuilt)
            }
        }
    }

    private func rebuild(_ recipe: Recipe, brewMethod: BrewMethod, instructions: RecipeInstructions) -> Recipe {
        func amount(_ type: IngredientType) -> IngredientAmount? {
            recipe.ingredients.first { $0.ingredientType == type }?.amount
        }

        let input = CreateRecipeInput(
            recipeProfile: RecipeProfile(name: recipe.recipeProfile.name, brewMethod: brewMethod),
            coffee: amount(.coffee) ?? .zeroGram,
            water: amount(.water) ?? IngredientAmount(amount: 0, type: .millilitre),
            ice: amount(.ice),
            cupsCount: recipe.cupsCount,
            cupSize: recipe.cupSize,
            id: recipe.id
        )
        return createRecipeFromInputUseCase.create(from: input, instructions: instructions)
    }
}
