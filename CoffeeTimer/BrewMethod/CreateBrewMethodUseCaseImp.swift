//
//  CreateBrewMethodUseCaseImp.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 24/11/2024.
//

import Foundation

enum CreateBrewMethodUseCaseError: Error {
    case missingMethodTitle
    case invalidCupsCount
}

protocol CreateBrewMethodUseCase {
    func canCreate(from context: CreateBrewMethodContext) throws -> Bool
}

struct CreateBrewMethodUseCaseImp: CreateBrewMethodUseCase {
    func canCreate(from context: CreateBrewMethodContext) throws -> Bool {
        guard !context.methodTitle.isEmpty else { throw CreateBrewMethodUseCaseError.missingMethodTitle }
        return false
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
