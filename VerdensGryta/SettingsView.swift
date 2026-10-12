import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.locale) private var locale
    @AppStorage("appLanguage") private var appLanguage = AppLanguage.norwegian.rawValue
    @AppStorage("appTheme") private var appTheme = AppTheme.system.rawValue
    @AppStorage("selectedAllergens") private var selectedAllergens = ""

    private var selectedLanguage: Binding<AppLanguage> {
        Binding(
            get: { AppLanguage(rawValue: appLanguage) ?? .norwegian },
            set: { appLanguage = $0.rawValue }
        )
    }

    private var selectedTheme: Binding<AppTheme> {
        Binding(
            get: { AppTheme(rawValue: appTheme) ?? .system },
            set: { appTheme = $0.rawValue }
        )
    }

    var body: some View {
        Form {
            Picker(selection: selectedLanguage) {
                ForEach(AppLanguage.allCases) { language in
                    Text(language.name.resource(locale: locale))
                        .tag(language)
                }
            } label: {
                Text(LocalizedCopy.language.resource(locale: locale))
            }

            Picker(selection: selectedTheme) {
                ForEach(AppTheme.allCases) { theme in
                    Text(theme.name.resource(locale: locale))
                        .tag(theme)
                }
            } label: {
                Text(LocalizedCopy.appearance.resource(locale: locale))
            }

            AllergenProfileSection(selectedAllergens: $selectedAllergens)

            Section("Help") {
                NavigationLink {
                    GuideView()
                } label: {
                    Label("How to use VerdensGryta", systemImage: "questionmark.circle")
                }
            }

            AppInformationSection(
                appName: appName,
                versionDescription: versionDescription
            )
        }
        .navigationTitle(
            Text(LocalizedCopy.settingsTitle.resource(locale: locale))
        )
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Label {
                        Text(LocalizedCopy.navigationBack.resource(locale: locale))
                    } icon: {
                        Image(systemName: "chevron.backward")
                    }
                }
            }
        }
    }

    private var appName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
            ?? "VerdensGryta"
    }

    private var versionDescription: String {
        let version = Bundle.main.object(
            forInfoDictionaryKey: "CFBundleShortVersionString"
        ) as? String ?? "—"
        let build = Bundle.main.object(
            forInfoDictionaryKey: "CFBundleVersion"
        ) as? String ?? "—"

        return "\(version) (\(build))"
    }
}

private struct AllergenProfileSection: View {
    @Binding var selectedAllergens: String

    var body: some View {
        Section {
            ForEach(FoodAllergen.allCases) { allergen in
                Toggle(allergen.localizedName, isOn: binding(for: allergen))
            }

            Text("The profile highlights recipe information only. Always check product labels and consider cross-contact. The app cannot guarantee that food is safe for an allergy.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        } header: {
            Text("Allergen profile")
        } footer: {
            Text("Based on the 14 allergen categories that must be declared in food labelling.")
        }
    }

    private func binding(for allergen: FoodAllergen) -> Binding<Bool> {
        Binding(
            get: { selection.contains(allergen) },
            set: { isSelected in
                var updated = selection
                if isSelected {
                    updated.insert(allergen)
                } else {
                    updated.remove(allergen)
                }
                selectedAllergens = updated.map(\.rawValue).sorted().joined(separator: ",")
            }
        )
    }

    private var selection: Set<FoodAllergen> {
        Set(selectedAllergens.split(separator: ",").compactMap {
            FoodAllergen(rawValue: String($0))
        })
    }
}

private struct AppInformationSection: View {
    @Environment(\.locale) private var locale

    let appName: String
    let versionDescription: String

    var body: some View {
        Section {
            LabeledContent {
                Text(appName)
            } label: {
                Text(LocalizedCopy.appName.resource(locale: locale))
            }

            LabeledContent {
                Text(versionDescription)
            } label: {
                Text(LocalizedCopy.versionBuild.resource(locale: locale))
            }
        } header: {
            Text(LocalizedCopy.settingsAbout.resource(locale: locale))
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
