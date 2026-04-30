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

- **Ferdig:** Tre frittstående mini-IV-skript med M&R-notasjon (P, φ, y, x, β): minimal (1D, 1Z), to-endogene, fire-endogene. Alle bruker `lm` så hvert steg er synlig, og kobler tabell 2 / 3 / 4 fra artikkelen direkte til FS / RF / 2SLS i koden. Notasjonsseksjon lagt til i metodelogg (`2026-04-08_...`).
- **To-fase-DGP** påbegynt (`simuler_utfall_to_fase.R` → `data/iv_replikasjon_to_fase.rds`) som svar på at v1-hovedspesifikasjonen feilet pga. perfekt motkorrelasjon mellom D_pdi og D_vr_k. PDI er nå et separat post-VR-utfall, ikke en konkurrerende første-hendelse. Estimering med to-fase-data er ikke fullført.
- **Neste økt** (brukerens forslag): pedagogisk spor — (2a) IV-antakelsene fra forelesningsslide 9 sjekket på `iv_to_endogene.R`, (2b) leave-one-out-konstruksjon i eget mini-skript, (2c) hazard-timing-laget. Deretter datakonstruksjon (3) og VLT-parallell (4) underveis.

### Skript-oversikt

**Aktive skript (`scripts/R/`):**
- `01_simuler_data.R` — replikerer tabell 1 (deskriptiv statistikk)
- `2026-04-10_simuler_utfall_data.R` — hazard-timing-mekanismen (v1-DGP, 5 competing risks med ligning 2 + jackknife) → `data/iv_replikasjon.rds`
- `2026-04-10_iv_fire_endogene.R` — pedagogisk multi-endogen IV med 4 behandlinger, M&R-notasjon (P, φ, y, x, β), kobler tabell 2/3/4 til FS/RF/2SLS

**Arvet/parkert (`scripts/R/arv/`):**
- `02_iv_instrument.R` — tidlig IV-instrument-eksperiment
- `2026-03-22_replica_markussen_roed.R` — første replikasjonsforsøk
- `2026-04-09_replikasjon_hazard_event_data.R` — tidlig hazard-eksperiment
- `2026-04-10_diagnoseplott.R` — diagnoseplott for v1-DGP
- `2026-04-10_estimering_rf_iv.R` — estimeringsskript (delvis pivotert mellom v1 og to-fase)
- `2026-04-10_iv_minimal.R` — Skript 1 i pedagogisk byggesteg-spor (1 D, 1 Z)
- `2026-04-10_iv_to_endogene.R` — Skript 2 i pedagogisk byggesteg-spor (2 endogene)
- `2026-04-10_simuler_utfall_to_fase.R` — to-fase-DGP (PDI som post-VR-utfall, eksperimentell)

- **RStudio-prosjektfil:** `replication-markussen-roed-2014.Rproj`

*Oppdateres ved vesentlige skift.*
