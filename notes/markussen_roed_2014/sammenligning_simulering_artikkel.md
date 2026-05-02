# Sammenligning av simulering mot Markussen & Røed (2014)

> Notat skrevet 2026-05-02 etter at vi har bygd en pedagogisk DGP som
> demonstrerer IV-mekanismen i likning 6. Sammenligner punktestimater og
> standardfeil mot artikkelens Tabell 4 (kolonne II — Labor earnings).

---

## Hva er utfallet?

**Arbeidsinntekt** første kalenderår etter avsluttet TDI-spell, målt i
2013-NOK. β-koeffisientene måler effekt vs. ubehandlet (VR0).

Artikkelens N = 274 494. Vår simulering har n = 50 000.

---

## Punktestimater (1000 NOK)

| VR  | Sann β (kalibrert) | Artikkelen (Tabell 4) | Vår simulering | Avvik fra artikkelen |
|-----|--------------------|-----------------------|----------------|----------------------|
| VR1 | 57.0               | **56.7**              | 50.6           | −6.1                 |
| VR2 | −46.0              | **−45.7**             | −43.5          | +2.2                 |
| VR3 | 59.0               | **59.3**              | 67.5           | +8.2                 |
| VR4 | −48.0              | **−47.7**             | −43.2          | +4.5                 |

**Tolkning:** Punktestimatene treffer rimelig. VR1, VR2 og VR4 er
innenfor 5–6 enheter av artikkelen. VR3 er 8 over — innenfor sampling-
støy for én kjøring. Konseptuelt stemmer alt: fortegn, størrelsesorden,
og at IV-estimatet er klart skilt fra OLS-endogen i samme retning som
artikkelen rapporterer.

---

## Standardfeil (1000 NOK)

| VR  | Artikkelen (klyngestand. på kontor×år) | Vår (klyngestand. på kontor) | Vår / Artikkelen |
|-----|----------------------------------------|------------------------------|------------------|
| VR1 | 22.0                                   | 8.0                          | **0.36**         |
| VR2 | 19.7                                   | 7.2                          | **0.37**         |
| VR3 | 15.8                                   | 6.2                          | **0.39**         |
| VR4 | 24.6                                   | 7.3                          | **0.30**         |

Vår SE er ca. **1/3 av artikkelens** — på tross av at vi har **mindre**
utvalg (n = 50 000 vs. 274 494). Naivt skulle SE skalert som
√(274/50) ≈ 2.3× høyere, men den er 3× lavere.

**Implikasjon:** "Iboende støy per observasjon" i artikkelens data er
ca. **6.5× større** enn i vår simulering.

---

## Hvorfor er vår simulering mer presis?

| Faktor                | Vår simulering          | Artikkelen                                        |
|-----------------------|-------------------------|---------------------------------------------------|
| Residualstøy `σ_ε`    | 40                      | ukjent — antagelig 80–120                         |
| Andre kontroller      | kun `age`, `kvinne`     | full liste i Appendix (utdanning, innvandrer-     |
|                       |                         | status, tidsdummyer, regional ledighet, m.m.)     |
| Førstesteg-F          | 231 (svært sterkt)      | 28–65 ifølge Tabell 2 (moderat)                   |
| Funksjonsform         | ren lineær DGP          | målefeil, ikke-linearitet, klyngestruktur         |
| Heterogenitet         | kun `helse` + `kvinne`  | full populasjonsspredning + uobserverbare         |

En simulering er alltid en **renere verden** enn data. Vi vet nøyaktig
hvor `helse` slutter og `ε` begynner; i ekte data er alt sammenfiltret,
og IV må jobbe hardere for å rense ut signal fra støy.

---

## Pedagogisk konklusjon

- Vi gjenskaper artikkelens **mekanikk** korrekt: fortegn, størrelses-
  orden, og at IV korrigerer en OLS-skjevhet i samme retning og omtrent
  samme størrelse som i Tabell 4.
- Vi **kan ikke** gjenskape artikkelens **presisjonsnivå** uten å
  betydelig øke `σ_ε` og svekke instrumentet — fordi virkeligheten
  er rotete.
- Simuleringen er ment å **vise mekanismen, ikke kalibrere usikkerhet**.
  Til presisjonsanalyse i VLT-studien må vi kalibrere `σ` og
  instrumentstyrke mot virkelige data.

---

## Neste steg (roadmap, ikke kun én økt)

### 1. Variabler og data for VLT-analysen
Vurdere hvilke variabler vi må trekke ut fra registerdata for å gjennom-
føre den parallelle analysen i ph.d.-skissen.
- Behandlingsvariabel: deltakelse i varig lønnstilskudd (VLT)
- Utfall: arbeidsinntekt, sysselsetting, trygdeoverføringer
- Instrument: kontorets VLT-tildelingsrate (leave-one-out)
- Kontroller: alder, kjønn, utdanning, innvandrerstatus, tidligere
  inntekt, regional ledighet, tidsdummyer
- Datakilde: FD-Trygd, NUDB, registerdata fra NAV

### 2. Hvordan vår analyse skiller seg fra M&R (2014)
- **Behandling:** VLT er én ordning, ikke fire konkurrerende VR-typer →
  enklere identifikasjon, mindre multikollinearitet i instrumenter
- **Populasjon:** mottakere av varig lønnstilskudd, ikke TDI-mottakere
- **Tidsperiode:** annet observasjonsvindu (fastsettes)
- **Identifikasjon:** samme leave-one-out-strategi, men over kontor som
  varierer i bruksintensitet av VLT
- **Utfall:** sammenlignbart (post-program arbeidsinntekt), men også
  varighet i ordningen
- Notatet bør utdypes i egen fil: `notes/vlt_analyse_design.md`

### 3. Blogginnlegg som forklarer artikkelen
Pedagogisk innføring rettet mot ikke-økonomer.
- Tema: hvordan IV-strategien fungerer, og hvorfor kontor-kultur er et
  gyldig instrument
- Strukturforslag:
  1. Problemet: hvorfor er det vanskelig å måle effekten av tiltak?
  2. Den naive sammenligningen og hvorfor den feiler
  3. Markussen & Røeds geniale idé: tilfeldige kontorer
  4. Hva betyr resultatene?
- Fil: `notes/blogg_iv_for_ikke_okonomer.md` (utkast kommer)

### 4. Fortsette Z-konstruksjonen
Vi er nært å gjenskape artikkelens mekanikk. Forbedringer som gjenstår:
- Cluster-standardfeil på kontor×år (matche artikkelens spec)
- Tidsdummyer (variasjon over år)
- Hazard-laget (likning 2) som forløper for φ_k
- Placebo-tester (Tabell 6–7 i artikkelen): instrumentet skal være
  ukorrelert med pre-treatment-utfall
- Sammenligning mot Tabell 3 (reduced form) parallelt med Tabell 4 (IV)

---

## Kilder

- Markussen & Røed (2014), Tabell 4, side 25 — IV-estimater
- `scripts/R/2026-04-30_dgp_bias_minimal.R` — DGP og estimering
- `scripts/R/2026-05-02_figur_iv_sammenligning.R` — figurkode
- `output/iv_estimater_sammenligning.png` — sammenligningsfigur
