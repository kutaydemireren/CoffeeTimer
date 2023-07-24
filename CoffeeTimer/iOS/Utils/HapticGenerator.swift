//
//  HapticGenerator.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 24/07/2023.
//

import UIKit
import AudioToolbox

protocol HapticGenerator {
	func heavy()
	func medium()
}

class HapticGeneratorImp: HapticGenerator {
	func heavy() {
		AudioServicesPlaySystemSound(1306)
		let generator = UIImpactFeedbackGenerator(style: .heavy)
		generator.prepare()
		generator.impactOccurred()
	}

	func medium() {
		AudioServicesPlaySystemSound(1306)
		let generator = UIImpactFeedbackGenerator(style: .medium)
		generator.prepare()
		generator.impactOccurred()
	}
}
