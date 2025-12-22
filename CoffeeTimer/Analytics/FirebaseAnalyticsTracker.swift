//
//  FirebaseAnalyticsTracker.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on [Date].
//

import Foundation
import FirebaseAnalytics

struct FirebaseAnalyticsTracker: AnalyticsTracker {
    func track(event: AnalyticsEvent) {
        Analytics.logEvent(event.name, parameters: event.parameters)
    }
}

