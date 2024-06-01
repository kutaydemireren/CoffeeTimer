//
//  RecipeInstructionsRepositoryImp.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 01/06/2024.
//

import Foundation

protocol Decoding {
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T
}

extension JSONDecoder: Decoding { }

//

protocol NetworkManager {
    func perform(request: Request) async throws -> Data
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

    func fetchInstructions(for brewMethod: BrewMethod) async throws -> RecipeInstructions {
        let data = try await networkManager.perform(request: FetchRecipeInstructionsRequest(brewMethod: brewMethod))
        let recipeInstructions = try decoding.decode(RecipeInstructions.self, from: data)
        return recipeInstructions
    }
}
