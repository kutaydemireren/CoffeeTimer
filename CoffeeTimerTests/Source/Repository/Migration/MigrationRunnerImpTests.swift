//
//  MigrationRunnerImpTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 24/10/2025.
//

import XCTest
@testable import CoffeeTimer

final class MigrationRunnerImpTests: XCTestCase {
    var mockStorage: MockStorage!
    var sut: MigrationRunnerImp!
    
    override func setUpWithError() throws {
        mockStorage = MockStorage()
        sut = MigrationRunnerImp(storage: mockStorage)
    }
}

// MARK: - Run Migrations
extension MigrationRunnerImpTests {
    func test_run_whenNoMigrations_shouldNotSave() {
        try? sut.run(migrations: [])
        
        XCTAssertNil(mockStorage.saveCalledWithKey)
    }
    
    func test_run_whenMigrationsNotCompleted_shouldRunAllMigrations() {
        let migration1 = MockMigration(version: 1)
        let migration2 = MockMigration(version: 2)
        
        try? sut.run(migrations: [migration1, migration2])
        
        XCTAssertTrue(migration1.migrateCalled)
        XCTAssertTrue(migration2.migrateCalled)
    }
    
    func test_run_whenSomeMigrationsCompleted_shouldOnlyRunPendingMigrations() {
        // Mark migration 1 as completed
        mockStorage.storageDictionary[MigrationConstants.completedMigrationsKey] = [1]
        
        let migration1 = MockMigration(version: 1)
        let migration2 = MockMigration(version: 2)
        
        try? sut.run(migrations: [migration1, migration2])
        
        XCTAssertFalse(migration1.migrateCalled) // Already completed
        XCTAssertTrue(migration2.migrateCalled) // Pending
    }
    
    func test_run_whenAllMigrationsCompleted_shouldNotRunAnyMigrations() {
        mockStorage.storageDictionary[MigrationConstants.completedMigrationsKey] = [1, 2]
        
        let migration1 = MockMigration(version: 1)
        let migration2 = MockMigration(version: 2)
        
        try? sut.run(migrations: [migration1, migration2])
        
        XCTAssertFalse(migration1.migrateCalled)
        XCTAssertFalse(migration2.migrateCalled)
    }
    
    func test_run_whenMigrationsRun_shouldSaveCompletedMigrations() {
        let migration1 = MockMigration(version: 1)
        let migration2 = MockMigration(version: 2)
        
        try? sut.run(migrations: [migration1, migration2])
        
        XCTAssertEqual(mockStorage.saveCalledWithKey, MigrationConstants.completedMigrationsKey)
        let completed = mockStorage.saveCalledWithValue as? [Int]
        XCTAssertEqual(completed, [1, 2])
    }
    
    func test_run_whenMigrationThrowsError_shouldPropagateError() {
        let migration = MockMigration(version: 1)
        migration.shouldThrowError = true
        
        XCTAssertThrowsError(try sut.run(migrations: [migration])) { error in
            XCTAssertEqual(error as? TestError, .notAllowed)
        }
    }
    
    func test_run_whenMigrationsOutOfOrder_shouldRunInVersionOrder() {
        let migration2 = MockMigration(version: 2)
        let migration1 = MockMigration(version: 1)
        let migration3 = MockMigration(version: 3)
        
        try? sut.run(migrations: [migration3, migration1, migration2])
        
        // Verify migrations were called in order
        XCTAssertTrue(migration1.migrateCalled)
        XCTAssertTrue(migration2.migrateCalled)
        XCTAssertTrue(migration3.migrateCalled)
    }
}

// MARK: - Mock Migration
final class MockMigration: Migration {
    let version: Int
    var migrateCalled = false
    var shouldThrowError = false
    
    init(version: Int) {
        self.version = version
    }
    
    func migrate(storage: Storage) throws {
        migrateCalled = true
        if shouldThrowError {
            throw TestError.notAllowed
        }
    }
}

