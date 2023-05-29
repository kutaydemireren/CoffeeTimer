//
//  TitleStorage.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 29/05/2023.
//

import Foundation

struct TitleStorage {
	static let funTitles = [
		"Icons are the new socks - impossible to match.",
		"Icons are the ultimate indecision enablers.",
		"Icons: so many choices, so little time.",
		"Icons: small graphics, big headaches.",
		"Choosing an icon: the struggle is real.",
		"Choosing an icon: where art and indecision collide.",
		"Tiny pictures, big decisions.",
		"Simple yet so complicated.",
		"Small but mighty frustrating."
	]

	static var randomFunTitle: String {
		funTitles.randomElement() ?? ""
	}
}
