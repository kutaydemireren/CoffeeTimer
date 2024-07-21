//
//  RecipesFlowView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 10/05/2023.
//

import SwiftUI
import Combine

final class RecipesFlowViewModel: ObservableObject, Completable {
    enum Flow: Hashable {
        case createRecipe
    }

    @Published var navigationPath: [Flow] = []

    var didComplete = PassthroughSubject<RecipesFlowViewModel, Never>()

    private var cancellables: [AnyCancellable] = []

    func makeRecipesVM() -> RecipesViewModel {
        let viewModel = RecipesViewModel()
        viewModel.didComplete
            .sink(receiveValue: didComplete(_:))
            .store(in: &cancellables)
        viewModel.didCreate
            .sink(receiveValue: didCreate(_:))
            .store(in: &cancellables)
        return viewModel
    }

    func makeCreateRecipeFlowVM() -> CreateRecipeFlowViewModel {
        let viewModel = CreateRecipeFlowViewModel()
        viewModel.didComplete
            .sink(receiveValue: didComplete)
            .store(in: &cancellables)
        return viewModel
    }

    func close() {
        didComplete.send(self)
    }

    private func didComplete(_ recipesViewModel: RecipesViewModel) {
        close()
    }

    private func didCreate(_ recipesViewModel: RecipesViewModel) {
        navigationPath.append(.createRecipe)
    }

    private func didComplete(_ viewModel: CreateRecipeFlowViewModel) {
        navigationPath.removeAll { $0 == .createRecipe }
    }
}

struct RecipesFlowView: View {
    @StateObject var viewModel: RecipesFlowViewModel

    var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            recipes()
                .navigationDestination(for: RecipesFlowViewModel.Flow.self) { flow in
                    switch flow {
                    case .createRecipe:
                        createRecipe()
                            .navigationBarBackButtonHidden(true)
                    }
                }
        }
    }

    func recipes() -> some View {
        return RecipesView(viewModel: viewModel.makeRecipesVM())
    }

    func createRecipe() -> some View {
        CreateRecipeFlowView(viewModel: viewModel.makeCreateRecipeFlowVM())
    }
}

struct RecipesFlowView_Previews: PreviewProvider {
    static var previews: some View {
        return RecipesFlowView(viewModel: RecipesFlowViewModel())
    }
}
