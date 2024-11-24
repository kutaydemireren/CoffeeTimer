//
//  RecipeInstructionsRepository.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 01/06/2024.
//

import Foundation

protocol RecipeInstructionsRepository {
    func save(instructions: RecipeInstructions) async throws
    func fetchInstructions(for brewMethod: BrewMethod) async throws -> RecipeInstructions
}
