//
//  ProfileIconStorage.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 29/05/2023.
//

import UIKit

struct ProfileIconStorage {
	static var recipeProfileIcons: [RecipeProfileIcon] {
		[
			RecipeProfileIcon(title: "planet", color: UIColor.magenta.hexString ?? ""),
			RecipeProfileIcon(title: "moon", color: UIColor.brown.hexString ?? ""),
			RecipeProfileIcon(title: "nuclear", color: UIColor.orange.hexString ?? ""),
			RecipeProfileIcon(title: "planet 2", color: UIColor.magenta.hexString ?? ""),
			RecipeProfileIcon(title: "moon 2", color: UIColor.brown.hexString ?? ""),
			RecipeProfileIcon(title: "nuclear 2", color: UIColor.orange.hexString ?? ""),
			RecipeProfileIcon(title: "planet 3", color: UIColor.magenta.hexString ?? ""),
			RecipeProfileIcon(title: "moon 3", color: UIColor.brown.hexString ?? ""),
			RecipeProfileIcon(title: "nuclear 3", color: UIColor.orange.hexString ?? ""),
			RecipeProfileIcon(title: "planet 4", color: UIColor.magenta.hexString ?? ""),
			RecipeProfileIcon(title: "moon 4", color: UIColor.brown.hexString ?? ""),
			RecipeProfileIcon(title: "nuclear 4", color: UIColor.orange.hexString ?? ""),
			RecipeProfileIcon(title: "nuclear 5 ", color: UIColor.orange.hexString ?? ""),
			RecipeProfileIcon(title: "rocket", color: UIColor.purple.hexString ?? ""),
			RecipeProfileIcon(title: "rocket 2", color: UIColor.purple.hexString ?? ""),
			RecipeProfileIcon(title: "rocket 3", color: UIColor.purple.hexString ?? "")
		].shuffled()
	}
}
