//
//  EditRecipeFlowView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 24/10/2025.
//

import SwiftUI
import Combine

final class EditRecipeFlowViewModel: ObservableObject, Completable {
    @Published var recipe: Recipe
    var didComplete = PassthroughSubject<EditRecipeFlowViewModel, Never>()

    private var onSaved: (() -> Void)?

    init(recipe: Recipe, onSaved: (() -> Void)? = nil) {
        self.recipe = recipe
        self.onSaved = onSaved
    }

    func saved() {
        onSaved?()
    }
}

struct EditRecipeFlowView: View {
    @StateObject var viewModel: EditRecipeFlowViewModel

    var body: some View {
        EditRecipeAmountsView(recipe: viewModel.recipe) {
            viewModel.saved()
            viewModel.close()
        }
    }
}

