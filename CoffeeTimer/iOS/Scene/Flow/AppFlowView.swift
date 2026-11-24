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
    @Published private(set) var reviewPromptTrigger: ReviewPromptTrigger?
    private var recipeToEdit: Recipe?

    /// Created once, so a brew keeps running while this flow re-renders.
    let brewQueueViewModel: BrewQueueViewModel
    let tweakBrewViewModel: TweakBrewViewModel

    private let reviewPromptPolicy: ReviewPromptPolicy
    private let analyticsTracker: AnalyticsTracker

    private var cancellables: [AnyCancellable] = []

    init(
        brewQueueViewModel: BrewQueueViewModel = BrewQueueViewModel(),
        tweakBrewViewModel: TweakBrewViewModel = TweakBrewViewModel(),
        reviewPromptPolicy: ReviewPromptPolicy = ReviewPromptPolicyImp.shared,
        analyticsTracker: AnalyticsTracker = AnalyticsTrackerImp()
    ) {
        self.brewQueueViewModel = brewQueueViewModel
        self.tweakBrewViewModel = tweakBrewViewModel
        self.reviewPromptPolicy = reviewPromptPolicy
        self.analyticsTracker = analyticsTracker

        brewQueueViewModel.didComplete
            .sink(receiveValue: didComplete)
            .store(in: &cancellables)
        brewQueueViewModel.didRequestEdit
            .sink(receiveValue: didRequestEdit(_:))
            .store(in: &cancellables)
        brewQueueViewModel.didRequestTweak
            .sink { [weak tweakBrewViewModel] recipe in
                Task { @MainActor in await tweakBrewViewModel?.tweak(recipe) }
            }
            .store(in: &cancellables)
        tweakBrewViewModel.didClose
            .sink { [weak brewQueueViewModel] in brewQueueViewModel?.tweakDidClose() }
            .store(in: &cancellables)
        tweakBrewViewModel.didFinish
            .sink { [weak self] in self?.didFinishTweak() }
            .store(in: &cancellables)
    }

    /// A tweak was saved: back to the main screen, which shows the recipe as it brews now.
    private func didFinishTweak() {
        brewQueueViewModel.dismissPostBrew()
        brewQueueViewModel.refresh()
        takePendingReviewPrompt()
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
        brewQueueViewModel.refresh()
        takePendingReviewPrompt()
    }

    private func didRequestEdit(_ recipe: Recipe) {
        recipeToEdit = recipe
        isEditRecipePresented = true
    }

    func makeEditRecipeFlowVM() -> EditRecipeFlowViewModel {
        let vm = EditRecipeFlowViewModel(
            recipe: recipeToEdit ?? Recipe(
                recipeProfile: .empty,
                ingredients: [],
                brewQueue: .empty,
                cupsCount: 1,
                cupSize: 250.0
            )
        )
        vm.didComplete
            .sink(receiveValue: didComplete)
            .store(in: &cancellables)
        return vm
    }

    private func didComplete(_ viewModel: EditRecipeFlowViewModel) {
        isEditRecipePresented = false
        brewQueueViewModel.refresh()
        takePendingReviewPrompt()
    }

    /// Positive moments inside a flow (creating a recipe or method, editing amounts)
    /// are asked about once the flow is closed and the main screen is back.
    private func takePendingReviewPrompt() {
        reviewPromptTrigger = reviewPromptPolicy.takePendingTrigger()
    }

    /// Called by the main screen right before it asks the system for a review.
    func confirmReviewRequest(_ trigger: ReviewPromptTrigger) -> Bool {
        guard reviewPromptTrigger == trigger,
              !isRecipesPresented,
              !isEditRecipePresented,
              !brewQueueViewModel.isActive,
              !brewQueueViewModel.isPresentingPostBrew,
              !brewQueueViewModel.isPresentingGiftView else {
            reviewPromptTrigger = nil
            return false
        }
        reviewPromptTrigger = nil
        reviewPromptPolicy.didRequestReview()
        analyticsTracker.track(event: AnalyticsEvent(
            name: "review_prompt_requested",
            parameters: ["trigger": trigger.rawValue]
        ))
        return true
    }

    func configure() {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(named: "backgroundSecondary")
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(named: "backgroundSecondary")?.withAlphaComponent(0.3)
        UIPageControl.appearance().isUserInteractionEnabled = false
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
            .reviewPrompt(
                trigger: viewModel.reviewPromptTrigger,
                delay: .seconds(1),
                confirm: viewModel.confirmReviewRequest(_:)
            )
            .task {
                viewModel.configure()
            }
    }

    func brewQueue() -> some View {
        BrewQueueView(viewModel: viewModel.brewQueueViewModel)
            .tweakBrew(viewModel.tweakBrewViewModel)
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
