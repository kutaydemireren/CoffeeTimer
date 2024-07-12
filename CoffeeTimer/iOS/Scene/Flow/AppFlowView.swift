//
//  FlowView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 11/04/2023.
//

import Foundation
import Combine
import SwiftUI

final class FlowViewModel: ObservableObject {
    
    @Published var navigationPath: [Screen] = []
    @Published var isRecipesPresented = false
    
    private var cancellables: [AnyCancellable] = []
    
    func make1() -> BrewQueueViewModel {
        let viewModel = BrewQueueViewModel()
        viewModel.didComplete
            .sink(receiveValue: didComplete)
            .store(in: &cancellables)
        return viewModel
    }
    
    func make2() -> CreateRecipeFlowViewModel {
        let viewModel = CreateRecipeFlowViewModel()
        viewModel.didComplete
            .sink(receiveValue: didComplete)
            .store(in: &cancellables)
        return viewModel
    }
    
    func make3() -> RecipesFlowViewModel {
        let viewModel = RecipesFlowViewModel()
        viewModel.didComplete
            .sink(receiveValue: didComplete)
            .store(in: &cancellables)
        return viewModel
    }
    
    private func didComplete(viewModel: BrewQueueViewModel) {
        isRecipesPresented = true
    }
    
    private func didComplete(viewModel: CreateRecipeFlowViewModel) {
        isRecipesPresented = false
    }
    
    private func didComplete(viewModel: RecipesFlowViewModel) {
        isRecipesPresented = false
    }
}

struct AppFlowView: View {
    
    @StateObject var viewModel: FlowViewModel
    
    var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            VStack() {
                brewQueue()
            }
            .navigationDestination(for: Screen.self) { screen in
                switch screen {
                case .brewQueue:
                    brewQueue()
                case .createRecipe:
                    createRecipe()
                case .recipesFlowView:
                    recipes()
                }
            }
        }
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .fullScreenCover(isPresented: $viewModel.isRecipesPresented) {
            recipes()
        }
    }
    
    func brewQueue() -> some View {
        BrewQueueView(viewModel: viewModel.make1())
    }
    
    func createRecipe() -> some View {
        CreateRecipeFlowView(viewModel: viewModel.make2())
    }
    
    func recipes() -> some View {
        RecipesFlowView(viewModel: viewModel.make3())
    }
}

struct FlowView_Previews: PreviewProvider {
    static var previews: some View {
        AppFlowView(viewModel: .init())
    }
}
