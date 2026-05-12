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
- **Unntak — kanonisk inngangsskript:** `01_simuler_data.R` beholder den numeriske prefiksen som kanonisk tabell-1-replikasjon (forløper til alle senere skript). Andre skript skal ha datoprefiks.

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
- `notes/markussen_roed_2014/identifikasjonsstrategi.md` — pedagogisk gjennomgang av likning 6, instrumentkonstruksjon, IV/2SLS
- `notes/markussen_roed_2014/kilde/Markussen_Roed_2014.md` — full artikkeltekst
- `notes/markussen_roed_2014/kilde/splits/` — sidesplittede utdrag av artikkelen
- `notes/data_dictionary.md` — dokumentasjon av simulerte datasett
- `notes/oppskrift_replikasjon_data.md` — generell oppskrift for replikasjon
- `notes/forelesninger/econ5106_L08_late.pdf` — forelesningsnotater om IV/LATE
- `log/2026-03-27_notes_go_through_reading.md` — lesenotater med metodologisk innsikt

## Tilstand nå

- **Basisversjon av replikasjonen ferdig (2026-05-12):** `2026-05-12_replikasjon_basis.R` (548 linjer) tar M&R-strategien fra A til Å i ett samlet, kommentert skript. Innholder: ability-narrativ (w korrelert med skolegang via rho_ws), DGP med hazard (h_base = 0.01, sigma_z = 0.010, delta_w = 0.005, lambda_w = 50, beta_true = 50), person-måned-ekspansjon, LPM-hazard (ligning 2), residual-summering (ligning 3), naïv vs jackknife kontor-aggregering (ligning 4, 5), y-simulering, fire estimerte modeller (sann/observert/IV/RF) + ivreg for korrekte SE. **Pedagogiske forklaringer i hver seksjon** — leseren skal kunne følge replikasjonen uten å ha vært med i økten.
- **Avsluttende utvidelses-avsnitt** i samme skript (§6): fire akser for videreutvikling med konkrete kodeforslag — (A) flere VR-tiltak/multi-endogen, (B) flere kovariater (alder, ledighet, tidligere inntekt), (C) flere observasjoner + klyngestandardfeil via fixest, (D) pedagogiske MC-tillegg. Anbefalt rekkefølge: klyngestandardfeil → to tiltak → berike x → full M&R med PDI.
- **Opprydding scripts/R/ (2026-05-12):** kun 3 aktive skript igjen — kanonisk tabell 1, fasit tidsdim-jackknife, og basisversjon. 7 filer flyttet til `arv/` (totalt 15 parkerte). README og CLAUDE oppdatert med arkiv-tabell.
- **Tidligere milepæler (referanse):** tre mini-IV-skript med M&R-notasjon (minimal 1D, to-endogene, fire-endogene) — alle nå i `arv/`. Jackknife-mini (todo 2b) og jackknife med tidsdimensjon (todo 2b+) loggført. Fasit-skript fortsatt aktivt for referanse.
- **Åpne spørsmål til neste økt:** klyngestandardfeil på kontornivå (raskest), to-tiltaks-utvidelse (bro mot full M&R), eller berike x med flere kovariater? Se §6 i basis-skriptet for konkret forslag.

### Skript-oversikt

**Aktive skript (`scripts/R/`) — 2026-05-12 etter opprydding:**
- `01_simuler_data.R` — replikerer tabell 1 (deskriptiv statistikk, kanonisk inngang)
- `2026-05-08_iv_jackknife_med_tid.R` — **fasit-referanse** for tidsdim jackknife: hazard-DGP, person-måned, ligning 2 → 3 → 4/5
- `2026-05-12_replikasjon_basis.R` — **hovedskript / basisversjon av M&R-replikasjonen**. Full kjede: ability-narrativ, DGP med hazard, instrumentkonstruksjon (ligning 2→5), OLS/IV/RF-tabell, ivreg for korrekte SE. Utgangspunkt for senere utvidelser (to tiltak, klyngestandardfeil, flere kovariater)

**Arvet/parkert (`scripts/R/arv/`) — 15 filer:**

| Fil | Hva |
|---|---|
| `02_iv_instrument.R` | Tidlig IV-instrument-eksperiment |
| `2026-03-22_replica_markussen_roed.R` | Første replikasjonsforsøk |
| `2026-04-09_replikasjon_hazard_event_data.R` | Tidlig hazard-eksperiment |
| `2026-04-10_diagnoseplott.R` | Diagnoseplott for v1-DGP |
| `2026-04-10_estimering_rf_iv.R` | Estimeringsskript (delvis pivotert mellom v1 og to-fase) |
| `2026-04-10_iv_fire_endogene.R` | Pedagogisk multi-endogen IV (4 behandlinger), M&R-notasjon, kobler tabell 2/3/4 til FS/RF/2SLS |
| `2026-04-10_iv_minimal.R` | Pedagogisk byggesteg 1 (1 D, 1 Z) |
| `2026-04-10_iv_to_endogene.R` | Pedagogisk byggesteg 2 (2 endogene) |
| `2026-04-10_simuler_utfall_data.R` | v1-DGP, 5 competing risks → `data/iv_replikasjon.rds` |
| `2026-04-10_simuler_utfall_to_fase.R` | To-fase-DGP (PDI som post-VR-utfall, eksperimentell) |
| `2026-04-30_dgp_bias_minimal.R` | Pedagogisk DGP brukt av figur-skript |
| `2026-05-02_figur_iv_sammenligning.R` | Figur OLS/IV-sammenligning (sourcer dgp_bias_minimal) |
| `2026-05-08_iv_jackknife_minimal.R` | Minimalt jackknife-eksempel (1D, 1Z, *uten* tidsdimensjon): tre φ-versjoner + MC bias-skala |
| `2026-05-11_iv_jackknife_minimal_med_tid.R` | Redundant kopi (duplikat av minimal) |
| `sjekk.R` | 6-linjers source-test |

Filer i arv/ slettes aldri. De kan kalles inn igjen ved senere utvidelser (særlig `iv_fire_endogene`, `iv_to_endogene` og `figur_iv_sammenligning`-paret som er pedagogisk verdifulle).

- **RStudio-prosjektfil:** `replication-markussen-roed-2014.Rproj`

*Oppdateres ved vesentlige skift.*
