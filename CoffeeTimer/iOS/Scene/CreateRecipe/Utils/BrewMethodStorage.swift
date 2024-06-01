//
//  BrewMethodStorage.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 29/05/2023.
//

import Foundation

struct BrewMethodStorage {
    static var brewMethods: [BrewMethod] {
        [
            .v60,
            .v60Single,
            .v60Iced,
            .chemex,
            .frenchPress,
            .melitta
        ]
    }
}
