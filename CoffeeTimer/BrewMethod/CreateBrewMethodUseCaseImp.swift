//
//  CreateBrewMethodUseCaseImp.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 24/11/2024.
//

import Foundation

// TODO: move

struct CustomMethodPathGenerator {
    static func generate(id: String) -> String {
        return "custom-method://\(id)"
    }
}

struct StaticCoffeetoWaterRatioGenerator {
    static func hotBrew() -> [CoffeeToWaterRatio] {
        return [
            .init(id: "1:16", value: 16, title: "1:16 - Strong"),
            .init(id: "1:17", value: 17, title: "1:17 - Robust"),
            .init(id: "1:18", value: 18, title: "1:18 - Medium"),
            .init(id: "1:19", value: 19, title: "1:19 - Mild"),
            .init(id: "1:20", value: 20, title: "1:20 - Delicate"),
        ]
    }

    static func icedBrew() -> [CoffeeToWaterRatio] {
        return [
            .init(id: "1:15", value: 15, title: "1:15 - Delicate"),
            .init(id: "1:16", value: 16, title: "1:16 - Strong"),
            .init(id: "1:17", value: 17, title: "1:17 - Robust"),
            .init(id: "1:18", value: 18, title: "1:18 - Medium"),
            .init(id: "1:19", value: 19, title: "1:19 - Mild")
        ]
    }
}

//

enum CreateBrewMethodUseCaseError: Error {
    case missingMethodTitle
    case missingInstructions
}

protocol CreateBrewMethodUseCase {
    func canCreate(from context: CreateBrewMethodContext) throws -> Bool
    func create(from context: CreateBrewMethodContext) async throws
}

struct CreateBrewMethodUseCaseImp: CreateBrewMethodUseCase {
    let repository: BrewMethodRepository

    init(repository: BrewMethodRepository = BrewMethodRepositoryImp()) {
        self.repository = repository
    }

    func canCreate(from context: CreateBrewMethodContext) throws -> Bool {
        guard !context.methodTitle.isEmpty else { throw CreateBrewMethodUseCaseError.missingMethodTitle }
        guard !context.instructions.isEmpty else { throw CreateBrewMethodUseCaseError.missingInstructions }
        return true
    }

    func create(from context: CreateBrewMethodContext) async throws {
        let numberOfPutIce = context.instructions.filter { item in
            switch item.action {
            case .put(let putModel):
                return putModel.ingredient == .ice
            default:
                return false
            }
        }.count
        let isIcedBrew = numberOfPutIce > 0
        let id = UUID().uuidString

        let brewMethod = BrewMethod(
            id: id,
            title: context.methodTitle,
            path: CustomMethodPathGenerator.generate(id: id),
            isIcedBrew: isIcedBrew,
            cupsCount: context.cupsCount,
            ratios: isIcedBrew ? StaticCoffeetoWaterRatioGenerator.icedBrew() : StaticCoffeetoWaterRatioGenerator.hotBrew()
        )

        try await repository.create(brewMethod: brewMethod)
    }
}
