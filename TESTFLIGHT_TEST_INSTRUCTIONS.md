# Testinstruks for VerdensGryta

Takk for at du tester VerdensGryta. Bruk en fysisk iPhone og noter iOS-versjon, appversjon og buildnummer når du rapporterer en feil. Ikke bruk oppskriften som eneste grunnlag for allergi- eller mattrygghetsbeslutninger; kontroller alltid produktetikettene.

## Før du begynner

1. Installer den nyeste tilgjengelige TestFlight-versjonen.
2. Start appen og kontroller at oppskriftsoversikten åpnes uten feilmelding.
3. Velg norsk, engelsk eller thai i Innstillinger, og velg ønsket lyst eller mørkt tema.

## Hovedtest

1. Finn en oppskrift ved å velge land eller rettstype. Prøv også å søke etter både en rett og en ingrediens.
2. Åpne oppskriften og kontroller at bilde, historie, tid, ingredienser, fremgangsmåte og kilde vises.
3. Endre antall porsjoner. Kontroller at ingrediensmengdene endres, og sett deretter porsjonene tilbake.
4. Åpne allergeninformasjonen. Velg minst ett relevant allergen i profilen og kontroller at kjent, mulig eller ukjent innhold vises tydelig.
5. Velg et ingrediensalternativ. Les forklaringen om smak, tid, temperatur og allergener dersom disse feltene finnes.
6. Kontroller kjøpsveiledningen og butikktypen for ingrediensene.
7. Legg oppskriften i handlelisten. Kontroller at valgte porsjoner og ingrediensalternativ følger med.
8. Merk én vare som «har hjemme», kryss av én vare, rediger en mengde og legg til en egen vare.
9. Forhåndsvis PDF-en. Prøv systemdeling eller utskrift; du kan avbryte delings- eller utskriftsdialogen uten å fullføre.
10. Start matlagingsmodus fra den samme oppskriften. Kontroller at porsjoner og det valgte alternativet er identiske med detaljvisningen og handlelisten.
11. Gå frem og tilbake mellom stegene. Start, sett på pause, fortsett og avslutt en tidtaker dersom oppskriften tilbyr tidtaking.
12. Fullfør eller avslutt matlagingsøkten, gå tilbake til oversikten og kontroller at appen fortsatt reagerer normalt.

## Lagring og omstart

1. Merk en oppskrift som favoritt og skriv et kort notat.
2. La minst én vare ligge i handlelisten.
3. Avslutt appen helt og åpne den igjen.
4. Kontroller at favoritten, notatet, handlelisten og relevante innstillinger fortsatt finnes.

Når en senere TestFlight-build blir tilgjengelig, installer oppdateringen uten å slette appen og gjenta kontrollen. Rapporter straks dersom brukerdata forsvinner.

## Test uten internett

1. Åpne appen én gang, avslutt den og slå på flymodus. Kontroller at både Wi‑Fi og mobildata er av.
2. Start appen på nytt.
3. Åpne minst tre oppskrifter, inkludert bildene, og gjennomfør søk, porsjonsendring, alternativ, handleliste og matlagingsmodus.
4. Kontroller at ingen del av oppskriftsinnholdet krever nettverk. Eksterne kildelenker forventes ikke å åpne uten internett.

## Språk og tilgjengelighet

- Bytt mellom norsk, engelsk og thai og åpne den samme oppskriften i hvert språk.
- Prøv lyst og mørkt tema.
- Øk tekststørrelsen i iPhone-innstillingene og kontroller at innhold kan rulles og leses uten skjult tekst.
- Hvis du bruker VoiceOver, kontroller at knapper, bilder, allergenvarsler og navigasjon får forståelige navn.

## Feilrapport

Oppgi:

- iPhone-modell og iOS-versjon
- appversjon og buildnummer
- valgt språk, tema og tekststørrelse
- oppskrift og porsjonsantall
- nøyaktige steg for å gjenskape feilen
- forventet og faktisk resultat
- om feilen fortsatt finnes etter at appen er startet på nytt
- skjermbilde eller skjermopptak når det er trygt å dele

En kritisk feil er blant annet krasj, manglende oppskriftsdata, tap av lagrede data, feil ingrediensalternativ i matlagingssteget eller misvisende allergeninformasjon. Stans videre distribusjon og rapporter slike feil med én gang.
