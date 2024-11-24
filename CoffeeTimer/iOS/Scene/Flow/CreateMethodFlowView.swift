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
        case updateInstruction
    }

    private var selectedInstruction: RecipeInstructionActionItem?
    var selectedInstructionIndex: Int? {
        return context.instructions.firstIndex(where: { $0.id == selectedInstruction?.id })
    }

    @Published var context = CreateBrewMethodContext()
    @Published var navigationPath: [Flow] = []

    var didComplete = PassthroughSubject<CreateMethodFlowViewModel, Never>()

    private var cancellables: [AnyCancellable] = []

    func makeCreateMethodVM() -> CreateMethodViewModel {
        let viewModel = CreateMethodViewModel()
        return viewModel
    }

    func didSelect(_ item: RecipeInstructionActionItem) {
        selectedInstruction = item
        navigationPath.append(.updateInstruction)
    }
}

struct CreateMethodFlowView: View {
    @StateObject var viewModel: CreateMethodFlowViewModel

    var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            createMethod
                .navigationDestination(for: CreateMethodFlowViewModel.Flow.self) { flow in
                    switch flow {
                    case .updateInstruction:
                        editInstructionIfSelected()
                    }
                }
        }
        .tint(Color("backgroundSecondary"))
    }

    @ViewBuilder
    var createMethod: some View {
        CreateMethodView(
            viewModel: viewModel.makeCreateMethodVM(),
            close: viewModel.close,
            selectItem: viewModel.didSelect(_:)
        )
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
