import SwiftUI
import SwiftData

@main
struct VerdensGrytaApp: App {
    @State private var shoppingListStore = ShoppingListStore()
    @State private var recipeSelectionStore = RecipeSelectionStore()
    @State private var cookingSessionStore = CookingSessionStore()
    @AppStorage("appLanguage") private var appLanguage = AppLanguage.norwegian.rawValue
    @AppStorage("appTheme") private var appTheme = AppTheme.system.rawValue

    private var language: AppLanguage {
        AppLanguage(rawValue: appLanguage) ?? .norwegian
    }

    private var theme: AppTheme {
        AppTheme(rawValue: appTheme) ?? .system
    }

    var body: some Scene {
        WindowGroup {
            ExploreRecipesView()
                .environment(shoppingListStore)
                .environment(recipeSelectionStore)
                .environment(cookingSessionStore)
                .environment(\.locale, Locale(identifier: language.rawValue))
                .preferredColorScheme(theme.colorScheme)
        }
        .modelContainer(for: UserRecipeState.self)
    }
}
