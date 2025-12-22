//
//  AnalyticsEvent.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on [Date].
//

import Foundation

struct AnalyticsEvent {
    let name: String
    let parameters: [String: Any]?
    
    init(name: String, parameters: [String: Any]? = nil) {
        self.name = name
        self.parameters = parameters
    }
}

