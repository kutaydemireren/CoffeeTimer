//
//  MigrationRunner.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 24/10/2025.
//

import Foundation

struct MigrationConstants {
    static let completedMigrationsKey = "completedMigrations"
}

protocol MigrationRunner {
    func run(migrations: [Migration]) throws
}

struct MigrationRunnerImp: MigrationRunner {
    private let storage: Storage
    
    init(storage: Storage = StorageImp(userDefaults: .standard)) {
        self.storage = storage
    }
    
    func run(migrations: [Migration]) throws {
        let completedMigrations = getCompletedMigrations()
        
        // Sort migrations by version and filter out already completed ones
        let pendingMigrations = migrations
            .sorted { $0.version < $1.version }
            .filter { !completedMigrations.contains($0.version) }
        
        var newlyCompleted: [Int] = []
        
        for migration in pendingMigrations {
            try migration.migrate(storage: storage)
            newlyCompleted.append(migration.version)
        }
        
        if !newlyCompleted.isEmpty {
            let allCompleted = completedMigrations + newlyCompleted
            storage.save(allCompleted, forKey: MigrationConstants.completedMigrationsKey)
        }
    }
    
    private func getCompletedMigrations() -> [Int] {
        return storage.load(forKey: MigrationConstants.completedMigrationsKey) as [Int]? ?? []
    }
}

