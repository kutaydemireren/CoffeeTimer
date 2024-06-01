//
//  RecipeInstructionsRepositoryImp.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 01/06/2024.
//

import Foundation

// TODO: move

protocol Request {

}

//

struct BrewRequest: Request {

}

//

protocol Decoding {
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T
}

extension JSONDecoder: Decoding { }

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
    let decoding: Decoding

    init(
        networkManager: NetworkManager = NetworkManagerImp(),
        decoding: Decoding = JSONDecoder()
    ) {
        self.networkManager = networkManager
        self.decoding = decoding
    }

    func fetchInstructions(for brewMethod: BrewMethod) throws -> RecipeInstructions {
        let data = try networkManager.perform(request: BrewRequest())
        let recipeInstructions = try decoding.decode(RecipeInstructions.self, from: data)
        return .empty
    }
}
