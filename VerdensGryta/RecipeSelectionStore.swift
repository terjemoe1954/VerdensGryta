import Foundation
import Observation

@MainActor
@Observable
final class RecipeSelectionStore {
    private(set) var substitutionsByRecipe: [String: Set<String>] = [:]
    private let key = "recipeSubstitutionSelections"

    init() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([String: Set<String>].self, from: data) else { return }
        substitutionsByRecipe = decoded
    }

    func substitutions(for recipeID: String) -> Set<String> {
        substitutionsByRecipe[recipeID] ?? []
    }

    func setSubstitutions(_ ids: Set<String>, for recipeID: String) {
        substitutionsByRecipe[recipeID] = ids
        if let data = try? JSONEncoder().encode(substitutionsByRecipe) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func removeSubstitution(_ id: String, for recipeID: String) {
        var ids = substitutions(for: recipeID)
        ids.remove(id)
        setSubstitutions(ids, for: recipeID)
    }
}
