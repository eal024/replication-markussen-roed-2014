# 2026-04-08 — Gjennomgang av empirisk strategi (seksjon 3)

## Hva ble gjort

Detaljert gjennomgang av M&R (2014) seksjon 3 (Empirical strategy), side 12–19. Fokus på:

1. **Forenkling av utfallsvariabler:** k = 3 (jobb, PDI, inntekt) gir 3 separate likninger (ligning 1)
2. **Konstruksjon av φ_i (lokal behandlingsstrategi)** — steg for steg:
   - 5 elementer: φ_PDI, φ_VR1, φ_VR2, φ_VR3, φ_VR4
   - Estimeres via lineære diskrete varighetsmodeller (ligning 2)
   - Person-måned-format: binær avhengig variabel per måned at risk, opptil 24 mnd
   - Residualer summeres per individ → gir kovariatjustert overgangstilbøyelighet
   - Gjennomsnitt per behandlingsmiljø (kontor × år) → φ_Sj
   - **Leave-one-out** (ligning 5): person i fjernes fra beregningen av eget instrument
3. **Reduced form (ligning 1):** φ_i settes direkte inn som forklaringsvariabel → totaleffekt
4. **IV-modell (ligning 6):** φ_i brukes som instrument for faktisk deltakelse P_i → LATE

## Viktige innsikter

- **Reduced form krever ikke eksklusjonsrestriksjonen** — fanger alle kanaler (inkl. atferdsresponser)
- **IV krever eksklusjonsrestriksjonen:** φ_i → P_i → y_i, men ikke φ_i → y_i direkte
- **Hvorfor LPM (ikke logit):** (a) leave-one-out kan beregnes analytisk med Sherman-Morrison, (b) unngår at funksjonell form driver resultater (Angrist & Pischke 2009, kap. 3.4.2)
- **Artikkelen bruker dummyer (ikke-parametrisk)** for de fleste kontrollvariabler — dette er viktig for troverdighet

## Deskriptive observasjoner (side 12, tabell 1)

- 20 % av spellene er ikke avsluttet innenfor observasjonsperioden (5 år)
- 47 % av VR-deltakere deltar i mer enn én VR-kategori
- Begge poeng er relevante for datakonstruksjonen

## Kontrollvariabler — fullstendig liste og status

### A. Individkjennetegn — DELVIS KONSTRUERT

| Variabel | Artikkelen | Replikasjonen | Mangler |
|---|---|---|---|
| Alder | Dummyer | Kontinuerlig | Må kodes til dummyer |
| Kjønn | Binær | Konstruert | OK |
| Utdanning | Dummyer | Kontinuerlig | Må kodes til dummyer |
| Nasjonalitet | Binær | Konstruert | OK |
| Tidligere arbeidsinntekt | Dummyer | Kontinuerlig | Må kodes til dummyer |
| Tidligere trygdemottak | Dummyer | Kontinuerlig | Må kodes til dummyer |

### B. Lokale sosioøkonomiske — IKKE KONSTRUERT

- Gjsn. utdanning (kommune + arbeidskontor, kjønn/alder-justert)
- Gjsn. inntekt (kommune + arbeidskontor, kjønn/alder-justert)
- Gjsn. dødelighet (kommune + arbeidskontor, kjønn/alder-justert)
- Gjsn. uføreandel (kommune + arbeidskontor, kjønn/alder-justert)

### C. Lokale konjunkturvariabler — IKKE KONSTRUERT

- Arbeidsledighetsrate (pendlerregion, 6 mnd før → 18 mnd etter TDI)
- Jobbfinningsrate for arbeidsledige (samme)
- Jobbdestruksjonsrate for sysselsatte (samme)

### D. Tidsdummyer — IKKE KONSTRUERT

- Inngangsmåned-dummyer (absorberer nasjonale trender/sesong)

## Prioritert rekkefølge for å legge til kontrollvariabler

1. **Tidsdummyer (D)** — trivielt å lage, nødvendig for å absorbere trender
2. **Individvariabler som dummyer (A)** — omkoding av eksisterende variabler
3. **Regional ledighetsrate som proxy for (C)** — forenkling, men fanger det viktigste
4. **Lokale sosioøkonomiske (B)** — arbeidskrevende, minst kritisk, egner seg som robusthetssjekk

## Relevante lærebokoppslag

- **Singer & Willett (2003)**, kap. 11–12: pedagogisk innføring i diskret varighetsmodell
- **Jenkins (1995)**, Oxford Bull. Econ. Stat.: bevis for at binær regresjon på person-periode-data = korrekt varighetslikelihood
- **Angrist & Pischke (2009)**, kap. 3.4.2: begrunnelse for LPM i IV-sammenheng
- **Cameron & Trivedi (2005)**, kap. 17–18: standard lærebok
- **Wooldridge (2010)**, kap. 20: varighetsanalyse

---

## Diskusjon og tolkning (økt 2, 2026-04-08)

### Ligning 2 er IKKE førstetrinnet i IV

Vanlig misforståelse: ligning 2 ser ut som et førstesteg, men er et *mellomsteg* for å konstruere instrumentet.

| Ligning | Formel | Rolle |
|---|---|---|
| Ligning 2 | P_Sijd = **d**'α + **x**'β + u | Hjelpeligning → residualer → instrument |
| IV førstesteg | D = α + φ·**Z** + γ·x + ν | Faktisk førstesteg: D på instrumentet Z |
| Ligning 1 | Y = α + β·D + γ·x + ε | Utfallsligningen (andresteg) |

### Min tolkning av hva residualen fanger

**d** (tidsdummyer) og **x** (individkjennetegn) er observerbart. Kontorets behandlingskultur er uobserverbart — en samlebetegnelse for praksisstil, vaner, prioriteringer. Residualen fra ligning 2 fanger nettopp dette: alt som ikke forklares av tid og individkjennetegn.

Residualen er *per definisjon* ortogonal på x og d (OLS-egenskapen). Det som gjenstår er:
- Kontorets systematiske behandlingsstrategi (det vi vil ha)
- Tilfeldig variasjon (som vaskes ut ved aggregering over mange klienter)

**Stegene fra residual til instrument:**
1. Estimer ligning 2 → residualer û_Sijd per person-måned
2. Summer residualene per person: û_Si = Σ_d û_Sijd
3. Ta gjennomsnitt per kontor (leave-one-out) → instrument **Z**
4. Bruk Z i IV-førstetrinnet

### Leave-one-out — konkret eksempel (ligning 5)

**Problemet:** Hvis person *i* sin behandling inngår i beregningen av kontorets strategi, og den strategien brukes til å forklare person *i* sitt utfall → mekanisk korrelasjon.

**Løsningen:** Fjern person *i* fra gjennomsnittet.

> Z_Si = gjennomsnittlig residual blant **alle andre** på samme kontor og år

**Eksempel:** Kontor A, år 2002, har 100 klienter.

For klient nr. 47:
- Summer residualene for klient 1–46 og 48–100
- Del på 99
- Det er Z for klient 47

For klient nr. 48:
- Summer residualene for klient 1–47 og 49–100
- Del på 99
- Det er Z for klient 48

Hvert individ får sitt eget instrument, men forskjellene er minimale (1 av ~100 klienter skiftes ut). Instrumentet fanger kontorets systematiske praksis, men er uavhengig av personen det skal forklare.

### Referanse: Jackknife IV

Angrist & Pischke kaller denne teknikken «jackknife IV». Standardtilnærming for å unngå at instrumentet forurenses av personen det skal forklare.

- **Angrist, J. D. & Pischke, J.-S. (2009).** *Mostly Harmless Econometrics: An Empiricist's Companion.* Princeton University Press. Kapittel 4.6 (jackknife IV, leave-one-out).
- Forlag: https://press.princeton.edu/books/paperback/9780691120355/mostly-harmless-econometrics

---

## Datastruktur: person-måned-format (ligning 2)

### Utgangspunkt — én rad per person

| id | office | entry_year | age | female | educ | got_vr1 | vr1_month |
|---|---|---|---|---|---|---|---|
| 1 | A | 2002 | 35 | 1 | 12 | 1 | 3 |
| 2 | A | 2002 | 42 | 0 | 10 | 0 | NA |
| 3 | B | 2002 | 28 | 1 | 16 | 1 | 1 |

### Ekspandert — én rad per person per måned at risk

| id | office | entry_year | month_d | age | female | educ | P_vr1 |
|---|---|---|---|---|---|---|---|
| 1 | A | 2002 | 1 | 35 | 1 | 12 | 0 |
| 1 | A | 2002 | 2 | 35 | 1 | 12 | 0 |
| 1 | A | 2002 | 3 | 35 | 1 | 12 | **1** |
| 2 | A | 2002 | 1 | 42 | 0 | 10 | 0 |
| 2 | A | 2002 | 2 | 42 | 0 | 10 | 0 |
| ... | ... | ... | ... | ... | ... | ... | 0 |
| 2 | A | 2002 | 24 | 42 | 0 | 10 | 0 |
| 3 | B | 2002 | 1 | 28 | 1 | 16 | **1** |

- Person 1: 3 rader (fikk VR1 i måned 3)
- Person 2: 24 rader (aldri VR1, sensurert)
- Person 3: 1 rad (fikk VR1 i måned 1)
- `P_vr1` = 1 kun i måneden hendelsen inntreffer, 0 ellers

### Rekkefølge for implementering

**Steg 1 — Datakonstruksjon** (i `01_simuler_data.R` eller ny fil):
- Ekspander persondatasettet til person-måned-format (`tidyr::uncount` eller løkke)
- Legg til `month_d` (varighet 1,...,24)
- Legg til binær hendelsesindikator `P_vr1` (og tilsvarende for VR2–VR4, PDI)
- Dummy-kod individvariabler (alder, utdanning, inntekt, trygd) — ikke-parametrisk som i artikkelen
- Legg til tidsdummyer for inngangsmåned

**Steg 2 — Estimering** (ny fil, f.eks. `03_varighetsmodell.R`):
- Importer data med `haven::read_*` eller `readr::read_*`
- Estimer ligning 2 med OLS: `lm(P_vr1 ~ factor(month_d) + x_dummyer, data = person_month)`
- Hent residualer: `residuals(mod)`
- Summer residualer per person: `group_by(id) |> summarise(u_sum = sum(resid))`
- Aggreger per kontor med leave-one-out: for person i, ta gjennomsnittet av alle *andres* residualsummer på samme kontor×år

**Steg 3 — IV-estimering** (ny fil, f.eks. `04_iv_estimering.R`):
- Importer data med leave-one-out-instrumentet
- OLS (biased): `lm(Y ~ D + x)`
- IV: `ivreg(Y ~ D + x | Z + x)` (pakke `ivreg` eller `fixest`)
- Sammenlign: OLS vs. IV vs. sann β

---

## Lærebokressurser for diskret varighetsmodell

### Primærreferanser — pedagogiske

| Referanse | Hva den gir | Tilgang |
|---|---|---|
| **Singer & Willett (2003)**, kap. 11–12 | Mest pedagogisk innføring. Viser person-periode-data, estimering, tolkning steg for steg. | [Oxford Academic](https://academic.oup.com/book/41753) |
| **Jenkins (1995)**, Oxford Bull. Econ. Stat. | Bevis: binær regresjon på person-periode-data = korrekt varighetslikelihood | [Wiley](https://onlinelibrary.wiley.com/doi/10.1111/j.1468-0084.1995.tb00031.x) |
| **Bristol-forelesninger (2013)** | Gratis slides med eksempler og R/Stata-kode | [PDF](https://www.bristol.ac.uk/media-library/sites/cmm/migrated/documents/discrete-time-eha-july2013-combined.pdf) |

### Sekundærreferanser — økonometri

| Referanse | Hva den gir | Tilgang |
|---|---|---|
| **Angrist & Pischke (2009)**, kap. 3.4.2 og 4.6 | LPM-begrunnelse + jackknife IV / leave-one-out | [Princeton UP](https://press.princeton.edu/books/paperback/9780691120355/mostly-harmless-econometrics) |
| **Wooldridge (2010)**, kap. 22 | Varighetsanalyse i økonometri | [MIT Press](https://mitpress.mit.edu/9780262232586/econometric-analysis-of-cross-section-and-panel-data/) |
| **Cameron & Trivedi (2005)**, kap. 17–18 | Standard mikroøkonometri-lærebok | |
| **Allison (1982)** | Klassikeren — diskret-tid metoder for hendelseshistorier | |

---

## Neste steg (neste økt, 2026-04-09)

1. Dummy-kod individvariabler + tidsdummyer i dataskriptet
2. Ekspander til person-måned-format
3. Estimer ligning 2 med OLS i eget skript (`03_varighetsmodell.R`)
4. Hent residualer, summer per person, konstruer leave-one-out-instrument
5. Kjør OLS vs. IV — verifiser at IV gjenfinner sann β
