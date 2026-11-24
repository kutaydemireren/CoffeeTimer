//
//  ReferenceDoseTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 24/11/2026.
//

import XCTest
@testable import CoffeeTimer

final class ReferenceDoseTests: XCTestCase {
    private func makeMethod(referenceDose: ReferenceDose?, ratios: [CoffeeToWaterRatio] = StaticCoffeetoWaterRatioGenerator.hotBrew()) -> BrewMethod {
        BrewMethod(
            id: "custom",
            iconName: "recipe-profile-gooseneck-kettle",
            title: "Custom",
            path: CustomMethodPathGenerator.generate(id: "custom"),
            isIcedBrew: false,
            cupsCount: .unlimited,
            ratios: ratios,
            info: .init(title: "Custom", body: ""),
            referenceDose: referenceDose
        )
    }
}

// MARK: Codable
extension ReferenceDoseTests {
    func test_decodeBrewMethodDTO_whenOldDataWithoutReferenceDose_shouldDecodeWithNil() throws {
        let json = """
        {"id":"old","icon":"recipe-profile-gooseneck-kettle","title":"Old","path":"custom-method://old","isIcedBrew":false,"cupsCount":{"minimum":1},"ratios":[{"id":"1:16","value":16,"title":"1:16 - Strong"}],"info":{"title":"Old","body":""}}
        """

        let dto = try JSONDecoder().decode(BrewMethodDTO.self, from: Data(json.utf8))

        XCTAssertNil(dto.referenceDose)
        XCTAssertEqual(dto.ratios.count, 1)
    }

    func test_encodeBrewMethodDTO_whenNoReferenceDose_shouldOmitKey() throws {
        let dto = BrewMethodDTO(id: "a", icon: nil, title: "A", path: nil, isIcedBrew: false, cupsCount: nil, ratios: [], info: nil)

        let data = try JSONEncoder().encode(dto)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])

        XCTAssertNil(object["referenceDose"])
    }

    func test_encodeDecodeBrewMethodDTO_whenReferenceDose_shouldRoundTrip() throws {
        let dto = BrewMethodDTO(
            id: "a", icon: nil, title: "A", path: nil, isIcedBrew: true, cupsCount: nil, ratios: [], info: nil,
            referenceDose: .init(coffee: 15, water: 150, ice: 100)
        )

        let decoded = try JSONDecoder().decode(BrewMethodDTO.self, from: JSONEncoder().encode(dto))

        XCTAssertEqual(decoded, dto)
        XCTAssertEqual(decoded.referenceDose?.map(), ReferenceDose(coffee: 15, water: 150, ice: 100))
    }

    func test_mapReferenceDoseDTO_whenMissingOrZeroAmounts_shouldReturnNil() {
        XCTAssertNil(ReferenceDoseDTO(coffee: nil, water: 500, ice: nil).map())
        XCTAssertNil(ReferenceDoseDTO(coffee: 30, water: 0, ice: nil).map())
    }

    func test_recipeMapper_whenBrewMethodHasReferenceDose_shouldRoundTripThroughRecipeDTO() throws {
        let method = makeMethod(referenceDose: .init(coffee: 30, water: 500))
        let recipe = Recipe(
            recipeProfile: .init(name: "R", brewMethod: method),
            ingredients: [],
            brewQueue: .init(stages: []),
            cupsCount: 2,
            cupSize: 250
        )
        let mapper = RecipeMapperImp()

        let dto = mapper.mapToRecipeDTO(recipe: recipe)
        let decodedDTO = try JSONDecoder().decode(RecipeDTO.self, from: JSONEncoder().encode(dto))
        let mapped = try mapper.mapToRecipe(recipeDTO: decodedDTO)

        XCTAssertEqual(mapped.recipeProfile.brewMethod.referenceDose, ReferenceDose(coffee: 30, water: 500))
    }
}

// MARK: Ratios
extension ReferenceDoseTests {
    func test_ratioLabel_shouldShowOneDecimalOnlyWhenNeeded() {
        XCTAssertEqual(CoffeeToWaterRatio.label(for: 16), "1:16")
        XCTAssertEqual(CoffeeToWaterRatio.label(for: 500.0 / 30.0), "1:16.7")
        XCTAssertEqual(CoffeeToWaterRatio.label(for: 15.98), "1:16")
    }

    func test_recipeRatios_whenNoReferenceDose_shouldBeMethodRatiosUnchanged() {
        let method = makeMethod(referenceDose: nil)

        XCTAssertEqual(method.recipeRatios, StaticCoffeetoWaterRatioGenerator.hotBrew())
        XCTAssertNil(method.defaultRatio)
    }

    func test_recipeRatios_whenReferenceDose_shouldListOwnRatioFirstAndDefaultToIt() {
        let method = makeMethod(referenceDose: .init(coffee: 30, water: 500))

        let ratios = method.recipeRatios

        XCTAssertEqual(ratios.first?.value, 16.7)
        XCTAssertEqual(ratios.first?.id, "1:16.7")
        XCTAssertEqual(Array(ratios.dropFirst()), StaticCoffeetoWaterRatioGenerator.hotBrew())
        XCTAssertEqual(method.defaultRatio, ratios.first)
    }

    func test_recipeRatios_whenOwnRatioEqualsStandardRatio_shouldNotDuplicate() {
        let method = makeMethod(referenceDose: .init(coffee: 15, water: 270))

        let ratios = method.recipeRatios

        XCTAssertEqual(ratios.map(\.value), [18, 16, 17, 19, 20])
        XCTAssertEqual(ratios.first?.id, "1:18")
    }
}

// MARK: Display
extension ReferenceDoseTests {
    func test_brewDisplayText_shouldShowWholeGramsInsteadOfMillilitres() {
        XCTAssertEqual("Pour 50.0 ml of water".brewDisplayText, "Pour 50 g of water")
        XCTAssertEqual("Total: 300.0 ml of water".brewDisplayText, "Total: 300 g of water")
        XCTAssertEqual("Pause for 45.0 seconds".brewDisplayText, "Pause for 45 seconds")
        XCTAssertEqual("Put all 15.0 g of coffee".brewDisplayText, "Put all 15 g of coffee")
        XCTAssertEqual("Ratio 1.05 stays".brewDisplayText, "Ratio 1.05 stays")
        XCTAssertEqual("Use a small mlx jug".brewDisplayText, "Use a small mlx jug")
    }

    func test_ingredientAmount_whenMillilitre_shouldDisplayGrams() {
        XCTAssertEqual(IngredientAmount(amount: 250, type: .millilitre).toRepresentableString, "250 g")
    }
}
