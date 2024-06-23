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
        // TODO: temp, revert
        // return [.v60Single]

        let data = try await networkManager.perform(request: FetchBrewMethodsRequest())
        let brewMethodDTOs = try decoding.decode([BrewMethodDTO].self, from: data)
        return map(brewMethodDTOs: brewMethodDTOs)
    }

    private func map(brewMethodDTOs: [BrewMethodDTO]) -> [BrewMethod] {
        brewMethodDTOs.map { brewMethodDTO in
            BrewMethod(
                id: brewMethodDTO.id,
                title: brewMethodDTO.title,
                path: brewMethodDTO.path,
                ratios: brewMethodDTO.ratios.compactMap { CoffeeToWaterRatio(rawValue: $0) }
            )
        }
    }
}
