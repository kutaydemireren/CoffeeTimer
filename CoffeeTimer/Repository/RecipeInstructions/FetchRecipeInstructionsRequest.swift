//
//  FetchRecipeInstructionsRequest.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 01/06/2024.
//

import Foundation

struct FetchRecipeInstructionsRequest: Request {
    let host: String
    let path: String

    init(brewMethod: BrewMethod) {
#if DEBUG
        host = "raw.githubusercontent.com"
        path = "/kutaydemireren/CoffeeTimer/main/data/v0/brew-instructions/\(brewMethod.id).json"
#else
        host = "coffeetimer-4672c.firebaseapp.com"
        path = brewMethod.path
#endif
    }
}
