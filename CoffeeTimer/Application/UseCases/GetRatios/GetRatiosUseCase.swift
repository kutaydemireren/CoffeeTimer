//
//  GetRatiosUseCase.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 11/06/2023.
//

import Foundation

struct GetRatiosUseCase {

	func ratios(for brewMethod: BrewMethod?) -> [CoffeeToWaterRatio] {

		guard let brewMethod = brewMethod else {
			return []
		}

		switch brewMethod {
		case .v60Iced:
			return [.ratio15, .ratio16, .ratio17, .ratio18, .ratio19]
		default:
			return [.ratio16, .ratio17, .ratio18, .ratio19, .ratio20]
		}
	}
}
