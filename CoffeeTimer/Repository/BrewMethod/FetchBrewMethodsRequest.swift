//
//  FetchBrewMethodsRequest.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 01/06/2024.
//

import Foundation

struct FetchBrewMethodsRequest: Request {
    let host: String = "raw.githubusercontent.com"
    let path: String = "/kutaydemireren/CoffeeTimer/main/data/v0/brew-methods.json"
}
