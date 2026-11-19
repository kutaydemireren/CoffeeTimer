//
//  DateProvider.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 19/11/2026.
//

import Foundation

protocol DateProvider {
    var now: Date { get }
}

struct DateProviderImp: DateProvider {
    var now: Date {
        Date()
    }
}
