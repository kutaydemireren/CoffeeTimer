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

    func getBrewMethods() async throws -> [BrewMethod] {
        let data = try await networkManager.perform(request: GetBrewMethodsRequest())
        var brewMethodDTOs = try decoding.decode([BrewMethodDTO].self, from: data)
        brewMethodDTOs.append(contentsOf: getSavedBrewMethodDTOs())
        return map(brewMethodDTOs: brewMethodDTOs)
    }

    func save(brewMethod: BrewMethod) async throws {
        var newBrewMethodDTOs = getSavedBrewMethodDTOs()
        newBrewMethodDTOs.append(map(brewMethod: brewMethod))
        storage.save(newBrewMethodDTOs, forKey: savedBrewMethodsKey)
    }

    func remove(brewMethod: BrewMethod) async throws {
        let removeBrewMethodDTO = map(brewMethod: brewMethod)
        var newBrewMethodDTOs = getSavedBrewMethodDTOs().filter { $0 != removeBrewMethodDTO }
        storage.save(newBrewMethodDTOs, forKey: savedBrewMethodsKey)
    }

    private func getSavedBrewMethodDTOs() -> [BrewMethodDTO] {
        if let brewMethodDTO = storage.load(forKey: savedBrewMethodsKey) as [BrewMethodDTO]? {
            return brewMethodDTO
        }
        return []
    }

    // MARK: BrewMethodDTO -> BrewMethod
    private func map(brewMethodDTOs: [BrewMethodDTO]) -> [BrewMethod] {
        brewMethodDTOs.map { brewMethodDTO in
                .init(
                    id: brewMethodDTO.id ?? "",
                    iconName: brewMethodDTO.icon ?? "recipe-profile-gooseneck-kettle",
                    title: brewMethodDTO.title ?? "",
                    path: brewMethodDTO.path ?? "",
                    isIcedBrew: brewMethodDTO.isIcedBrew ?? false,
                    cupsCount: map(cupsCountDTO: brewMethodDTO.cupsCount),
                    ratios: brewMethodDTO.ratios.map(map(ratio:)),
                    info: map(infoModel: brewMethodDTO.info, fallbackTitle: brewMethodDTO.title ?? "")
                )
        }
    }

    private func map(cupsCountDTO: CupsCountDTO?) -> CupsCount {
        guard let cupsCountDTO else { return CupsCount.unlimited }
        return .init(
            minimum: cupsCountDTO.minimum ?? CupsCount.unlimited.minimum,
            maximum: cupsCountDTO.maximum ?? CupsCount.unlimited.maximum
        )
    }

    private func map(ratio: CoffeeToWaterRatioDTO) -> CoffeeToWaterRatio {
        return .init(
            id: ratio.id ?? "",
            value: ratio.value ?? 0,
            title: ratio.title ?? ""
        )
    }

    private func map(infoModel: InfoModelDTO?, fallbackTitle: String) -> InfoModel {
        guard let infoModel else {
            return .init(title: fallbackTitle, body: "")
        }

        return .init(
            title: infoModel.title ?? "",
            source: infoModel.source,
            body: infoModel.body ?? ""
        )
    }

    // MARK: BrewMethod -> BrewMethodDTO
    private func map(brewMethod: BrewMethod) -> BrewMethodDTO {
        return .init(
            id: brewMethod.id,
            icon: brewMethod.iconName,
            title: brewMethod.title,
            path: brewMethod.path,
            isIcedBrew: brewMethod.isIcedBrew,
            cupsCount: map(cupsCount: brewMethod.cupsCount),
            ratios: brewMethod.ratios.map(map(ratio:)),
            info: map(infoModel: brewMethod.info)
        )
    }

    private func map(cupsCount: CupsCount) -> CupsCountDTO {
        return .init(
            minimum: cupsCount.minimum,
            maximum: cupsCount.maximum
        )
    }

    private func map(ratio: CoffeeToWaterRatio) -> CoffeeToWaterRatioDTO {
        return .init(
            id: ratio.id,
            value: ratio.value,
            title: ratio.title
        )
    }

    private func map(infoModel: InfoModel) -> InfoModelDTO {
        return .init(
            title: infoModel.title,
            source: infoModel.source,
            body: infoModel.body
        )
    }
}
