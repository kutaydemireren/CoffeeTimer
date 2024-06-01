//
//  Entities+Identifiable.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 29/05/2023.
//

import Foundation

extension Recipe: Identifiable {
    var id: String {
        recipeProfile.id
    }
}

extension RecipeProfile: Identifiable {
    var id: String {
        name + "_" + icon.id
    }
}

extension RecipeProfileIcon: Identifiable {
    var id: String {
        title
    }
}

extension BrewMethod: Identifiable { }
