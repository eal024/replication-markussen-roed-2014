# Replication: Markussen & Røed (2014)

*Opprettet: 2026-03-25*

Replikasjon av «The Impacts of Vocational Rehabilitation» (IZA DP No. 7892).

Formålet er å forstå IV-strategien i detalj ved å gjenskape analysen med simulerte data — som forberedelse til en egen IV-analyse av varig lønnstilskudd (VLT).

---

## Originalartikkel

- **Tittel:** The Impacts of Vocational Rehabilitation
- **Forfattere:** Simen Markussen & Knut Røed (Frischsenteret)
- **Publikasjon:** IZA Discussion Paper No. 7892, januar 2014
- **Data:** Administrative registerdata (SSB), TDI-inntreden 1996–2005, N = 345 000
- **Metode:** IV med lokal praksisvariasjoner (leave-one-out) som instrument

## Filstruktur

```
./
├── CLAUDE.md                                # Arbeidsregler for AI-assistenten
├── README.md                                # Dette dokumentet
├── replication-markussen-roed-2014.Rproj    # RStudio-prosjektfil
├── scripts/R/                               # 2026-05-12: ryddet — 3 aktive skript
│   ├── 01_simuler_data.R                    # Datagenerering (tabell 1, kanonisk)
│   ├── 2026-05-08_iv_jackknife_med_tid.R    # Fasit-referanse for tidsdim jackknife
│   ├── 2026-05-12_replikasjon_basis.R       # HOVEDSKRIPT: basisversjon M&R-replikasjon
│   └── arv/                                 # 15 parkerte / eldre skript (se tabell nedenfor)
├── data/                                    # Simulerte datasett (.rds)
├── output/                                  # Figurer og diagnoseplott
├── notes/
│   ├── data_dictionary.md
│   ├── oppskrift_replikasjon_data.md
│   ├── markussen_roed_2014/
│   │   ├── notes.md                         # Eget arbeid: sammendrag + funn
│   │   ├── identifikasjonsstrategi.md       # Eget arbeid: metodisk gjennomgang
│   │   └── kilde/
│   │       ├── Markussen_Roed_2014.md       # Full artikkeltekst
│   │       └── splits/                      # Sidesplittede utdrag
│   └── forelesninger/
│       └── econ5106_L08_late.pdf            # IV/LATE-forelesningsnotater
└── log/                                     # Arbeidslogg, sesjonsnotater og TODO
```

### Arkiv (`scripts/R/arv/`) — hva ligger der?

| Fil | Hva |
|---|---|
| `02_iv_instrument.R` | Tidlig IV-instrument-eksperiment |
| `2026-03-22_replica_markussen_roed.R` | Første replikasjonsforsøk |
| `2026-04-09_replikasjon_hazard_event_data.R` | Tidlig hazard-eksperiment |
| `2026-04-10_diagnoseplott.R` | Diagnoseplott for v1-DGP |
| `2026-04-10_estimering_rf_iv.R` | Estimering RF/IV (mellom v1 og to-fase) |
| `2026-04-10_iv_fire_endogene.R` | Pedagogisk multi-endogen IV (4 behandlinger) |
| `2026-04-10_iv_minimal.R` | Byggesteg 1 (1 D, 1 Z) |
| `2026-04-10_iv_to_endogene.R` | Byggesteg 2 (2 endogene) |
| `2026-04-10_simuler_utfall_data.R` | v1-DGP, 5 competing risks |
| `2026-04-10_simuler_utfall_to_fase.R` | To-fase-DGP (PDI som post-VR-utfall) |
| `2026-04-30_dgp_bias_minimal.R` | DGP brukt av figur-skript |
| `2026-05-02_figur_iv_sammenligning.R` | Figur OLS/IV-sammenligning |
| `2026-05-08_iv_jackknife_minimal.R` | Minimalt jackknife (1D, 1Z, uten tid) + MC bias-skala |
| `2026-05-11_iv_jackknife_minimal_med_tid.R` | Redundant kopi av minimal |
| `sjekk.R` | 6-linjers source-test |

Filer i `arv/` slettes aldri. Pedagogisk verdifulle å hente tilbake ved senere utvidelser: `iv_fire_endogene`, `iv_to_endogene`, og DGP+figur-paret.

## Status

**Per 2026-05-12 — basisversjon ferdig og fullt kommentert.** `2026-05-12_replikasjon_basis.R` (548 linjer) er ett samlet skript som tar M&R-strategien fra A til Å i miniformat: ability-narrativ (w korrelert med skolegang), hazard-DGP for ett tiltak (VR1) med kontor-kultur som eksogen kanal, person-måned-ekspansjon, LPM-hazard (ligning 2), residual-summering (ligning 3), naïv vs jackknife kontor-aggregering (ligning 4 og 5), y-simulering med endogenitetskanal via `lambda_w*w`, og fire estimerte modeller (OLS-sann, OLS-observert, IV-2SLS manuelt, reduced form) pluss `ivreg` for korrekte standardfeil. Hver matematisk operasjon har pedagogisk kommentarblokk med intuisjon, mekanisme og hensikt — skriptet kan leses ord for ord uten ekstern hjelp. Avsluttes med §6 UTVIDELSER (fire akser: flere VR, flere kovariater, oppskalering + klyngestandardfeil, MC-tillegg). Tabell 1 ligger fortsatt i `01_simuler_data.R` (N=345 107). Fasit-referansen `2026-05-08_iv_jackknife_med_tid.R` er beholdt aktivt for sammenligning. Identifikasjonsstrategien er oppsummert pedagogisk i `notes/markussen_roed_2014/identifikasjonsstrategi.md`. Neste steg (anbefalt rekkefølge): klyngestandardfeil på kontornivå → to tiltak (VR1 + VR2) → berike kovariater (alder, region) → full M&R med PDI.

## Dokumentoversikt

### Notater (persistente)

| Dokument | Opprettet | Hva |
|---|---|---|
| [notes.md](notes/markussen_roed_2014/notes.md) | 2026-03-27 | Sammendrag av artikkelen — forskningsspørsmål, metode, data, funn, relevans for VLT |
| [data_dictionary.md](notes/data_dictionary.md) | 2026-03-28 | Kolonner, fordelingsvalg og antakelser for alle simulerte datasett |
| [oppskrift_replikasjon_data.md](notes/oppskrift_replikasjon_data.md) | 2026-04-02 | Generell oppskrift for replikasjon med simulerte data (forløper til en gjenbrukbar skill) |
| [identifikasjonsstrategi.md](notes/markussen_roed_2014/identifikasjonsstrategi.md) | 2026-04-29 | Pedagogisk gjennomgang av likning 6, hvordan φ konstrueres, endogenitet og IV/2SLS — med kobling til konvensjonell IV-notasjon |

### Logger og TODO

| Dokument | Hva |
|---|---|
| [todo.md](log/todo.md) | Aktiv oppgaveliste — gjort, i kø, og senere |
| [2026-03-27_notes_go_through_reading.md](log/2026-03-27_notes_go_through_reading.md) | Lesenotater fra første gjennomgang av artikkelen |
| [2026-04-08_gjennomgang_empirisk_strategi.md](log/2026-04-08_gjennomgang_empirisk_strategi.md) | Detaljert gjennomgang av seksjon 3 (likning 2–6, leave-one-out, person-måned-format) |
| [2026-04-10_iv_minimal_byggesteg.md](log/2026-04-10_iv_minimal_byggesteg.md) | Pedagogisk byggesteg-spor: tre frittstående mini-IV-skript med M&R-notasjon |
| [2026-04-10_rf_iv_estimering.md](log/2026-04-10_rf_iv_estimering.md) | Reduced form, OLS og IV på simulert datasett — sann β-gjenfinning |
| [2026-05-08_jackknife_minimal.md](log/2026-05-08_jackknife_minimal.md) | Jackknife-konstruksjon (ligning 5) i isolert minimalt skript: truth vs naïv vs jack |
| [2026-05-11_jackknife_med_tid.md](log/2026-05-11_jackknife_med_tid.md) | Jackknife med tidsdimensjon: hazard-DGP, person-måned-ekspansjon, ligning 2 → 3 → 4/5 trinn for trinn |

### Kildemateriale

| Dokument | Hva |
|---|---|
| [kilde/Markussen_Roed_2014.md](notes/markussen_roed_2014/kilde/Markussen_Roed_2014.md) | Full markdown-konvertert artikkel |
| [kilde/splits/](notes/markussen_roed_2014/kilde/splits/) | Samme artikkel splittet i 9 sideintervaller |
| [forelesninger/econ5106_L08_late.pdf](notes/forelesninger/econ5106_L08_late.pdf) | Forelesningsnotater om IV/LATE (referert i metodelogg) |
