//
//  CoffeeToWaterRatio.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 15/04/2023.
//

import Foundation

enum CoffeeToWaterRatio: String, CaseIterable, Identifiable {
	case ratio15 = "1:15"
	case ratio16 = "1:16"
	case ratio17 = "1:17"
	case ratio18 = "1:18"
	case ratio19 = "1:19"
	case ratio20 = "1:20"

	var id: Self { self }

	var value: Double {
		switch self {
		case .ratio15:
			return 15
		case .ratio16:
			return 16
		case .ratio17:
			return 17
		case .ratio18:
			return 18
		case .ratio19:
			return 19
		case .ratio20:
			return 20
		}
	}

	var toRepresentableString: String {
		switch self {
		case .ratio15:
			return "1:15 - Strong"
		case .ratio16:
			return "1:16 - Strong"
		case .ratio17:
			return "1:17 - Robust"
		case .ratio18:
			return "1:18 - Medium"
		case .ratio19:
			return "1:19 - Mild"
		case .ratio20:
			return "1:20 - Delicate"
		}
	}
}
