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

## Neste steg

1. Legg til tidsdummyer og dummy-koding av individvariabler i simulerte data
2. Implementer varighetsmodell (ligning 2) i R — person-måned-format
3. Konstruer residualbasert instrument (ligning 3–5)
4. Test reduced form (ligning 1) med simulerte data
