import SwiftUI

extension RecipeDishType {
    var localizedName: LocalizedStringResource {
        return switch self {
        case .nationalDish: "National dish"
        case .popularDish: "Popular dish"
        case .regionalSpecialty: "Regional specialty"
        case .unknown: "Unknown dish type"
        }
    }
}

extension RecipeDifficulty {
    var localizedName: LocalizedStringResource {
        return switch self {
        case .easy: "Easy"
        case .medium: "Medium"
        case .hard: "Hard"
        case .unknown: "Unknown difficulty"
        }
    }
}

extension RecipeCategory {
    var localizedName: LocalizedStringResource {
        switch self {
        case .beef: "Beef"
        case .pork: "Pork"
        case .lamb: "Lamb or mutton"
        case .poultry: "Poultry"
        case .fish: "Fish"
        case .crustacean: "Crustacean"
        case .mollusc: "Mollusc"
        case .vegetarian: "Vegetarian"
        case .unknown: "Unknown category"
        }
    }

    var symbolName: String {
        switch self {
        case .fish, .crustacean, .mollusc:
            "fish"
        case .vegetarian:
            "leaf"
        default:
            "fork.knife"
        }
    }
}

extension CookingEquipment {
    var localizedName: LocalizedStringResource {
        switch self {
        case .stove: "Stove"
        case .oven: "Oven"
        case .airFryer: "Air fryer"
        case .slowCooker: "Slow cooker"
        case .pot: "Pot"
        case .fryingPan: "Frying pan"
        case .noHeat: "No heat"
        case .unknown: "Unknown equipment"
        }
    }

    var symbolName: String {
        switch self {
        case .oven, .airFryer:
            "oven"
        case .pot, .slowCooker:
            "soup"
        case .fryingPan:
            "frying.pan"
        case .stove:
            "cooktop"
        case .noHeat, .unknown:
            "fork.knife"
        }
    }
}

extension IngredientUnit {
    var localizedName: LocalizedStringResource {
        switch self {
        case .gram: "g"
        case .kilogram: "kg"
        case .milliliter: "ml"
        case .liter: "l"
        case .teaspoon: "tsp"
        case .tablespoon: "tbsp"
        case .item: "item"
        case .unknown: "unknown unit"
        }
    }

    func localizedString(locale: Locale) -> String {
        let language = locale.language.languageCode?.identifier
        return switch self {
        case .gram: "g"
        case .kilogram: "kg"
        case .milliliter: "ml"
        case .liter: "l"
        case .teaspoon: language == "nb" ? "ts" : (language == "th" ? "ชช." : "tsp")
        case .tablespoon: language == "nb" ? "ss" : (language == "th" ? "ชต." : "tbsp")
        case .item: language == "nb" ? "stk." : (language == "th" ? "ชิ้น" : "item")
        case .unknown: language == "nb" ? "ukjent enhet" : (language == "th" ? "หน่วยไม่ทราบ" : "unknown unit")
        }
    }
}

extension StoreType {
    var localizedName: LocalizedStringResource {
        switch self {
        case .regularGrocery: "Regular grocery store"
        case .asianGrocery: "Asian grocery store"
        case .internationalGrocery: "International grocery store"
        case .unknown: "Unknown store type"
        }
    }

    func localizedString(locale: Locale) -> String {
        let language = locale.language.languageCode?.identifier
        return switch self {
        case .regularGrocery: language == "nb" ? "Vanlig dagligvarebutikk" : (language == "th" ? "ร้านขายของชำทั่วไป" : "Regular grocery store")
        case .asianGrocery: language == "nb" ? "Asiatisk matbutikk" : (language == "th" ? "ร้านขายของชำเอเชีย" : "Asian grocery store")
        case .internationalGrocery: language == "nb" ? "Internasjonal matbutikk" : (language == "th" ? "ร้านขายของชำนานาชาติ" : "International grocery store")
        case .unknown: language == "nb" ? "Ukjent butikktype" : (language == "th" ? "ประเภทร้านไม่ทราบ" : "Unknown store type")
        }
    }
}

extension RecipeContentStatus {
    var localizedName: LocalizedStringResource {
        switch self {
        case .demo: "Demo"
        case .draft: "Draft"
        case .reviewed: "Reviewed"
        case .unknown: "Unknown status"
        }
    }
}

extension FoodAllergen {
    var localizedName: LocalizedStringResource {
        switch self {
        case .gluten: "Cereals containing gluten"
        case .crustaceans: "Crustaceans"
        case .eggs: "Eggs"
        case .fish: "Fish allergen"
        case .peanuts: "Peanuts"
        case .soybeans: "Soybeans"
        case .milk: "Milk"
        case .nuts: "Nuts"
        case .celery: "Celery"
        case .mustard: "Mustard"
        case .sesame: "Sesame"
        case .sulphites: "Sulphur dioxide and sulphites"
        case .lupin: "Lupin"
        case .molluscs: "Molluscs"
        }
    }
}
