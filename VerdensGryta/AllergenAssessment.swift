import Foundation

struct AllergenAssessment: Equatable {
    let matchedKnown: Set<FoodAllergen>
    let matchedPossible: Set<FoodAllergen>
    let hasUnknownData: Bool
}

struct AllergenAssessmentService {
    func assess(
        ingredients: [ScaledIngredient],
        profile: Set<FoodAllergen>
    ) -> AllergenAssessment {
        let known = Set(ingredients.flatMap { $0.ingredient.knownAllergens })
        let possible = Set(ingredients.flatMap { $0.ingredient.uncertainAllergens })
        return AllergenAssessment(
            matchedKnown: known.intersection(profile),
            matchedPossible: possible.intersection(profile),
            hasUnknownData: ingredients.contains {
                $0.ingredient.resolvedAllergenDataStatus == .unknown
            }
        )
    }
}
