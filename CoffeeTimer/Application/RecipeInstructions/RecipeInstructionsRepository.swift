//
//  RecipeInstructionsRepository.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 01/06/2024.
//

import Foundation

protocol RecipeInstructionsRepository {
    func fetchInstructions(for brewMethod: BrewMethod) throws -> RecipeInstructions
}
