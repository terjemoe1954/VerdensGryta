import Foundation

struct ScaledRecipeAmounts: Equatable {
    let selectedServings: Decimal
    let scaleFactor: Decimal
    let ingredients: [ScaledIngredient]
    let ingredientsByStepID: [String: [ScaledIngredient]]

    var needsEquipmentCapacityCheck: Bool {
        scaleFactor >= 2
    }
}

struct ScaledIngredient: Identifiable, Equatable {
    let ingredient: Ingredient
    let quantity: Decimal?
    let originalIngredient: Ingredient?
    let selectedChange: VariantChange?

    var id: String { ingredient.id }
}

struct PortionCalculator {
    func calculate(
        recipe: Recipe,
        selectedServings: Decimal,
        selectedSubstitutionIDs: Set<String> = []
    ) -> ScaledRecipeAmounts {
        let validServings = max(selectedServings, Decimal(string: "0.5") ?? 0.5)
        let factor = validServings / Decimal(recipe.baseServings)

        let changes = recipe.adaptedVariant?.changes.filter {
            selectedSubstitutionIDs.contains($0.id)
        } ?? []
        let changesByIngredientID = Dictionary(
            uniqueKeysWithValues: changes.map { ($0.originalIngredientID, $0) }
        )
        let scaledIngredients = recipe.ingredients.map {
            scale(
                ingredient: $0,
                by: factor,
                change: changesByIngredientID[$0.id]
            )
        }
        let ingredientsByID = Dictionary(
            uniqueKeysWithValues: scaledIngredients.map { ($0.id, $0) }
        )
        let ingredientsByStepID = Dictionary(
            uniqueKeysWithValues: recipe.steps.map { step in
                (
                    step.id,
                    step.ingredientIDs.compactMap { ingredientsByID[$0] }
                )
            }
        )

        return ScaledRecipeAmounts(
            selectedServings: validServings,
            scaleFactor: factor,
            ingredients: scaledIngredients,
            ingredientsByStepID: ingredientsByStepID
        )
    }

    func scale(
        ingredient: Ingredient,
        by factor: Decimal,
        change: VariantChange? = nil
    ) -> ScaledIngredient {
        let selectedIngredient = change.map {
            Ingredient(
                id: ingredient.id,
                name: $0.alternativeName,
                quantity: ingredient.quantity.map { $0 * (change?.quantityFactor ?? 1) },
                unit: $0.unit ?? ingredient.unit,
                amountNote: ingredient.amountNote,
                alternativeProductNames: ingredient.alternativeProductNames,
                shoppingGuide: ingredient.shoppingGuide,
                allergens: $0.allergens,
                possibleAllergens: $0.possibleAllergens,
                allergenDataStatus: $0.allergenDataStatus
            )
        } ?? ingredient

        return ScaledIngredient(
            ingredient: selectedIngredient,
            quantity: selectedIngredient.quantity.map { $0 * factor },
            originalIngredient: change == nil ? nil : ingredient,
            selectedChange: change
        )
    }
}

struct IngredientQuantityFormatter {
    struct Result: Equatable {
        let quantityText: String
        let unit: IngredientUnit
    }

    func format(
        quantity: Decimal,
        unit: IngredientUnit,
        locale: Locale
    ) -> Result {
        let converted = metricConversion(quantity: quantity, unit: unit)

        return Result(
            quantityText: formattedNumber(
                converted.quantity,
                unit: converted.unit,
                locale: locale
            ),
            unit: converted.unit
        )
    }

    private func metricConversion(
        quantity: Decimal,
        unit: IngredientUnit
    ) -> (quantity: Decimal, unit: IngredientUnit) {
        switch unit {
        case .gram where quantity >= 1000:
            (quantity / 1000, .kilogram)
        case .milliliter where quantity >= 1000:
            (quantity / 1000, .liter)
        default:
            (quantity, unit)
        }
    }

    private func formattedNumber(
        _ quantity: Decimal,
        unit: IngredientUnit,
        locale: Locale
    ) -> String {
        if unit == .item, let fraction = formattedFraction(quantity) {
            return fraction
        }

        return quantity.formatted(
            .number
                .locale(locale)
                .precision(.fractionLength(0...2))
        )
    }

    private func formattedFraction(_ quantity: Decimal) -> String? {
        let value = NSDecimalNumber(decimal: quantity).doubleValue
        guard value >= 0 else { return nil }

        let whole = Int(value.rounded(.down))
        let remainder = value - Double(whole)
        let fractions: [(value: Double, symbol: String)] = [
            (0.125, "⅛"),
            (0.25, "¼"),
            (1.0 / 3.0, "⅓"),
            (0.375, "⅜"),
            (0.5, "½"),
            (0.625, "⅝"),
            (2.0 / 3.0, "⅔"),
            (0.75, "¾"),
            (0.875, "⅞")
        ]

        if remainder < 0.01 {
            return String(whole)
        }

        guard let match = fractions.min(by: {
            abs($0.value - remainder) < abs($1.value - remainder)
        }), abs(match.value - remainder) < 0.02 else {
            return nil
        }

        return whole == 0 ? match.symbol : "\(whole) \(match.symbol)"
    }
}
