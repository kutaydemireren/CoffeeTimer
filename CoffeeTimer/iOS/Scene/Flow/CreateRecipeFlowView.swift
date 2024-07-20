//
//  CreateRecipeFlowView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 16/04/2023.
//

import SwiftUI
import Combine

final class CreateRecipeFlowViewModel: ObservableObject, Completable {
    enum Flow: Hashable {
        case createMethod
    }

    @Published var navigationPath: [Flow] = []
    @Published var context = CreateRecipeContext()

    var didComplete = PassthroughSubject<CreateRecipeFlowViewModel, Never>()

    private var cancellables: [AnyCancellable] = []

    func makeCreateMethodVM() -> CreateMethodFlowViewModel {
        let viewModel = CreateMethodFlowViewModel()
        viewModel.didComplete
            .sink(receiveValue: didComplete)
            .store(in: &cancellables)
        return viewModel
    }

    func close() {
        didComplete.send(self)
    }

    func crateCustomMethod() {
        navigationPath.append(.createMethod)
    }

    private func didComplete(_ viewModel: CreateMethodFlowViewModel) {
        navigationPath.removeAll { $0 == .createMethod }
    }
}

struct CreateRecipeFlowView: View {
    @StateObject var viewModel: CreateRecipeFlowViewModel
    
    var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            createRecipe
        }
        .navigationDestination(for: CreateRecipeFlowViewModel.Flow.self) { flow in
            switch flow {
            case .createMethod:
                createMethod
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
    
    @ViewBuilder
    var createRecipe: some View {
        CreateRecipeView(
            viewModel: CreateRecipeViewModel(),
            close: viewModel.close,
            createMethod: viewModel.crateCustomMethod
        )
        .environmentObject(viewModel.context)
    }

    @ViewBuilder
    var createMethod: some View {
        CreateMethodFlowView(viewModel: viewModel.makeCreateMethodVM())
        .environmentObject(viewModel.context)
    }
}

#Preview {
    CreateRecipeFlowView(viewModel: CreateRecipeFlowViewModel())
}
