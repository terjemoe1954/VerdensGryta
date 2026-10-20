import SwiftUI
import SwiftData

struct RecipeDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.locale) private var locale
    @Environment(ShoppingListStore.self) private var shoppingListStore
    @Environment(RecipeSelectionStore.self) private var recipeSelectionStore
    @Environment(CookingSessionStore.self) private var cookingSessionStore
    @Environment(\.modelContext) private var modelContext
    @Query private var userStates: [UserRecipeState]
    @State private var selectedServings: Double
    @State private var selectedSubstitutionIDs: Set<String> = []
    @AppStorage("selectedAllergens") private var selectedAllergens = ""

    let recipe: Recipe
    private let calculator = PortionCalculator()

    init(recipe: Recipe) {
        self.recipe = recipe
        _selectedServings = State(initialValue: Double(recipe.baseServings))
    }

    var body: some View {
        let scaledAmounts = calculator.calculate(
            recipe: recipe,
            selectedServings: Decimal(selectedServings),
            selectedSubstitutionIDs: selectedSubstitutionIDs
        )
        let allergenProfile = Set(selectedAllergens.split(separator: ",").compactMap {
            FoodAllergen(rawValue: String($0))
        })
        let assessment = AllergenAssessmentService().assess(
            ingredients: scaledAmounts.ingredients,
            profile: allergenProfile
        )

        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                RecipeImagePlaceholder(recipeID: recipe.id, symbolName: recipe.symbolName)
                RecipeHeaderSection(
                    title: recipe.title,
                    originalName: recipe.originalName,
                    country: recipe.country,
                    region: recipe.region,
                    dishType: recipe.dishType
                )
                RecipeHistorySection(
                    summary: recipe.summary,
                    history: recipe.history
                )
                RecipeFactsSection(
                    baseServings: recipe.baseServings,
                    difficulty: recipe.difficulty,
                    categories: recipe.categories,
                    equipment: recipe.equipment
                )
                RecipePortionSection(
                    selectedServings: $selectedServings,
                    baseServings: recipe.baseServings,
                    needsEquipmentCapacityCheck: scaledAmounts.needsEquipmentCapacityCheck
                )
                RecipeTimingSection(timing: recipe.timing)
                RecipeAllergenSection(assessment: assessment, profileIsEmpty: allergenProfile.isEmpty)
                RecipeUserSection(
                    isFavorite: userState?.isFavorite ?? false,
                    note: Binding(
                        get: { userState?.note ?? "" },
                        set: updateNote
                    ),
                    toggleFavorite: toggleFavorite
                )
                RecipePriceSection(
                    estimate: recipe.priceEstimate,
                    baseServings: recipe.baseServings,
                    selectedServings: scaledAmounts.selectedServings
                )
                if let changes = recipe.adaptedVariant?.changes, !changes.isEmpty {
                    RecipeSubstitutionsSection(
                        changes: changes,
                        ingredients: recipe.ingredients,
                        selectedIDs: $selectedSubstitutionIDs
                    )
                }
                RecipeIngredientsSection(
                    ingredients: scaledAmounts.ingredients,
                    allergenProfile: allergenProfile
                )
                RecipeStepsSection(
                    steps: recipe.steps,
                    ingredientsByStepID: scaledAmounts.ingredientsByStepID,
                    selectedChanges: recipe.adaptedVariant?.changes.filter {
                        selectedSubstitutionIDs.contains($0.id)
                    } ?? []
                )
                RecipeVariantsSection(
                    originalVariant: recipe.originalVariant,
                    adaptedVariant: recipe.adaptedVariant
                )
                RecipeSourceSection(
                    source: recipe.source,
                    status: recipe.contentStatus,
                    lastContentReview: recipe.lastContentReview
                )
                NavigationLink {
                    CookingModeView(recipe: recipe)
                } label: {
                    if cookingSessionStore.session?.recipeID == recipe.id {
                        Label("Resume cooking", systemImage: "fork.knife")
                            .frame(maxWidth: .infinity)
                    } else {
                        Label("Start cooking", systemImage: "fork.knife")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .simultaneousGesture(TapGesture().onEnded {
                    if cookingSessionStore.session?.recipeID != recipe.id {
                        cookingSessionStore.start(
                            recipeID: recipe.id,
                            servings: scaledAmounts.selectedServings,
                            substitutionIDs: selectedSubstitutionIDs
                        )
                    }
                })
            }
            .padding()
        }
        .navigationTitle(Text(recipe.title.resolve(locale: locale).value))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            selectedSubstitutionIDs = recipeSelectionStore.substitutions(for: recipe.id)
        }
        .onChange(of: selectedSubstitutionIDs) { _, newValue in
            recipeSelectionStore.setSubstitutions(newValue, for: recipe.id)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Label(recipesTitle, systemImage: "chevron.backward")
                }
                .accessibilityLabel(recipesTitle)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    shoppingListStore.replaceRecipe(
                        recipe: recipe,
                        servings: scaledAmounts.selectedServings,
                        ingredients: scaledAmounts.ingredients
                    )
                } label: {
                    Label("Add to shopping list", systemImage: "cart.badge.plus")
                }
            }
        }
    }

    private var recipesTitle: String {
        switch locale.language.languageCode?.identifier {
        case "nb": "Oppskrifter"
        case "th": "สูตรอาหาร"
        default: "Recipes"
        }
    }

    private var userState: UserRecipeState? {
        userStates.first { $0.recipeID == recipe.id }
    }

    private func stateForEditing() -> UserRecipeState {
        if let userState { return userState }
        let state = UserRecipeState(recipeID: recipe.id)
        modelContext.insert(state)
        return state
    }

    private func toggleFavorite() {
        let state = stateForEditing()
        state.isFavorite.toggle()
        try? modelContext.save()
    }

    private func updateNote(_ note: String) {
        stateForEditing().note = note
        try? modelContext.save()
    }
}

private struct RecipeUserSection: View {
    let isFavorite: Bool
    @Binding var note: String
    let toggleFavorite: () -> Void

    var body: some View {
        DetailSection(title: "My recipe") {
            Button(action: toggleFavorite) {
                if isFavorite {
                    Label("Remove from favorites", systemImage: "heart.fill")
                } else {
                    Label("Add to favorites", systemImage: "heart")
                }
            }
            Text("Private note")
                .font(.headline)
            TextEditor(text: $note)
                .frame(minHeight: 100)
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.secondary.opacity(0.3))
                }
                .accessibilityLabel("Private note")
            Text("Favorites and notes are stored only on this device.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

private struct RecipePriceSection: View {
    @Environment(\.locale) private var locale
    let estimate: PriceEstimate?
    let baseServings: Int
    let selectedServings: Decimal

    var body: some View {
        DetailSection(title: "Price estimate") {
            if let estimate {
                let baseTotal = estimate.totalNOK
                let perServing = baseTotal / Decimal(baseServings)
                let selectedTotal = perServing * selectedServings
                LabeledContent("Estimated dish total") {
                    Text(selectedTotal, format: .currency(code: "NOK"))
                }
                LabeledContent("Estimated per serving") {
                    Text(perServing, format: .currency(code: "NOK"))
                }
                LabeledContent("Estimate date", value: estimate.asOfDate)
                LocalizedContentText(content: estimate.basis, textStyle: .footnote)
                if !estimate.missingIngredientIDs.isEmpty {
                    Label("Some ingredients are missing from the estimate", systemImage: "exclamationmark.triangle")
                }
                Text("Estimate only. The cost of whole packages can be higher.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else {
                ContentUnavailableView("Price estimate unavailable", systemImage: "banknote")
            }
        }
    }
}

private struct RecipeImagePlaceholder: View {
    let recipeID: String
    let symbolName: String?

    var body: some View {
        ZStack {
            RecipeArtwork(recipeID: recipeID, symbolName: symbolName)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 210)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(alignment: .bottomTrailing) {
            Image(systemName: "fork.knife")
                .font(.headline)
                .foregroundStyle(.white)
                .padding(12)
                .background(.black.opacity(0.22), in: Circle())
                .padding(14)
                .accessibilityHidden(true)
        }
        .accessibilityHidden(true)
    }
}

private struct RecipeHeaderSection: View {
    let title: LocalizedText
    let originalName: String
    let country: LocalizedText
    let region: LocalizedText?
    let dishType: RecipeDishType

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            LocalizedContentText(content: title, textStyle: .largeTitle)

            Text(originalName)
                .font(.title3)
                .foregroundStyle(.secondary)

            Label {
                VStack(alignment: .leading, spacing: 2) {
                    LocalizedContentText(content: country, textStyle: .body)
                    if let region {
                        LocalizedContentText(content: region, textStyle: .subheadline)
                    }
                }
            } icon: {
                Image(systemName: "globe.europe.africa")
            }

            Label(dishType.localizedName, systemImage: "fork.knife")
                .font(.subheadline)

        }
    }
}

private struct RecipeHistorySection: View {
    let summary: LocalizedText
    let history: LocalizedText

    var body: some View {
        DetailSection(title: "About this dish") {
            LocalizedContentText(content: summary, textStyle: .headline)
            LocalizedContentText(content: history, textStyle: .body)
        }
    }
}

private struct RecipeFactsSection: View {
    let baseServings: Int
    let difficulty: RecipeDifficulty
    let categories: [RecipeCategory]
    let equipment: [CookingEquipment]

    var body: some View {
        DetailSection(title: "Recipe facts") {
            LabeledContent("Base servings") {
                Text(baseServings, format: .number)
            }

            LabeledContent("Difficulty") {
                Text(difficulty.localizedName)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Categories")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                ForEach(Array(categories.enumerated()), id: \.offset) { _, category in
                    Label(category.localizedName, systemImage: category.symbolName)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Equipment")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                ForEach(Array(equipment.enumerated()), id: \.offset) { _, item in
                    Label(item.localizedName, systemImage: item.symbolName)
                }
            }
        }
    }
}

private struct RecipePortionSection: View {
    @Binding var selectedServings: Double

    let baseServings: Int
    let needsEquipmentCapacityCheck: Bool

    var body: some View {
        DetailSection(title: "Portions") {
            Stepper(
                value: $selectedServings,
                in: 0.5...12,
                step: 0.5
            ) {
                LabeledContent("Selected servings") {
                    Text(
                        selectedServings,
                        format: .number.precision(.fractionLength(0...1))
                    )
                    .font(.headline)
                }
            }

            Text("Amounts are always recalculated from the original recipe for \(baseServings) servings.")
                .font(.footnote)
                .foregroundStyle(.secondary)

            if needsEquipmentCapacityCheck {
                Label(
                    "Check pot and pan capacity. Large batches may need to cook in rounds; time and temperature do not scale automatically.",
                    systemImage: "exclamationmark.triangle"
                )
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
        }
    }
}

private struct RecipeTimingSection: View {
    let timing: RecipeTiming

    var body: some View {
        DetailSection(title: "Time") {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 110), alignment: .leading)],
                alignment: .leading,
                spacing: 12
            ) {
                TimeValue(title: "Preparation", minutes: timing.preparationMinutes)
                TimeValue(title: "Active", minutes: timing.activeMinutes)
                TimeValue(title: "Waiting", minutes: timing.waitingMinutes)
                TimeValue(title: "Total", minutes: timing.totalMinutes)
            }

            LocalizedContentText(content: timing.overlapNote, textStyle: .footnote)
        }
    }
}

private struct TimeValue: View {
    let title: LocalizedStringResource
    let minutes: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("\(minutes) min")
                .font(.headline)
        }
    }
}

private struct RecipeIngredientsSection: View {
    let ingredients: [ScaledIngredient]
    let allergenProfile: Set<FoodAllergen>

    var body: some View {
        DetailSection(title: "Ingredients") {
            ForEach(ingredients) { ingredient in
                IngredientDetailRow(ingredient: ingredient, allergenProfile: allergenProfile)

                if ingredient.id != ingredients.last?.id {
                    Divider()
                }
            }
        }
    }
}

private struct IngredientDetailRow: View {
    let ingredient: ScaledIngredient
    let allergenProfile: Set<FoodAllergen>

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                LocalizedContentText(
                    content: ingredient.ingredient.name,
                    textStyle: .body
                )
                Spacer()
                IngredientAmount(
                    quantity: ingredient.quantity,
                    unit: ingredient.ingredient.unit,
                    amountNote: ingredient.ingredient.amountNote
                )
            }

            if let original = ingredient.originalIngredient {
                HStack(spacing: 4) {
                    Text("Original:")
                    LocalizedContentText(content: original.name, textStyle: .footnote)
                    Text("— selected alternative")
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
            }

            let knownMatches = Set(ingredient.ingredient.knownAllergens).intersection(allergenProfile)
            let possibleMatches = Set(ingredient.ingredient.uncertainAllergens).intersection(allergenProfile)
            if !knownMatches.isEmpty {
                AllergenLabels(title: "Contains", allergens: knownMatches, color: .red)
            }
            if !possibleMatches.isEmpty {
                AllergenLabels(title: "Possible or product-dependent", allergens: possibleMatches, color: .orange)
            }
            if ingredient.ingredient.resolvedAllergenDataStatus == .unknown {
                Label("Allergen information is incomplete", systemImage: "questionmark.circle")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            if !ingredient.ingredient.alternativeProductNames.isEmpty {
                Text("Also sold as: \(ingredient.ingredient.alternativeProductNames.formatted())")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            if let guide = ingredient.ingredient.shoppingGuide {
                Label {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(guide.storeType.localizedName)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        LocalizedContentText(
                            content: guide.guidance,
                            textStyle: .footnote
                        )
                    }
                } icon: {
                    Image(systemName: "basket")
                }
            }
        }
    }
}

private struct IngredientAmount: View {
    @Environment(\.locale) private var locale

    let quantity: Decimal?
    let unit: IngredientUnit?
    let amountNote: LocalizedText?

    private let formatter = IngredientQuantityFormatter()

    var body: some View {
        if let quantity, let unit {
            let formatted = formatter.format(
                quantity: quantity,
                unit: unit,
                locale: locale
            )

            HStack(spacing: 4) {
                Text(formatted.quantityText)
                Text(formatted.unit.localizedName)
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        } else if let amountNote {
            LocalizedContentText(content: amountNote, textStyle: .subheadline)
        }
    }
}

private struct RecipeStepsSection: View {
    let steps: [RecipeStep]
    let ingredientsByStepID: [String: [ScaledIngredient]]
    let selectedChanges: [VariantChange]

    var body: some View {
        DetailSection(title: "Preparation steps") {
            ForEach(steps) { step in
                RecipeStepRow(
                    step: displayedStep(step),
                    ingredients: ingredientsByStepID[step.id] ?? []
                )

                if step.id != steps.last?.id {
                    Divider()
                }
            }
        }
    }

    private func displayedStep(_ step: RecipeStep) -> RecipeStep {
        let override = selectedChanges.lazy.compactMap {
            $0.stepTextOverrides?[step.id]
        }.first
        return RecipeStep(id: step.id, order: step.order, text: override ?? step.text, ingredientIDs: step.ingredientIDs)
    }
}

private struct RecipeAllergenSection: View {
    let assessment: AllergenAssessment
    let profileIsEmpty: Bool

    var body: some View {
        DetailSection(title: "Allergen assessment") {
            if profileIsEmpty {
                Label("Choose allergens in Settings to highlight matches.", systemImage: "person.crop.circle.badge.questionmark")
            } else if assessment.matchedKnown.isEmpty && assessment.matchedPossible.isEmpty {
                Label("No matches were found in the available data. This is not a safety guarantee.", systemImage: "info.circle")
            }
            if !assessment.matchedKnown.isEmpty {
                AllergenLabels(title: "Known match", allergens: assessment.matchedKnown, color: .red)
            }
            if !assessment.matchedPossible.isEmpty {
                AllergenLabels(title: "Possible or unknown content", allergens: assessment.matchedPossible, color: .orange)
            }
            if assessment.hasUnknownData {
                Label("Some ingredients have incomplete allergen data.", systemImage: "questionmark.circle")
                    .foregroundStyle(.secondary)
            }
            Text("Always check product labels and consider cross-contact. The app cannot guarantee that this dish is safe for an allergy.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

private struct AllergenLabels: View {
    let title: LocalizedStringResource
    let allergens: Set<FoodAllergen>
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            ForEach(FoodAllergen.allCases.filter(allergens.contains)) { allergen in
                Label(allergen.localizedName, systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(color)
                    .font(.subheadline)
            }
        }
    }
}

private struct RecipeSubstitutionsSection: View {
    let changes: [VariantChange]
    let ingredients: [Ingredient]
    @Binding var selectedIDs: Set<String>

    var body: some View {
        DetailSection(title: "Ingredient alternatives") {
            ForEach(changes) { change in
                VStack(alignment: .leading, spacing: 8) {
                    Button {
                        if selectedIDs.contains(change.id) {
                            selectedIDs.remove(change.id)
                        } else {
                            selectedIDs.insert(change.id)
                        }
                    } label: {
                        Label(
                            selectedIDs.contains(change.id) ? "Use original ingredient" : "Choose this alternative",
                            systemImage: selectedIDs.contains(change.id) ? "checkmark.circle.fill" : "circle"
                        )
                    }
                    if let original = ingredients.first(where: { $0.id == change.originalIngredientID }) {
                        HStack(spacing: 4) {
                            Text("Original:")
                            LocalizedContentText(content: original.name, textStyle: .subheadline)
                            Text("—")
                            LocalizedContentText(content: change.alternativeName, textStyle: .subheadline)
                        }
                    }
                    LocalizedContentText(content: change.reason, textStyle: .body)
                    LocalizedContentText(content: change.difference, textStyle: .footnote)
                    if let timeChange = change.timeChange {
                        Label { LocalizedContentText(content: timeChange, textStyle: .footnote) } icon: { Image(systemName: "clock") }
                    }
                    if let temperatureChange = change.temperatureChange {
                        Label { LocalizedContentText(content: temperatureChange, textStyle: .footnote) } icon: { Image(systemName: "thermometer.medium") }
                    }
                }
                if change.id != changes.last?.id { Divider() }
            }
        }
    }
}

private struct RecipeStepRow: View {
    let step: RecipeStep
    let ingredients: [ScaledIngredient]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Step \(step.order)")
                .font(.headline)
            LocalizedContentText(content: step.text, textStyle: .body)

            ForEach(ingredients) { ingredient in
                HStack(alignment: .firstTextBaseline) {
                    LocalizedContentText(
                        content: ingredient.ingredient.name,
                        textStyle: .footnote
                    )
                    Spacer()
                    IngredientAmount(
                        quantity: ingredient.quantity,
                        unit: ingredient.ingredient.unit,
                        amountNote: ingredient.ingredient.amountNote
                    )
                }
                .foregroundStyle(.secondary)
            }
        }
    }
}

private struct RecipeVariantsSection: View {
    let originalVariant: RecipeVariant
    let adaptedVariant: RecipeVariant?

    var body: some View {
        DetailSection(title: "Variants") {
            RecipeVariantBlock(
                heading: "Original variant",
                variant: originalVariant,
                symbolName: "doc.text"
            )

            if let adaptedVariant {
                Divider()
                RecipeVariantBlock(
                    heading: "Adapted variant",
                    variant: adaptedVariant,
                    symbolName: "cart"
                )
            }
        }
    }
}

private struct RecipeVariantBlock: View {
    let heading: LocalizedStringResource
    let variant: RecipeVariant
    let symbolName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(heading, systemImage: symbolName)
                .font(.headline)
            LocalizedContentText(content: variant.name, textStyle: .subheadline)
            LocalizedContentText(content: variant.description, textStyle: .body)

            ForEach(variant.changes) { change in
                VariantChangeRow(change: change)
            }
        }
    }
}

private struct VariantChangeRow: View {
    let change: VariantChange

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            LocalizedContentText(content: change.alternativeName, textStyle: .headline)
            LocalizedContentText(content: change.reason, textStyle: .body)
            LocalizedContentText(content: change.difference, textStyle: .footnote)
        }
        .padding()
        .background(.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
    }
}

private struct RecipeSourceSection: View {
    let source: RecipeSource
    let status: RecipeContentStatus
    let lastContentReview: String

    var body: some View {
        DetailSection(title: "Content information") {
            LabeledContent("Status") {
                Text(status.localizedName)
            }

            LabeledContent("Last content review") {
                Text(lastContentReview)
            }

            if let url = source.url {
                Link(destination: url) {
                    Label(source.title, systemImage: "link")
                }
            } else {
                Label(source.title, systemImage: "doc.text")
            }

            LocalizedContentText(content: source.licenseNote, textStyle: .footnote)
        }
    }
}

private struct DetailSection<Content: View>: View {
    let title: LocalizedStringResource
    @ViewBuilder let content: Content

    init(
        title: LocalizedStringResource,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct LocalizedContentText: View {
    @Environment(\.locale) private var locale

    let content: LocalizedText
    let textStyle: Font.TextStyle

    var body: some View {
        let resolved = content.resolve(locale: locale)

        VStack(alignment: .leading, spacing: 3) {
            Text(resolved.value)
                .font(.system(textStyle))

            if resolved.usedFallback {
                Label("Showing English fallback", systemImage: "globe")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        Text(verbatim: "Load a bundled recipe to preview details.")
    }
}
