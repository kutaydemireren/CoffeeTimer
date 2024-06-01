//
//  BrewMethodRepositoryImp.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 01/06/2024.
//

import Foundation

struct BrewMethodRepositoryImp: BrewMethodRepository {
    let networkManager: NetworkManager
    let decoding: Decoding

    init(
        networkManager: NetworkManager = NetworkManagerImp(),
        decoding: Decoding = JSONDecoder()
    ) {
        self.networkManager = networkManager
        self.decoding = decoding
    }

    func fetchBrewMethods() async throws -> [BrewMethod] {
        let data = try await networkManager.perform(request: RecipeInstructionsRequest(brewMethod: .frenchPress))
        let _ = try decoding.decode(RecipeInstructions.self, from: data)
        return []
    }
}
