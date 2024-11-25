//
//  BrewMethodRepositoryImpTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 01/06/2024.
//

import XCTest
@testable import CoffeeTimer

final class BrewMethodRepositoryImpTests: XCTestCase {
    let expectedSavedBrewMethodsKey = BrewMethodConstants.savedBrewMethodsKey

    var mockNetworkManager: MockNetworkManager!
    var mockDecoding: MockDecoding!
    var mockStorage: MockStorage!
    var sut: BrewMethodRepositoryImp!

    override func setUpWithError() throws {
        mockNetworkManager = MockNetworkManager()
        mockNetworkManager._data = Data()
        mockDecoding = MockDecoding()
        mockDecoding._decoded = [BrewMethod]()
        mockStorage = MockStorage()
        sut = BrewMethodRepositoryImp(
            networkManager: mockNetworkManager,
            decoding: mockDecoding,
            storage: mockStorage
        )
    }

    override func tearDownWithError() throws {
        mockNetworkManager = nil
        mockDecoding = nil
        mockStorage = nil
        sut = nil
    }
}

// MARK: get Brew Methods
extension BrewMethodRepositoryImpTests {
    func test_getBrewMethods_whenNetworkThrowsError_shouldThrowExpectedError() async throws {
        mockNetworkManager._error = TestError.notAllowed

        await assertThrowsError {
            try await sut.getBrewMethods()
        } _: { error in
            XCTAssertEqual(error as? TestError, .notAllowed)
        }
    }

    func test_getBrewMethods_whenDecodingThrowsError_shouldThrowExpectedError() async throws {
        mockDecoding._error = TestError.notAllowed

        await assertThrowsError {
            try await sut.getBrewMethods()
        } _: { error in
            XCTAssertEqual(error as? TestError, .notAllowed)
        }
    }

    func test_getBrewMethods_shouldCreateExpectedBrewRequest() async throws {
        _ = try await sut.getBrewMethods()

        XCTAssertEqual(try mockNetworkManager._request.createURLRequest(), try GetBrewMethodsRequest().createURLRequest())
    }

    func test_getBrewMethods_whenNoSavedBrewMethod_shouldOnlyReturnRemoteBrewMethods() async throws {
        mockDecoding._decoded = [BrewMethodDTO.frenchPress(cupsCount: .init(minimum: nil, maximum: 5)), BrewMethodDTO.v60Single]

        let resultedBrewMethods = try await sut.getBrewMethods()

        XCTAssertEqual(resultedBrewMethods, [.frenchPress(), .v60Single])
    }

    func test_getBrewMethods_whenSavedBrewMethod_shouldReturnAllBrewMethods() async throws {
        mockDecoding._decoded = [BrewMethodDTO.frenchPress(cupsCount: .init(minimum: nil, maximum: 5)), BrewMethodDTO.v60Single]
        mockStorage.storageDictionary = [expectedSavedBrewMethodsKey: [BrewMethodDTO.v60Iced]]

        let resultedBrewMethods = try await sut.getBrewMethods()

        XCTAssertEqual(resultedBrewMethods, [.frenchPress(), .v60Single, .v60Iced])
    }
}

// MARK: Save Brew Methods
extension BrewMethodRepositoryImpTests {
    func test_save_shouldAppendToSavedRecipes() async throws {
        let existingBrewMethodDTOs: [BrewMethodDTO] = [.v60Iced]
        mockStorage.storageDictionary = [expectedSavedBrewMethodsKey: existingBrewMethodDTOs]

        try await sut.save(brewMethod: .frenchPress())

        XCTAssertEqual(mockStorage.loadCalledWithKey, expectedSavedBrewMethodsKey)
        XCTAssertEqual(mockStorage.saveCalledWithKey, expectedSavedBrewMethodsKey)
        XCTAssertEqual(mockStorage.saveCalledWithValue as? [BrewMethodDTO], [.v60Iced, .frenchPress(cupsCount: .init(minimum: 1, maximum: 5))])
    }
}
