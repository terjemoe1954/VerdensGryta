import Foundation
import SwiftData

@Model
final class UserRecipeState {
    @Attribute(.unique) var recipeID: String
    var isFavorite: Bool
    var note: String

    init(recipeID: String, isFavorite: Bool = false, note: String = "") {
        self.recipeID = recipeID
        self.isFavorite = isFavorite
        self.note = note
    }
}
