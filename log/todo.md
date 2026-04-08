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

## Neste økt (prioritert rekkefølge)

- [ ] Tidsdummyer (inngangsmåned) — trivielt, nødvendig
- [ ] Dummy-koding av individvariabler (alder, utdanning, inntekt, trygd) — ikke-parametrisk som i artikkelen
- [ ] Sann behandlingseffekt (β): la utfall avhenge av behandling med kjent effekt
- [ ] OLS-estimering (biased) vs. IV-estimering — sjekk at IV gjenfinner β
- [ ] Varighetsmodell (lineær diskret) for residualbasert instrument (ligning 2) — person-måned-format
- [ ] Konstruer residualbasert instrument (ligning 3–5) med leave-one-out
- [ ] Reduced form-estimering (tabell 3)
- [ ] Utvide fra binær (VR/ikke) til flerverdi (VR1–VR4)
- [ ] Utvide fra 4 til 152 kontor
- [ ] Regional ledighetsrate som proxy for konjunkturkontroller
- [ ] Lokale sosioøkonomiske variabler (robusthetssjekk)
- [ ] Vurdere oppskrift_replikasjon_data.md som Claude Code skill
