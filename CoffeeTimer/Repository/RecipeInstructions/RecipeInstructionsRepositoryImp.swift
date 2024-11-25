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

struct RecipeInstructionsConstants {
    static let savedRecipeInstructionsKey = "savedRecipeInstructions"
}

struct RecipeInstructionsRepositoryImp: RecipeInstructionsRepository {
    private let savedInstructionsKey = RecipeInstructionsConstants.savedRecipeInstructionsKey

    private let networkManager: NetworkManager
    private let decoding: Decoding
    private let storage: Storage

    init(
        networkManager: NetworkManager = NetworkManagerImp(),
        decoding: Decoding = JSONDecoder(),
        storage: Storage = StorageImp(userDefaults: .standard)
    ) {
        self.networkManager = networkManager
        self.decoding = decoding
        self.storage = storage
    }

    func fetchInstructions(for brewMethod: BrewMethod) async throws -> RecipeInstructions {
        let data = try await networkManager.perform(request: FetchRecipeInstructionsRequest(brewMethod: brewMethod))
        let recipeInstructions = try decoding.decode(RecipeInstructions.self, from: data)
        return recipeInstructions
    }

    func save(instructions: RecipeInstructions) async throws {
        var newInstructions = getSavedInstructions()
        newInstructions.append(instructions)
        storage.save(newInstructions, forKey: savedInstructionsKey)
    }

    private func getSavedInstructions() -> [RecipeInstructions] {
        guard let instructions = storage.load(forKey: savedInstructionsKey) as [RecipeInstructions]? else {
            return []
        }
        return instructions
    }
}
