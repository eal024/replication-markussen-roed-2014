# CLAUDE.md — Arbeidsregler for dette prosjektet

> **Globale regler** finnes i `~/.claude/CLAUDE.md` (sikkerhet, språk, statistikkilder, økt-rutiner). Denne filen inneholder kun prosjektspesifikke regler.

---

## Prosjekt

Replikasjon av Markussen & Røed (2014), "The Impacts of Vocational Rehabilitation". Formålet er å forstå IV-identifikasjonsstrategien i detalj gjennom simulering — som forberedelse til en egen IV-analyse av varig lønnstilskudd (VLT).

## Mappestruktur

```
scripts/R/        # R-skript — dato-prefiks (YYYY-MM-DD_beskrivelse.R)
data/             # Simulerte datasett (ikke rå registerdata)
output/           # Figurer og tabeller
notes/            # Artikkelnotater, metodenotater, datadokumentasjon
  oppskrift_replikasjon_data.md  # Generell oppskrift for replikasjon (→ fremtidig skill)
log/              # Arbeidslogg, TODO, sesjonsnotater
```

## R-konvensjoner

- Bruk `tidyverse`-stil (pipe `|>`, `dplyr`, `ggplot2`)
- Sett `set.seed()` i alle simuleringsskript for reproduserbarhet
- Variabelnavn i data: snake_case, engelske (matcher artikkelens terminologi)
- Hjelpefunksjoner: prefix `fn_` for interne hjelpefunksjoner
- Nye skript får dato-prefiks: `YYYY-MM-DD_beskrivelse.R`

## Arbeidsflyt

1. **Les før du endrer.** Forstå eksisterende kode og notater før du foreslår endringer.
2. **Bygg videre, ikke start på nytt.** Utvid eksisterende skript heller enn å lage nye fra scratch, med mindre strukturen krever det.
3. **Verifiser mot artikkelen.** Simulerte data skal alltid sjekkes mot tabell 1 (deskriptiv statistikk). Estimater skal sammenlignes med artikkelens tabeller.
4. **Dokumenter valg.** Fordelingsvalg, koeffisienter og antakelser skal begrunnes i `notes/data_dictionary.md`.
5. **Hold det enkelt.** Ikke legg til kompleksitet som ikke trengs for å forstå identifikasjonsstrategien.
6. **Følg oppskriften.** `notes/oppskrift_replikasjon_data.md` gir steg-for-steg-rutine for replikasjonsarbeidet.

## Artikkelreferanser

- **Tabell 1** (s. 12): Deskriptiv statistikk — grunnlag for datasimulering
- **Tabell 2** (s. 17): Førstesteg — instrumentets prediktive kraft
- **Tabell 3** (s. 20): Reduced form-estimater
- **Tabell 4** (s. 22): IV-estimater (hovedresultat)
- **Ligning 2** (s. 9): Lineær diskret varighetsmodell
- **Ligning 5** (s. 11): Leave-one-out instrumentkonstruksjon

## Nøkkelbegreper

| Begrep | Forklaring |
|---|---|
| TDI | Midlertidig uførestønad (temporary disability insurance) |
| PDI | Varig uføretrygd (permanent disability insurance) |
| VR1–VR4 | Fire typer yrkesrettet rehabilitering |
| Leave-one-out | Instrumentet: gjennomsnittlig behandlingsrate blant *andre* på samme kontor×år |
| RF | Reduced form — effekt av behandlingsmiljø direkte på utfall |
| LATE | Local average treatment effect — IV estimerer effekten for compliers |

## Referansemateriale

- `notes/markussen_roed_2014/notes.md` — sammendrag av artikkelen
- `notes/markussen_roed_2014/Markussen_Roed_2014.md` — full artikkeltekst
- `notes/data_dictionary.md` — dokumentasjon av simulert datasett
- `notes/oppskrift_replikasjon_data.md` — generell oppskrift for replikasjon
- `log/2026-03-27_notes_go_through_reading.md` — lesenotater med metodologisk innsikt

## Tilstand nå

- **Ferdig:** Tre-delt struktur for IV-replikasjon (DGP / diagnostikk / estimering), år-utdanning + venstre-trunkert Y, full tabell 2-relevansmatrise, IV gjenfinner sann β for VR1 og PDI
- **Pågår:** To åpne diagnostikk-spørsmål — (1) PDI-spillover snur fortegn pga. competing risks (motsatt av artikkelen), (2) VR3 dominerer som største behandling og presser kryssvirkninger negativt
- **Neste:** Heve PDI-spillover eller variabelt tidsbudsjett, klyngestandardfeil på kontornivå, berike datasettet for full tabell 1-sammenligning
- **Tabell 1-data (eldre strøm):** `scripts/R/01_simuler_data.R`
- **IV-instrument (eldre):** `scripts/R/02_iv_instrument.R`
- **Hazard + tabell 2 (eldre eksperiment):** `scripts/R/2026-04-09_replikasjon_hazard_event_data.R`
- **DGP + jackknife:** `scripts/R/2026-04-10_simuler_utfall_data.R` → `data/iv_replikasjon.rds`
- **Diagnoseplott (frittstående):** `scripts/R/2026-04-10_diagnoseplott.R` → `output/diagnose_*.pdf`
- **Estimering (deskriptiv → tabell 2 → OLS/RF/IV):** `scripts/R/2026-04-10_estimering_rf_iv.R`
- **RStudio-prosjektfil:** `replication-markussen-roed-2014.Rproj`

*Oppdateres ved vesentlige skift.*
