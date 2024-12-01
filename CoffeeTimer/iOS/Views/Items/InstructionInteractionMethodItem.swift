//
//  InstructionInteractionMethodItem.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 22/07/2024.
//

import Foundation

enum InstructionInteractionMethodItem: String, Titled, Hashable, Identifiable, CaseIterable {
    var id: Self {
        return self
    }

    var title: String {
        switch self {
        case .auto:
            return "Auto"
        case .userInteractive:
            return "User Interactive"
        }
    }

    case auto
    case userInteractive
}
