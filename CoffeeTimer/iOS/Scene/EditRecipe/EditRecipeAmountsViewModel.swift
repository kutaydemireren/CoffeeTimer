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

    init(
        configureContextFromRecipeUseCase: ConfigureContextFromRecipeUseCase = ConfigureContextFromRecipeUseCaseImp(),
        updateRecipeFromContextUseCase: UpdateRecipeFromContextUseCase = UpdateRecipeFromContextUseCaseImp()
    ) {
        self.configureContextFromRecipeUseCase = configureContextFromRecipeUseCase
        self.updateRecipeFromContextUseCase = updateRecipeFromContextUseCase
    }

    func configure(with recipe: Recipe) {
        originalRecipeId = recipe.id
        allRatios = recipe.recipeProfile.brewMethod.ratios
        
        configureContextFromRecipeUseCase.configure(context: context, from: recipe, with: allRatios)
    }

    func saveChanges() async {
        guard let recipeId = originalRecipeId else { return }
        _ = await updateRecipeFromContextUseCase.update(recipeId: recipeId, from: context)
    }
}
