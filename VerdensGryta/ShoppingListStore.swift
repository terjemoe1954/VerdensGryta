import Foundation
import Observation

struct ShoppingListItem: Codable, Identifiable, Hashable {
    let id: String
    let recipeID: String
    let recipeTitle: LocalizedText
    let country: LocalizedText
    let servings: Decimal
    let ingredientID: String
    let name: LocalizedText
    let originalName: LocalizedText?
    var quantity: Decimal?
    var unit: IngredientUnit?
    let amountNote: LocalizedText?
    let storeType: StoreType?
    let shoppingGuidance: LocalizedText?
    let department: ShoppingDepartment?
    let selectedChangeID: String?
    let selectedQuantityFactor: Decimal?
    var isIncluded: Bool
    var isChecked: Bool

    var mergeKey: String {
        "\(ingredientID)|\(unitKey)|\(originalName == nil ? "original" : id)"
    }

    private var unitKey: String {
        String(describing: unit)
    }
}

@MainActor
@Observable
final class ShoppingListStore {
    private(set) var items: [ShoppingListItem] = []
    private let storageKey = "shoppingListItems"

    init() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([ShoppingListItem].self, from: data) else {
            return
        }
        items = decoded
    }

    func replaceRecipe(
        recipe: Recipe,
        servings: Decimal,
        ingredients: [ScaledIngredient]
    ) {
        let checkedByID = Dictionary(uniqueKeysWithValues: items.map { ($0.id, $0.isChecked) })
        items.removeAll { $0.recipeID == recipe.id }
        items.append(contentsOf: ingredients.map { scaled in
            let changeSuffix = scaled.selectedChange?.id ?? "original"
            let id = "\(recipe.id)|\(scaled.id)|\(changeSuffix)"
            return ShoppingListItem(
                id: id,
                recipeID: recipe.id,
                recipeTitle: recipe.title,
                country: recipe.country,
                servings: servings,
                ingredientID: scaled.id,
                name: scaled.ingredient.name,
                originalName: scaled.originalIngredient?.name,
                quantity: scaled.quantity,
                unit: scaled.ingredient.unit,
                amountNote: scaled.ingredient.amountNote,
                storeType: scaled.ingredient.shoppingGuide?.storeType,
                shoppingGuidance: scaled.ingredient.shoppingGuide?.guidance,
                department: ShoppingDepartment(ingredientID: scaled.id),
                selectedChangeID: scaled.selectedChange?.id,
                selectedQuantityFactor: scaled.selectedChange?.quantityFactor,
                isIncluded: true,
                isChecked: checkedByID[id] ?? false
            )
        })
        save()
    }

    func addManualItem(named name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let id = UUID().uuidString
        let text = LocalizedText(values: ["en": trimmed, "nb": trimmed, "th": trimmed])
        items.append(ShoppingListItem(
            id: id,
            recipeID: "manual",
            recipeTitle: LocalizedText(values: ["en": "Manual items", "nb": "Egne varer", "th": "รายการที่เพิ่มเอง"]),
            country: LocalizedText(values: ["en": "", "nb": "", "th": ""]),
            servings: 0,
            ingredientID: "manual-\(id)",
            name: text,
            originalName: nil,
            quantity: nil,
            unit: nil,
            amountNote: nil,
            storeType: nil,
            shoppingGuidance: nil,
            department: nil,
            selectedChangeID: nil,
            selectedQuantityFactor: nil,
            isIncluded: true,
            isChecked: false
        ))
        save()
    }

    func remove(_ id: String) {
        items.removeAll { $0.id == id }
        save()
    }

    func revertAlternative(for id: String) {
        guard let index = items.firstIndex(where: { $0.id == id }),
              let original = items[index].originalName else { return }
        let item = items[index]
        let factor = item.selectedQuantityFactor ?? 1
        items[index] = ShoppingListItem(
            id: item.id,
            recipeID: item.recipeID,
            recipeTitle: item.recipeTitle,
            country: item.country,
            servings: item.servings,
            ingredientID: item.ingredientID,
            name: original,
            originalName: nil,
            quantity: item.quantity.map { factor == 0 ? $0 : $0 / factor },
            unit: item.unit,
            amountNote: item.amountNote,
            storeType: item.storeType,
            shoppingGuidance: item.shoppingGuidance,
            department: item.department,
            selectedChangeID: nil,
            selectedQuantityFactor: nil,
            isIncluded: item.isIncluded,
            isChecked: item.isChecked
        )
        save()
    }

    func setIncluded(_ included: Bool, for id: String) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        items[index].isIncluded = included
        save()
    }

    func setChecked(_ checked: Bool, for id: String) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        items[index].isChecked = checked
        save()
    }

    func setQuantity(_ quantity: Decimal?, for id: String) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        items[index].quantity = quantity
        save()
    }

    var includedItems: [ShoppingListItem] {
        items.filter(\.isIncluded)
    }

    func mergedItems() -> [ShoppingListItem] {
        var result: [ShoppingListItem] = []
        for sourceItem in includedItems {
            let item = normalizedForMerge(sourceItem)
            if let index = result.firstIndex(where: { $0.mergeKey == item.mergeKey }),
               let current = result[index].quantity,
               let additional = item.quantity {
                result[index].quantity = current + additional
            } else {
                result.append(item)
            }
        }
        return result
    }

    private func normalizedForMerge(_ source: ShoppingListItem) -> ShoppingListItem {
        var item = source
        guard let quantity = item.quantity, let unit = item.unit else { return item }
        switch unit {
        case .kilogram:
            item.quantity = quantity * 1_000
            item.unit = .gram
        case .liter:
            item.quantity = quantity * 1_000
            item.unit = .milliliter
        case .tablespoon:
            item.quantity = quantity * 3
            item.unit = .teaspoon
        case .gram, .milliliter, .teaspoon, .item, .toTaste, .unknown:
            break
        }
        return item
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}

enum ShoppingDepartment: String, Codable, CaseIterable, Hashable {
    case produce, meat, dairy, sauces, pantry, bakery, other

    init(ingredientID: String) {
        switch ingredientID {
        case "holy-basil", "garlic", "chilli", "cabbage", "onion": self = .produce
        case "chicken", "lamb": self = .meat
        case "crema", "cheese": self = .dairy
        case "sauce", "salsa": self = .sauces
        case "tortillas": self = .bakery
        case "pepper", "salt", "water": self = .pantry
        default: self = .other
        }
    }

    var localizedName: LocalizedStringResource {
        return switch self {
        case .produce: "Fruit and vegetables"
        case .meat: "Meat"
        case .dairy: "Dairy"
        case .sauces: "Sauces and international pantry"
        case .pantry: "Pantry"
        case .bakery: "Bread and tortillas"
        case .other: "Other department"
        }
    }

    func localizedString(locale: Locale) -> String {
        let language = locale.language.languageCode?.identifier
        return switch self {
        case .produce: language == "nb" ? "Frukt og grønt" : (language == "th" ? "ผักและผลไม้" : "Fruit and vegetables")
        case .meat: language == "nb" ? "Kjøtt" : (language == "th" ? "เนื้อสัตว์" : "Meat")
        case .dairy: language == "nb" ? "Meierivarer" : (language == "th" ? "ผลิตภัณฑ์นม" : "Dairy")
        case .sauces: language == "nb" ? "Sauser og internasjonale varer" : (language == "th" ? "ซอสและอาหารนานาชาติ" : "Sauces and international pantry")
        case .pantry: language == "nb" ? "Tørrvarer" : (language == "th" ? "ของแห้ง" : "Pantry")
        case .bakery: language == "nb" ? "Brød og tortillas" : (language == "th" ? "ขนมปังและตอร์ติยา" : "Bread and tortillas")
        case .other: language == "nb" ? "Annen avdeling" : (language == "th" ? "แผนกอื่น" : "Other department")
        }
    }
}
