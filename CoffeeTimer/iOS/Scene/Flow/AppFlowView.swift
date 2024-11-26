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

    private var cancellables: [AnyCancellable] = []

    func makeBrewQueueVM() -> BrewQueueViewModel {
        let viewModel = BrewQueueViewModel()
        viewModel.didComplete
            .sink(receiveValue: didComplete)
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
}

struct FlowView_Previews: PreviewProvider {
    static var previews: some View {
        AppFlowView(viewModel: .init())
    }
}
