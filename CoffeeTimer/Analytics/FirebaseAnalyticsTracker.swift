//
//  FirebaseAnalyticsTracker.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on [Date].
//

import Foundation
import FirebaseAnalytics

struct FirebaseAnalyticsTracker {
    func logEvent(_ name: String, parameters: [String: Any]?) {
        Analytics.logEvent(name, parameters: parameters)
    }
}
