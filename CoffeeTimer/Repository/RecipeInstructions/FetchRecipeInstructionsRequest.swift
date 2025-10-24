//
//  FetchRecipeInstructionsRequest.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 01/06/2024.
//

import Foundation

struct FetchRecipeInstructionsRequest: Request {
#if DEBUG
    let host: String = "raw.githubusercontent.com"
    let path: String
#else
    let host: String = "coffeetimer-4672c.firebaseapp.com"
    let path: String
#endif

    init(brewMethod: BrewMethod) {
        path = "/kutaydemireren/CoffeeTimer/refs/heads/main/data/v0/brew-instructions/\(brewMethod.id).json"
//        path = brewMethod.path
    }
}
