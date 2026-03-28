# Datadokumentasjon: simulert datasett

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
| `earn_5yr` | Årsinntekt 5 år etter TDI-exit (NOK 2013). Utfallsvariabel | Log-normal, uavhengig (foreløpig) |
| `transfer_5yr` | Overføringer 5 år etter TDI-exit (NOK 2013). Utfallsvariabel | Log-normal, uavhengig (foreløpig) |

---

## Kjente begrensninger

- Utfallsvariablene (`empl_post`, `pdi_post`, `earn_5yr`, `transfer_5yr`) har foreløpig ingen datagenererende prosess — de er trukket fra gruppegjennomsnitt, ikke forklart av kovariater eller behandling.
- `duration_months` er trolig høyreskjev i virkeligheten, men modellert som normal.
- Standardavvikene er antatt, ikke hentet fra artikkelen (tabell 1 oppgir kun gjennomsnitt).
- Koeffisientene i inntektsmodellen er rimelige antakelser, ikke estimert fra data.
