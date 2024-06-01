//
//  BrewMethodRepositoryImp.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 01/06/2024.
//

import Foundation

struct BrewMethodRepositoryImp: BrewMethodRepository {
    let networkManager: NetworkManager

    init(networkManager: NetworkManager = NetworkManagerImp()) {
        self.networkManager = networkManager
    }

    func fetchBrewMethods() async throws -> [BrewMethod] {
        let _ = try await networkManager.perform(request: RecipeInstructionsRequest(brewMethod: .frenchPress))
        return []
    }
}
