//
//  FirebaseAnalyticsTracker.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren.
//

import Foundation
import FirebaseAnalytics

struct FirebaseAnalyticsTracker {
    func logEvent(_ name: String, parameters: [String: Any]?) {
        Analytics.logEvent(name, parameters: parameters)
    }
}
