//
//  TweakBrewViewModelTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 24/11/2026.
//

import XCTest
import Combine
@testable import CoffeeTimer

@MainActor
final class TweakBrewViewModelTests: XCTestCase {
    private var fetchInstructions: MockFetchRecipeInstructionsUseCase!
    private var saveUseCase: MockSaveBrewMethodUseCase!
    private var analyticsTracker: MockAnalyticsTracker!
    private var sut: TweakBrewViewModel!
    private var cancellables: [AnyCancellable] = []
    private var finishCount = 0
    private var closeCount = 0

    override func setUp() async throws {
        fetchInstructions = MockFetchRecipeInstructionsUseCase()
        fetchInstructions._instructions = loadOldEditorV60Instructions()
        saveUseCase = MockSaveBrewMethodUseCase()
        analyticsTracker = MockAnalyticsTracker()
        finishCount = 0
        closeCount = 0
        let saveUseCase = saveUseCase!
        sut = TweakBrewViewModel(
            fetchRecipeInstructionsUseCase: fetchInstructions,
            saveBrewMethodUseCase: saveUseCase,
            analyticsTracker: analyticsTracker,
            transitionDelay: .zero,
            makeEditor: { draft in
                MethodEditorViewModel(
                    draft: draft,
                    saveBrewMethodUseCase: saveUseCase,
                    draftStore: MockMethodDraftStore(),
                    analyticsTracker: MockAnalyticsTracker(),
                    reviewPromptPolicy: MockReviewPromptPolicy()
                )
            }
        )
        sut.didFinish.sink { [weak self] in self?.finishCount += 1 }.store(in: &cancellables)
        sut.didClose.sink { [weak self] in self?.closeCount += 1 }.store(in: &cancellables)
    }

    override func tearDown() {
        cancellables = []
    }

    private func recipe(with brewMethod: BrewMethod) -> Recipe {
        Recipe(
            recipeProfile: RecipeProfile(name: "Morning cup", brewMethod: brewMethod),
            ingredients: .stubSingleV60,
            brewQueue: .stubSingleV60,
            cupsCount: 1,
            cupSize: 250
        )
    }

    private var copy: BrewMethod {
        .frenchPress(path: "custom-method://copy")
    }

    private func waitForSwitchPrompt() async {
        for _ in 0..<50 where !sut.isSwitchPromptPresented {
            try? await Task.sleep(for: .milliseconds(10))
        }
    }

    // MARK: - Opening the editor

    func test_tweak_whenOwnMethod_shouldOpenEditorOnTheSameMethod() async throws {
        await sut.tweak(recipe(with: .oldCustom))

        let editor = try XCTUnwrap(sut.methodEditor)
        XCTAssertEqual(editor.draft.editedMethodId, BrewMethod.oldCustom.id)
        XCTAssertEqual(editor.draft.name, BrewMethod.oldCustom.title)
    }

    func test_tweak_whenBuiltInMethod_shouldOpenACopyNamedMyMethod() async throws {
        await sut.tweak(recipe(with: .v60Single))

        let editor = try XCTUnwrap(sut.methodEditor)
        XCTAssertEqual(editor.draft.origin, .copy(of: BrewMethod.v60Single.id))
        XCTAssertEqual(editor.draft.name, "My V60 Single")
        XCTAssertNil(editor.draft.editedMethodId)
    }

    func test_tweak_whenInstructionsCannotBeFetched_shouldNotOpenEditorAndClose() async {
        fetchInstructions._error = TestError.notAllowed

        await sut.tweak(recipe(with: .v60Single))

        XCTAssertNil(sut.methodEditor)
        XCTAssertEqual(closeCount, 1)
    }

    // MARK: - Closing and saving

    func test_editorClose_shouldDismissEditorAndClose() async throws {
        await sut.tweak(recipe(with: .v60Single))

        try XCTUnwrap(sut.methodEditor).close()

        XCTAssertNil(sut.methodEditor)
        XCTAssertEqual(closeCount, 1)
        XCTAssertEqual(finishCount, 0)
        XCTAssertFalse(sut.isSwitchPromptPresented)
    }

    func test_editorSave_whenOwnMethod_shouldFinishWithoutSwitchPrompt() async throws {
        await sut.tweak(recipe(with: .oldCustom))

        try XCTUnwrap(sut.methodEditor).didSave.send(.oldCustom)

        XCTAssertNil(sut.methodEditor)
        XCTAssertFalse(sut.isSwitchPromptPresented)
        XCTAssertEqual(finishCount, 1)
        XCTAssertTrue(saveUseCase.switchRecipeCalls.isEmpty)
    }

    func test_editorSave_whenBuiltInMethod_shouldOfferToSwitchTheRecipe() async throws {
        await sut.tweak(recipe(with: .v60Single))

        try XCTUnwrap(sut.methodEditor).didSave.send(copy)
        await waitForSwitchPrompt()

        XCTAssertNil(sut.methodEditor)
        XCTAssertTrue(sut.isSwitchPromptPresented)
        XCTAssertEqual(sut.switchPromptTitle, "Brew \u{201C}Morning cup\u{201D} with \(copy.title)?")
        XCTAssertEqual(finishCount, 0)
    }

    func test_switchToCopy_shouldMoveTheBrewedRecipeToTheCopyAndFinish() async throws {
        let brewed = recipe(with: .v60Single)
        await sut.tweak(brewed)
        try XCTUnwrap(sut.methodEditor).didSave.send(copy)
        await waitForSwitchPrompt()

        await sut.switchToCopy().value

        XCTAssertEqual(saveUseCase.switchRecipeCalls.count, 1)
        XCTAssertEqual(saveUseCase.switchRecipeCalls.first?.recipe, brewed)
        XCTAssertEqual(saveUseCase.switchRecipeCalls.first?.brewMethod, copy)
        XCTAssertEqual(finishCount, 1)
        XCTAssertFalse(sut.isSwitchPromptPresented)
        let event = analyticsTracker.trackedEvents.first { $0.name == "tweak_brew_recipe_switch" }
        XCTAssertEqual(event?.parameters?["switched"] as? Bool, true)
    }

    func test_keepRecipe_shouldLeaveTheRecipeOnTheBuiltInAndFinish() async throws {
        await sut.tweak(recipe(with: .v60Single))
        try XCTUnwrap(sut.methodEditor).didSave.send(copy)
        await waitForSwitchPrompt()

        sut.keepRecipe()
        // The prompt closing calls it again; it must not finish twice.
        sut.keepRecipe()

        XCTAssertTrue(saveUseCase.switchRecipeCalls.isEmpty)
        XCTAssertEqual(finishCount, 1)
        let event = analyticsTracker.trackedEvents.first { $0.name == "tweak_brew_recipe_switch" }
        XCTAssertEqual(event?.parameters?["switched"] as? Bool, false)
    }
}
