//
//  String+Filter.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 06/05/2023.
//

import Foundation

extension String {
    func filteringNonNumerics() -> String {
        var newValue = ""
        
        if Double(self) != nil {
            newValue = self
        } else {
            let trimmed = trimmingCharacters(in: CharacterSet(charactersIn: "."))
            newValue = trimmed.filter { "0123456789.".contains($0) }
        }
        
        return newValue
    }
}
