//
//  AppInitializer.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 24/10/2025.
//

import Foundation

protocol AppInitializer {
    func initialize()
}

struct AppInitializerImp: AppInitializer {
    private let migrationRunner: MigrationRunner
    
    init(migrationRunner: MigrationRunner = MigrationRunnerImp()) {
        self.migrationRunner = migrationRunner
    }
    
    func initialize() {
        // Run all migrations at app startup
        // This ensures data is migrated before any repository accesses it
        try? migrationRunner.run(migrations: [
            RecipeMigration()
            // Add future migrations here
        ])
    }
}

