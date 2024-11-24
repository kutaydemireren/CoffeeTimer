//
//  CreateBrewMethodUseCaseImp.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 24/11/2024.
//

import Foundation

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

        let brewMethod = BrewMethod(
            id: UUID().uuidString,
            title: context.methodTitle,
            path: "",
            isIcedBrew: numberOfPutIce > 0,
            cupsCount: .unlimited,
            ratios: []
        )

        try await repository.create(brewMethod: brewMethod)
    }

    /*
     TODO: `create`
     Notes
     - Create new Brew Method instance
     - Call repository to with the new instance

     BrewMethod(
         id: <#T##String#>, // get from title
         title: <#T##String#>, // -> validate this
         path: <#T##String#>, // get after save
         isIcedBrew: <#T##Bool#>, // check ingredients used in instructions
         cupsCount: <#T##CupsCount#>, // no validation, will be simply set
         ratios: [] // construct depending on `isIcedBrew` or not
     )
     */

}
