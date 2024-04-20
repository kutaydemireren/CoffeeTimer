//
//  RecipeInstructionsTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 20/04/2024.
//

import XCTest

//

struct RecipeInstructions: Decodable {
    let ingredients: [String]
    let steps: [RecipeInstructionStep]
}

struct RecipeInstructionStep: Decodable {
    private enum Action: Decodable {
        case unknown
        case put
        case message
        case pause
    }

    enum CodingKeys: CodingKey {
        case action
    }

    let instructionAction: InstructionAction?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let action = (try? container.decode(Action.self, forKey: .action)) ?? .unknown

        switch action {
        case .put:
            instructionAction = try? PutInstructionAction(from: decoder)
        case .message:
            instructionAction = try? MessageInstructionAction(from: decoder)
        case .pause:
            instructionAction = try? PauseInstructionAction(from: decoder)
        case .unknown:
            instructionAction = nil
        }
    }

}

protocol InstructionAction: Decodable { 
    var message: String? { get }
}

struct MessageInstructionAction: InstructionAction {
    let message: String?
}

struct PutInstructionAction: InstructionAction {
    struct Amount: Codable {
        let type: String?
        let factor: Double?
        let factorOf: String?
        let constant: Double?
    }

    let ingredient: String?
    let amount: Amount?
    let message: String?
}

struct PauseInstructionAction: InstructionAction {
    struct Duration: Codable {
        let type: String?
        let length: Int?
    }

    let ingredient: String?
    let duration: Duration?
    let message: String?
}

//

final class RecipeInstructionsTests: XCTestCase {

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }
}
