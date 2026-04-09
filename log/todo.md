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

## Neste økt (prioritert rekkefølge)

### Utvide hazard-simuleringen (`2026-04-09_replikasjon_hazard_event_data.R`)
- [ ] Legg til VR3, VR4 og PDI (z3, z4, z_pdi i office_culture)
- [ ] Estimer ligning 2 for alle 5 behandlinger → 5 sett residualer
- [ ] Konstruer leave-one-out-instrument for alle 5 (φ_VR1, ..., φ_PDI)
- [ ] Replikér full tabell 2 (5×5-matrise med krysseffekter)

### IV-estimering
- [ ] Legg inn sann behandlingseffekt (β) i utfallsligningen
- [ ] OLS vs. IV — sjekk at IV gjenfinner sann β
- [ ] Reduced form-estimering (tabell 3)

### Forbedre datasimulering
- [ ] Tidsdummyer (inngangsmåned)
- [ ] Dummy-koding av individvariabler — ikke-parametrisk som i artikkelen
- [ ] Utvide fra 4 til flere kontor
- [ ] Regional ledighetsrate som proxy for konjunkturkontroller

### Senere
- [ ] Lokale sosioøkonomiske variabler (robusthetssjekk)
- [ ] Vurdere oppskrift_replikasjon_data.md som Claude Code skill
