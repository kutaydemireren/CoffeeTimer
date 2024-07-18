//
//  RecipeProfile+UserDefined.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 29/05/2023.
//

import Foundation

extension RecipeProfile {
    static var empty: RecipeProfile {
        RecipeProfile(
            name: "", 
            brewMethod: .none
        )
    }
    
    var hasContent: Bool {
        !name.isEmpty && brewMethod != .none
    }
}

extension BrewMethod {
    static var none: BrewMethod {
        BrewMethod(id: "", title: "", path: "", isIcedBrew: false, cupsCount: .unlimited, ratios: [])
    }
}

extension CoffeeToWaterRatio {
    static var ratio16: Self {
        return CoffeeToWaterRatio(id: "1:16", value: 16, title: "1 - 16")
    }
    
    static var ratio17: Self {
        return CoffeeToWaterRatio(id: "1:17", value: 17, title: "1 - 17")
    }
    
    static var ratio18: Self {
        return CoffeeToWaterRatio(id: "1:18", value: 18, title: "1 - 18")
    }
    
    static var ratio20: Self {
        return CoffeeToWaterRatio(id: "1:20", value: 20, title: "1 - 20")
    }
}
