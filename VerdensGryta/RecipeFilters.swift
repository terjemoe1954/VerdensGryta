import SwiftUI

struct RecipeFilterSelection: Equatable {
    var category: RecipeCategory?
    var country: String?
    var dishType: RecipeDishType?
    var equipment: CookingEquipment?
    var maximumMinutes: Int?
    var favoritesOnly = false

    var isActive: Bool {
        category != nil || country != nil || dishType != nil || equipment != nil || maximumMinutes != nil || favoritesOnly
    }

    mutating func clear() {
        self = RecipeFilterSelection()
    }
}

struct RecipeFiltersView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selection: RecipeFilterSelection
    let countries: [String]

    private let categories: [RecipeCategory] = [.beef, .pork, .lamb, .poultry, .fish, .crustacean, .mollusc, .vegetarian]
    private let dishTypes: [RecipeDishType] = [.nationalDish, .popularDish, .regionalSpecialty]
    private let equipment: [CookingEquipment] = [.stove, .oven, .airFryer, .slowCooker, .pot, .fryingPan, .noHeat]

    var body: some View {
        NavigationStack {
            Form {
                Toggle("Favorites only", isOn: $selection.favoritesOnly)
                Picker("Category", selection: $selection.category) {
                    Text("All categories").tag(RecipeCategory?.none)
                    ForEach(categories, id: \.self) { Text($0.localizedName).tag(Optional($0)) }
                }
                Picker("Country", selection: $selection.country) {
                    Text("All countries").tag(String?.none)
                    ForEach(countries, id: \.self) { Text($0).tag(Optional($0)) }
                }
                Picker("Dish type", selection: $selection.dishType) {
                    Text("All dish types").tag(RecipeDishType?.none)
                    ForEach(dishTypes, id: \.self) { Text($0.localizedName).tag(Optional($0)) }
                }
                Picker("Equipment", selection: $selection.equipment) {
                    Text("All equipment").tag(CookingEquipment?.none)
                    ForEach(equipment, id: \.self) { Text($0.localizedName).tag(Optional($0)) }
                }
                Picker("Maximum total time", selection: $selection.maximumMinutes) {
                    Text("Any duration").tag(Int?.none)
                    Text("Up to 30 min").tag(Int?.some(30))
                    Text("Up to 60 min").tag(Int?.some(60))
                    Text("Up to 3 hours").tag(Int?.some(180))
                }
            }
            .navigationTitle("Filters")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Clear") { selection.clear() }
                        .disabled(!selection.isActive)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
