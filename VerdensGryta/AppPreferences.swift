import SwiftUI

enum LocalizedCopy {
    case appName
    case appearance
    case countryMexico
    case countryNorway
    case countryThailand
    case dishTypePopular
    case exploreTitle
    case language
    case languageEnglish
    case languageNorwegian
    case languageThai
    case navigationBack
    case recipeChilaquilesName
    case recipeChilaquilesShoppingHint
    case recipeFarikalName
    case recipeFarikalShoppingHint
    case recipePhatKaphraoName
    case recipePhatKaphraoShoppingHint
    case settingsAbout
    case settingsTitle
    case themeDark
    case themeLight
    case themeSystem
    case versionBuild

    func resource(locale: Locale) -> LocalizedStringResource {
        switch self {
        case .appName:
            LocalizedStringResource(
                "settings.appName",
                defaultValue: "App name",
                locale: locale
            )
        case .appearance:
            LocalizedStringResource(
                "settings.appearance",
                defaultValue: "Appearance",
                locale: locale
            )
        case .countryMexico:
            LocalizedStringResource(
                "country.mexico",
                defaultValue: "Mexico",
                locale: locale
            )
        case .countryNorway:
            LocalizedStringResource(
                "country.norway",
                defaultValue: "Norway",
                locale: locale
            )
        case .countryThailand:
            LocalizedStringResource(
                "country.thailand",
                defaultValue: "Thailand",
                locale: locale
            )
        case .dishTypePopular:
            LocalizedStringResource(
                "dishType.popular",
                defaultValue: "Popular dish",
                locale: locale
            )
        case .exploreTitle:
            LocalizedStringResource(
                "explore.title",
                defaultValue: "Explore recipes",
                locale: locale
            )
        case .language:
            LocalizedStringResource(
                "settings.language",
                defaultValue: "Language",
                locale: locale
            )
        case .languageEnglish:
            LocalizedStringResource(
                "language.english",
                defaultValue: "English",
                locale: locale
            )
        case .languageNorwegian:
            LocalizedStringResource(
                "language.norwegian",
                defaultValue: "Norwegian",
                locale: locale
            )
        case .languageThai:
            LocalizedStringResource(
                "language.thai",
                defaultValue: "Thai",
                locale: locale
            )
        case .navigationBack:
            LocalizedStringResource(
                "navigation.back",
                defaultValue: "Back",
                locale: locale
            )
        case .recipeChilaquilesName:
            LocalizedStringResource(
                "recipe.chilaquiles.name",
                defaultValue: "Chilaquiles",
                locale: locale
            )
        case .recipeChilaquilesShoppingHint:
            LocalizedStringResource(
                "recipe.chilaquiles.shoppingHint",
                defaultValue: "Ingredients: regular and international grocery stores.",
                locale: locale
            )
        case .recipeFarikalName:
            LocalizedStringResource(
                "recipe.farikal.name",
                defaultValue: "Fårikål",
                locale: locale
            )
        case .recipeFarikalShoppingHint:
            LocalizedStringResource(
                "recipe.farikal.shoppingHint",
                defaultValue: "Ingredients: regular grocery store.",
                locale: locale
            )
        case .recipePhatKaphraoName:
            LocalizedStringResource(
                "recipe.phatKaphrao.name",
                defaultValue: "Phat kaphrao",
                locale: locale
            )
        case .recipePhatKaphraoShoppingHint:
            LocalizedStringResource(
                "recipe.phatKaphrao.shoppingHint",
                defaultValue: "Thai basil and sauces: Asian grocery store.",
                locale: locale
            )
        case .settingsAbout:
            LocalizedStringResource(
                "settings.about",
                defaultValue: "About",
                locale: locale
            )
        case .settingsTitle:
            LocalizedStringResource(
                "settings.title",
                defaultValue: "Settings",
                locale: locale
            )
        case .themeDark:
            LocalizedStringResource(
                "theme.dark",
                defaultValue: "Dark",
                locale: locale
            )
        case .themeLight:
            LocalizedStringResource(
                "theme.light",
                defaultValue: "Light",
                locale: locale
            )
        case .themeSystem:
            LocalizedStringResource(
                "theme.system",
                defaultValue: "System",
                locale: locale
            )
        case .versionBuild:
            LocalizedStringResource(
                "settings.versionBuild",
                defaultValue: "Version and build",
                locale: locale
            )
        }
    }
}

enum AppLanguage: String, CaseIterable, Identifiable {
    case norwegian = "nb"
    case english = "en"
    case thai = "th"

    var id: String { rawValue }

    var name: LocalizedCopy {
        switch self {
        case .norwegian:
            .languageNorwegian
        case .english:
            .languageEnglish
        case .thai:
            .languageThai
        }
    }
}

enum AppTheme: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var name: LocalizedCopy {
        switch self {
        case .system:
            .themeSystem
        case .light:
            .themeLight
        case .dark:
            .themeDark
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            nil
        case .light:
            .light
        case .dark:
            .dark
        }
    }
}
