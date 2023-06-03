//
//  ProfileIconStorage.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 29/05/2023.
//

import SwiftUI

struct ProfileIconStorage {
	static var recipeProfileIcons: [RecipeProfileIcon] {
		[
			RecipeProfileIcon(title: "planet", color: UIColor(named: "profileIcon1")?.hexString ?? ""),
			RecipeProfileIcon(title: "moon", color: UIColor(named: "profileIcon2")?.hexString ?? ""),
			RecipeProfileIcon(title: "nuclear", color: UIColor(named: "profileIcon3")?.hexString ?? ""),
			RecipeProfileIcon(title: "planet 2", color: UIColor(named: "profileIcon4")?.hexString ?? ""),
			RecipeProfileIcon(title: "moon 2", color: UIColor(named: "profileIcon1")?.hexString ?? ""),
			RecipeProfileIcon(title: "nuclear 2", color: UIColor(named: "profileIcon2")?.hexString ?? ""),
			RecipeProfileIcon(title: "planet 3", color: UIColor(named: "profileIcon3")?.hexString ?? ""),
			RecipeProfileIcon(title: "moon 3", color: UIColor(named: "profileIcon4")?.hexString ?? ""),
			RecipeProfileIcon(title: "nuclear 3", color: UIColor(named: "profileIcon1")?.hexString ?? ""),
			RecipeProfileIcon(title: "planet 4", color: UIColor(named: "profileIcon2")?.hexString ?? ""),
			RecipeProfileIcon(title: "moon 4", color: UIColor(named: "profileIcon3")?.hexString ?? ""),
			RecipeProfileIcon(title: "nuclear 4", color: UIColor(named: "profileIcon4")?.hexString ?? ""),
			RecipeProfileIcon(title: "nuclear 5 ", color: UIColor(named: "profileIcon1")?.hexString ?? ""),
			RecipeProfileIcon(title: "rocket", color: UIColor(named: "profileIcon2")?.hexString ?? ""),
			RecipeProfileIcon(title: "rocket 2", color: UIColor(named: "profileIcon3")?.hexString ?? ""),
			RecipeProfileIcon(title: "rocket 3", color: UIColor(named: "profileIcon4")?.hexString ?? "")
		].shuffled()
	}
}
