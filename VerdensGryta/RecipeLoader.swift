import Foundation

enum RecipeLoadingError: LocalizedError, Equatable {
    case resourceMissing(String)
    case unreadableResource
    case invalidJSON(String)
    case emptyCollection
    case duplicateID(String)
    case invalidRecipe(String)

    var errorDescription: String? {
        switch self {
        case .resourceMissing(let name):
            "The bundled recipe resource \(name).json is missing."
        case .unreadableResource:
            "The bundled recipe data could not be read."
        case .invalidJSON(let detail):
            "The recipe data is invalid: \(detail)"
        case .emptyCollection:
            "The recipe collection is empty."
        case .duplicateID(let id):
            "More than one recipe uses the ID “\(id)”."
        case .invalidRecipe(let detail):
            "A recipe failed validation: \(detail)"
        }
    }
}

struct RecipeLoader {
    private let bundle: Bundle
    private let resourceName: String

    init(bundle: Bundle = .main, resourceName: String = "DemoRecipes") {
        self.bundle = bundle
        self.resourceName = resourceName
    }

    func load() throws -> [Recipe] {
        guard let url = bundle.url(forResource: resourceName, withExtension: "json") else {
            throw RecipeLoadingError.resourceMissing(resourceName)
        }

        guard let data = try? Data(contentsOf: url) else {
            throw RecipeLoadingError.unreadableResource
        }

        return try decode(data)
    }

    func decode(_ data: Data) throws -> [Recipe] {
        let recipes: [Recipe]

        do {
            recipes = try JSONDecoder().decode([Recipe].self, from: data)
        } catch {
            throw RecipeLoadingError.invalidJSON(error.localizedDescription)
        }

        try validate(recipes)
        return recipes
    }

    private func validate(_ recipes: [Recipe]) throws {
        guard !recipes.isEmpty else {
            throw RecipeLoadingError.emptyCollection
        }

        var ids = Set<String>()

        for recipe in recipes {
            guard !recipe.id.isEmpty else {
                throw RecipeLoadingError.invalidRecipe("A recipe has an empty ID.")
            }
            guard ids.insert(recipe.id).inserted else {
                throw RecipeLoadingError.duplicateID(recipe.id)
            }
            guard recipe.baseServings > 0 else {
                throw RecipeLoadingError.invalidRecipe(
                    "\(recipe.id) must have at least one base serving."
                )
            }
            guard !recipe.ingredients.isEmpty else {
                throw RecipeLoadingError.invalidRecipe(
                    "\(recipe.id) has no ingredients."
                )
            }
            guard !recipe.steps.isEmpty else {
                throw RecipeLoadingError.invalidRecipe(
                    "\(recipe.id) has no preparation steps."
                )
            }
        }
    }
}
