//
//  FlowView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 11/04/2023.
//

import Foundation
import Combine
import SwiftUI

final class AppFlowViewModel: ObservableObject {
    @Published var isRecipesPresented = false
    @Published var isEditRecipePresented = false
    private var recipeToEdit: Recipe?

    private var cancellables: [AnyCancellable] = []

    func makeBrewQueueVM() -> BrewQueueViewModel {
        let viewModel = BrewQueueViewModel()
        viewModel.didComplete
            .sink(receiveValue: didComplete)
            .store(in: &cancellables)
        viewModel.didRequestEdit
            .sink(receiveValue: didRequestEdit(_:))
            .store(in: &cancellables)
        return viewModel
    }

    func makeRecipesFlowVM() -> RecipesFlowViewModel {
        let viewModel = RecipesFlowViewModel()
        viewModel.didComplete
            .sink(receiveValue: didComplete)
            .store(in: &cancellables)
        return viewModel
    }

    private func didComplete(viewModel: BrewQueueViewModel) {
        isRecipesPresented = true
    }

    private func didComplete(viewModel: RecipesFlowViewModel) {
        isRecipesPresented = false
    }

    private func didRequestEdit(_ recipe: Recipe) {
        recipeToEdit = recipe
        isEditRecipePresented = true
    }

    func makeEditRecipeFlowVM() -> EditRecipeFlowViewModel {
        let vm = EditRecipeFlowViewModel(recipe: recipeToEdit ?? Recipe(recipeProfile: .empty, ingredients: [], brewQueue: .empty))
        vm.didComplete
            .sink(receiveValue: didComplete)
            .store(in: &cancellables)
        return vm
    }

    private func didComplete(_ viewModel: EditRecipeFlowViewModel) {
        isEditRecipePresented = false
    }

    func configure() {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(named: "backgroundSecondary")
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(named: "backgroundSecondary")?.withAlphaComponent(0.3)
    }
}

struct AppFlowView: View {
    @StateObject var viewModel: AppFlowViewModel

    var body: some View {
        brewQueue()
            .fullScreenCover(isPresented: $viewModel.isRecipesPresented) {
                recipes()
            }
            .sheet(isPresented: $viewModel.isEditRecipePresented) {
                editRecipe()
            }
            .task {
                viewModel.configure()
            }
    }

    func brewQueue() -> some View {
        BrewQueueView(viewModel: viewModel.makeBrewQueueVM())
    }

    func recipes() -> some View {
        RecipesFlowView(viewModel: viewModel.makeRecipesFlowVM())
    }

    func editRecipe() -> some View {
        EditRecipeFlowView(viewModel: viewModel.makeEditRecipeFlowVM())
    }
}

struct FlowView_Previews: PreviewProvider {
    static var previews: some View {
        AppFlowView(viewModel: .init())
    }
}
