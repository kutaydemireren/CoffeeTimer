//
//  GetRatiosUseCase.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 11/06/2023.
//

import Foundation

protocol GetRatiosUseCase {
    func ratios(for brewMethod: BrewMethod?) -> [CoffeeToWaterRatio]
}

struct GetRatiosUseCaseImp: GetRatiosUseCase {

    func ratios(for brewMethod: BrewMethod?) -> [CoffeeToWaterRatio] {

        guard let brewMethod = brewMethod else {
            return []
        }

        // TODO: update to map from brewMethod
        return [.ratio16, .ratio17, .ratio18, .ratio19, .ratio20]

        /*
        if brewMethod.isIced {
            return [.ratio15, .ratio16, .ratio17, .ratio18, .ratio19]
        } else {
            return [.ratio16, .ratio17, .ratio18, .ratio19, .ratio20]
        }
        */
    }
}
