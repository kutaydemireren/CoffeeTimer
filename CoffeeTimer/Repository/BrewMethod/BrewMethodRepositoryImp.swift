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

    /// Adds the method, or replaces the saved method with the same id in place.
    func save(brewMethod: BrewMethod) async throws {
        var newBrewMethodDTOs = getSavedBrewMethodDTOs()
        let brewMethodDTO = map(brewMethod: brewMethod)
        if let index = newBrewMethodDTOs.firstIndex(where: { $0.id == brewMethod.id }) {
            newBrewMethodDTOs[index] = brewMethodDTO
        } else {
            newBrewMethodDTOs.append(brewMethodDTO)
        }
        storage.save(newBrewMethodDTOs, forKey: savedBrewMethodsKey)
    }

    func remove(brewMethod: BrewMethod) async throws {
        let newBrewMethodDTOs = getSavedBrewMethodDTOs().filter { $0.id != brewMethod.id }
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
                    info: map(infoModel: brewMethodDTO.info, fallbackTitle: brewMethodDTO.title ?? ""),
                    referenceDose: brewMethodDTO.referenceDose?.map()
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
            body: infoModel.body ?? "",
            animation: infoModel.animation
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
            info: map(infoModel: brewMethod.info),
            referenceDose: brewMethod.referenceDose.map(ReferenceDoseDTO.init(referenceDose:))
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
            body: infoModel.body,
            animation: infoModel.animation
        )
    }
}
