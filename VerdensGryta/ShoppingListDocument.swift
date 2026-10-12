import Foundation
import UIKit

struct ShoppingListDocument {
    private let formatter = IngredientQuantityFormatter()

    func text(items: [ShoppingListItem], locale: Locale) -> String {
        let lines = items.map { item in
            "☐ \(amount(item, locale: locale)) \(item.name.resolve(locale: locale).value)\(originalNote(item, locale: locale))"
        }
        return (["VerdensGryta — \(localized(en: "Shopping list", nb: "Handleliste", th: "รายการซื้อของ", locale: locale))", ""] + lines + ["", disclaimer(locale: locale)]).joined(separator: "\n")
    }

    @MainActor
    func pdfURL(items: [ShoppingListItem], locale: Locale) throws -> URL {
        let page = CGRect(x: 0, y: 0, width: 595, height: 842)
        let renderer = UIGraphicsPDFRenderer(bounds: page)
        let lines = pdfLines(items: items, locale: locale)
        let data = renderer.pdfData { context in
            var y: CGFloat = 42
            context.beginPage()
            for line in lines {
                let font = line.isHeading ? UIFont.boldSystemFont(ofSize: line.size) : UIFont.systemFont(ofSize: line.size)
                let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: UIColor.black]
                let height = (line.text as NSString).boundingRect(
                    with: CGSize(width: 511, height: CGFloat.greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: attributes,
                    context: nil
                ).height.rounded(.up) + 8
                if y + height > 800 {
                    context.beginPage()
                    y = 42
                }
                (line.text as NSString).draw(in: CGRect(x: 42, y: y, width: 511, height: height), withAttributes: attributes)
                y += height
            }
        }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("VerdensGryta-handleliste.pdf")
        try data.write(to: url, options: .atomic)
        return url
    }

    private func pdfLines(items: [ShoppingListItem], locale: Locale) -> [(text: String, size: CGFloat, isHeading: Bool)] {
        var lines: [(String, CGFloat, Bool)] = [
            ("VerdensGryta — \(localized(en: "Shopping list", nb: "Handleliste", th: "รายการซื้อของ", locale: locale))", 24, true),
            (Date.now.formatted(.dateTime.locale(locale).year().month(.wide).day()), 11, false)
        ]
        let recipes = Dictionary(grouping: items, by: \.recipeID)
        for recipeItems in recipes.values {
            guard let first = recipeItems.first else { continue }
            let title = first.recipeTitle.resolve(locale: locale).value
            let country = first.country.resolve(locale: locale).value
            if first.recipeID == "manual" {
                lines.append(("\n\(title)", 16, true))
            } else {
                lines.append(("\n\(title) — \(country) — \(first.servings) \(localized(en: "servings", nb: "porsjoner", th: "ที่", locale: locale))", 16, true))
            }
            for item in recipeItems {
                lines.append(("☐  \(amount(item, locale: locale))  \(item.name.resolve(locale: locale).value)\(originalNote(item, locale: locale))", 12, false))
                if let store = item.storeType {
                    let department = item.department.map { " — \($0.localizedString(locale: locale))" } ?? ""
                    lines.append(("    \(store.localizedString(locale: locale))\(department)", 10, false))
                }
            }
        }
        lines.append(("\n\(disclaimer(locale: locale))", 9, false))
        return lines
    }

    private func amount(_ item: ShoppingListItem, locale: Locale) -> String {
        if let quantity = item.quantity, let unit = item.unit {
            let value = formatter.format(quantity: quantity, unit: unit, locale: locale)
            return "\(value.quantityText) \(value.unit.localizedString(locale: locale))"
        }
        return item.amountNote?.resolve(locale: locale).value ?? ""
    }

    private func originalNote(_ item: ShoppingListItem, locale: Locale) -> String {
        guard let originalName = item.originalName else { return "" }
        return " (\(localized(en: "Original:", nb: "Original:", th: "ต้นฉบับ:", locale: locale)) \(originalName.resolve(locale: locale).value))"
    }

    private func disclaimer(locale: Locale) -> String {
        localized(
            en: "Check product labels and allergens. Store suggestions do not confirm stock or price.",
            nb: "Kontroller produktetiketter og allergener. Butikkforslag bekrefter ikke lager eller pris.",
            th: "ตรวจสอบฉลากผลิตภัณฑ์และสารก่อภูมิแพ้ คำแนะนำร้านค้าไม่ยืนยันสต็อกหรือราคา",
            locale: locale
        )
    }

    private func localized(en: String, nb: String, th: String, locale: Locale) -> String {
        switch locale.language.languageCode?.identifier {
        case "nb": nb
        case "th": th
        default: en
        }
    }
}

@MainActor
enum ShoppingListPrinter {
    static func printPDF(at url: URL) {
        let controller = UIPrintInteractionController.shared
        let info = UIPrintInfo(dictionary: nil)
        info.outputType = .general
        info.jobName = "VerdensGryta shopping list"
        controller.printInfo = info
        controller.printingItem = url
        controller.present(animated: true)
    }
}
