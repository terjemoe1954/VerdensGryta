# TestFlight-forhåndskontroll

Kontrollert 20. oktober 2026 mot prosjektets evaluerte Xcode-innstillinger og Apples dokumentasjon for distribusjon.

## Prosjektstatus

- Target: `VerdensGryta` (iOS-app).
- Bundle-ID: `com.terjemoe.VerdensGryta`.
- Markedsversjon: `1.0`.
- Buildnummer: `1`.
- Signering: automatisk, med et valgt utviklerteam.
- Plattformer: fysisk iPhone og iPhone-simulator.
- Deployment target: iOS 27.0.
- Enhetsfamilie: kun iPhone (`1`). Første beta annonserer derfor ikke egen iPad-støtte.
- Appikon: universelt iOS-ikon på 1024 × 1024 piksler. Mørk og tonet variant faller foreløpig tilbake til standardikonet.
- Vanlig Xcode-build består uten feil.
- Lokal, usignert Release-arkivering for en generell iPhone består uten kompilatorfeil eller appadvarsler. Dette er bare en teknisk arkivkontroll og kan ikke lastes opp.
- Lokal signert Release-arkivering består med eksisterende Apple Development-identitet og team. `codesign` bekrefter at appen er gyldig på disk og oppfyller sitt designated requirement. Arkivet inneholder bundle-ID `com.terjemoe.VerdensGryta`, versjon `1.0` og build `1`. Dette bekrefter lokal signering, men er ikke en App Store-distribusjon eller opplasting.

## Apples distribusjonskrav som er kontrollert

TestFlight krever medlemskap i Apple Developer Program, en appoppføring i App Store Connect med samme bundle-ID som prosjektet, gyldig distribusjonssignering og et arkiv som lastes opp til App Store Connect. Xcode kan håndtere signeringsressurser automatisk når prosjektet er knyttet til riktig team. Intern TestFlight kan begrenses til App Store Connect-brukere; ekstern testing krever Apples betagjennomgang.

## Må avklares før arkivering og opplasting

- Bekreft at Apple Developer-medlemskapet og teamtilgangen er aktive.
- Bekreft eller opprett App Store Connect-oppføringen med nøyaktig bundle-ID `com.terjemoe.VerdensGryta`.
- Bestem om build 1 skal beholdes til første opplasting. Senere opplastinger for versjon 1.0 må få et høyere buildnummer.
- Gjennomfør fysisk iPhone-test og en reell frakoblet test før ekstern distribusjon.
- Fullfør menneskelig prøvelaging samt språk-, allergen-, mattrygghets- og rettighetskontroll av oppskriftsutkastene.
- Velg interne testere før opplasting. Testinstruks og testlogg finnes i `TESTFLIGHT_TEST_INSTRUCTIONS.md` og `TESTFLIGHT_TEST_LOG.md`.

Ingen App Store-distribusjon, opplasting, App Store Connect-endring eller invitasjon av testere er utført i denne kontrollen.
