# TODO

## Gjort

- [x] Kopiert artikkelnotater fra research-project til `notes/markussen_roed_2014/`
- [x] Gjennomgang av artikkel: RF vs. IV, leave-one-out, hovedfunn, institusjonell setting
- [x] Simulert datasett som replikerer tabell 1 (deskriptiv statistikk, 5 grupper)
- [x] Lesenotater i `log/2026-03-27_notes_go_through_reading.md`
- [x] Opprettet CLAUDE.md (lokal) og global `~/.claude/CLAUDE.md` med arbeidsregler
- [x] Opprettet `notes/oppskrift_replikasjon_data.md` — generell oppskrift for replikasjon (fremtidig skill)
- [x] Lagt til forelesningsnotater om IV/LATE (`econ5106_L08_late (3).pdf`)
- [x] Lagt til post-TDI inntektsvariabler (`labor_earn_post`, `transfer_post`)
- [x] Splittet kode: `01_simuler_data.R` (data) og `02_iv_instrument.R` (IV)
- [x] Opprettet 4 kontor med ulik behandlingsstrategi og leave-one-out instrument
- [x] Oppdatert kode til å følge `~/.claude/r_kodestil.md` (4 mellomrom, here::here, kommentarstil)

- [x] Gjennomgang av empirisk strategi: ligning 2–5, varighetsmodell, instrumentkonstruksjon
- [x] Person-måned-data med right-censoring og kontorkultur (z1, z2)
- [x] Estimert ligning 2 (LPM), residualer, leave-one-out-instrument (Z_vr1)
- [x] Verifisert at Z_vr1 predikerer VR1-overgang (tabell 2-replikasjon, signifikant)
- [x] Utvidet til to behandlinger (VR1, VR2) med kontorspesifikk tildelingsandel
- [x] Utvidet hazard-simuleringen til alle 5 behandlinger (VR1–VR4, PDI) + tabell 2 (5×5)
- [x] Lagt inn uobservert heterogenitet η og sann β i utfallsligningen
- [x] Lagret persondatasett med D, Y, Z (`data/iv_replikasjon.rds`)
- [x] Reduced form, naiv OLS og 2SLS — IV gjenfinner sann β for VR1, VR2, PDI
- [x] Førstesteg-F (70–188) bekrefter instrumentets relevans

## Neste økt (prioritert rekkefølge)

### Åpne diagnostikk-spørsmål (fra 2026-04-10-økten)
- [ ] **PDI-spillover snur fortegn:** vår DGP gir negative Z_PDI → D_VR pga. competing risks. Heve `pdi_spillover` til 0.3–0.5, eller modellere kontorets saksbehandlingstempo separat fra behandlingsmiks
- [ ] **VR3 dominerer competing risks:** vurder å redusere z_vr3-spennet eller innføre variabelt tidsbudsjett (ikke fast 24 mnd) for å dempe nullsum-logikken
- [ ] **Inntektsnivå er ~2× artikkelen:** kalibrere α_y nedover hvis vi vil ha full tabell 1-match

### Forbedre simulering / robusthet
- [ ] Forstå hvorfor IV gir svakest gjenfinning for VR4 (instrumentet har minst spenn der)
- [ ] Øk antall kontor (10 → 50+) for å se hvordan det påvirker presisjonen
- [ ] Legg til mer x-variasjon (alder, utdanning som dummyer, inntekt-trinn)
- [ ] Klyngestandardfeil på kontornivå (`vcov = ~office_id`)
- [ ] Berike datasettet med alder + innvandrer + tidligere inntekt for full tabell 1-sammenligning

### Forbedre datasimulering
- [ ] Tidsdummyer (inngangsmåned)
- [ ] Dummy-koding av individvariabler — ikke-parametrisk som i artikkelen
- [ ] Regional ledighetsrate som proxy for konjunkturkontroller

### Forbedre datasimulering
- [ ] Tidsdummyer (inngangsmåned)
- [ ] Dummy-koding av individvariabler — ikke-parametrisk som i artikkelen
- [ ] Utvide fra 4 til flere kontor
- [ ] Regional ledighetsrate som proxy for konjunkturkontroller

### Senere
- [ ] Lokale sosioøkonomiske variabler (robusthetssjekk)
- [ ] Vurdere oppskrift_replikasjon_data.md som Claude Code skill
