//
//  EditRecipeAmountsViewModel.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 24/10/2025.
//

import Foundation
import Combine

@MainActor
final class EditRecipeAmountsViewModel: ObservableObject {
    @Published var allRatios: [CoffeeToWaterRatio] = []
    @Published var context = CreateRecipeContext()

    private let configureContextFromRecipeUseCase: ConfigureContextFromRecipeUseCase
    private let updateRecipeFromContextUseCase: UpdateRecipeFromContextUseCase
    private var originalRecipeId: UUID?
    private var analyticsTracker: AnalyticsTracker

    init(
        configureContextFromRecipeUseCase: ConfigureContextFromRecipeUseCase = ConfigureContextFromRecipeUseCaseImp(),
        updateRecipeFromContextUseCase: UpdateRecipeFromContextUseCase = UpdateRecipeFromContextUseCaseImp(),
        analyticsTracker: AnalyticsTracker = AnalyticsTrackerImp()
    ) {
        self.configureContextFromRecipeUseCase = configureContextFromRecipeUseCase
        self.updateRecipeFromContextUseCase = updateRecipeFromContextUseCase
        self.analyticsTracker = analyticsTracker
    }

    func configure(with recipe: Recipe) {
        originalRecipeId = recipe.id
        allRatios = recipe.recipeProfile.brewMethod.ratios
        
        configureContextFromRecipeUseCase.configure(context: context, from: recipe, with: allRatios)
        analyticsTracker.track(event: AnalyticsEvent(name: "edit_amounts_opened"))
    }

    func saveChanges() async {
        guard let recipeId = originalRecipeId else { return }
        _ = await updateRecipeFromContextUseCase.update(recipeId: recipeId, from: context)
        analyticsTracker.track(event: AnalyticsEvent(name: "edit_amounts_saved"))
    }
    
    func trackCancel() {
        analyticsTracker.track(event: AnalyticsEvent(name: "edit_amounts_cancelled"))
    }
}
