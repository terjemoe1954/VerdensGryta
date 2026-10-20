import SwiftUI

struct RecipeArtwork: View {
    let recipeID: String
    let symbolName: String?

    var body: some View {
        Group {
            if let imageName = imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .overlay {
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.12)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
            } else {
                ZStack {
                    LinearGradient(
                        colors: artworkColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    Circle()
                        .fill(.white.opacity(0.14))
                        .frame(width: 120, height: 120)

                    Image(systemName: symbolName ?? "fork.knife")
                        .font(.system(.largeTitle, design: .rounded, weight: .semibold))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                }
            }
        }
        .accessibilityHidden(true)
    }

    private var imageName: String? {
        switch recipeID {
        case "th-phat-kaphrao": "PhatKaphrao"
        case "no-farikal": "Farikal"
        case "mx-chilaquiles": "Chilaquiles"
        case "jp-osaka-okonomiyaki": "OsakaOkonomiyaki"
        case "pe-lomo-saltado": "LomoSaltado"
        case "ma-vegetable-couscous": "VegetableCouscous"
        case "it-pasta-carbonara": "PastaCarbonara"
        case "kr-bibimbap": "Bibimbap"
        case "jp-tokyo-oyakodon": "Oyakodon"
        case "kr-beef-bulgogi": "BeefBulgogi"
        case "mx-white-pozole": "WhitePozole"
        case "no-kjottkaker": "Kjottkaker"
        case "it-cacio-e-pepe": "CacioEPepe"
        case "pe-papa-huancaina": "PapaHuancaina"
        case "ma-vegetable-harira": "VegetableHarira"
        case "th-clear-tom-yum-kung": "ClearTomYumKung"
        case "jp-miso-soup": "MisoSoup"
        case "kr-japchae": "Japchae"
        case "mx-red-chicken-enchiladas": "RedChickenEnchiladas"
        case "no-creamy-fish-soup": "CreamyFishSoup"
        case "it-treviso-tiramisu": "TrevisoTiramisu"
        case "pe-aji-de-gallina": "AjiDeGallina"
        case "ma-chicken-lemon-olive-tajine": "ChickenTagine"
        case "th-green-chicken-curry": "GreenChickenCurry"
        case "jp-yokosuka-curry": "YokosukaCurry"
        case "th-pad-thai-goong": "PadThaiGoong"
        case "it-naples-margherita-pizza": "MargheritaPizza"
        case "kr-kimchi-jjigae": "KimchiJjigae"
        case "mx-classic-guacamole": "ClassicGuacamole"
        case "no-multekrem": "Multekrem"
        case "it-tuscany-pappa-pomodoro": "PappaAlPomodoro"
        case "jp-salmon-onigiri": "SalmonOnigiri"
        case "kr-gochujang-tteokbokki": "GochujangTteokbokki"
        case "pe-causa-limena-chicken": "CausaLimenaChicken"
        case "mx-tlaxcala-tortilla-soup": "TlaxcalaTortillaSoup"
        case "ma-classic-zaalouk": "MoroccanZaalouk"
        case "th-som-tam-thai": "SomTamThai"
        case "no-heart-waffles": "NorwegianHeartWaffles"
        case "it-sicilian-caponata": "SicilianCaponata"
        case "jp-beef-nikujaga": "BeefNikujaga"
        case "kr-beef-doenjang-jjigae": "BeefDoenjangJjigae"
        case "mx-yucatan-cochinita-pibil": "YucatanCochinitaPibil"
        case "pe-green-arroz-con-pollo": "PeruvianGreenArrozConPollo"
        case "ma-sea-bream-vegetable-tagine": "SeaBreamVegetableTagine"
        case "th-mango-sticky-rice": "ThaiMangoStickyRice"
        case "no-traditional-raspeballer": "NorwegianRaspeballer"
        case "it-tuscany-ribollita": "TuscanRibollita"
        case "jp-tokyo-sukiyaki": "TokyoSukiyaki"
        case "kr-beef-miyeokguk": "KoreanBeefMiyeokguk"
        case "mx-jalisco-red-pozole": "JaliscoRedPozole"
        default: nil
        }
    }

    private var artworkColors: [Color] {
        switch symbolName {
        case "fish.fill": [.cyan, .blue]
        case "leaf.fill": [.green, .teal]
        case "flame.fill": [.orange, .red]
        case "birthday.cake.fill": [.pink, .purple]
        case "takeoutbag.and.cup.and.straw.fill": [.yellow, .orange]
        default: [.orange, .brown]
        }
    }
}
