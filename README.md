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
├── CLAUDE.md                              # Arbeidsregler for AI-assistenten
├── README.md                              # Dette dokumentet
├── replication-markussen-roed-2014.Rproj  # RStudio-prosjektfil
├── scripts/R/
│   ├── 01_simuler_data.R                  # Datagenerering (tabell 1)
│   ├── 2026-04-10_iv_fire_endogene.R      # Multi-endogen IV med 4 behandlinger
│   ├── 2026-04-10_simuler_utfall_data.R   # v1-DGP med fem competing risks
│   └── arv/                               # Parkerte / eksperimentelle skript
├── data/                                  # Simulerte datasett (.rds)
├── output/                                # Figurer og diagnoseplott
├── notes/
│   ├── data_dictionary.md
│   ├── oppskrift_replikasjon_data.md
│   ├── markussen_roed_2014/
│   │   ├── notes.md                       # Eget arbeid: sammendrag + funn
│   │   ├── identifikasjonsstrategi.md     # Eget arbeid: metodisk gjennomgang
│   │   └── kilde/
│   │       ├── Markussen_Roed_2014.md     # Full artikkeltekst
│   │       └── splits/                    # Sidesplittede utdrag
│   └── forelesninger/
│       └── econ5106_L08_late.pdf          # IV/LATE-forelesningsnotater
└── log/                                   # Arbeidslogg, sesjonsnotater og TODO
```

## Status

Simulert datasett (N=345 107) som matcher tabell 1 ferdig. IV-instrumentkonstruksjon verifisert: person-måned-data med diskret varighetsmodell (likning 2), residualbasert leave-one-out-instrument (likning 5) som signifikant predikerer behandling. Tre frittstående mini-IV-skript dekker 1D/1Z, 2D/2Z og 4D/4Z med M&R-notasjon. 2SLS gjenfinner sann β for hovedbehandlingene. Identifikasjonsstrategien er oppsummert pedagogisk i `notes/markussen_roed_2014/identifikasjonsstrategi.md`. Neste steg: full M&R-replikasjon med klyngestandardfeil og flere utfall.

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

### Kildemateriale

| Dokument | Hva |
|---|---|
| [kilde/Markussen_Roed_2014.md](notes/markussen_roed_2014/kilde/Markussen_Roed_2014.md) | Full markdown-konvertert artikkel |
| [kilde/splits/](notes/markussen_roed_2014/kilde/splits/) | Samme artikkel splittet i 9 sideintervaller |
| [forelesninger/econ5106_L08_late.pdf](notes/forelesninger/econ5106_L08_late.pdf) | Forelesningsnotater om IV/LATE (referert i metodelogg) |
