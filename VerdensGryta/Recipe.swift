import Foundation

struct LocalizedText: Codable, Hashable {
    let values: [String: String]

    func resolve(locale: Locale) -> ResolvedLocalizedText {
        let requestedLanguage = locale.language.languageCode?.identifier
        let exactIdentifier = locale.identifier(.bcp47)

        let candidates = [
            exactIdentifier,
            requestedLanguage,
            "en",
            "nb",
            values.keys.sorted().first
        ]
        .compactMap { $0 }

        for candidate in candidates {
            if let value = values[candidate], !value.isEmpty {
                return ResolvedLocalizedText(
                    value: value,
                    usedFallback: candidate != exactIdentifier
                        && candidate != requestedLanguage
                )
            }
        }

        return ResolvedLocalizedText(value: "—", usedFallback: true)
    }
}

struct ResolvedLocalizedText: Hashable {
    let value: String
    let usedFallback: Bool
}

enum RecipeDishType: Hashable, Codable {
    case nationalDish
    case popularDish
    case regionalSpecialty
    case unknown(String)

    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self)
        switch value {
        case "nationalDish":
            self = .nationalDish
        case "popularDish":
            self = .popularDish
        case "regionalSpecialty":
            self = .regionalSpecialty
        default:
            self = .unknown(value)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .nationalDish:
            try container.encode("nationalDish")
        case .popularDish:
            try container.encode("popularDish")
        case .regionalSpecialty:
            try container.encode("regionalSpecialty")
        case .unknown(let value):
            try container.encode(value)
        }
    }
}

enum RecipeCategory: Hashable, Codable {
    case beef
    case pork
    case lamb
    case poultry
    case fish
    case crustacean
    case mollusc
    case vegetarian
    case unknown(String)

    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self)
        switch value {
        case "beef": self = .beef
        case "pork": self = .pork
        case "lamb": self = .lamb
        case "poultry": self = .poultry
        case "fish": self = .fish
        case "crustacean": self = .crustacean
        case "mollusc": self = .mollusc
        case "vegetarian": self = .vegetarian
        default: self = .unknown(value)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .beef: try container.encode("beef")
        case .pork: try container.encode("pork")
        case .lamb: try container.encode("lamb")
        case .poultry: try container.encode("poultry")
        case .fish: try container.encode("fish")
        case .crustacean: try container.encode("crustacean")
        case .mollusc: try container.encode("mollusc")
        case .vegetarian: try container.encode("vegetarian")
        case .unknown(let value): try container.encode(value)
        }
    }
}

enum CookingEquipment: Hashable, Codable {
    case stove
    case oven
    case airFryer
    case slowCooker
    case pot
    case fryingPan
    case noHeat
    case unknown(String)

    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self)
        switch value {
        case "stove": self = .stove
        case "oven": self = .oven
        case "airFryer": self = .airFryer
        case "slowCooker": self = .slowCooker
        case "pot": self = .pot
        case "fryingPan": self = .fryingPan
        case "noHeat": self = .noHeat
        default: self = .unknown(value)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .stove: try container.encode("stove")
        case .oven: try container.encode("oven")
        case .airFryer: try container.encode("airFryer")
        case .slowCooker: try container.encode("slowCooker")
        case .pot: try container.encode("pot")
        case .fryingPan: try container.encode("fryingPan")
        case .noHeat: try container.encode("noHeat")
        case .unknown(let value): try container.encode(value)
        }
    }
}

enum RecipeDifficulty: Hashable, Codable {
    case easy
    case medium
    case hard
    case unknown(String)

    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self)
        switch value {
        case "easy": self = .easy
        case "medium": self = .medium
        case "hard": self = .hard
        default: self = .unknown(value)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .easy: try container.encode("easy")
        case .medium: try container.encode("medium")
        case .hard: try container.encode("hard")
        case .unknown(let value): try container.encode(value)
        }
    }
}

enum RecipeContentStatus: Hashable, Codable {
    case demo
    case draft
    case reviewed
    case unknown(String)

    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self)
        switch value {
        case "demo": self = .demo
        case "draft": self = .draft
        case "reviewed": self = .reviewed
        default: self = .unknown(value)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .demo: try container.encode("demo")
        case .draft: try container.encode("draft")
        case .reviewed: try container.encode("reviewed")
        case .unknown(let value): try container.encode(value)
        }
    }
}

enum IngredientUnit: Hashable, Codable {
    case gram
    case kilogram
    case milliliter
    case liter
    case teaspoon
    case tablespoon
    case item
    case unknown(String)

    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self)
        switch value {
        case "g": self = .gram
        case "kg": self = .kilogram
        case "ml": self = .milliliter
        case "l": self = .liter
        case "tsp": self = .teaspoon
        case "tbsp": self = .tablespoon
        case "item": self = .item
        default: self = .unknown(value)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .gram: try container.encode("g")
        case .kilogram: try container.encode("kg")
        case .milliliter: try container.encode("ml")
        case .liter: try container.encode("l")
        case .teaspoon: try container.encode("tsp")
        case .tablespoon: try container.encode("tbsp")
        case .item: try container.encode("item")
        case .unknown(let value): try container.encode(value)
        }
    }
}

enum StoreType: Hashable, Codable {
    case regularGrocery
    case asianGrocery
    case internationalGrocery
    case unknown(String)

    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self)
        switch value {
        case "regularGrocery": self = .regularGrocery
        case "asianGrocery": self = .asianGrocery
        case "internationalGrocery": self = .internationalGrocery
        default: self = .unknown(value)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .regularGrocery: try container.encode("regularGrocery")
        case .asianGrocery: try container.encode("asianGrocery")
        case .internationalGrocery: try container.encode("internationalGrocery")
        case .unknown(let value): try container.encode(value)
        }
    }
}

struct Recipe: Codable, Identifiable, Hashable {
    let id: String
    let title: LocalizedText
    let summary: LocalizedText
    let country: LocalizedText
    let region: LocalizedText?
    let originalName: String
    let history: LocalizedText
    let dishType: RecipeDishType
    let categories: [RecipeCategory]
    let equipment: [CookingEquipment]
    let baseServings: Int
    let ingredients: [Ingredient]
    let steps: [RecipeStep]
    let timing: RecipeTiming
    let difficulty: RecipeDifficulty
    let originalVariant: RecipeVariant
    let adaptedVariant: RecipeVariant?
    let symbolName: String?
    let source: RecipeSource
    let contentStatus: RecipeContentStatus
    let lastContentReview: String
    let priceEstimate: PriceEstimate?
}

struct PriceEstimate: Codable, Hashable {
    let totalNOK: Decimal
    let asOfDate: String
    let basis: LocalizedText
    let missingIngredientIDs: [String]
}

struct Ingredient: Codable, Identifiable, Hashable {
    let id: String
    let name: LocalizedText
    let quantity: Decimal?
    let unit: IngredientUnit?
    let amountNote: LocalizedText?
    let alternativeProductNames: [String]
    let shoppingGuide: ShoppingGuide?
    let allergens: [FoodAllergen]?
    let possibleAllergens: [FoodAllergen]?
    let allergenDataStatus: AllergenDataStatus?

    var knownAllergens: [FoodAllergen] { allergens ?? [] }
    var uncertainAllergens: [FoodAllergen] { possibleAllergens ?? [] }
    var resolvedAllergenDataStatus: AllergenDataStatus { allergenDataStatus ?? .unknown }
}

enum AllergenDataStatus: String, Codable, Hashable {
    case complete
    case unknown
}

enum FoodAllergen: String, Codable, CaseIterable, Identifiable, Hashable {
    case gluten, crustaceans, eggs, fish, peanuts, soybeans, milk, nuts
    case celery, mustard, sesame, sulphites, lupin, molluscs

    var id: String { rawValue }
}

struct ShoppingGuide: Codable, Hashable {
    let storeType: StoreType
    let guidance: LocalizedText
}

struct RecipeStep: Codable, Identifiable, Hashable {
    let id: String
    let order: Int
    let text: LocalizedText
    let ingredientIDs: [String]
}

struct RecipeTiming: Codable, Hashable {
    let preparationMinutes: Int
    let activeMinutes: Int
    let waitingMinutes: Int
    let totalMinutes: Int
    let overlapNote: LocalizedText
}

struct RecipeVariant: Codable, Hashable {
    let name: LocalizedText
    let description: LocalizedText
    let changes: [VariantChange]
}

struct VariantChange: Codable, Identifiable, Hashable {
    let id: String
    let originalIngredientID: String
    let alternativeName: LocalizedText
    let reason: LocalizedText
    let difference: LocalizedText
    let quantityFactor: Decimal?
    let unit: IngredientUnit?
    let allergens: [FoodAllergen]?
    let possibleAllergens: [FoodAllergen]?
    let allergenDataStatus: AllergenDataStatus?
    let stepTextOverrides: [String: LocalizedText]?
    let timeChange: LocalizedText?
    let temperatureChange: LocalizedText?
}

struct RecipeSource: Codable, Hashable {
    let title: String
    let url: URL?
    let licenseNote: LocalizedText
}
