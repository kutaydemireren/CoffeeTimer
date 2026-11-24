//
//  CreateRecipeFlowView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 16/04/2023.
//

import SwiftUI
import Combine

final class CreateRecipeFlowViewModel: ObservableObject, Completable {
    @Published var context = CreateRecipeContext()
    @Published var isStartChoicePresented = false
    @Published var methodEditor: MethodEditorViewModel?
    @Published private(set) var storedDraftName: String?

    var didComplete = PassthroughSubject<CreateRecipeFlowViewModel, Never>()

    private var cancellables: [AnyCancellable] = []

    @MainActor let createRecipeViewModel = CreateRecipeViewModel()

    private let fetchRecipeInstructionsUseCase: FetchRecipeInstructionsUseCase
    private let draftStore: MethodDraftStore
    private let factory: MethodDraftFactory

    init(
        fetchRecipeInstructionsUseCase: FetchRecipeInstructionsUseCase = FetchRecipeInstructionsUseCaseImp(),
        draftStore: MethodDraftStore = MethodDraftStoreImp(),
        factory: MethodDraftFactory = MethodDraftFactory()
    ) {
        self.fetchRecipeInstructionsUseCase = fetchRecipeInstructionsUseCase
        self.draftStore = draftStore
        self.factory = factory
    }

    /// "Or, create your own".
    @MainActor
    func createMethod() {
        storedDraftName = draftStore.load()?.name
        isStartChoicePresented = true
    }

    @MainActor
    func startFromScratch() {
        isStartChoicePresented = false
        openEditor(with: .scratch())
    }

    @MainActor
    func startFrom(_ brewMethod: BrewMethod) {
        isStartChoicePresented = false
        makeItMine(brewMethod)
    }

    @MainActor
    func continueDraft() {
        isStartChoicePresented = false
        guard let draft = draftStore.load() else { return }
        openEditor(with: draft)
    }

    @MainActor
    func makeItMine(_ brewMethod: BrewMethod) {
        Task {
            guard let instructions = try? await fetchRecipeInstructionsUseCase.fetch(brewMethod: brewMethod) else { return }
            let existingTitles = createRecipeViewModel.brewMethods.map(\.title)
            openEditor(with: factory.draft(copying: brewMethod, instructions: instructions, existingTitles: existingTitles))
        }
    }

    @MainActor
    func edit(_ brewMethod: BrewMethod) {
        Task {
            guard let instructions = try? await fetchRecipeInstructionsUseCase.fetch(brewMethod: brewMethod) else { return }
            openEditor(with: factory.draft(editing: brewMethod, instructions: instructions))
        }
    }

    @MainActor
    private func openEditor(with draft: MethodDraft) {
        let viewModel = MethodEditorViewModel(draft: draft)
        viewModel.didSave
            .sink { [weak self] brewMethod in self?.didSave(brewMethod) }
            .store(in: &cancellables)
        viewModel.didClose
            .sink { [weak self] in self?.methodEditor = nil }
            .store(in: &cancellables)
        // Let the start sheet go away before the editor covers the screen.
        Task {
            try? await Task.sleep(for: .milliseconds(350))
            methodEditor = viewModel
        }
    }

    @MainActor
    private func didSave(_ brewMethod: BrewMethod) {
        methodEditor = nil
        Task {
            await createRecipeViewModel.continueWith(savedMethod: brewMethod, in: context)
        }
    }
}

struct CreateRecipeFlowView: View {
    @StateObject var viewModel: CreateRecipeFlowViewModel

    var body: some View {
        createRecipe
            .sheet(isPresented: $viewModel.isStartChoicePresented) {
                MethodStartChoiceView(
                    brewMethods: viewModel.createRecipeViewModel.brewMethods,
                    draftName: viewModel.storedDraftName,
                    startFromScratch: viewModel.startFromScratch,
                    startFrom: viewModel.startFrom(_:),
                    continueDraft: viewModel.continueDraft,
                    close: { viewModel.isStartChoicePresented = false }
                )
            }
            .fullScreenCover(item: $viewModel.methodEditor) { editor in
                MethodEditorView(viewModel: editor)
                    .keyboardToolbarHost()
            }
    }

    @ViewBuilder
    var createRecipe: some View {
        CreateRecipeView(
            viewModel: viewModel.createRecipeViewModel,
            close: viewModel.close,
            createMethod: viewModel.createMethod,
            makeItMine: viewModel.makeItMine(_:),
            editMethod: viewModel.edit(_:)
        )
        .environmentObject(viewModel.context)
    }
}

#Preview {
    CreateRecipeFlowView(viewModel: CreateRecipeFlowViewModel())
}
