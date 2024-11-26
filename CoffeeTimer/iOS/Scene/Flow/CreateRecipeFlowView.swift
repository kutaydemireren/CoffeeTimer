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
    @Published var isCreateMethodPresented = false

    var didComplete = PassthroughSubject<CreateRecipeFlowViewModel, Never>()

    private var cancellables: [AnyCancellable] = []

    @MainActor let createRecipeViewModel = CreateRecipeViewModel()

    func makeCreateMethodVM() -> CreateMethodFlowViewModel {
        let viewModel = CreateMethodFlowViewModel()
        viewModel.didComplete
            .sink(receiveValue: didComplete)
            .store(in: &cancellables)
        return viewModel
    }

    func crateMethod() {
        isCreateMethodPresented = true
    }

    private func didComplete(_ viewModel: CreateMethodFlowViewModel) {
        isCreateMethodPresented = false
        Task {
            await createRecipeViewModel.refreshBrewMethods()
        }
    }
}

struct CreateRecipeFlowView: View {
    @StateObject var viewModel: CreateRecipeFlowViewModel

    var body: some View {
        createRecipe
            .fullScreenCover(isPresented: $viewModel.isCreateMethodPresented) {
                createMethod
            }
    }

    @ViewBuilder
    var createRecipe: some View {
        CreateRecipeView(
            viewModel: viewModel.createRecipeViewModel,
            close: viewModel.close,
            createMethod: viewModel.crateMethod
        )
        .environmentObject(viewModel.context)
    }

    @ViewBuilder
    var createMethod: some View {
        CreateMethodFlowView(viewModel: viewModel.makeCreateMethodVM())
    }
}

#Preview {
    CreateRecipeFlowView(viewModel: CreateRecipeFlowViewModel())
}
