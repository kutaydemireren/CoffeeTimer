//
//  RecipeInstructionsRepositoryImp.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 01/06/2024.
//

import Foundation

//

protocol Request {

}

//

struct BrewRequest: Request {

}

//

protocol NetworkManager {
    // TODO: async
    func perform(request: Request) throws -> Data
}

struct NetworkManagerImp: NetworkManager {
    func perform(request: Request) throws -> Data {
        fatalError("missing implementation")
    }
}

//

struct RecipeInstructionsRepositoryImp: RecipeInstructionsRepository {
    let networkManager: NetworkManager

    init(networkManager: NetworkManager = NetworkManagerImp()) {
        self.networkManager = networkManager
    }

    func fetchInstructions(for brewMethod: BrewMethod) throws -> RecipeInstructions {
        let data = try networkManager.perform(request: BrewRequest())
        return .empty
    }
}
