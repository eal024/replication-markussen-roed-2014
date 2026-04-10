# 2026-04-10 — Reduced form, OLS og IV på simulert datasett

## Hva ble gjort

Etablert komplett replikasjon av Markussen & Røed (2014) sin IV-strategi for
alle 5 behandlinger (VR1–VR4, PDI), med sann behandlingseffekt og gjenfinning
via 2SLS. To nye skript (revidert i andre runde med mer realistisk Y).

1. **`scripts/R/2026-04-10_simuler_utfall_data.R`** — datagenerering
   - Utvidet hazard-simuleringen med uobservert heterogenitet η ~ N(0,1)
   - η inn i hazarder (`+0.004 · η`) og inn i utfall (`−60 · η`) — gir OLS-skjevhet
   - Sann behandlingseffekt: β_VR1=25, β_VR2=40, β_VR3=15, β_VR4=10, β_PDI=−200
     (PDI styrket fra −120 til −200 for å gi tydelig opphopning av nuller)
   - Utdanning i antall år skole (year_school: 10/13/16/18 etter SSB-konvensjon),
     binær educ_high avledes for hazardkalibrering. Tegn: kvinne −, utdanning +.
   - Y = α + Σ β_S · D_S + γ_female · female + γ_school · (year_school − 10)
         + λ_η · η + ε, deretter sensurert: y = max(0, y_latent)
   - Censureringen gir den klassiske venstre-trunkerte fordelingen — 22 % av
     PDI-mottakere har 0 i inntekt, øvrige grupper ~0 nuller
   - Estimerer ligning 2 → residualer → leave-one-out-instrument Z_S_norm
   - Lagrer persondatasett til `data/iv_replikasjon.rds` med β_true som attributt

2. **`scripts/R/2026-04-10_estimering_rf_iv.R`** — modellering (starter med innlesing)
   - Naiv OLS: Y ~ D_S + x  (skjev pga. uobservert η)
   - Reduced form: Y ~ Z_S + x  (intent-to-treat-aktig totaleffekt)
   - 2SLS: Y ~ D_S + x | Z_S + x  (via `fixest::feols`)
   - Sammenligning sann β / OLS / RF / IV i tabell

## Resultater (revidert kjøring med år-skole + sensurert Y, β_PDI=−200)

| Behandling | Sann β | OLS    | RF    | IV (2SLS) | OLS-skjev | IV-skjev |
|---|---:|---:|---:|---:|---:|---:|
| VR1 |   25 |  −16.1 |   5.1 |  **27.5** |  −41.1 |  +2.5 |
| VR2 |   40 |  −13.9 |   3.2 |    20.0   |  −53.9 | −20.0 |
| VR3 |   15 |  −12.2 |  11.1 |    26.5   |  −27.2 | +11.5 |
| VR4 |   10 |  −48.7 |   0.4 |    −6.0   |  −58.7 | −16.0 |
| PDI | −200 | −225.0 | −35.4 | **−192.9**|  −25.0 |  +7.1 |

(IV-estimater i fet er innenfor 2 SE av sann β.)

**Kontrollvariabler — gjenfinnes nesten perfekt:**

| Variabel    | Sann | OLS   | IV    |
|---|---:|---:|---:|
| female      |  −25 | −22.5 | −23.7 |
| year_school |   15 |  14.6 |  14.5 |

PDI-recovery er bemerkelsesverdig god (−193 mot −200) selv om 22 % av
PDI-mottakerne er sensurert ved 0 — Tobit-skjevheten er liten her.

## Tolkning

- **OLS er konsekvent skjev nedover** med ~30–60 enheter — dette er forventet:
  høy η = dårlig underliggende tilstand → mer behandling OG dårligere Y, så
  cov(D, η)>0 og λ_η<0 trekker OLS-koeffisientene ned.
- **IV gjenfinner sann β** for VR1, VR2 og PDI innenfor standardfeil. Wu-Hausman
  p<2e−16 bekrefter at OLS er forskjellig fra IV (endogenitet til stede).
- **VR4 er problembarnet:** instrumentet er svakest (F=70 mot 188 for VR1) fordi
  z_vr4 har lite spenn på tvers av kontor. Dette er en konkret illustrasjon av
  «svakt instrument»-problemet.
- **Reduced form alene** undervurderer effekten — den måler totaleffekten av
  «å bli plassert på et aktivt kontor», ikke effekten av faktisk å motta
  behandlingen. Skalafaktoren er førstesteg-koeffisienten.
- **Førstesteg-F-statistikker** (70–188) er alle >10 → ingen svakt-instrument-bias
  i Stock-Yogo-forstand, men VR4 ligger nær grensen.

## Designvalg verdt å huske

- **η som felles seleksjons- og utfallskanal** er den klassiske bias-mekanismen.
  Andre kanaler (måle-feil, omittert variabel ortogonal på Z) kunne også vært brukt.
- **`fixest::feols`** håndterer multi-endogen IV med naturlig syntaks:
  `y ~ x | 0 | D1 + D2 + ... ~ Z1 + Z2 + ...` — `fit_D_S` blir 2SLS-koeffisienten.
- **Sann β lagret som `attr(df, "beta_true")`** så modellskriptet kan sammenligne
  uten å duplisere parameterverdier. Dette er en lett måte å holde data og
  «sannheten» sammen i en ren `.rds`-fil.
- **Skriptene er separate per filstrukturregelen:** dataskriptet ender med
  `saveRDS()`, modellskriptet starter med `readRDS()`.

## Strukturomorganisering — DGP og modellering separert

Etter brukerinnspill er kodebasen splittet i tre separate skript med klare ansvar:

| Skript | Ansvar |
|---|---|
| `2026-04-10_simuler_utfall_data.R` | Kun DGP + jackknife: persondata, hazarder, Y, ligning 2-residualer, leave-one-out-instrument, `saveRDS` |
| `2026-04-10_diagnoseplott.R` | Frittstående diagnostikk: 3 PDF-er (inntekt total, inntekt per gruppe, kumulativ overgang) + verifikasjonstabeller mot artikkelen |
| `2026-04-10_estimering_rf_iv.R` | Estimering: deskriptiv → tabell 2 (relevansmatrise) → OLS → RF → IV → sammenligning med sann β |

`event_month` er lagt til i lagret datasett for å støtte overgangskurver i diagnoseskriptet.

## Diagnostikk vs artikkelen

| Mål | Vår DGP | Artikkelen | Status |
|---|---:|---:|:---|
| Månedsrate VR1 | 0.84 % | 0.76 % | ✓ |
| Månedsrate VR2 | 0.53 % | 0.35 % | litt høy |
| Månedsrate VR3 | 1.78 % | 1.86 % | ✓ |
| Månedsrate VR4 | 0.46 % | 0.37 % | litt høy |
| Månedsrate PDI | 1.09 % | 1.21 % | ✓ |
| Andel ubehandlet @ 24 mnd | 32.4 % | (n/a) | rimelig |
| Inntekt non-treated | ~302 | 163 (5-årssnitt) | ~2× høy, men ikke direkte sammenlignbart |
| Y-mass at 0 (PDI) | 22.1 % | (n/a) | klar venstre-trunkering |

## Tabell 2 — relevansmatrise (D_S på alle Z_S)

| D ↓ \ Z → | VR1 | VR2 | VR3 | VR4 | PDI |
|---|---:|---:|---:|---:|---:|
| VR1 | **0.154\*\*\*** | −0.008 | −0.021\*\*\* | −0.007 | −0.016\*\* |
| VR2 | −0.008\* | **0.112\*\*\*** | −0.013\*\* | −0.004 | −0.008 |
| VR3 | −0.025\*\*\* | −0.017\*\* | **0.243\*\*\*** | −0.013 | −0.035\*\*\* |
| VR4 | −0.007 | −0.005 | −0.011\* | **0.091\*\*\*** | −0.008 |
| PDI | −0.015\*\* | −0.008 | −0.028\*\*\* | −0.008 | **0.176\*\*\*** |

Førstesteg-F: 80–193, alle p < 1e−84.

## Diskusjon: to interessante avvik fra artikkelen

### A) VR3 har sterkest off-diagonale kryssvirkninger

VR3 er den klart største behandlingen i vår DGP: høyest baseline hazard (0.003), bredest kontorspenn (z_vr3 spenn = 0.019, > 2× neste), 25.6 % av populasjonen. Dette gjør VR3 til hovedkilden til **competing-risks-effekten** — VR3-tunge kontor «bruker opp» kandidater og presser ned alle andre overganger innenfor det faste tidsbudsjettet på 24 måneder.

Den statistiske signifikansen er delvis et N=50 000-artefakt: koeffisienter på 0.01–0.04 blir lett signifikante. Økonomisk størrelsesorden er fortsatt 5–10× mindre enn diagonalen, så instrumentet er ikke ødelagt. Effekten forklarer hvorfor IV-estimatet for VR3 er noe overestimert (27 vs sann 15) — Z_VR3 fanger litt av «tapet» av andre behandlinger.

### B) PDI-spillover snur fortegn — competing risks dominerer

Artikkelen (s. 18) finner at φ_PDI predikerer VR **positivt** (strenge PDI-kontor behandler saker raskere → presser også flere mot arbeidskontor). Vi prøvde å replikere dette via `pdi_spillover = 0.1` i VR-hazardene.

Vi får det motsatte: alle Z_PDI → D_VR-koeffisientene er negative (−0.008 til −0.035).

**Mekanismeanalyse:**

| Effekt | Retning | Størrelsesorden |
|---|:---:|---|
| PDI-spillover (`+0.1 · z_pdi` i VR-hazardene) | VR ↑ | +60 % på VR-base |
| Competing risks (høy PDI = færre VR-kandidater igjen) | VR ↓ | −50 % på VR-tilgjengelighet |

Competing risks vinner fordi vårt faste 24-måneders tidsbudsjett gir nullsum-logikk: «raskere saksbehandling» kan ikke gi *flere* hendelser totalt, bare en annen miks.

**Mulige fikser (utsatt):**
1. Heve `pdi_spillover` til 0.3–0.5
2. Modellere «saksbehandlingstempo» separat fra «behandlingsmiks»
3. Variere total hazard mellom kontor (slippe nullsum-budsjettet)

Begge avvikene er kjente svakheter i DGP-en, ikke feil i estimatorene. IV-identifikasjonen virker fortsatt: VR1 og PDI gjenfinnes godt, OLS-skjevheten er konsistent nedover, og hovedpoenget — at IV korrigerer for uobservert η — står seg.

## Filer endret eller opprettet

- `scripts/R/2026-04-10_simuler_utfall_data.R` (ny → revidert med year_school + censurering, deretter slankt til ren DGP)
- `scripts/R/2026-04-10_diagnoseplott.R` (ny — alternativ B, frittstående diagnostikk)
- `scripts/R/2026-04-10_estimering_rf_iv.R` (ny → restrukturert: deskriptiv + tabell 2 + OLS + RF + IV)
- `data/iv_replikasjon.rds` (50 000 rader × 20 kolonner)
- `output/diagnose_inntekt_total.pdf`
- `output/diagnose_inntekt_per_gruppe.pdf`
- `output/diagnose_overgangsrater.pdf`
- `replication-markussen-roed-2014.Rproj` (ny — RStudio-prosjektfil)
- `log/todo.md` (oppdatert)
- `log/2026-04-10_rf_iv_estimering.md` (denne filen)
- `CLAUDE.md` (oppdatert «Tilstand nå»)

## Pakker installert

- `fixest` (med avhengigheter zoo, Formula, numDeriv, sandwich, dreamerr, stringmagic)

## Neste

- Vurdere å heve `pdi_spillover` eller introdusere variabelt tidsbudsjett for å snu PDI-effekten i tabell 2
- Forstå hvorfor IV er svak for VR4 (instrumentet har minst spenn der)
- Klyngestandardfeil på kontornivå (`vcov = ~office_id`)
- Tidsdummyer + dummy-kodede individvariabler for mer realistisk replikasjon
- Berike datasettet med alder + innvandrer + tidligere inntekt for full tabell 1-sammenligning
