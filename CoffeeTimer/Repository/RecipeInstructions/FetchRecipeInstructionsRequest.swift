//
//  FetchRecipeInstructionsRequest.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 01/06/2024.
//

import Foundation

struct FetchRecipeInstructionsRequest: Request {
    let host: String = "coffeetimer-4672c.firebaseapp.com"
    let path: String

    init(brewMethod: BrewMethod) {
        path = brewMethod.path
    }
}
