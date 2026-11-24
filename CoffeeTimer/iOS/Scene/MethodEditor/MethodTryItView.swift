//
//  MethodTryItView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 24/11/2026.
//

import SwiftUI
import Combine

/// Plays a method on the real brew screen with shorter timers, without saving anything.
struct MethodTryItView: View {
    let speedUp: UInt
    var close: () -> Void

    @StateObject private var viewModel: BrewQueueViewModel

    init(recipe: Recipe, speedUp: UInt, close: @escaping () -> Void) {
        self.speedUp = speedUp
        self.close = close
        _viewModel = StateObject(wrappedValue: BrewQueueViewModel(
            recipeRepository: DryRunRecipeRepository(recipe: recipe),
            analyticsTracker: SilentAnalyticsTracker(),
            reviewPromptPolicy: SilentReviewPromptPolicy()
        ))
    }

    var body: some View {
        BrewQueueView(viewModel: viewModel)
            .safeAreaInset(edge: .top, spacing: 0) {
                HStack {
                    Text("Trying it \u{00B7} timers \(speedUp)\u{00D7} faster")
                        .font(.subheadline)
                        .foregroundStyle(Color("foregroundPrimary"))
                    Spacer()
                    Button("Done", action: close)
                        .bold()
                        .foregroundStyle(Color("backgroundSecondary"))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .backgroundPrimary()
            }
            // The brew is not saved: the end of it, and "Recipes", lead back to the method screen.
            .onReceive(viewModel.$isPresentingPostBrew) { isPresenting in
                if isPresenting { close() }
            }
            .onReceive(viewModel.didComplete) { _ in close() }
    }
}

/// Holds the dry-run recipe in memory, so nothing reaches the saved recipes.
final class DryRunRecipeRepository: RecipeRepository {
    private let recipe: Recipe

    init(recipe: Recipe) {
        self.recipe = recipe
    }

    var recipesPublisher: AnyPublisher<[Recipe], Never> {
        Just([recipe]).eraseToAnyPublisher()
    }

    func getSelectedRecipe() -> Recipe? { recipe }
    func save(_ recipe: Recipe) { }
    func update(selectedRecipe: Recipe) { }
    func update(savedRecipe: Recipe) { }
    func remove(recipe: Recipe) { }
}

/// Try it is not a brew: it sends no analytics events.
struct SilentAnalyticsTracker: AnalyticsTracker {
    func track(event: AnalyticsEvent) { }
}

/// Try it is not a brew: it does not count toward the review prompt.
final class SilentReviewPromptPolicy: ReviewPromptPolicy {
    func record(_ event: ReviewPromptEvent) { }
    func takePendingTrigger() -> ReviewPromptTrigger? { nil }
    func didRequestReview() { }
}
