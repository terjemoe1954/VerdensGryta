import SwiftUI
import QuickLook

struct ShoppingListView: View {
    @Environment(ShoppingListStore.self) private var store
    @Environment(RecipeSelectionStore.self) private var selections
    @Environment(\.locale) private var locale
    @State private var pdfURL: URL?
    @State private var previewURL: URL?
    @State private var documentError: String?
    @State private var manualItemName = ""
    @State private var isShowingClearConfirmation = false

    var body: some View {
        List {
            Section("Add your own item") {
                TextField("Item name", text: $manualItemName)
                Button("Add item") {
                    store.addManualItem(named: manualItemName)
                    manualItemName = ""
                }
                .disabled(manualItemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            if store.items.isEmpty {
                ContentUnavailableView(
                    "Shopping list is empty",
                    systemImage: "cart",
                    description: Text("Open a recipe and add its current ingredients.")
                )
            } else {
                Section("At home") {
                    ForEach(store.items.filter { !$0.isIncluded }) { item in
                        ShoppingListRow(item: item, isAtHome: true)
                    }
                    if store.items.allSatisfy(\.isIncluded) {
                        Text("Mark an ingredient as already at home to omit it from shopping and documents.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                ForEach(groupedStoreTypes, id: \.key) { group in
                    Section(group.title) {
                        ForEach(group.items) { item in
                            ShoppingListRow(item: item, isAtHome: false)
                        }
                    }
                }

                Section("Share and print") {
                    ShareLink(item: ShoppingListDocument().text(items: store.mergedItems(), locale: locale)) {
                        Label("Share as text", systemImage: "square.and.arrow.up")
                    }
                    if let pdfURL {
                        Button {
                            previewURL = pdfURL
                        } label: {
                            Label("Preview PDF", systemImage: "doc.text.magnifyingglass")
                        }
                        ShareLink(item: pdfURL) {
                            Label("Share PDF", systemImage: "doc.richtext")
                        }
                        Button {
                            ShoppingListPrinter.printPDF(at: pdfURL)
                        } label: {
                            Label("Print", systemImage: "printer")
                        }
                    }
                }

                Section {
                    Text("Check product labels and allergens. Store suggestions do not confirm stock or price.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section {
                    Button("Clear shopping list", role: .destructive) {
                        isShowingClearConfirmation = true
                    }
                }
            }
        }
        .navigationTitle("Shopping list")
        .task(id: store.items) {
            do {
                pdfURL = try ShoppingListDocument().pdfURL(items: store.mergedItems(), locale: locale)
                documentError = nil
            } catch {
                documentError = error.localizedDescription
            }
        }
        .alert("Couldn’t create PDF", isPresented: Binding(
            get: { documentError != nil },
            set: { if !$0 { documentError = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(documentError ?? "")
        }
        .confirmationDialog(
            "Clear the shopping list?",
            isPresented: $isShowingClearConfirmation,
            titleVisibility: .visible
        ) {
            Button("Clear shopping list", role: .destructive) {
                store.removeAll()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This removes every item from the shopping list. This action cannot be undone.")
        }
        .quickLookPreview($previewURL)
    }

    private var groupedStoreTypes: [(key: String, title: LocalizedStringResource, items: [ShoppingListItem])] {
        let included = store.items.filter(\.isIncluded)
        let order: [(String, StoreType?, LocalizedStringResource)] = [
            ("regular", .regularGrocery, "Regular grocery store"),
            ("asian", .asianGrocery, "Asian grocery store"),
            ("international", .internationalGrocery, "International grocery store"),
            ("other", nil, "Other / no store suggestion")
        ]
        return order.compactMap { key, type, title in
            let items = included.filter { $0.storeType == type }
            return items.isEmpty ? nil : (key, title, items)
        }
    }
}

private struct ShoppingListRow: View {
    @Environment(ShoppingListStore.self) private var store
    @Environment(RecipeSelectionStore.self) private var selections
    @Environment(\.locale) private var locale
    let item: ShoppingListItem
    let isAtHome: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Button {
                    if isAtHome {
                        store.setIncluded(true, for: item.id)
                    } else {
                        store.setChecked(!item.isChecked, for: item.id)
                    }
                } label: {
                    Image(systemName: isAtHome ? "house.fill" : (item.isChecked ? "checkmark.circle.fill" : "circle"))
                }
                .buttonStyle(.plain)

                Text(item.name.resolve(locale: locale).value)
                    .strikethrough(item.isChecked)
                Spacer()
                ShoppingAmountText(item: item)
            }

            if let original = item.originalName {
                Text("Original: \(original.resolve(locale: locale).value) — selected alternative")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Button("Use original ingredient") {
                    if let changeID = item.selectedChangeID {
                        selections.removeSubstitution(changeID, for: item.recipeID)
                    }
                    store.revertAlternative(for: item.id)
                }
                .buttonStyle(.borderless)
                .font(.caption)
            }
            if let guidance = item.shoppingGuidance {
                Text(guidance.resolve(locale: locale).value)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            if let department = item.department {
                Label(department.localizedName, systemImage: "square.grid.2x2")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            HStack {
                Button(isAtHome ? "Need to buy" : "Already at home") {
                    store.setIncluded(isAtHome, for: item.id)
                }
                .buttonStyle(.borderless)
                if item.quantity != nil {
                    Button("−") { adjust(by: -0.5) }.buttonStyle(.borderless)
                    Button("+") { adjust(by: 0.5) }.buttonStyle(.borderless)
                }
                Button("Remove", role: .destructive) {
                    store.remove(item.id)
                }
                .buttonStyle(.borderless)
            }
            .font(.caption)
        }
    }

    private func adjust(by amount: Decimal) {
        guard let quantity = item.quantity else { return }
        store.setQuantity(max(0, quantity + amount), for: item.id)
    }
}

private struct ShoppingAmountText: View {
    @Environment(\.locale) private var locale
    let item: ShoppingListItem

    var body: some View {
        if let quantity = item.quantity, let unit = item.unit {
            let value = IngredientQuantityFormatter().format(quantity: quantity, unit: unit, locale: locale)
            Text(verbatim: "\(value.quantityText) \(value.unit.localizedString(locale: locale))")
                .foregroundStyle(.secondary)
        } else if let note = item.amountNote {
            Text(note.resolve(locale: locale).value).foregroundStyle(.secondary)
        }
    }
}
