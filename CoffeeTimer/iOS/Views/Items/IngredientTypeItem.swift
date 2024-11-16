//
//  IngredientTypeItem.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 22/07/2024.
//

import Foundation

enum IngredientTypeItem: String, Titled, Hashable, Identifiable, CaseIterable {
    var id: Self {
        return self
    }

    var title: String {
        return rawValue.capitalized
    }

    case coffee = "coffee"
    case water = "water"
    case ice = "ice"
}
