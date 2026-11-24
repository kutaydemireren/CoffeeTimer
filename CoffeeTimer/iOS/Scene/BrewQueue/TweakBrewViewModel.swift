//
//  TweakBrewViewModel.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 24/11/2026.
//

import SwiftUI
import Combine

/// "Tweak this brew" on the post-brew screen: opens the method editor on the method just brewed.
///
/// The user's own method opens as with Edit on its tile. A built-in method opens as a copy ("My V60"), as with
/// Make it mine; once the copy is saved, the user is asked whether the recipe just brewed should use it.
final class TweakBrewViewModel: ObservableObject {
    @Published var methodEditor: MethodEditorViewModel?
    @Published var isSwitchPromptPresented = false

    /// The recipe just brewed.
    private(set) var recipe: Recipe?
    /// The saved copy of a built-in method, while the switch prompt is offered.
    private(set) var savedCopy: BrewMethod?

    /// Sent once the tweak is saved and, for a built-in method, the switch prompt is answered.
    let didFinish = PassthroughSubject<Void, Never>()
    /// Sent when the editor is closed without saving: the post-brew screen stays.
    let didClose = PassthroughSubject<Void, Never>()

    private let fetchRecipeInstructionsUseCase: FetchRecipeInstructionsUseCase
    private let saveBrewMethodUseCase: SaveBrewMethodUseCase
    private let factory: MethodDraftFactory
    private let analyticsTracker: AnalyticsTracker
    private let makeEditor: @MainActor (MethodDraft) -> MethodEditorViewModel
    /// Lets one screen go away before the next one is shown.
    private let transitionDelay: Duration

    private var cancellables: [AnyCancellable] = []

    init(
        fetchRecipeInstructionsUseCase: FetchRecipeInstructionsUseCase = FetchRecipeInstructionsUseCaseImp(),
        saveBrewMethodUseCase: SaveBrewMethodUseCase = SaveBrewMethodUseCaseImp(),
        factory: MethodDraftFactory = MethodDraftFactory(),
        analyticsTracker: AnalyticsTracker = AnalyticsTrackerImp(),
        transitionDelay: Duration = .milliseconds(350),
        makeEditor: @escaping @MainActor (MethodDraft) -> MethodEditorViewModel = { MethodEditorViewModel(draft: $0) }
    ) {
        self.fetchRecipeInstructionsUseCase = fetchRecipeInstructionsUseCase
        self.saveBrewMethodUseCase = saveBrewMethodUseCase
        self.factory = factory
        self.analyticsTracker = analyticsTracker
        self.transitionDelay = transitionDelay
        self.makeEditor = makeEditor
    }

    var switchPromptTitle: String {
        guard let recipe, let savedCopy else { return "" }
        return "Brew \u{201C}\(recipe.recipeProfile.name)\u{201D} with \(savedCopy.title)?"
    }

    var switchTitle: String {
        "Switch to \(savedCopy?.title ?? "the copy")"
    }

    var keepTitle: String {
        "Keep \(recipe?.recipeProfile.brewMethod.title ?? "it")"
    }

    @MainActor
    func tweak(_ recipe: Recipe) async {
        let brewMethod = recipe.recipeProfile.brewMethod
        guard let instructions = try? await fetchRecipeInstructionsUseCase.fetch(brewMethod: brewMethod) else {
            didClose.send()
            return
        }
        self.recipe = recipe
        savedCopy = nil

        let draft = MethodDraftFactory.isOwn(brewMethod)
            ? factory.draft(editing: brewMethod, instructions: instructions)
            : factory.draft(copying: brewMethod, instructions: instructions)
        openEditor(with: draft)
    }

    @MainActor
    private func openEditor(with draft: MethodDraft) {
        let editor = makeEditor(draft)
        editor.didSave
            .sink { [weak self] brewMethod in self?.didSave(brewMethod) }
            .store(in: &cancellables)
        editor.didClose
            .sink { [weak self] in self?.close() }
            .store(in: &cancellables)
        methodEditor = editor
    }

    @MainActor
    private func close() {
        methodEditor = nil
        cancellables.removeAll()
        didClose.send()
    }

    @MainActor
    private func didSave(_ brewMethod: BrewMethod) {
        methodEditor = nil
        cancellables.removeAll()
        guard let recipe, !MethodDraftFactory.isOwn(recipe.recipeProfile.brewMethod) else {
            // The user's own method: Update everywhere already rebuilt the recipes using it.
            didFinish.send()
            return
        }
        savedCopy = brewMethod
        Task { @MainActor in
            try? await Task.sleep(for: transitionDelay)
            isSwitchPromptPresented = true
        }
    }

    /// Moves the recipe just brewed onto the saved copy, keeping its name, cups and amounts.
    @MainActor
    @discardableResult
    func switchToCopy() -> Task<Void, Never> {
        isSwitchPromptPresented = false
        let recipe = recipe
        let savedCopy = savedCopy
        self.savedCopy = nil
        return Task { @MainActor in
            if let recipe, let savedCopy {
                _ = try? await saveBrewMethodUseCase.switchRecipe(recipe, to: savedCopy)
            }
            trackSwitch(true)
            finish()
        }
    }

    /// The recipe stays on the built-in method. Also used when the prompt is dismissed without an answer.
    @MainActor
    func keepRecipe() {
        isSwitchPromptPresented = false
        guard savedCopy != nil else { return }
        savedCopy = nil
        trackSwitch(false)
        finish()
    }

    private func trackSwitch(_ switched: Bool) {
        analyticsTracker.track(event: AnalyticsEvent(
            name: "tweak_brew_recipe_switch",
            parameters: ["switched": switched]
        ))
    }

    @MainActor
    private func finish() {
        recipe = nil
        savedCopy = nil
        didFinish.send()
    }
}

extension View {
    /// Presents the method editor and the switch prompt of "Tweak this brew".
    func tweakBrew(_ viewModel: TweakBrewViewModel) -> some View {
        modifier(TweakBrewModifier(viewModel: viewModel))
    }
}

private struct TweakBrewModifier: ViewModifier {
    @ObservedObject var viewModel: TweakBrewViewModel

    func body(content: Content) -> some View {
        content
            .fullScreenCover(item: $viewModel.methodEditor) { editor in
                MethodEditorView(viewModel: editor)
                    .keyboardToolbarHost()
            }
            .confirmationDialog(
                viewModel.switchPromptTitle,
                isPresented: $viewModel.isSwitchPromptPresented,
                titleVisibility: .visible
            ) {
                Button(viewModel.switchTitle) {
                    viewModel.switchToCopy()
                }
                Button(viewModel.keepTitle, role: .cancel) {
                    viewModel.keepRecipe()
                }
            } message: {
                Text("The recipe keeps its name, cups and amounts and brews with the new steps.")
            }
            .onChange(of: viewModel.isSwitchPromptPresented) { _, isPresented in
                // Tapping outside the prompt keeps the recipe as it is.
                if !isPresented { viewModel.keepRecipe() }
            }
    }
}
