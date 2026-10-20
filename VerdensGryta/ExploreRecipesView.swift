import SwiftUI
import SwiftData

struct ExploreRecipesView: View {
    @Environment(\.locale) private var locale
    @State private var loadState = RecipeLoadState.loading
    @State private var searchText = ""
    @State private var filters = RecipeFilterSelection()
    @State private var showsFilters = false

    private let loader = RecipeLoader()

    var body: some View {
        NavigationStack {
            ExploreContent(
                loadState: loadState,
                retry: loadRecipes,
                searchText: searchText,
                filters: filters
            )
            .navigationTitle(Text(verbatim: ""))
            .toolbar {
                ToolbarItem(placement: .principal) {
                    ExploreNavigationTitle()
                }

                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        Button {
                            showsFilters = true
                        } label: {
                            Label("Filters", systemImage: filters.isActive ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                        }
                        NavigationLink {
                            ShoppingListView()
                        } label: {
                            Label("Shopping list", systemImage: "cart")
                        }
                        NavigationLink {
                            SettingsView()
                        } label: {
                            SettingsToolbarLabel()
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search dishes and ingredients")
            .sheet(isPresented: $showsFilters) {
                RecipeFiltersView(selection: $filters, countries: countries)
            }
            .id(locale.identifier)
        }
        .task {
            if case .loading = loadState {
                loadRecipes()
            }
        }
    }

    private var countries: [String] {
        guard case .loaded(let recipes) = loadState else { return [] }
        return Set(recipes.map { $0.country.resolve(locale: locale).value }).sorted()
    }

    private func loadRecipes() {
        loadState = .loading

        do {
            loadState = .loaded(try loader.load())
        } catch {
            loadState = .failed(error.localizedDescription)
        }
    }
}

private enum RecipeLoadState: Equatable {
    case loading
    case loaded([Recipe])
    case failed(String)
}

private struct ExploreContent: View {
    let loadState: RecipeLoadState
    let retry: () -> Void
    let searchText: String
    let filters: RecipeFilterSelection

    var body: some View {
        switch loadState {
        case .loading:
            ProgressView("Loading recipes…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .loaded(let recipes):
            RecipeList(recipes: recipes, searchText: searchText, filters: filters)
        case .failed(let message):
            RecipeLoadErrorView(message: message, retry: retry)
        }
    }
}

private struct RecipeList: View {
    @Environment(CookingSessionStore.self) private var cookingSessionStore
    @Environment(\.locale) private var locale
    @Query private var userStates: [UserRecipeState]
    let recipes: [Recipe]
    let searchText: String
    let filters: RecipeFilterSelection

    var body: some View {
        List {
            if let session = cookingSessionStore.session,
               let activeRecipe = recipes.first(where: { $0.id == session.recipeID }) {
                Section("Active cooking session") {
                    NavigationLink {
                        CookingModeView(recipe: activeRecipe)
                    } label: {
                        HStack {
                            Image(systemName: "fork.knife")
                                .accessibilityHidden(true)
                            VStack(alignment: .leading) {
                                Text("Resume cooking")
                                Text(activeRecipe.title.resolve(locale: locale).value)
                                    .font(.subheadline)
                            }
                        }
                        .font(.headline)
                        .accessibilityElement(children: .combine)
                    }
                }
            }

            Section {
                if filteredRecipes.isEmpty {
                    ContentUnavailableView(
                        "No matching recipes",
                        systemImage: "magnifyingglass",
                        description: Text("Try another search or clear one or more filters.")
                    )
                }
                ForEach(filteredRecipes) { recipe in
                    NavigationLink {
                        RecipeDetailView(recipe: recipe)
                    } label: {
                        RecipeCard(
                            recipeID: recipe.id,
                            title: recipe.title,
                            country: recipe.country,
                            dishType: recipe.dishType,
                            summary: recipe.summary,
                            symbolName: recipe.symbolName,
                            totalMinutes: recipe.timing.totalMinutes,
                            difficulty: recipe.difficulty,
                            isFavorite: userStates.contains {
                                $0.recipeID == recipe.id && $0.isFavorite
                            }
                        )
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(
                        EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
                    )
                }
            } header: {
                Text(LocalizedCopy.exploreTitle.resource(locale: locale))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                    .textCase(nil)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
    }

    private var filteredRecipes: [Recipe] {
        let favoriteIDs = Set(userStates.filter(\.isFavorite).map(\.recipeID))
        let query = normalizedSearchText(
            searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        return recipes.filter { recipe in
            let searchValues = [
                recipe.title.resolve(locale: locale).value,
                recipe.originalName,
                recipe.country.resolve(locale: locale).value,
                recipe.region?.resolve(locale: locale).value ?? ""
            ] + recipe.ingredients.flatMap { ingredient in
                [ingredient.name.resolve(locale: locale).value]
                    + ingredient.alternativeProductNames
            }
            let matchesSearch = query.isEmpty || searchValues.contains {
                normalizedSearchText($0).contains(query)
            }
            let country = recipe.country.resolve(locale: locale).value
            return matchesSearch
                && (filters.category.map { recipe.categories.contains($0) } ?? true)
                && (filters.country.map { country == $0 } ?? true)
                && (filters.dishType.map { recipe.dishType == $0 } ?? true)
                && (filters.equipment.map { recipe.equipment.contains($0) } ?? true)
                && (filters.maximumMinutes.map { recipe.timing.totalMinutes <= $0 } ?? true)
                && (!filters.favoritesOnly || favoriteIDs.contains(recipe.id))
        }
    }

    private func normalizedSearchText(_ value: String) -> String {
        value.folding(
            options: [.caseInsensitive, .diacriticInsensitive],
            locale: locale
        )
    }
}

private struct RecipeCard: View {
    let recipeID: String
    let title: LocalizedText
    let country: LocalizedText
    let dishType: RecipeDishType
    let summary: LocalizedText
    let symbolName: String?
    let totalMinutes: Int
    let difficulty: RecipeDifficulty
    let isFavorite: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                RecipeArtwork(recipeID: recipeID, symbolName: symbolName)

                VStack {
                    HStack(alignment: .top) {
                        Text(dishType.localizedName)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.black.opacity(0.22), in: Capsule())

                        Spacer()

                        if isFavorite {
                            Image(systemName: "heart.fill")
                                .foregroundStyle(.white)
                                .padding(8)
                                .background(.black.opacity(0.22), in: Circle())
                                .accessibilityLabel("Add to favorites")
                        }
                    }
                    Spacer()
                }
                .padding(12)
            }
            .frame(height: 112)
            .clipped()

            VStack(alignment: .leading, spacing: 10) {
                RecipeCardText(content: title, style: .headline)

                HStack(spacing: 6) {
                    Image(systemName: "mappin.and.ellipse")
                        .accessibilityHidden(true)
                    RecipeCardText(content: country, style: .subheadline)
                }
                .foregroundStyle(.secondary)

                RecipeCardText(content: summary, style: .subheadline)
                    .foregroundStyle(.secondary)

                Divider()

                HStack(spacing: 16) {
                    Label("\(totalMinutes) min", systemImage: "clock")
                    Label(difficulty.localizedName, systemImage: "chart.bar")
                }
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            }
            .padding(16)
        }
        .background(.background, in: RoundedRectangle(cornerRadius: 20))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(.primary.opacity(0.08))
        }
        .shadow(color: .black.opacity(0.07), radius: 12, y: 5)
        .contentShape(RoundedRectangle(cornerRadius: 20))
        .accessibilityElement(children: .combine)
    }

}

private struct RecipeCardText: View {
    @Environment(\.locale) private var locale

    let content: LocalizedText
    let style: Font.TextStyle

    var body: some View {
        let resolved = content.resolve(locale: locale)

        VStack(alignment: .leading, spacing: 2) {
            Text(resolved.value)
                .font(.system(style))

            if resolved.usedFallback {
                Text("English fallback")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct RecipeLoadErrorView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("Couldn’t load recipes", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("Try again", action: retry)
        }
    }
}

private struct ExploreNavigationTitle: View {
    @Environment(\.locale) private var locale

    var body: some View {
        Text(LocalizedCopy.exploreTitle.resource(locale: locale))
            .font(.headline)
            .accessibilityAddTraits(.isHeader)
    }
}

private struct SettingsToolbarLabel: View {
    @Environment(\.locale) private var locale

    var body: some View {
        Label {
            Text(LocalizedCopy.settingsTitle.resource(locale: locale))
        } icon: {
            Image(systemName: "gearshape")
        }
    }
}

#Preview {
    ExploreRecipesView()
}
