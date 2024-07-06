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
        let data = try await networkManager.perform(request: FetchBrewMethodsRequest())
        let brewMethodDTOs = try decoding.decode([BrewMethodDTO].self, from: data)
        return map(brewMethodDTOs: brewMethodDTOs)
    }

    private func map(brewMethodDTOs: [BrewMethodDTO]) -> [BrewMethod] {
        brewMethodDTOs.map { brewMethodDTO in
            BrewMethod(
                id: brewMethodDTO.id ?? "",
                title: brewMethodDTO.title ?? "",
                path: brewMethodDTO.path ?? "", 
                cupsCount: map(cupsCountDTO: brewMethodDTO.cupsCount),
                ratios: brewMethodDTO.ratios.map(map(ratio:))
            )
        }
    }

    private func map(cupsCountDTO: CupsCountDTO?) -> CupsCount {
        guard let cupsCountDTO else { return CupsCount.unlimited }
        return CupsCount(
            minimum: cupsCountDTO.minimum ?? CupsCount.unlimited.minimum,
            maximum: cupsCountDTO.maximum ?? CupsCount.unlimited.maximum
        )
    }

    private func map(ratio: CoffeeToWaterRatioDTO) -> CoffeeToWaterRatio {
        return CoffeeToWaterRatio(
            id: ratio.id ?? "",
            value: ratio.value ?? 0,
            title: ratio.title ?? ""
        )
    }
}
