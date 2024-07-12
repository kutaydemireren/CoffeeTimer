//
//  CreateRecipeFlowView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 16/04/2023.
//

import SwiftUI
import Combine

final class CreateRecipeFlowViewModel: ObservableObject, Completable {
    var didComplete = PassthroughSubject<CreateRecipeFlowViewModel, Never>()
    
    @Published var context: CreateRecipeContext = CreateRecipeContext()
    
    func close() {
        didComplete.send(self)
    }
}

struct CreateRecipeFlowView: View {
    
    @StateObject var viewModel: CreateRecipeFlowViewModel
    
    var body: some View {
        createRecipe
    }
    
    var createRecipe: some View {
        CreateRecipeView(
            viewModel: CreateRecipeViewModel(),
            closeRequest: viewModel.close)
        .environmentObject(viewModel.context)
    }
}

struct CreateRecipeFlowView_Previews: PreviewProvider {
    static var previews: some View {
        return CreateRecipeFlowView(viewModel: CreateRecipeFlowViewModel())
    }
}
