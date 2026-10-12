import SwiftUI

struct CookingModeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.locale) private var locale
    @Environment(CookingSessionStore.self) private var sessionStore
    
    let recipe: Recipe
    private let calculator = PortionCalculator()

    var body: some View {
        if let session = sessionStore.session, session.recipeID == recipe.id {
            let amounts = calculator.calculate(
                recipe: recipe,
                selectedServings: session.servings,
                selectedSubstitutionIDs: session.substitutionIDs
            )
            let step = recipe.steps[session.stepIndex]

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    CookingProgressHeader(
                        title: recipe.title,
                        stepNumber: session.stepIndex + 1,
                        stepCount: recipe.steps.count,
                        servings: session.servings
                    )
                    CookingStepCard(
                        step: displayedStep(step, substitutions: session.substitutionIDs),
                        ingredients: amounts.ingredientsByStepID[step.id] ?? []
                    )
                    CookingTimersSection(stepNumber: step.order, timers: session.timers)
                    CookingNavigationControls(
                        canGoBack: session.stepIndex > 0,
                        isLastStep: session.stepIndex == recipe.steps.count - 1,
                        previous: { sessionStore.setStep(session.stepIndex - 1, stepCount: recipe.steps.count) },
                        next: { sessionStore.setStep(session.stepIndex + 1, stepCount: recipe.steps.count) },
                        finish: {
                            sessionStore.endSession()
                            dismiss()
                        }
                    )
                }
                .padding()
            }
            .navigationTitle("Cooking mode")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Label(recipesTitle, systemImage: "chevron.backward")
                    }
                    .accessibilityLabel(recipesTitle)
                }
            }
        } else {
            ContentUnavailableView("No active cooking session", systemImage: "fork.knife")
        }
    }

    private func displayedStep(_ step: RecipeStep, substitutions: Set<String>) -> RecipeStep {
        let selectedChanges = recipe.adaptedVariant?.changes.filter { substitutions.contains($0.id) } ?? []
        let override = selectedChanges.compactMap { $0.stepTextOverrides?[step.id] }.first
        guard let override else { return step }
        return RecipeStep(id: step.id, order: step.order, text: override, ingredientIDs: step.ingredientIDs)
    }

    private var recipesTitle: String {
        switch locale.language.languageCode?.identifier {
        case "nb": "Oppskrifter"
        case "th": "สูตรอาหาร"
        default: "Recipes"
        }
    }
}

private struct CookingProgressHeader: View {
    let title: LocalizedText
    let stepNumber: Int
    let stepCount: Int
    let servings: Decimal

    var body: some View {
        let servingsValue = NSDecimalNumber(decimal: servings).doubleValue
        VStack(alignment: .leading, spacing: 10) {
            CookingLocalizedText(content: title, style: .title)
            Text("Step \(stepNumber) of \(stepCount)")
                .font(.headline)
            ProgressView(value: Double(stepNumber), total: Double(stepCount))
            Label("\(servingsValue, format: .number.precision(.fractionLength(0...1))) servings — saved cooking snapshot", systemImage: "lock.fill")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct CookingStepCard: View {
    let step: RecipeStep
    let ingredients: [ScaledIngredient]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            CookingLocalizedText(content: step.text, style: .title2)
            if !ingredients.isEmpty {
                Divider()
                Text("Ingredients for this step")
                    .font(.headline)
                ForEach(ingredients) { ingredient in
                    HStack(alignment: .firstTextBaseline) {
                        CookingLocalizedText(content: ingredient.ingredient.name, style: .body)
                        Spacer()
                        CookingIngredientAmount(ingredient: ingredient)
                    }
                    .accessibilityElement(children: .combine)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 20))
    }
}

private struct CookingIngredientAmount: View {
    @Environment(\.locale) private var locale
    let ingredient: ScaledIngredient

    var body: some View {
        if let quantity = ingredient.quantity, let unit = ingredient.ingredient.unit {
            let value = IngredientQuantityFormatter().format(quantity: quantity, unit: unit, locale: locale)
            HStack(spacing: 4) {
                Text(value.quantityText)
                Text(value.unit.localizedName)
            }
            .foregroundStyle(.secondary)
        } else if let note = ingredient.ingredient.amountNote {
            CookingLocalizedText(content: note, style: .body)
        }
    }
}

private struct CookingLocalizedText: View {
    @Environment(\.locale) private var locale
    let content: LocalizedText
    let style: Font.TextStyle

    var body: some View {
        Text(content.resolve(locale: locale).value)
            .font(.system(style))
    }
}

private struct CookingTimersSection: View {
    @Environment(CookingSessionStore.self) private var sessionStore
    let stepNumber: Int
    let timers: [CookingTimer]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Timers")
                .font(.title2.bold())
            HStack {
                ForEach([1, 5, 10], id: \.self) { minutes in
                    Button("\(minutes) min") {
                        sessionStore.startTimer(minutes: minutes, stepNumber: stepNumber)
                    }
                    .buttonStyle(.bordered)
                }
            }
            ForEach(timers) { timer in
                CookingTimerRow(timer: timer)
            }
        }
    }
}

private struct CookingTimerRow: View {
    @Environment(CookingSessionStore.self) private var sessionStore
    let timer: CookingTimer

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let remaining = timer.remaining(at: context.date)
            HStack {
                VStack(alignment: .leading) {
                    Text("Step \(timer.stepNumber) timer")
                        .font(.headline)
                    Text(durationText(remaining))
                        .font(.title2.monospacedDigit())
                        .accessibilityLabel("\(Int(remaining)) seconds remaining")
                        .accessibilityAddTraits(.updatesFrequently)
                }
                Spacer()
                if timer.isFinished || remaining <= 0 {
                    Button("Done") { sessionStore.finishTimer(timer.id) }
                        .buttonStyle(.borderedProminent)
                } else if timer.pausedRemainingSeconds != nil {
                    Button("Resume") { sessionStore.resumeTimer(timer.id) }
                } else {
                    Button("Pause") { sessionStore.pauseTimer(timer.id) }
                }
                Button("End") { sessionStore.finishTimer(timer.id) }
            }
            .padding()
            .background(.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 14))
        }
    }

    private func durationText(_ seconds: TimeInterval) -> String {
        let total = max(0, Int(seconds.rounded(.up)))
        return String(format: "%02d:%02d", total / 60, total % 60)
    }
}

private struct CookingNavigationControls: View {
    let canGoBack: Bool
    let isLastStep: Bool
    let previous: () -> Void
    let next: () -> Void
    let finish: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            Button(action: previous) {
                Label("Previous", systemImage: "chevron.backward")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .disabled(!canGoBack)

            Button(action: isLastStep ? finish : next) {
                if isLastStep {
                    Label("Finish cooking", systemImage: "checkmark")
                        .frame(maxWidth: .infinity)
                } else {
                    Label("Next", systemImage: "chevron.forward")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }
}
