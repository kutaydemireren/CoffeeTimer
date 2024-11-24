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

extension PutActionModel {
    static var stub: Self {
        .init(
            requirement: .none,
            duration: 0,
            startMethod: .userInteractive,
            skipMethod: .userInteractive,
            message: "put msg",
            details: "dtl",
            ingredient: .coffee,
            mainFactor: 0.2,
            mainFactorOf: .stubTotalCoffe,
            adjustmentFactor: -0.1,
            adjustmentFactorOf: .stubTotalCoffe
        )
    }
}

extension KeywordItem {
    static var stubTotalCoffe: Self {
        return .init(keyword: "#total.coffee", title: "Total Coffee")
    }
}

extension PauseActionModel {
    static var stub: Self {
        .init(
            duration: 20,
            message: "pause msg",
            details: "dtl"
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
