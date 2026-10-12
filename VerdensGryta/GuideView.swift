import SwiftUI

struct GuideView: View {
    private let steps: [(icon: String, title: LocalizedStringResource, detail: LocalizedStringResource)] = [
        ("globe", "Choose a country and dish", "Search or filter the editorial demo selection, then open a dish."),
        ("person.2", "Choose servings", "Adjust servings before adding ingredients or starting cooking mode."),
        ("arrow.trianglehead.branch", "Choose original or alternative", "Review why an alternative is suggested and select it explicitly."),
        ("basket", "Review store suggestions", "Check store type, department and product guidance. Suggestions do not confirm stock."),
        ("printer", "Prepare the shopping list", "Mark what you already have, then share, preview or print the list."),
        ("fork.knife", "Follow cooking mode", "Use one step at a time with the selected ingredients, scaled amounts and timers.")
    ]

    var body: some View {
        List {
            Section {
                Text("How to use VerdensGryta")
                    .font(.largeTitle.bold())
                Text("VerdensGryta keeps the same servings and ingredient choices through the recipe, shopping list, PDF and cooking session.")
            }

            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                Section("Step \(index + 1)") {
                    Label(step.title, systemImage: step.icon)
                        .font(.headline)
                    Text(step.detail)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Important") {
                Label("Always check product labels, allergens and cross-contact.", systemImage: "exclamationmark.triangle")
                Text("Store and price information is guidance or an estimate, not a guarantee of stock, price or allergy safety.")
            }
        }
        .navigationTitle("Guide")
        .navigationBarTitleDisplayMode(.inline)
    }
}
