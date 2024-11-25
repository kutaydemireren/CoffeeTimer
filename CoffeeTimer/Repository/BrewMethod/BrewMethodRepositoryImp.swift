//
//  BrewMethodRepositoryImp.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 01/06/2024.
//

import Foundation

struct BrewMethodConstants {
    static let savedBrewMethodsKey = "savedBrewMethods"
}

struct BrewMethodRepositoryImp: BrewMethodRepository {
    private let savedBrewMethodsKey = BrewMethodConstants.savedBrewMethodsKey

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
                isIcedBrew: brewMethodDTO.isIcedBrew ?? false,
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

    func save(brewMethod: BrewMethod) async throws {
        var newBrewMethodDTOs = getSavedBrewMethodDTOs()
        newBrewMethodDTOs.append(map(brewMethod: brewMethod))
        storage.save(newBrewMethodDTOs, forKey: savedBrewMethodsKey)
    }

    private func map(brewMethod: BrewMethod) -> BrewMethodDTO {
        return .init(
            id: brewMethod.id,
            title: brewMethod.title,
            path: brewMethod.path,
            isIcedBrew: brewMethod.isIcedBrew,
            cupsCount: map(cupsCount: brewMethod.cupsCount),
            ratios: brewMethod.ratios.map(map(ratio:))
        )
    }

    private func map(cupsCount: CupsCount) -> CupsCountDTO {
        return CupsCountDTO(
            minimum: cupsCount.minimum,
            maximum: cupsCount.maximum
        )
    }

    private func map(ratio: CoffeeToWaterRatio) -> CoffeeToWaterRatioDTO {
        return CoffeeToWaterRatioDTO(
            id: ratio.id,
            value: ratio.value,
            title: ratio.title
        )
    }

    private func getSavedBrewMethodDTOs() -> [BrewMethodDTO] {
        if let brewMethodDTO = storage.load(forKey: savedBrewMethodsKey) as [BrewMethodDTO]? {
            return brewMethodDTO
        }
        return []
    }
}
