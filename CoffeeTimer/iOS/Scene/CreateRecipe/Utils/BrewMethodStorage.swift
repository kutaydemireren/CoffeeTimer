//
//  BrewMethodStorage.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 29/05/2023.
//

import Foundation

struct BrewMethodStorage {
    // TODO: can be removed once brew methods are fetched
    static var brewMethods: [BrewMethod] {
        [
            .v60Single,
            .v60Iced,
            .frenchPress
        ]
    }
}
