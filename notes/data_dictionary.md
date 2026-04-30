# Datadokumentasjon: simulerte datasett

*Opprettet: 2026-03-28*

Dokumentasjon for alle simulerte datasett i `data/`. Hver seksjon dekker ett datasett: kilde-skript, formål, kolonner, antakelser.

## Datasett-oversikt

| Fil | Kilde-skript | Formål |
|---|---|---|
| (in-memory, ikke lagret) | `01_simuler_data.R` | Tabell 1-replikasjon (deskriptiv statistikk) |
| `iv_replikasjon.rds` | `2026-04-10_simuler_utfall_data.R` | v1-DGP for IV-replikasjon (5 competing risks) |
| `iv_replikasjon_to_fase.rds` | `arv/2026-04-10_simuler_utfall_to_fase.R` | To-fase-DGP der PDI er post-VR-utfall |

---

## Datasett 1: Tabell 1-replikasjon (`01_simuler_data.R`)

Datasett basert på tabell 1 i Markussen & Røed (2014, s. 12). Parametrene (gjennomsnitt per gruppe) er hentet direkte fra artikkelen. Fordelingene er valgt for å gi en realistisk form gitt populasjonen (TDI-mottakere, 1996–2005).

N = 345 107 individer fordelt på fem grupper: non_treated, VR1, VR2, VR3, VR4.

---

## Korrelasjonsstruktur

Variablene simuleres sekvensielt slik at realistiske korrelasjoner oppstår fra en underliggende struktur:

1. **Eksogene variabler** (`female`, `age`, `immigrant`) trekkes uavhengig.
2. **Utdanning** (`year_school`) betinges på innvandringsstatus: innvandrere får −1.5 år. Basen justeres opp slik at gruppegjennomsnitt holdes.
3. **Inntekt** (`earn_prior`) genereres som en log-lineær modell:
   ```
   log(earn_prior) = intercept + 0.01*age + 0.05*school - 0.10*female - 0.15*immigrant + e
   ```
   der `e ~ N(0, 0.4)`. Interceptet kalibreres per gruppe slik at E[earn_prior] matcher tabell 1.
4. **Arbeidsinntekt og overføringer** (`labor_earn_prior`, `transfer_prior`) er en dekomponering av `earn_prior`. Andelen arbeidsinntekt modelleres med en logistisk funksjon som varierer med alder (eldre → mer overføringer) og utdanning (mer utdanning → høyere arbeidsandel). Summen er alltid lik `earn_prior`.

### Resulterende korrelasjoner (hele utvalget)

| Sammenheng | Korrelasjon |
|---|---|
| alder → inntekt | +0.20 |
| utdanning → inntekt | +0.26 |
| kvinne → inntekt | −0.10 |
| innvandrer → inntekt | −0.16 |
| innvandrer → utdanning | −0.24 |
| arbeidsinntekt ↔ overføringer | +0.59 |

---

## Variabler

### Binære variabler (Bernoulli)

| Variabel | Beskrivelse |
|---|---|
| `female` | Kvinne (1/0) |
| `immigrant` | Innvandrer (1/0) |
| `observed_end` | TDI-spell observert avsluttet (1/0) |
| `multi_vr` | Deltatt i mer enn ett VR-tiltak (1/0). NA for non_treated |
| `empl_post` | Sysselsatt første år etter TDI-exit (1/0). Utfallsvariabel |
| `pdi_post` | Overgang til varig uføretrygd (1/0). Utfallsvariabel |

Trukket med `sample(0:1, n, prob)` der sannsynligheten er gruppegjennomsnittene fra tabell 1.

### Kontinuerlige variabler — normalfordeling (avkuttet)

| Variabel | Beskrivelse | SD | Min | Max |
|---|---|---|---|---|
| `age` | Alder ved TDI-inntreden | 8 | 18 | 55 |
| `year_school` | Antall år fullført utdanning | 2 | 7 | 20 |
| `duration_months` | Varighet på TDI-spell (måneder) | 15 | 1 | 120 |

Trukket med `rnorm()`, klippet til [min, max]. Alder og utdanning er rimelig symmetriske; varighet er trolig høyreskjev i virkeligheten, men beholdes som normal inntil videre.

### Kontinuerlige variabler — log-normalfordeling

| Variabel | Beskrivelse | Generering |
|---|---|---|
| `earn_prior` | Samlet inntekt året før TDI (NOK 2013) | Log-lineær modell med kovariater (se over) |
| `labor_earn_prior` | Arbeidsinntekt året før TDI (NOK 2013) | Andel av `earn_prior`, logistisk modell |
| `transfer_prior` | Overføringer året før TDI (NOK 2013) | `earn_prior - labor_earn_prior` (foreløpig) |

**Merknad om `transfer_prior`:** Variabelen inkluderer sykepenger (100% kompensasjon, inntil 12 mnd) og eventuelt AAP/TDI (66% av tidligere inntekt). Størrelsen er dermed i stor grad mekanisk bestemt av tidligere arbeidsinntekt og lengden på sykepengeperioden før TDI-inntreden. Nåværende simulering bruker en logistisk andelsmodell — kan erstattes med en regelbasert konstruksjon senere.
| `labor_earn_post` | Arbeidsinntekt første kalenderår etter TDI-exit (NOK 2013). Utfallsvariabel | Betinget log-normal (se under) |
| `transfer_post` | Overføringer første kalenderår etter TDI-exit (NOK 2013). Utfallsvariabel | Betinget log-normal (se under) |
| `earn_5yr` | Årsinntekt 5 år etter TDI-exit (NOK 2013). Utfallsvariabel | Log-normal, uavhengig (foreløpig) |
| `transfer_5yr` | Overføringer 5 år etter TDI-exit (NOK 2013). Utfallsvariabel | Log-normal, uavhengig (foreløpig) |

---

## Post-TDI inntektsvariabler (ikke i tabell 1)

`labor_earn_post` og `transfer_post` er utfallsvariabler fra tabell 3 (kolonne II og IV), men gjennomsnitt per gruppe rapporteres ikke i tabell 1. Variablene er konstruert med betinget fordeling:

- **`labor_earn_post`**: Betinget på `empl_post`. Sysselsatte (empl_post=1) trekkes fra log-normal med median ~220k NOK (over 160k-terskelen per definisjon). Ikke-sysselsatte trekkes fra log-normal med median ~40k.
- **`transfer_post`**: Betinget på `pdi_post` og `empl_post`. PDI-mottakere får høye overføringer (~180k). Sysselsatte uten PDI får lave overføringer (~20k). Øvrige får moderate overføringer (~90k).

**Merknad:** Parametrene er rimelige antakelser, ikke hentet fra artikkelen. Gjennomsnittene kan ikke verifiseres mot tabell 1.

---

## Kjente begrensninger (datasett 1)

- Utfallsvariablene (`empl_post`, `pdi_post`, `earn_5yr`, `transfer_5yr`) har foreløpig ingen datagenererende prosess — de er trukket fra gruppegjennomsnitt, ikke forklart av kovariater eller behandling.
- `duration_months` er trolig høyreskjev i virkeligheten, men modellert som normal.
- Standardavvikene er antatt, ikke hentet fra artikkelen (tabell 1 oppgir kun gjennomsnitt).
- Koeffisientene i inntektsmodellen er rimelige antakelser, ikke estimert fra data.

---

## Datasett 2: `iv_replikasjon.rds` (v1-DGP)

Generert av `scripts/R/2026-04-10_simuler_utfall_data.R`. **N = 50 000** individer × ~20 kolonner. Hver rad er én person.

**Formål:** Persondatasett for IV-replikasjon med fem competing risks (VR1–VR4 + PDI som første hendelse). Brukes av `2026-04-10_iv_fire_endogene.R` og det parkerte estimeringsskriptet.

### Kolonner

| Kolonne | Type | Beskrivelse |
|---|---|---|
| `id` | int | Person-ID |
| `office_id` | factor | Kontor-tilhørighet (10 kontor) |
| `female` | 0/1 | Kjønnsindikator |
| `year_school` | int | Antall år skolegang (10/13/16/18) |
| `educ_high` | 0/1 | Avledet dummy: høy utdanning (≥13 år) |
| `eta` | num | Uobservert heterogenitet η ~ N(0,1) — felles seleksjons-/utfallskanal |
| `event_type` | factor | Første overgang: VR1, VR2, VR3, VR4, PDI eller `censored` |
| `event_month` | int | Måned for første hendelse (1–24, NA hvis sensurert) |
| `D_vr1`, `D_vr2`, `D_vr3`, `D_vr4`, `D_pdi` | 0/1 | Behandlingsdummyer (én = 1 per person, med mindre sensurert) |
| `y` | num | Utfall (sensurert: `pmax(0, y_latent)`) |
| `y_latent` | num | Underliggende latent inntekt før sensurering |
| `Z_vr1_norm`, `Z_vr2_norm`, `Z_vr3_norm`, `Z_vr4_norm`, `Z_pdi_norm` | num | Leave-one-out-instrumenter, normalisert til spenn 1 |

### Sannhetsverdier (lagret som attributter)

- `attr(df, "beta_true")`: c(VR1=25, VR2=40, VR3=15, VR4=10, PDI=−200)
- `attr(df, "lambda_eta")`: koeffisient på η i utfallsligningen (skaper OLS-skjevhet)
- `attr(df, "alpha_y")`, `gamma_female`, `gamma_school`: nivå- og kovariat-koeffisienter

### Kjente begrensninger

- D-ene er mutuelt eksklusive (kun én første hendelse per person) — bryter sammen for fire-endogene-spec uten ekstra struktur (jf. logg 2026-04-10)
- VR3 dominerer competing risks pga. høyest baseline hazard (0.003) og bredest kontorspenn
- PDI-spillover snur fortegn vs. artikkelen (negative Z_PDI → D_VR-koeffisienter) pga. nullsum-tidsbudsjett

---

## Datasett 3: `iv_replikasjon_to_fase.rds` (to-fase-DGP)

Generert av `scripts/R/arv/2026-04-10_simuler_utfall_to_fase.R`. Eksperimentell.

**Formål:** Løse den perfekte motkorrelasjonen mellom D_pdi og D_vr_k i v1-DGP. Her er VR-tildeling og PDI to separate faser:
- **Fase 1:** Fire competing risks i 24 måneder (VR1–VR4 eller sensurert)
- **Fase 2:** PDI som separat post-VR-utfall via lineær sannsynlighetsmodell

### Kolonner

Samme grunnstruktur som datasett 2, med følgende endringer:

| Kolonne | Endring vs. datasett 2 |
|---|---|
| `vr_event_type` | Erstatter `event_type`. Kun fire VR-utfall (+ censored), PDI er ikke lenger en konkurrerende risiko |
| `D_pdi` | Trukket separat i fase 2, post-VR |
| `p_pdi` | Underliggende PDI-sannsynlighet for hver person (gitt fase 1-utfall + η) |
| `Z_pdi_norm` | Konstruert algebraisk ortogonal på Z_VR-rommet (via OLS-residual) |

### Sannhetsverdier (lagret som attributter)

- `attr(df, "beta_true")`: VR-koeffisientene
- `attr(df, "gamma_pdi")`: Fase 2-koeffisienter — c(baseline, VR1=−0.15, VR2=+0.10, VR3=−0.18, VR4=−0.05)
- Øvrige som datasett 2

### Status

Estimering ikke fullført. Dokumentert som eksperimentell pivotering i logg 2026-04-10.
