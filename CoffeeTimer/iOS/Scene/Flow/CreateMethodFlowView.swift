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

    private var selectedInstruction: RecipeInstructionActionItem?
    var selectedInstructionIndex: Int? {
        return context.instructions.firstIndex(where: { $0.id == selectedInstruction?.id })
    }

    @Published var context = CreateMethodContext()
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

    func didSelect(_ item: RecipeInstructionActionItem) {
        selectedInstruction = item
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
        .tint(Color("backgroundSecondary"))
    }

    @ViewBuilder
    var createMethod: some View {
        CreateMethodView(viewModel: viewModel.makeCreateMethodVM())
            .environmentObject(viewModel.context)
    }

    @ViewBuilder
    func editInstructionIfSelected() -> some View {
        if let index = viewModel.selectedInstructionIndex {
            RecipeInstructionActionView(item: $viewModel.context.instructions[index])
        }
    }
}

#Preview {
    CreateMethodFlowView(viewModel: CreateMethodFlowViewModel())
}
