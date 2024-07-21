//
//  CreateMethodFlowView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 20/07/2024.
//

import SwiftUI
import Combine

final class CreateMethodFlowViewModel: ObservableObject, Completable {
    @Published var context = CreateMethodContext()

    var didComplete = PassthroughSubject<CreateMethodFlowViewModel, Never>()

    private var cancellables: [AnyCancellable] = []

    func makeCreateMethodVM() -> CreateMethodViewModel {
        let viewModel = CreateMethodViewModel()
        viewModel.didComplete
            .sink(receiveValue: didComplete(_:))
            .store(in: &cancellables)
        return viewModel
    }

    func didComplete(_ viewModel: CreateMethodViewModel) {
        close()
    }
}

struct CreateMethodFlowView: View {
    @StateObject var viewModel: CreateMethodFlowViewModel

    var body: some View {
        createMethod
    }

    @ViewBuilder
    var createMethod: some View {
        CreateMethodView(viewModel: viewModel.makeCreateMethodVM())
            .environmentObject(viewModel.context)
    }
}

#Preview {
    CreateMethodFlowView(viewModel: CreateMethodFlowViewModel())
}
