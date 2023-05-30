//
//  Color+HexString.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 29/05/2023.
//

import SwiftUI

extension UIColor {
	var hexString: String? {
		return Color(uiColor: self).hexString
	}
}

extension Color {
	var hexString: String? {

		guard let components = UIColor(self).cgColor.components else {
			return nil
		}

		let red = Int(components[0] * 255.0)
		let green = Int(components[1] * 255.0)
		let blue = Int(components[2] * 255.0)

		return String(format: "#%02X%02X%02X", red, green, blue)
	}

	init?(hexString: String) {
		var formattedHex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
		if formattedHex.count == 6 {
			formattedHex = "FF" + formattedHex
		}

		var hexValue: UInt64 = 0
		guard Scanner(string: formattedHex).scanHexInt64(&hexValue) else {
			return nil
		}

		let red = Double((hexValue & 0xFF0000) >> 16) / 255.0
		let green = Double((hexValue & 0x00FF00) >> 8) / 255.0
		let blue = Double(hexValue & 0x0000FF) / 255.0

		self.init(red: red, green: green, blue: blue)
	}
}
