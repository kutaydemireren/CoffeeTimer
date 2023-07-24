//
//  RecipeProfile+UserDefined.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 29/05/2023.
//

import Foundation

extension RecipeProfile {
	static var empty: RecipeProfile {
		RecipeProfile(name: "", icon: .init(title: "", color: ""))
	}

	var hasContent: Bool {
		self != .empty &&
		!name.isEmpty &&
		!icon.title.isEmpty &&
		!icon.color.isEmpty
	}
}
