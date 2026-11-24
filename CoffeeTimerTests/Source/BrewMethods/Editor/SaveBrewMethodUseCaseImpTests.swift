//
//  SaveBrewMethodUseCaseImpTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 24/11/2026.
//

import XCTest
@testable import CoffeeTimer

final class SaveBrewMethodUseCaseImpTests: XCTestCase {
    private var instructionsRepository: InMemoryRecipeInstructionsRepository!
    private var brewMethodRepository: InMemoryBrewMethodRepository!
    private var recipeRepository: MockRecipeRepository!
    private var sut: SaveBrewMethodUseCaseImp!

    override func setUp() {
        instructionsRepository = InMemoryRecipeInstructionsRepository()
        brewMethodRepository = InMemoryBrewMethodRepository()
        recipeRepository = MockRecipeRepository()
        sut = SaveBrewMethodUseCaseImp(
            recipeInstructionsRepository: instructionsRepository,
            brewMethodRepository: brewMethodRepository,
            recipeRepository: recipeRepository,
            idGenerator: { "new-id" }
        )
    }

    private func editedOldMethodDraft() -> MethodDraft {
        var draft = MethodDraftFactory().draft(editing: .oldCustom, instructions: loadOldEditorV60Instructions())
        draft.steps[6].amount = .upTo(160)
        return draft
    }

    private func recipeFromOldMethod() -> Recipe {
        let input = CreateRecipeInput(
            recipeProfile: RecipeProfile(name: "Old recipe", brewMethod: .oldCustom),
            coffee: .init(amount: 29, type: .gram),
            water: .init(amount: 500, type: .millilitre),
            ice: nil,
            cupsCount: 2,
            cupSize: 250
        )
        return CreateRecipeFromInputUseCaseImp().create(from: input, instructions: loadOldEditorV60Instructions())
    }

    func test_save_whenNew_shouldSaveMethodAndInstructionsUnderANewId() async throws {
        var draft = MethodDraft.scratch()
        draft.name = "Kalita Wave"
        draft.coffee = 20
        draft.water = 320
        draft.steps = [MethodStep(kind: .addCoffee, amount: .add(20)), MethodStep(kind: .pour, amount: .rest)]

        let result = try await sut.save(draft, mode: .asNew)

        XCTAssertEqual(result.id, "new-id")
        XCTAssertEqual(result.referenceDose, ReferenceDose(coffee: 20, water: 320))
        XCTAssertEqual(brewMethodRepository.methods, [result])
        XCTAssertEqual(instructionsRepository.instructions.first?.identifier, "new-id")
        XCTAssertEqual(instructionsRepository.instructions.first?.steps.count, 2)
    }

    func test_save_whenInvalid_shouldThrowTheIssuesAndSaveNothing() async {
        do {
            _ = try await sut.save(.scratch(), mode: .asNew)
            XCTFail("expected an error")
        } catch {
            XCTAssertEqual(error as? SaveBrewMethodUseCaseError, .invalid([.missingName, .missingSteps]))
        }
        XCTAssertTrue(brewMethodRepository.methods.isEmpty)
        XCTAssertTrue(instructionsRepository.instructions.isEmpty)
    }

    func test_save_whenUpdateEverywhere_shouldKeepTheIdAndRebuildRecipesUsingIt() async throws {
        try await brewMethodRepository.save(brewMethod: .oldCustom)
        try await instructionsRepository.save(instructions: loadOldEditorV60Instructions())
        let recipe = recipeFromOldMethod()
        recipeRepository.savedRecipes.send([recipe])
        recipeRepository.getSelectedRecipeReturnValue = recipe

        let result = try await sut.save(editedOldMethodDraft(), mode: .updateEverywhere)

        XCTAssertEqual(result.id, BrewMethod.oldCustom.id)
        XCTAssertEqual(brewMethodRepository.methods.count, 1)
        XCTAssertEqual(instructionsRepository.instructions.count, 1)

        let rebuilt = try XCTUnwrap(recipeRepository.updateSavedRecipeCalledWith)
        XCTAssertEqual(rebuilt.id, recipe.id)
        XCTAssertEqual(rebuilt.recipeProfile.name, "Old recipe")
        XCTAssertEqual(rebuilt.recipeProfile.brewMethod, result)
        XCTAssertEqual(rebuilt.ingredients, recipe.ingredients)
        // Up to 160 of 250 g is 64% of the water: 320 of 500 g, so the first pour grows from 242 to 262 g.
        XCTAssertEqual(rebuilt.brewQueue.stages[6].action, .pourWater(.init(amount: 262, type: .millilitre)))
        XCTAssertEqual(recipe.brewQueue.stages[6].action, .pourWater(.init(amount: 242, type: .millilitre)))
        XCTAssertEqual(recipeRepository.updateSelectedRecipeCalledWith, rebuilt)
    }

    func test_save_whenSaveAsNew_shouldLeaveTheOldMethodAndItsRecipesAlone() async throws {
        try await brewMethodRepository.save(brewMethod: .oldCustom)
        try await instructionsRepository.save(instructions: loadOldEditorV60Instructions())
        recipeRepository.savedRecipes.send([recipeFromOldMethod()])

        let result = try await sut.save(editedOldMethodDraft(), mode: .asNew)

        XCTAssertEqual(result.id, "new-id")
        XCTAssertEqual(brewMethodRepository.methods.map(\.id), [BrewMethod.oldCustom.id, "new-id"])
        XCTAssertEqual(instructionsRepository.instructions.map(\.identifier), [BrewMethod.oldCustom.id, "new-id"])
        XCTAssertEqual(instructionsRepository.instructions.first?.steps.map(\.kind), loadOldEditorV60Instructions().steps.map(\.kind))
        XCTAssertNil(recipeRepository.updateSavedRecipeCalledWith)
        XCTAssertNil(recipeRepository.updateSelectedRecipeCalledWith)
    }

    func test_recipesUsing_shouldFindSavedRecipesOfTheMethod() {
        recipeRepository.savedRecipes.send([recipeFromOldMethod(), .stubSingleV60])

        XCTAssertEqual(sut.recipesUsing(methodId: BrewMethod.oldCustom.id).count, 1)
        XCTAssertTrue(sut.recipesUsing(methodId: "unknown").isEmpty)
    }
}
