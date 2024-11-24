//
//  IngredientAmountTypeItem.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 23/11/2024.
//

import Foundation

enum IngredientAmountTypeItem: String, Titled, Hashable, Identifiable, CaseIterable {
    var id: Self {
        return self
    }

    var title: String {
        return rawValue
    }

    case gram = "gram"
    case millilitre = "millilitre"
}

struct KeywordItem: Titled, Hashable, Identifiable {
    var id: Self {
        return self
    }

    let keyword: String
    let title: String
}
