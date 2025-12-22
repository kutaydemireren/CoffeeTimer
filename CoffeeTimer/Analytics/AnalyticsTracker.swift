//
//  AnalyticsTracker.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on [Date].
//

import Foundation

protocol AnalyticsTracker {
    func track(event: AnalyticsEvent)
}

