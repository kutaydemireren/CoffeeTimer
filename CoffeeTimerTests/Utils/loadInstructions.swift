//
//  loadInstructions.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 02/06/2024.
//

import Foundation
@testable import CoffeeTimer

func loadMiniInstructions() -> RecipeInstructions {
    final class ClassForBundle { }
    guard let bundleURL = Bundle(for: ClassForBundle.self).url(forResource: "mini_instructions", withExtension: "json") else {
        fatalError("Instructions file not found in test bundle")
    }

    do {
        let data = try Data(contentsOf: bundleURL)
        let decoder = JSONDecoder()
        let recipe = try decoder.decode(RecipeInstructions.self, from: data)
        return recipe
    } catch {
        fatalError("Error decoding instructions: \(error)")
    }
}
