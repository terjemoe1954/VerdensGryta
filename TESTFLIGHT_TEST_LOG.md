# TestFlight-testlogg

Bruk én kopi av denne loggen per build og testperiode. Ikke kryss av et punkt før testen faktisk er utført på angitt enhet.

## Build og testmiljø

- Appversjon: 1.0
- Buildnummer: 1
- Testdato: 21. oktober 2026
- Tester: Terje (resultater rapportert under veiledet test)
- iPhone-modell: iPhone 15 Pro
- iOS-versjon: iOS 27.0.1
- Installasjon: [ ] Ny installasjon  [ ] Oppdatering over tidligere build
- Språk testet: [x] Norsk  [x] Engelsk  [x] Thai
- Tema testet: [x] Lyst  [x] Mørkt  [x] System
- Tekststørrelse: Vanlig og stor tilgjengelighetsstørrelse
- VoiceOver brukt: [x] Ja  [ ] Nei

## Resultater

Skriv `Bestått`, `Feil` eller `Ikke testet`, og legg ved feil-ID ved behov.

| Område | Resultat | Oppskrift/data brukt | Feil-ID eller merknad |
| --- | --- | --- | --- |
| Kaldstart og oppskriftsoversikt | Bestått | Build 1 | Fysisk iPhone |
| Søk etter rett | Bestått | Build 1 |  |
| Søk etter ingrediens | Bestått | Build 1 |  |
| Land- og rettstypefilter | Bestått | Build 1 |  |
| Oppskriftsbilde, historie og kilde | Bestått | Build 1 |  |
| Porsjonsendring og mengder | Bestått | Build 1 |  |
| Allergenprofil og varsler | Bestått | Build 1 | Etikett- og krysskontaktvarsel kontrollert |
| Ingrediensalternativ | Bestått | Build 1 | Samme valg kontrollert i ingredienser og steg |
| Kjøpsveiledning | Bestått | Build 1 |  |
| Handleliste og «har hjemme» | Bestått | Build 1 | Lagret liste fra tidligere økt var bevart som forventet |
| Mengderedigering og egen vare | Bestått | Build 1 | Enkeltsletting fungerer; «Tøm handlelisten» finnes ikke |
| Tøm handlelisten | Bestått | Build 2 | Avbrytelse bevarte varene; bekreftet tømming viste tomtilstand, som var bevart etter tvangsavslutning og omstart |
| PDF-forhåndsvisning | Bestått | Build 1 |  |
| Systemdeling/utskriftsdialog | Bestått | Build 1 |  |
| Matlagingsmodus og samme alternativ | Bestått | Build 1 |  |
| Frem/tilbake mellom steg | Bestått | Build 1 |  |
| Tidtakere | Bestått | Build 1 | Pause og fortsett kontrollert |
| Favoritt og notat etter omstart | Bestått | Build 1 | Tvangsavslutning og ny oppstart |
| Handleliste etter omstart | Bestått | Build 1 |  |
| Data etter TestFlight-oppdatering | Bestått | Build 1 → build 2 | Favoritt, notat, handleliste og innstillinger var bevart |
| Norsk innhold og grensesnitt | Bestått | Build 1 |  |
| Engelsk innhold og grensesnitt | Bestått | Build 1 |  |
| Thai innhold og grensesnitt | Bestått | Build 1 |  |
| Stor tekst | Bestått | Build 1 | Tilgjengelighetsstørrelse brukt |
| VoiceOver | Bestått | Build 1 |  |
| Full bruk i flymodus | Bestått | Build 1 | Inkluderte tvangsavslutning og ny oppstart uten nett |

## Frakoblet test

- Appen ble åpnet én gang før flymodus: [x]
- Flymodus var på: [x]
- Wi‑Fi var av: [x]
- Mobildata var av: [x]
- Appen ble tvangsavsluttet og startet på nytt uten nett: [x]
- Minst tre oppskrifter og tilhørende bilder åpnet: [x]
- Søk, porsjoner, alternativ, handleliste og matlagingsmodus fungerte: [x]
- Resultat: Bestått på fysisk iPhone 21. oktober 2026.

## Oppdateringstest

- Forrige appversjon/build: 1.0 (1)
- Ny appversjon/build: 1.0 (2)
- Favoritt opprettet før oppdatering: [x]
- Notat opprettet før oppdatering: [x]
- Handleliste opprettet før oppdatering: [x]
- Oppdatering installert uten å slette appen: [x]
- Favoritt bevart: [x]
- Notat bevart: [x]
- Handleliste bevart: [x]
- Innstillinger bevart: [x]
- Resultat: Bestått. Brukeren bekreftet at alle data var bevart etter oppdateringen.

## Feil

Kopier denne delen for hver feil.

### Feil-ID og kort tittel

- Alvorlighet: [ ] Kritisk  [ ] Høy  [ ] Middels  [ ] Lav
- Kan gjenskapes: [ ] Alltid  [ ] Av og til  [ ] Én gang
- Oppskrift og porsjoner:
- Valgt språk, tema og tekststørrelse:
- Forutsetninger:
- Steg for å gjenskape:
  1.
  2.
  3.
- Forventet resultat:
- Faktisk resultat:
- Vedlegg/skjermbilde:
- Midlertidig løsning:
- Status: [ ] Åpen  [ ] Rettet  [ ] Kontrollert på nytt  [ ] Utsatt

## Godkjenning av build

- [x] Ingen åpne kritiske feil funnet i denne testen.
- [x] Ingen åpne feil som kan gi uriktig allergen- eller mattrygghetsinformasjon ble funnet i denne testen.
- [x] Kjernetesten er fullført på fysisk iPhone.
- [x] Frakoblet test er fullført.
- [x] Oppdateringstesten er fullført når minst to builds finnes.
- [x] Builden kan deles med neste testgruppe.

Godkjent av:

Dato:

Kommentar: Build 1 besto hovedtesten og flymodustesten på iPhone 15 Pro med iOS 27.0.1. Oppdatering fra build 1 til build 2 besto uten tap av favoritt, notat, handleliste eller innstillinger. «Tøm handlelisten» i build 2 besto for avbrytelse, bekreftet tømming, tomtilstand og omstart.
