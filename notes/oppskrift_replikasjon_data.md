# Oppskrift: Replikasjon av empirisk artikkel med simulerte data

> Denne filen er en arbeidsoppskrift for å replikere empiriske artikler steg for steg. Den er designet som grunnlag for en gjenbrukbar skill som kan brukes på tvers av replikasjonsprosjekter.

---

## Oversikt

Replikasjon med simulerte data har to formål:
1. **Forstå identifikasjonsstrategien** — ved å bygge opp den datagenererende prosessen (DGP) tvinges man til å forstå hvert ledd i analysen
2. **Verifisere at estimeringsmetoden fungerer** — når man kjenner den sanne effekten, kan man sjekke om metoden gjenfinner den

---

## Fase 1: Les og kartlegg artikkelen

### 1.1 Identifiser nøkkelelementer

- [ ] **Forskningsspørsmål:** Hva er den kausale effekten man forsøker å estimere?
- [ ] **Populasjon:** Hvem er observasjonsenhetene? (N, tidsperiode, seleksjonskriterier)
- [ ] **Behandlingsvariabel(er):** Hva er D? Binær, flerverdi, kontinuerlig?
- [ ] **Utfallsvariabler:** Hva er Y? (sysselsetting, inntekt, etc.)
- [ ] **Identifikasjonsstrategi:** OLS, IV, DiD, RDD, matching? Hva er kilden til eksogen variasjon?
- [ ] **Instrument (hvis IV):** Hva er Z? Hvorfor er det relevant og ekskluderbart?
- [ ] **Kontrollvariabler:** Hvilke X-er inkluderes? Individ-, lokal-, tidsnivå?

### 1.2 Kartlegg tabeller og ligninger

- [ ] Finn deskriptiv statistikk-tabellen (gjennomsnitt, N per gruppe)
- [ ] Finn estimeringsligningene (nummererte ligninger i artikkelen)
- [ ] Finn førstesteg-tabellen (instrument → behandling)
- [ ] Finn hovedresultat-tabellen (IV/RF-estimater)
- [ ] Noter sidetall for rask referanse

### 1.3 Skriv sammendrag

Lag en strukturert oppsummering i `notes/` som dekker punktene over. Dette blir referansedokumentet for resten av arbeidet.

---

## Fase 2: Simuler deskriptiv statistikk (Tabell 1)

Målet er et datasett der `group_by(category) |> summarise(across(..., mean))` matcher artikkelens tabell 1.

### 2.1 Sett opp parametere

For hver gruppe (behandlet/ubehandlet), hent fra artikkelen:
- N (antall observasjoner)
- Gjennomsnitt for alle variabler i tabell 1

Lagre parametrene som en strukturert liste (en liste per gruppe).

### 2.2 Velg fordelinger

| Variabeltype | Anbefalt fordeling | Eksempel |
|---|---|---|
| Binær (andel) | Bernoulli | female, immigrant |
| Alder, utdanning | Trunkert normal | age, year_school |
| Inntekt | Log-normal | earn_prior, earn_5yr |
| Varighet | Gamma eller log-normal | duration_months |

### 2.3 Bygg korrelasjonsstruktur

Simuler sekvensielt for å fange realistiske sammenhenger:

1. **Eksogene variabler** — trekk uavhengig (kjønn, alder, innvandring)
2. **Betingede variabler** — betinge på eksogene (utdanning|innvandring)
3. **Inntekt** — log-lineær modell med kovariater, kalibrer intercept per gruppe
4. **Dekomponering** — del inntekt i komponenter (arbeids- vs. overførings-inntekt)

**Viktig:** Kalibrer intercept slik at E[variabel] matcher gruppegjennomsnitt fra artikkelen.

### 2.4 Verifiser

```r
df_sim |>
  group_by(category) |>
  summarise(across(everything(), \(x) mean(x, na.rm = TRUE)))
```

Sammenlign med tabell 1. Dokumenter avvik og begrunnelser i `notes/data_dictionary.md`.

---

## Fase 3: Bygg den datagenererende prosessen (DGP)

Her legges den kausale strukturen inn. Utfallsvariablene skal nå *genereres* av behandling og kovariater, ikke trekkes uavhengig.

### 3.1 Definer den sanne effekten

Sett de sanne behandlingseffektene (β) basert på artikkelens hovedresultater. Disse er verdiene IV-estimatoren skal gjenfinner.

### 3.2 Legg til instrument-variasjon

For IV-studier:
- [ ] Opprett enheter for instrumentet (f.eks. kontor, region, domstol)
- [ ] Tilordne individer til enheter
- [ ] Simuler lokal praksis-variasjon (ulike tildelingsrater per enhet)
- [ ] Konstruer instrumentet (f.eks. leave-one-out-gjennomsnitt)

### 3.3 Simuler behandlingstildeling

Behandling D skal avhenge av:
- Instrumentet Z (førstesteg-relevans)
- Kovariater X (seleksjon på observerbare)
- Uobserverbare U (seleksjon på uobserverbare — endogeniteten som motiverer IV)

```
P(D=1) = f(Z, X, U)
```

### 3.4 Simuler utfall

Utfall Y skal avhenge av:
- Behandling D (den kausale effekten β)
- Kovariater X
- Uobserverbare U (korrelasjonen mellom U og D er endogenitets-problemet)

```
Y = α + β*D + γ*X + U + ε
```

**Eksklusjonsrestriksjonen:** Z påvirker Y *kun* gjennom D. Z skal ikke inngå direkte i Y-ligningen.

### 3.5 Verifiser DGP

- OLS av Y på D gir biased estimat (pga. U)
- IV av Y på D instrumentert med Z skal gjenfinner β (den sanne effekten)
- Reduced form (Y på Z) skal gi π = φ*β (førstesteg × effekt)

---

## Fase 4: Estimer modellen

### 4.1 Reduced form

Estimer effekten av instrumentet direkte på utfall:
```
Y = α + π*Z + γ*X + ε
```

### 4.2 Førstesteg

Estimer effekten av instrumentet på behandling:
```
D = α + φ*Z + γ*X + ν
```

Sjekk F-statistikk (> 10 for sterkt instrument).

### 4.3 IV / 2SLS

Estimer kausaleffekten:
```
Y = α + β*D̂ + γ*X + ε
```

der D̂ er predikert fra førstetrinnet.

### 4.4 Sammenlign med artikkelens resultater

| Estimat | Artikkel | Replikasjon | Kommentar |
|---|---|---|---|
| β (IV) | ... | ... | |
| π (RF) | ... | ... | |
| φ (1. steg) | ... | ... | |
| F-stat | ... | ... | |

---

## Fase 5: Robusthet og utvidelser

- [ ] Placebo-tester (effekt på pre-behandlings-utfall)
- [ ] Variasjon i instrumentstyrke
- [ ] Sensitivitetsanalyse for DGP-antakelser
- [ ] Monte Carlo: gjenta simuleringen mange ganger, sjekk bias og dekningsgrad

---

## Sjekkliste for ferdig replikasjon

- [ ] Deskriptiv statistikk matcher tabell 1
- [ ] Instrument har tilstrekkelig førstesteg (F > 10)
- [ ] IV-estimat er i riktig retning og størrelsesorden
- [ ] RF-estimat er konsistent med IV (lavere magnitude pga. målefeil)
- [ ] OLS-estimat avviker fra IV (bekrefter endogenitet i DGP)
- [ ] Placebo-test feiler ikke å avvise null
- [ ] Alle fordelingsvalg og antakelser dokumentert

---

## Tilpasning til ulike identifikasjonsstrategier

Oppskriften over er skrevet for IV. For andre strategier, tilpass fase 3–4:

| Strategi | DGP-krav | Estimeringsmetode |
|---|---|---|
| **IV** | Instrument Z, endogenitet via U | 2SLS, LIML |
| **DiD** | Parallelle trender, behandlingstidspunkt | TWFE, Callaway-Sant'Anna |
| **RDD** | Running variable, cutoff, tilordningsregel | Lokal lineær regresjon |
| **Matching** | CIA/unconfoundedness, common support | PSM, IPW, AIPW |

---

## Bruk som skill

Denne oppskriften er designet for å kunne formaliseres som en Claude Code skill:

```
/replicate <artikkelreferanse>
```

Skillen ville guide brukeren gjennom fasene, opprette filstruktur, og holde styr på fremdrift. Nøkkelfunksjonalitet:

1. **Artikkelanalyse** — parse og strukturere nøkkelelementer fra artikkelen
2. **DGP-oppsett** — generere simulerings-skript basert på artikkelens tabeller
3. **Estimering** — sette opp estimeringsligninger som matcher artikkelens metode
4. **Verifisering** — automatisk sammenligning av replikerte vs. publiserte resultater
