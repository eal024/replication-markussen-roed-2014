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

## Notasjon — variabler i ligningene

Ligningene i seksjon 3 bruker en kompakt indeksnotasjon. Her er full ordliste over hva hver indeks og hvert symbol står for, slik at notatet kan leses uten å gå tilbake til artikkelen.

### Indekser

| Symbol | Betyr | Verdiområde |
|---|---|---|
| **i** | Individ (TDI-tilgang) | 1, 2, ..., N (≈ 345 000 i artikkelen) |
| **j** | Lokalt behandlingsmiljø = **kontor × inngangsår** | én verdi per kontor-år-kombinasjon (s. 14: «A treatment environment corresponds to a particular local administrative entity and a particular year of entry») |
| **d** | **Risikomåned** — antall måneder siden TDI-inntreden, ikke kalendermåned | 1, 2, ..., 24 (høyresensureres ved 24 mnd) |
| **S** | Type tilstand / behandling individet kan gå over til | {VR1, VR2, VR3, VR4, PDI} — én ligning estimeres per S |
| **k** | Type utfall i ligning 1 | f.eks. {jobb, PDI, inntekt} |

### Variabler

| Symbol | Betyr |
|---|---|
| **P_Sijd** | Hendelsesindikator: **= 1** hvis individ _i_ gjør overgang til tilstand _S_ i risikomåned _d_, **= 0** ellers. Individet bidrar med én rad per måned «at risk» til hendelsen inntreffer eller spellet sensureres. Når P_S = 1 forsvinner individet ut av risikosettet for den S-en. |
| **x_i** | Vektor av **kontrollvariabler** for individ _i_: alder, kjønn, utdanning, nasjonalitet, tidligere arbeidsinntekt, tidligere trygdemottak, lokale sosioøkonomiske forhold, lokale konjunkturer, inngangsmåned-dummyer. Stort sett dummy-kodet (ikke-parametrisk) i artikkelen. |
| **d** (vektor) | **Varighetsdummyer** — én dummy per risikomåned (factor(month_d)) som fanger ikke-parametrisk baseline hazard. Forveksles ikke med skalaren _d_ over: vektoren `d` er settet av varighetsdummyer, skalaren _d_ er hvilken måned vi er i. |
| **u_Sijd** | Residual fra ligning 2 — det som er igjen etter at varighet og x er trukket fra. Tolkes som «kontorets behandlingstilbøyelighet» pluss støy. |
| **φ_Si** | Lokal behandlingsstrategi for tilstand _S_, sett fra individ _i_ — gjennomsnittet av residualene blant **alle andre** i samme kontor-år (leave-one-out). Vektoren **φ_i** = (φ_PDI,i, φ_VR1,i, ..., φ_VR4,i) har fem elementer. |
| **y_ki** | Utfall _k_ for individ _i_ (f.eks. arbeidsinntekt over 5 år, jobb år 1, PDI år 1). |
| **D_Si** | Faktisk behandlingsdummy: 1 hvis individ _i_ faktisk mottok behandling _S_ som første tiltak. Endogen i ligning 1, instrumenteres med φ_Si i IV-spesifikasjonen. |

### Sammenheng mellom symbolene — kort om ligning 1–6

Hele identifikasjonskjeden går gjennom seks ligninger. De fire i midten (2 → 3 → 4 → 5) er hjelpetrinn som lager instrumentet **φ_i**, mens ligning 1 og 6 er de to utfallsligningene som faktisk gir effektestimater (henholdsvis reduced form og IV).

| Ligning | Formel (skjematisk) | Hva er det? |
|---|---|---|
| **Ligning 1** (s. 13) | `y_ki = β_k·φ_i + x_i'δ_k + ε_ki` | **Reduced form-utfallsligning** — strategien φ settes direkte inn. β_k = totaleffekt av å være på et «aktivt» kontor (ITT-aktig). |
| **Ligning 2** (s. 15) | `P_Sijd = d'α + x_i'β + u_Sijd` | **LPM-hazard** i person-måned-format. Estimeres med OLS for å rense ut varighet og x. Det vi bryr oss om er residualen `û_Sijd`. |
| **Ligning 3** (s. 16) | `û_Si = Σ_{d=1}^{D_Si} û_Sijd` | **Sum av residualer per individ** — hver person bidrar én residual per risikomåned, vi legger dem sammen. Tolkes som «kovariatjustert overgangstilbøyelighet på klientnivå»: positiv hvis personen gikk over raskere enn x skulle tilsi, negativ ellers. På tvers av alle individer er snittet 0 by construction. |
| **Ligning 4** (s. 16) | `φ_Sj = (1/N_j) · Σ_{i ∈ j} û_Si` | **Naivt miljømål** — snitt av residualsummene over alle N_j klienter i kontor-år _j_. Dette ville vært en god proxy for kontorets strategi, men kan ikke brukes direkte fordi person _i_ selv inngår i snittet som senere brukes til å forklare _i_'s utfall. |
| **Ligning 5** (s. 16) | `φ_Si = (1/(N_j − 1)) · Σ_{i' ≠ i, i' ∈ j} û_Si'` | **Leave-one-out-versjonen (jackknife)** — samme som (4), men person _i_ er fjernet fra snittet. Hvert individ får sin egen φ_Si som er snittet av *alle andres* aggregerte residualer i samme kontor-år. |
| **Ligning 6** (s. 18) | `y_ki = Σ_S γ_kS·D_Si + x_i'δ_k + ε_ki`, med D instrumentert via φ | **IV-utfallsligning** — faktisk behandling D_Si på høyresiden, instrumentert med vektoren **φ_i** = (φ_VR1,i, …, φ_VR4,i, φ_PDI,i). γ_kS får LATE-tolkning for compliers. |

### Jackknife-metoden i én setning

Problemet ligning 5 løser: hvis person _i_'s egen behandlingshistorikk inngår i kontor-års-snittet som så skal forklare _i_'s utfall, oppstår en **mekanisk korrelasjon** mellom regressor og feilledd (cov(û_Si, ε_ki) ≠ 0 selv om sann effekt er null). Løsningen — kjent som **jackknife IV** (Angrist & Pischke 2009, kap. 4.6) — er å fjerne én observasjon om gangen: hvert individ får en versjon av φ som er beregnet uten dem selv. Forskjellene mellom individenes φ-verdier er minimale (1 av N_j klienter byttes ut), så instrumentet fanger fortsatt kontorets systematiske praksis, men er nå eksogent for personen det skal brukes på (gitt at x fanger residential sortering — se neste avsnitt).

### Konkret tolkning av P_Sijd

For individ _i_ = 47, kontor-år _j_ = «Kontor A, 2002», tilstand _S_ = VR1:

- Hvis person 47 starter VR1 i måned 3 → person 47 bidrar med 3 rader: P_VR1,47,j,1 = 0, P_VR1,47,j,2 = 0, **P_VR1,47,j,3 = 1**, og forsvinner deretter ut av risikosettet for VR1.
- Hvis person 47 aldri får VR1 → 24 rader, alle med P_VR1 = 0 (høyresensurert).
- Hvis person 47 starter VR3 i måned 5 → 5 rader for VR1-ligningen (alle 0, censurert ved overgang til konkurrerende risiko), og 5 rader for VR3-ligningen der den siste har P_VR3 = 1.

Hver av de fem S-tilstandene har sitt eget person-måned-datasett og sin egen LPM, der `u_Sijd` deretter brukes til å lage `φ_Si`.

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

**I R — ligning 5 i én mutate:**

```r
df_resid <- df_resid |>
    group_by(office_id) |>
    mutate(
        n_office   = n(),
        sum_office = sum(u_sum),
        Z_vr1 = (sum_office - u_sum) / (n_office - 1)  # alle andres gjennomsnitt
    ) |>
    ungroup()
```

- `sum_office` = summen av alle residualsummer på kontoret
- `sum_office - u_sum` = fjern person i sin egen residualsum
- Del på `n_office - 1` = gjennomsnitt av alle *andre*

### Viktig: rik x er nødvendig for identifikasjon (s. 18)

Instrumentet Z er kun eksogent **betinget på x**. Hvis kontor med høy VR1-tilbøyelighet også systematisk har klienter med dårligere jobbmuligheter — *etter* at x er kontrollert for — bryter identifikasjonen sammen. Altså: folk sorterer seg geografisk (bosted → kontor), og den sorteringen kan korrelere med utfall. En rik x som fanger opp denne bostedssorteringen er det som gjør instrumentet troverdig.

Derfor bruker artikkelen dummyer (ikke-parametrisk) for alder, utdanning, inntekt og trygd, pluss lokale sosioøkonomiske variabler og konjunkturkontroller. Jo mer x fanger opp, jo mer troverdig er antakelsen om at tilordning til kontor er «som tilfeldig» betinget på x.

### Seksjon 4: Predikerer instrumentet faktisk behandling? (tabell 2)

Seksjon 4 er i praksis **relevanstesten** for instrumentet — viser at φ faktisk predikerer behandling. Svarer på: «har kontorpraksis reell betydning for hvem som får hva?»

**To ting testes:**

1. **Diagonalen i tabell 2:** φ_VR1 predikerer VR1-overgang, φ_VR2 predikerer VR2, osv. Alle diagonalelementer er sterkt signifikante (***). Et kontor med høy VR1-tilbøyelighet sender faktisk flere til VR1 — instrumentet «virker».

2. **Andel forklart varians (nederst i tabellen):** Hvor mye av variasjonen i predikerte overgangssannsynligheter som forklares av φ alene:
   - VR1: 12.5 %
   - VR2: 29.6 %
   - VR3: 5.0 % (svakest)
   - VR4: 48.8 % (sterkest)
   - PDI: 5.5 %

   Individkjennetegn (x, d) forklarer mest, men kontorpraksis er langt fra ubetydelig.

**Interessant funn:** Høy PDI-tilbøyelighet øker overgang til *alle* VR-programmer. Tolkning: kontor med høy PDI-intensitet har generelt raskere saksbehandling → sender folk raskere videre til arbeidskontor også.

**For datasimuleringen:** Tabell 2 gir konkrete koeffisienter for hvor sterkt kontorstrategi påvirker behandlingsplassering. Disse brukes til å kalibrere den simulerte sammenhengen mellom φ og faktisk behandling.

### Referanse: Jackknife IV[^1]

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

## Simulering av competing risks med geometrisk fordeling (økt 2026-04-09)

Hendelsestidspunkt for VR1/VR2 simuleres med `rgeom(n, prob)` — antall *mislykkede forsøk* (måneder uten hendelse) før første suksess (overgang til behandling).

Nøkkelen er at `prob` er en **vektor** — hver person har sin egen månedlige hazard:

```r
rgeom(10, head(df_person$h_vr1, 10))
# Eks: c(45, 120, 8, 200, 3, ...)
```

Person med høy `h_vr1` (f.eks. 0.014 på kontor A med z1=0.012) får typisk lavt tall (rask overgang), mens person med lav `h_vr1` (f.eks. 0.004 på kontor B med z1=0.002) får typisk høyt tall (sen eller ingen overgang). Slik fanges kontorkulturens effekt på *hvem* som overføres.

`rgeom` gir 0 ved suksess på første forsøk, men vi vil at måned 1 er tidligste hendelse, derav `+ 1L`.

**Competing risks:** For hver person trekkes potensielle tidspunkt for *både* VR1 og VR2. Den tidligste hendelsen vinner (`pmin`), resten sensureres. Hvis ingen inntreffer innen 24 måneder → right-censored.

Denne tilnærmingen er vesentlig riktigere enn å pre-tildele behandlingstype og deretter trekke tidspunkt — fordi residualene fra ligning 2 da fanger kontorets tilbøyelighet til å *sende folk til* en gitt behandling, ikke bare *når* en allerede tildelt behandling skjer.

---

## Neste steg

1. Dummy-kod individvariabler + tidsdummyer i dataskriptet
2. Legg til VR3, VR4, PDI → full 5×5 tabell 2
3. Sann behandlingseffekt (β), OLS vs. IV
4. Reduced form (tabell 3)

---

[^1]: Angrist, J. D. & Pischke, J.-S. (2009). *Mostly Harmless Econometrics: An Empiricist's Companion.* Princeton University Press, kap. 4.6 (jackknife IV, leave-one-out). [Forlag](https://press.princeton.edu/books/paperback/9780691120355/mostly-harmless-econometrics)
