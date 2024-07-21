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

    var didComplete = PassthroughSubject<CreateRecipeFlowViewModel, Never>()

    private var cancellables: [AnyCancellable] = []

    func close() {
        didComplete.send(self)
    }
}

struct CreateRecipeFlowView: View {
    @StateObject var viewModel: CreateRecipeFlowViewModel
    
    var body: some View {
        createRecipe
    }
    
    @ViewBuilder
    var createRecipe: some View {
        CreateRecipeView(
            viewModel: CreateRecipeViewModel(),
            close: viewModel.close
        )
        .environmentObject(viewModel.context)
    }
}

#Preview {
    CreateRecipeFlowView(viewModel: CreateRecipeFlowViewModel())
}
