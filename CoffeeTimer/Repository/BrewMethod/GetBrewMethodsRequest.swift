//
//  GetBrewMethodsRequest.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 01/06/2024.
//

import Foundation

struct GetBrewMethodsRequest: Request {
#if DEBUG
    let host: String = "raw.githubusercontent.com"
    let path: String = "/kutaydemireren/CoffeeTimer/epic/custom-method/data/v0/brew-methods.json"
#else
    let host: String = "coffeetimer-4672c.firebaseapp.com"
    let path: String = "/v0/brew-methods.json"
#endif
}
