//
//  Instructions+Stub.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 22/07/2024.
//

import Foundation

extension RecipeInstructionActionItem {
    static var stubPut: Self {
        .init(
            action: .put(.stub)
        )
    }

    static var stubPause: Self {
        .init(
            action: .pause(.stub)
        )
    }

    static var stubMessage: Self {
        .init(
            action: .message(.stub)
        )
    }
}

extension PutInstructionActionViewModel {
    static var stub: Self {
        .init(
            requirement: .none,
            startMethod: .userInteractive,
            skipMethod: .userInteractive,
            message: "put msg",
            details: "dtl",
            ingredient: .coffee,
            amount: ""
        )
    }
}

extension PauseInstructionActionViewModel {
    static var stub: Self {
        .init(
            message: "pause msg",
            details: "dtl",
            duration: 20
        )
    }
}

extension MessageActionModel {
    static var stub: Self {
        .init(
            message: "message msg",
            details: "dtl"
        )
    }
}
