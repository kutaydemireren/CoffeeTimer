//
//  Migration.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 24/10/2025.
//

import Foundation

protocol Migration {
    var version: Int { get }
    func migrate(storage: Storage) throws
}

