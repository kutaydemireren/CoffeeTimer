//
//  CreateMethodFlowView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 20/07/2024.
//

import SwiftUI
import Combine

final class CreateMethodFlowViewModel: ObservableObject, Completable {
    enum Flow: Hashable {
        case editInstruction
    }

    // TODO: revert this back to simple init
    @Published var context: CreateMethodContext = {
        let context = CreateMethodContext()
        context.instructions = .stub
        return context
    }()
    @Published var navigationPath: [Flow] = []

    var didComplete = PassthroughSubject<CreateMethodFlowViewModel, Never>()

    private var cancellables: [AnyCancellable] = []

    func makeCreateMethodVM() -> CreateMethodViewModel {
        let viewModel = CreateMethodViewModel()
        viewModel.didComplete
            .sink(receiveValue: didComplete(_:))
            .store(in: &cancellables)
        viewModel.didSelect
            .sink(receiveValue: didSelect(_:))
            .store(in: &cancellables)
        return viewModel
    }

    func didComplete(_ viewModel: CreateMethodViewModel) {
        close()
    }

    func didSelect(_ item: RecipeInstructionStepItem) {
        context.selectedInstruction = item
        navigationPath.append(.editInstruction)
    }
}

struct CreateMethodFlowView: View {
    @StateObject var viewModel: CreateMethodFlowViewModel

    var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            createMethod
                .navigationDestination(for: CreateMethodFlowViewModel.Flow.self) { flow in
                    switch flow {
                    case .editInstruction:
                        editInstructionIfSelected()
                    }
                }
        }
    }

    @ViewBuilder
    var createMethod: some View {
        CreateMethodView(viewModel: viewModel.makeCreateMethodVM())
            .environmentObject(viewModel.context)
    }

    @ViewBuilder
    func editInstructionIfSelected() -> some View {
        if let selectedInstruction = viewModel.context.selectedInstruction {
            RecipeInstructionStepItemView(item: selectedInstruction)
        } else {
            EmptyView()
        }
    }
}

#Preview {
    CreateMethodFlowView(viewModel: CreateMethodFlowViewModel())
}
