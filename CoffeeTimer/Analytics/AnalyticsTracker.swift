//
//  AnalyticsTracker.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren.
//

import Foundation

protocol AnalyticsTracker {
    func track(event: AnalyticsEvent)
}

