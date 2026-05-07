# Variabler i Markussen & Røed (2014) — kartlegging mot egne registre

> **Opphav:** replikasjonsrepoet `replication-markussen-roed-2014`
> **GitHub (opphav):** https://github.com/eal024/replication-markussen-roed-2014
>
> **Filen finnes parallelt i to repoer:**
> - **Replikasjon (opphav):** `replication-markussen-roed-2014/notes/2026-05-07_data_variabel_kartlegging_basertMR_2014.md`
> - **Phd-data (kopi):** `phd-data/kartlegging/2026-05-07_data_variabel_kartlegging_basertMR_2014.md`
>
> **Sync-regel:**
> 1. **Ved oppstart av arbeidsøkt** — sjekk om den andre kopien er nyere. Kjør `git log -1 --format="%cd %s" -- <fil>` i begge repoer eller `diff` direkte mellom dem. Hvis ulik: slå sammen før du redigerer videre.
> 2. **Ved endringer i én kopi** — speil til den andre i samme arbeidsøkt. Bruk samme commit-tekst der det er mulig. Avvik blir vanskelige å oppdage senere.
>
> **Relaterte notater i opphav:**
> - `notes/markussen_roed_2014/notes.md` — sammendrag av artikkelen
> - `notes/markussen_roed_2014/identifikasjonsstrategi.md` — IV-strategien
> - `notes/data_dictionary.md` — simulerte datasett
> - `notes/markussen_roed_2014/kilde/Markussen_Roed_2014.md` — full artikkeltekst
>
> **Artikkel:** Markussen & Røed (2014), "The Impacts of Vocational Rehabilitation", IZA Discussion Paper No. 7892.
>
> **Formål:** Kartlegge variablene M&R bruker, og bygge bro til registervariabler for egen IV-analyse av varig lønnstilskudd (VLT).

---

## Status

- [x] Variabler identifisert og gruppert (T/K/J/O/U)
- [x] Kolonne `Form` lagt til (datatype i register)
- [ ] Kommentarrunde (rad-for-rad gjennomgang med PhD-student)
- [ ] Registerkilder fylt inn
- [ ] Variabelnavn / kodelister fylt inn
- [ ] Uthentingsstrategi per variabel
- [ ] Testkjøring mot register

## Konvensjoner

- **ID-prefiks:** `T` trygdeytelser/tiltak · `K` konstante · `J` jevnt endres · `O` kontor/lokalt · `U` utfall · `V` VLT-spesifikt · `X` hjelpe-/kalibreringsvariabler
- Tomme celler markeres med `–` til de fylles ut
- Hver tabell har faste kolonner: **Form** (datatype i register: flag, beløp, dato, kategorisk, avledet, rate), **Register** (kilde, f.eks. FD-Trygd, A-ordningen), **Variabelnavn** (eksakt feltnavn i registeret), **Notater** (uthentingsstrategi, kodelister, transformasjoner, fallback-kilder)

---

## Gruppe 1 — Trygdeytelser og tiltak (T)

Hendelser og tilstander som beskriver hvor i systemet personen er.

| ID | Variabel | Rolle hos M&R | Form | Register | Variabelnavn | Notater |
|---|---|---|---|---|---|---|
| T1 | Pre-TDI ytelser (sykepenger + AAP) | Bakgrunn; "fraction with previous employment and exhausted sick pay" (tabell 1) | Flag + beløp | – | – | Pre-TDI-perioden dekker både sykepenger og AAP (temporary DI). Hver kommer som flag (1/0) og utbetalingsbeløp. M&R nevner kun "exhausted sick pay"; egen analyse utvider til AAP. |
| T2 | TDI-inntreden (dato) | Definerer t=0 og populasjon | Dato | – | – | Inngang er definert i registeret. |
| T3 | TDI-spell-slutt (dato + flag observert/sensurert) | Spell-varighet og høyresensurering | Dato + flag | – | – | – |
| T4 | TDI person-måned (avledet av T2+T3) | Datasett-format for likning 2 (hazardmodell) | Avledet | – | – | Varighet kan avledes fra T2+T3 (egen telling), eller hentes fra DVH-varighetsteller (alternativ kilde). |
| T5 | VR1 — subsidiert ordinær jobb (startdato) | D_VR1; konkurrerende første-event | Dato | – | – | M&R forenkler til 4 VR-typer (eget navn i artikkelen). Faktisk Arena-hierarki har flere undertyper — mapping dokumenteres i Arena-fil i `phd-data`-repoet. |
| T6 | VR2 — skjermet (startdato) | D_VR2 | Dato | – | – | Se T5 (felles Arena-mapping). |
| T7 | VR3 — utdanning (startdato) | D_VR3 | Dato | – | – | Se T5 (felles Arena-mapping). |
| T8 | VR4 — målrettede kurs (startdato) | D_VR4 | Dato | – | – | Se T5 (felles Arena-mapping). |
| T9 | PDI — varig uføretrygd (startdato) | D_PDI; også utfall (U2) | Dato | – | – | – |
| T10 | Sosialstønad (kommunal økonomisk sosialhjelp) | Ikke eksplisitt hos M&R, men inngår typisk i "previous transfers" (J4) | Flag + beløp (månedlig) | KOSTRA / FD-Trygd | – | Egen tillegg. Som T1: hver måned som flag (1/0) + utbetalingsbeløp. Inngår både som pre-T2 kontroll (sum til J4) og som tilstand under spell. |

## Gruppe 2 — Konstante kjennetegn (K)

Tidsuavhengige per person. M&R legger inn ikke-parametrisk (dummies).

| ID | Variabel | Rolle hos M&R | Form | Register | Variabelnavn | Notater |
|---|---|---|---|---|---|---|
| K1 | Kjønn | 1 dummy | Flag | – | – | – |
| K2 | Fødselsår (gir alder via T2) | Inngår via alders-dummies (J1) | År | – | – | – |
| K3 | Innvandrerbakgrunn — 4 opprinnelseskategorier | 4 dummies (Europa/Nord-Amerika, Afrika, Asia, Sør-Amerika) | Kategorisk | – | – | – |
| K4 | Utdanning ved inntreden — nivå × type | 19 dummies (NUS-koder); målt ved t=0 | Kategorisk | NAV (selvregistrert) | – | Egen analyse: ikke tilgjengelig som registerutdanning (NUDB/SSB). Kun selvregistrert hos NAV — lavere kvalitet og dekning enn M&R. Avvik fra M&R som bruker 19 NUS-kode-dummies. Vurder hvor mye dette svekker kontrollvariabel-oppsettet. |
| K5 | År innvandret (for innvandrere) | Ikke hos M&R; gir tid-i-Norge som ekstra kontroll | År | Folkeregisteret (FREG) | – | Egen tillegg. Sammen med K3 (opprinnelse) gir mer granulær innvandringskontroll. NA for personer født i Norge. |
| K6 | Sivilstand ved inntreden (inkl. ektefelle/partner-flag) | Ikke hos M&R; standardkontroll | Kategorisk | Folkeregisteret (FREG) | – | Egen tillegg. Kategorisk: ugift / gift / registrert partner / skilt / separert / enke. Ektefelle-fnr kan kobles for partner-data ved behov. Målt ved T2. |
| K7 | Antall barn under 18 i husholdningen | Ikke hos M&R; standardkontroll | Antall | Folkeregisteret (FREG) | – | Egen tillegg. Telling ved T2. |

## Gruppe 3 — Variabler som endres jevnt (J)

Tidsvarierende på individnivå, men målt på/før inntredentidspunkt og holdt fast som kontroll.

| ID | Variabel | Rolle hos M&R | Form | Register | Variabelnavn | Notater |
|---|---|---|---|---|---|---|
| J1 | Alder ved inntreden | 40 dummies (18–57) | Avledet (T2 − K2) | – | – | – |
| J2 | Inntreden-måned | 115 månedsdummies; absorberer nasjonale trender | Dato (måned) | – | – | – |
| J3 | Tidligere arbeidsinntekt — sum siste 3 år | Residualisert mot alder+kjønn → 13 kategorier | Beløp (månedlig) | A-ordningen (a-meldingen) | AA-inntekt | Månedsfil per person. Må summeres til årsnivå og deretter til 3-års-sum før inntreden (T2). |
| J4 | Tidligere trygde-/sosialforsikringsoverføringer — sum siste 3 år | Residualisert → 12 kategorier | Beløp | FD-Trygd (+ KOSTRA for sosialstønad, T10) | – | Aggregert sum av relevante ytelser (sykepenger, AAP, sosialstønad osv.) over de 3 årene før T2. |
| J5 | År i jobb / yrkeserfaring ved inntreden | Ikke hos M&R; ekstra arbeidsmarkedskontroll | Antall år (avledet) | A-ordningen (a-meldingen) | – | Egen tillegg. Telles som antall år (eller måneder) med positiv arbeidsinntekt før T2. Bruk samme månedsfil som J3. |

## Gruppe 4 — Kontorrelaterte og lokale variabler (O)

Stedfestingen som hele identifikasjonsstrategien hviler på.

| ID | Variabel | Rolle hos M&R | Form | Register | Variabelnavn | Notater |
|---|---|---|---|---|---|---|
| O1 | Arbeidskontor-ID ved inntreden (152 kontor i M&R) | Definerer behandlingsmiljø for VR1–VR4 | Kategorisk | NAV (kontor-ID) | – | Etter NAV-reformen (2006) er arbeidskontor og trygdekontor slått sammen til ett NAV-kontor. Egen analyse: O1 = O2 (samme enhet). Vi har kontor-ID i registeret. |
| O2 | Lokalt trygdekontor-ID ved inntreden (430 kontor i M&R) | Definerer behandlingsmiljø for PDI-streng-praksis | Kategorisk | NAV (kontor-ID) | – | Eksisterer ikke separat etter NAV-reformen (2006) — se O1. M&R's distinksjon mellom 152 arbeidskontor og 430 trygdekontor finnes ikke i dagens data. |
| O3 | Behandlingsmiljø = O1/O2 × inntredensår | Cellen leave-one-out beregnes innenfor | Avledet | NAV | – | Etter NAV-reformen: NAV-kontor × år (én celle, ikke to). |
| O4 | Bostedskommune | Grunnlag for lokale sosioøkonomiske rater | Kategorisk | Folkeregisteret (FREG) | – | Tidligere TPS (Det sentrale personregister), nå FREG/Folkeregisteret. Kobles på via fnr. |
| O5 | Travel-to-work-area / BA-region (40 regioner i M&R) | Grunnlag for konjunkturindikatorer | Kategorisk | (delvis avledbar) | – | Eksakt reiseavstand krever jobbadresse + bostedsadresse — ikke tilgjengelig. Mulig tilnærming: firma-ID (A-ordningen) + bostedskommune (O4) → BA-region eller pendlingsstrømmer. Avvik fra M&R som bruker 40 BA-regioner. |
| O6 | Lokale sosioøkonomiske rater (8 stk: uføreandel, dødelighet, inntekt, utdanning — på kommune- og kontornivå) | Kontrollvariabler | Rate / beløp | SSB (kommunestatistikk) | – | SSB-statistikk på kommunenivå kan kobles per individ via O4 (bostedskommune). Kontornivå krever ekstra mapping kontor → kommune(r). |
| O7 | Lokale konjunkturindikatorer (44 dummies: ledighet, jobbfinning, jobbdestruksjon, ulike tidsvinduer) | Kontrollvariabler | Rate | – | – | – |
| O8 | φ_i — leave-one-out instrumenter for VR1, VR2, VR3, VR4, PDI (5 stk) | **Avledet variabel**, ikke direkte fra register; bygges av T5–T9 + O3 + x_i | Avledet | – | – | Etter NAV-reformen: alle φ-instrumenter bygges innenfor samme NAV-kontor-celle (siden O1=O2). M&R kunne bruke to ulike kontornivåer; det kan vi ikke. |
| O9 | Antall ansatte per NAV-kontor × år | Ikke hos M&R; kapasitets-/arbeidsmengde-proxy | Antall | NAV (organisasjonsdata) eller A-ordningen (NAV som arbeidsgiver) | – | Egen tillegg. Kan brukes som kontorvariabel eller robusthetssjekk på behandlingsmiljø-tolkningen. |
| O10 | Caseworker-tildeling (saksbehandler per individ × år) | Ikke hos M&R; muliggjør caseworker-FE / caseworker-IV | Kategorisk / koblingsdata | NAV (saksbehandler-register) | – | **Søknadsavhengig** — krever utvidet datatilgang. Hvis tilgjengelig: gir mer presis behandlingsmiljø-måling enn kontor-celle (jf. Maestas-Mullen-Strand-stil designs). |
| O11 | Arbeidsgiver-ID (firma) ved T2 | Ikke hos M&R; sentralt for VLT (arbeidsplass-tilknyttet) | Kategorisk | A-ordningen (a-meldingen) | – | Egen tillegg. Identifiserer bedriften personen jobber for. NACE/næringskode kobles på via Virksomhets- og foretaksregisteret. Grunnlag for industri-FE og for å identifisere bedrifter som bruker VLT mye. |
| O12 | Bostedsfylke | Aggregering av O4 | Kategorisk (avledet) | (avledet av O4) | – | Egen tillegg. Praktisk nivå for aggregering av sosioøkonomiske rater når kommunenivå er for grovt/fint. |

## Gruppe 5 — Utfallsvariabler (U)

To tidsperspektiv: kondisjonelt på spell-slutt (post-TDI) og ukondisjonelt (fra inntreden).

| ID | Variabel | Rolle hos M&R | Form | Register | Variabelnavn | Notater |
|---|---|---|---|---|---|---|
| U1 | Sysselsatt 1. kalenderår etter spell-slutt | Binær, terskel 160 000 NOK arbeidsinntekt (2013-priser) | Flag (avledet) | (avledet av U3) | – | Avledet fra U3 (arbeidsinntekt). Terskel bør uttrykkes i G (X1) for å være sammenlignbar over år. |
| U2 | PDI-overgang 1. kalenderår etter spell-slutt | Binær | Flag + dato | NAV (PDI-register) | – | Vi har PDI som flag (1/0) og tilgangsmåned. Flag U2 = 1 hvis tilgangsmåned ≤ 12 mnd etter T3. |
| U3 | Arbeidsinntekt 1. kalenderår etter spell-slutt | Kroner | Beløp | A-ordningen (a-meldingen) | AA-inntekt | Samme kilde som J3. Aggregeres til årlig sum for kalenderåret etter T3. |
| U4 | Trygdeoverføringer 1. kalenderår etter spell-slutt | Kroner | Beløp | FD-Trygd / NAV | – | Sum av relevante ytelser (sykepenger, AAP, PDI, dagpenger osv.) for kalenderåret etter T3. |
| U5 | Gjennomsnittlig årlig arbeidsinntekt år 1–5 etter inntreden | Ukondisjonal — fanger lock-in | Beløp | (avledet av U3-grunnlag) | – | Samme inntektsserie som U3, ukondisjonal: snitt over år 1–5 fra T2. |
| U6 | Gjennomsnittlig årlig trygdeinntekt år 1–5 etter inntreden | Ukondisjonal | Beløp | (avledet av U4-grunnlag) | – | Samme trygdeserie som U4, ukondisjonal: snitt over år 1–5 fra T2. |
| U7 | Arbeidsinntekt år-for-år, år 1–7 etter inntreden | Profilanalyse | Beløp (panel) | (avledet av U3-grunnlag) | – | Samme inntektsserie som U3/U5, men panel år-for-år (1..7) fra T2. |
| U8 | "Ferdig + ansatt uten subsidie" år-for-år, år 1–7 | Profilanalyse | Flag (panel) | (avledet av flere) | – | Krever kombinasjon: ikke i tiltak/ytelse + arbeidsinntekt > terskel. Bygges av T5–T9 + U3/U4. |

## Gruppe 6 — Hjelpe-/kalibreringsvariabler (X)

Kalenderårs- eller systemvariabler som ikke er person- eller kontorspesifikke, men som trengs for normalisering og tolkning.

| ID | Variabel | Rolle hos M&R | Form | Register | Variabelnavn | Notater |
|---|---|---|---|---|---|---|
| X1 | Grunnbeløp (G) per år | Implisitt — M&R uttrykker terskler i 2013-NOK | Beløp (årlig) | NAV / SSB (årlig publisert) | – | Brukes for å uttrykke arbeidsinntekt og terskler i G (folketrygdens grunnbeløp), slik at årganger blir sammenlignbare. Erstatter M&R's KPI-justering til 2013-priser. |

## Gruppe 7 — VLT-spesifikke variabler (V)

Egen analyses behandlingsvariabler. Analog til M&R's T5–T8 (VR1–VR4), men sentrert på varig lønnstilskudd.

| ID | Variabel | Rolle hos M&R | Form | Register | Variabelnavn | Notater |
|---|---|---|---|---|---|---|
| V1 | VLT-tildeling (startdato) | Analog til D_VR i M&R | Dato | NAV (tiltaksregister) | – | Egen analyses behandling D_i. Inngår både i førstesteg (instrumenteres av φ_VLT) og som behandling i utfallsligningen. |
| V2 | VLT-varighet | – | Antall mnd / dato slutt | NAV (tiltaksregister) | – | For dose-respons og sensitivitetsanalyser. |
| V3 | VLT-tilskuddsbeløp | – | Beløp | NAV (tiltaksregister) | – | Effekt-per-krone-analyser. Uttrykk i G (X1) for sammenlignbarhet over år. |
| V4 | VLT-arbeidsgiver-ID | – | Kategorisk | NAV (tiltaksregister) | – | Bedriften som mottar tilskudd. Kobles til O11 (generell arbeidsgiver-ID) og NACE. Grunnlag for bedrifts-FE og "VLT-aktive bedrifter"-analyser. |

---

## Andre kandidater under vurdering

Flagget for diskusjon — ikke besluttet om de skal inn i hovedtabellen.

### Høy prioritet

- **Tidligere tiltaksdeltakelse** — historikk av VR/AAP-tiltak før T2. Viktig som baseline for VLT-analysen siden VLT ofte kommer etter andre tiltak.

### Medium prioritet

- **Diagnose ved sykefravær / AAP / TDI (ICPC/ICD)** — *venter — tas opp senere.* M&R bruker det ikke (post-treatment-bekymring), men nyttig for robusthetssjekk og subgruppeanalyser.

### Lav prioritet / situasjonsavhengig

- **Bostedsstabilitet / flytting under spell** — sjekk om individer flytter ut av kontorets område (kan svekke instrumentet).
- **Brutto lønn vs. pensjonsgivende inntekt** — A-ordningen har begge; vurder hvilken som er mest sammenlignbar med M&R's "earnings".
- **Arbeidsforhold-kjeden** — start/slutt-datoer for arbeidsforhold (A-ordningen) — for å definere "ansatt før TDI".

### Kommentar til "største avviket"

Enig i at **utdanningsdata (K4)** er det mest betydelige avviket — M&R bruker 19 NUS-kode-dummies fra NUDB, vi har bare selvregistrert NAV-data. Det treffer både kontrollvariabel-oppsettet og residualiseringen i J3/J4 (M&R residualiserer mot alder + kjønn + utdanning). Andre avvik som er substansielle:

1. **O1 = O2 (NAV-kontor)** — vi mister M&R's mulighet for to ulike kontornivåer i identifikasjonen (jf. note på O8).
2. **O5 reiseavstand / BA-region** — ikke direkte tilgjengelig; må tilnærmes.
3. **O7 lokale konjunkturindikatorer** — ennå ikke utfylt; må verifiseres at de kan konstrueres i samme oppløsning som M&R.

---

## Logg

| Dato | Endring |
|---|---|
| 2026-05-07 | Fil opprettet. Variabler identifisert og gruppert, kolonner Register/Variabelnavn/Notater står tomme. |
| 2026-05-07 | Lagt til kolonne `Form` (datatype i register). Fylt inn for alle rader basert på M&R-rolle. T1: oppdatert variabelnavn til "Pre-TDI ytelser (sykepenger + AAP)" — pre-TDI dekker begge ordninger; flag + beløp for hver. T4: notert DVH-varighetsteller som alternativ til egen telling fra T2+T3. T5–T8: notert at M&R forenkler 4 VR-typer; faktisk Arena-hierarki ligger i `phd-data`-repoet. |
| 2026-05-07 | K4 (utdanning): registerkilde notert som "NAV (selvregistrert)" — ikke tilgjengelig som registerutdanning (NUDB/SSB). Avvik fra M&R som bruker 19 NUS-kode-dummies. |
| 2026-05-07 | J3 (tidligere arbeidsinntekt): kilde A-ordningen (a-meldingen), feltnavn AA-inntekt. Månedsfil per person — må aggregeres til 3-års-sum før T2. |
| 2026-05-07 | Gruppe 4 (O): O1 og O2 slått sammen til ett NAV-kontor etter NAV-reformen (2006); M&R's 152/430-distinksjon finnes ikke i dagens data. O3 forenkles til NAV-kontor × år. O4 fra Folkeregisteret (tidligere TPS). O5 reiseavstand ikke direkte tilgjengelig — mulig tilnærming via firma-ID + bokommune. O6 fra SSB-kommunestatistikk, kobles via O4. |
| 2026-05-07 | Gruppe 5 (U): U1 avledet fra U3 + G-terskel. U2 PDI-flag + tilgangsmåned fra NAV. U3 samme kilde som J3 (A-ordningen). U4 sum av FD-Trygd-ytelser. U5–U8 avledet av samme inntekts-/trygdeserier som U3/U4 (ukondisjonal vs. kondisjonal aggregering). |
| 2026-05-07 | Nye rader: T10 sosialstønad (KOSTRA, flag + beløp), K5 år innvandret (FREG), J5 år i jobb (avledet fra A-ordningen), O9 antall ansatte per kontor, O10 caseworker-tildeling (søknadsavhengig). |
| 2026-05-07 | Ny gruppe X (hjelpe-/kalibreringsvariabler) med X1 Grunnbeløp. Konvensjon-listen oppdatert med X-prefiks. |
| 2026-05-07 | Lagt til seksjon "Andre kandidater under vurdering" med høy/medium/lav-prioritert kandidatliste, samt kommentar til "største avviket" (utdanning + O1=O2 + O5 + O7). |
| 2026-05-07 | Nye rader: K6 sivilstand (FREG), K7 antall barn under 18 (FREG), O11 arbeidsgiver-ID (A-ordningen), O12 bostedsfylke (avledet av O4). Ny gruppe V (VLT-spesifikt) med V1–V4. Andre kandidater oppdatert: VLT/arbeidsgiver/sivilstand/barn/bostedsfylke flyttet til tabell; diagnose markert som "venter — tas opp senere". |
| 2026-05-07 | Filnavn endret til `2026-05-07_data_variabel_kartlegging_basertMR_2014.md` (datoprefiks + mer presist navn). |
| 2026-05-07 | Filen kopiert til `phd-data/kartlegging/`. Header omstrukturert til parallell-kopi-modell med sync-regel (sjekk diff ved øktstart, speil endringer samme økt). |
