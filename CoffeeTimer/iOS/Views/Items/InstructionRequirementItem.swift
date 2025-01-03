//
//  InstructionRequirementItem.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 22/07/2024.
//

import Foundation

enum InstructionRequirementItem: String, Titled, Hashable, Identifiable, CaseIterable {
    var id: Self {
        return self
    }

    var title: String {
        return rawValue.capitalized
    }

    case `none` = "none"
    case countdown = "countdown"
}
