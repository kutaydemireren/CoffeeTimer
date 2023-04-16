//
//  BrewQueueRepository.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 16/04/2023.
//

import Foundation

protocol BrewQueueRepository: AnyObject {
	static var selectedRecipe: Recipe { get set }
}
