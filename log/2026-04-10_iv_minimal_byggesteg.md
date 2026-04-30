# 2026-04-10 — Pedagogisk minimal-IV i tre byggesteg

## Hva ble gjort

Steg tilbake fra den fulle M&R-replikasjonen for å bygge IV-mekanikken i isolerte
mini-skript. Tre nye skript, alle frittstående, alle med samme notasjon som
artikkelen (P, φ, y, x, β, η).

### Skript 1 — `2026-04-10_iv_minimal.R`

Klassisk IV med én endogen og ett instrument. Viser:

- DGP med η som endogenitetskanal og Z som eksogent instrument
- Naiv OLS er biased (≈ +7 vs sann 30)
- Manuelt førstesteg → predikere D̂ → manuelt andresteg
- `feols` IV gir samme svar med korrekte SE
- Førstesteg-F = 748, Wu-Hausman p = 8.5e−5
- IV gjenfinner sann β = 30 (estimat 25.5)

Notasjonsbro: én D ↔ M&Rs vektor av fire D-er; én Z ↔ M&Rs jackknifede φ.

### Skript 2 — `2026-04-10_iv_to_endogene.R`

Multi-endogen IV med to behandlinger. Endte opp som en minimal lineær DGP
(kontinuerlig P) etter en mellomversjon med LPM/binær trekning som ble droppet
fordi den distraherte fra IV-mekanikken.

Bruker `lm()` (ikke `fixest`) for å gjøre hvert steg synlig:

- 2 førstesteg, hvert med BEGGE φ + kontroller
- Predikere P̂_1, P̂_2
- Andresteg på predikasjonene
- Reduced form lagt til etter spørsmål om tabell 3
- Kobler til artikkelen i kommentarer: FS → tabell 2, RF → tabell 3, 2SLS → tabell 4
- Stargazer-utskrift (NB: `column.labels` knekker på underscore i tekstmodus)

Resultat: P_1 (sann 30) → IV 28.7; P_2 (sann 50) → IV 51.5. OLS biased ~−24
for begge.

**Wald-sjekk** for én Z og én D: β_IV ≈ β_RF / β_FS, bekreftet for begge
behandlinger innenfor støy.

### Skript 3 — `2026-04-10_iv_fire_endogene.R`

Triviell utvidelse av Skript 2 til fire behandlinger og fire instrumenter.
Strukturen er identisk; bare flere kolonner. 2SLS gjenfinner alle fire β
(30, 50, 15, 10) innenfor noen få enheter. OLS konsekvent skjev nedover.

## Diskusjon underveis

### Notasjonen i ligning 2 og 6

Detaljert gjennomgang av M&Rs notasjon, lagt inn i
`log/2026-04-08_gjennomgang_empirisk_strategi.md` som ny seksjon
«Notasjon — variabler i ligningene». Inkluderer:

- Indekstabell (i, j, d, S, k) med presisering at j = kontor × inngangsår
- Variabeltabell (P_Sijd, x_i, u_Sijd, φ_Si, y_ki, D_Si)
- Tabell over alle seks ligninger (1–6) med korte forklaringer
- Kort jackknife-paragraf
- Konkret tolkningseksempel av P_Sijd

### Notasjonskollisjon i artikkelen

Påpekt at `P` brukes i to ulike betydninger:
- Ligning 2: P_Sijd = person-måned-hazardindikator (én rad per måned)
- Ligning 6: P_ki = person-nivå deltakelsesdummy (én rad per person)

P-vektoren i ligning 6 er gjensidig utelukkende — én og bare én = 1 (basert
på FØRSTE behandling). Verdt å huske ved replikasjon.

### Strukturelt avvik mellom v1-DGP og artikkelen

Da vi forsøkte hovedspesifikasjonen (4 endogene, PDI dropp) på dagens v1-data,
feilet den katastrofalt — fordi vår DGP gir hver person max ÉN hendelse, slik
at D_pdi og D_vr_k er perfekt motkorrelert. Det skapte massiv OVB.

Konklusjon: M&Rs ligning 6 forutsetter implisitt at PDI-status ikke er perfekt
motkorrelert med VR-deltakelse. I virkelige data er dette en mild forutsetning
(folk kan ha begge over tid). I vår enkelt-fase-DGP brytes den fullstendig.

### To-fase-DGP påbegynt

`2026-04-10_simuler_utfall_to_fase.R` ble skrevet og kjørt:
- Fase 1: VR-tildeling (4 competing risks i 24 mnd)
- Fase 2: PDI som separat post-VR-utfall, lineær sannsynlighetsmodell
- Sann γ_VR_k for PDI: VR1 = -0.15, VR2 = +0.10, VR3 = -0.18, VR4 = -0.05
- z_pdi konstruert ALGEBRAISK ortogonal på z_vr-rommet (via OLS-residual)
- PDI-andeler matcher targets innenfor η-seleksjons-effekten
- Output: `data/iv_replikasjon_to_fase.rds`

Estimering med to-fase-data ble ikke fullført — vi pivoterte til
mini-skriptene i stedet.

## Tabell 3 og 4 i artikkelen

Verifisert: tabell 3 er **reduced form** (y direkte på φ); tabell 4 er
**IV/2SLS** (y på faktisk D, instrumentert). I `iv_to_endogene.R` og
`iv_fire_endogene.R` er kommentarene oppdatert for å peke på rett tabell.

Wald-relasjon for ett-Z-ett-D: β_IV = β_RF / β_FS. Eksempel fra artikkelen:
β_IV(VR1) = 4 982 / 0.01031 ≈ 483 000 NOK (skalert effekt).

## Forelesningsnotatene

Sjekket gjennom hele `econ5106_L08_late.pdf` (64 slides). Dekker:

- LATE-grunnformen (1 D, 1 Z) — slides 1–23
- Counterfactual distributions — slides 24–37
- **Multiple instruments** (1 D, flere Z) — slides 38–40 — feil retning ift. M&R
- **Variable treatment intensity** (ordinal D, 1 Z) — slides 41–52
- **Covariates / Abadie κ** — slides 53+

Multi-endogen IV (flere binære D, flere Z) er **ikke** dekket. Anbefalte
referanser: Wooldridge (2010) kap. 5.1.2–5.1.3, Kirkeboen-Leuven-Mogstad
(2016) for moderne LATE-tolkning av multi-treatment.

## Filer endret/opprettet

- `scripts/R/2026-04-10_iv_minimal.R` (ny)
- `scripts/R/2026-04-10_iv_to_endogene.R` (ny — den gamle LPM-versjonen ble erstattet)
- `scripts/R/2026-04-10_iv_fire_endogene.R` (ny)
- `scripts/R/2026-04-10_simuler_utfall_to_fase.R` (ny — to-fase-DGP, ikke ferdig integrert)
- `scripts/R/2026-04-10_estimering_rf_iv.R` (oppdatert med 3 IV-spec — siden delvis tilbakeskrudd ifm. v1/to-fase-veiskillet)
- `data/iv_replikasjon_to_fase.rds` (ny)
- `log/2026-04-08_gjennomgang_empirisk_strategi.md` (utvidet med notasjonsdel)

## Forslag til neste økt (fra brukeren)

1. Verifisere resultatet i `iv_fire_endogene.R`
2. Vurdere pedagogisk oppbygning: FS → 2SLS → IV/LATE-kriterier (4 antakelser
   fra forelesningsslidene) → instrumentkonstruksjon (hazard-timing + jackknife)
   → koble til z1 fra mini-skriptene
3. Datakonstruksjon (delvis gjort)
4. Knytte til VLT-casen

### Min anbefaling for neste økt

Start med **punkt 2a**: gå gjennom IV-antakelsene (random assignment, exclusion,
monotonicity, relevance) på det enkle `iv_to_endogene.R`-skriptet. Det er den
korteste broa fra «hva gjør 2SLS mekanisk» til «hva må være sant for at det er
meningsfylt». Deretter **punkt 2b**: vis leave-one-out-konstruksjonen i et eget
lite skript som bygger på det. VLT-paralleller bør drypes inn underveis i 2 og
3, ikke vente til slutt.
