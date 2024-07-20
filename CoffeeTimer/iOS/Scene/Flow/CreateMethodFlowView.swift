//
//  CreateMethodFlowView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 20/07/2024.
//

import SwiftUI
import Combine

final class CreateMethodFlowViewModel: ObservableObject, Completable {
    var didComplete = PassthroughSubject<CreateMethodFlowViewModel, Never>()

    @Published var context = CreateMethodContext()

    func close() {
        didComplete.send(self)
    }
}

struct CreateMethodFlowView: View {
    @StateObject var viewModel: CreateMethodFlowViewModel

    var body: some View {
        createMethod
    }

    @ViewBuilder
    var createMethod: some View {
        CreateMethodView(
            viewModel: CreateMethodViewModel(),
            closeRequest: viewModel.close
        )
        .environmentObject(viewModel.context)
    }
}

#Preview {
    CreateMethodFlowView(viewModel: CreateMethodFlowViewModel())
}
