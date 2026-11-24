//
//  RecipeInstructionStep+Stub.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 24/11/2026.
//

import Foundation
@testable import CoffeeTimer

extension RecipeInstructionStep {
    static var stubPut: Self {
        .init(
            action: .put,
            instructionAction: PutInstructionAction.stub
        )
    }

    static var stubPause: Self {
        .init(
            action: .pause,
            instructionAction: PauseInstructionAction.stub
        )
    }

    static var stubMessage: Self {
        .init(
            action: .message,
            instructionAction: MessageInstructionAction.stub
        )
    }
}

extension PutInstructionAction {
    static var stub: Self {
        .init(
            requirement: .unknown,
            startMethod: .userInteractive,
            skipMethod: .userInteractive,
            message: "put msg",
            details: "dtl",
            ingredient: .coffee,
            amount: .init(
                type: .gram,
                mainFactor: .init(factor: 0.2, factorOf: "#total.coffee"),
                adjustmentFactor: .init(factor: -0.1, factorOf: "#total.coffee")
            )
        )
    }
}

extension PauseInstructionAction {
    static var stub: Self {
        .init(
            requirement: .countdown(20),
            startMethod: .auto,
            skipMethod: .auto,
            message: "pause msg",
            details: "dtl"
        )
    }
}

extension MessageInstructionAction {
    static var stub: Self {
        .init(
            requirement: .unknown,
            startMethod: .userInteractive,
            skipMethod: .userInteractive,
            message: "message msg",
            details: "dtl"
        )
    }
}
