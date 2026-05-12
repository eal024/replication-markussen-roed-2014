# 2026-05-12 — Basisreplikasjon og opprydding

## Hva ble gjort

### Basisreplikasjon (2026-05-12_replikasjon_basis.R)

Egen fra-bunnen-replikasjon av M&R-strategien skrevet stegvis i denne økten:

- **Narrativ-blokk** øverst: ability-fortelling der `w` driver både VR-seleksjon (`delta_w·w` i hazard) og y direkte (`lambda_w·w` i utfallsligningen). Sann utfallslikning oppgis og kontrasteres mot "det forskeren ser".
- **Parametre samlet på topp** (etter set.seed) — gjør skriptet kjørbart fra topp til bunn i ny R-sesjon.
- **Kalibrering**: `h_base = 0.01`, `sigma_z = 0.010`, `delta_w = 0.005`, `lambda_w = 50`, `beta_true = 30`, `rho_ws = 0.4`. Gir ~30 % behandlet over 24 mnd og synlig OLS-bias.
- **DGP-blokk**: `df_office`, `df_person` (med w korrelert med skolegang via standardisert-skole + uavhengig støy), hazard via `pmax(...,1e-6)`, geometric overgangs-tid, sensurering ved 24 mnd.
- **Sanity-blokk**: `share_treated`, `share_clipped`, `median_h`.
- **Instrumentkonstruksjon** trinn for trinn:
    - Ligning 2: `lm(P ~ factor(d) + female + year_school)` på person-måned-data
    - Ligning 3: `summarise(u_sji = sum(u), .by = c(id, office_id))`
    - Ligning 4: naïv kontor-snitt `phi_sj = mean(u_sji)`
    - Ligning 5: jackknife `phi_si_j = (N_j*phi_sj - u_sji)/(N_j - 1)`
- **Diagnose-blokk**: cor(phi_sj, z_office), cor(phi_jack, z_office), cor(phi_*, w). Bekreftet ~0.93 relevans og ~0 eksogenitet.
- **Y-simulering** og fire modeller estimert:
    - `model_true`: y ~ P + x + w (sann modell, baseline)
    - `model_observert`: y ~ P + x (OLS, biased)
    - `model_iv`: y ~ p_hat + x (manuelt 2SLS)
    - `model_rf`: y ~ phi_si_j + x (reduced form)
- **ivreg** lagt til som korrekte-SE-versjon.

### Opprydding av scripts/R/

- Renavnet `2026-05-11 tidsdimensjon.R` → `2026-05-12_replikasjon_basis.R`
- Flyttet 7 filer til `arv/`:
    - 2026-04-10_iv_fire_endogene.R
    - 2026-04-10_simuler_utfall_data.R
    - 2026-04-30_dgp_bias_minimal.R
    - 2026-05-02_figur_iv_sammenligning.R
    - 2026-05-08_iv_jackknife_minimal.R
    - 2026-05-11_iv_jackknife_minimal_med_tid.R (redundant kopi)
    - sjekk.R
- Aktive skript i scripts/R/ nå: 3 stk (01_simuler_data, fasit-tidsdim, basisreplikasjon)
- README.md og CLAUDE.md oppdatert med ny aktiv-liste og arkiv-tabell

## Pedagogiske avklaringer i økten

- **Notasjon**: avklart at M&R bruker `P` på to nivåer (person-måned P_Sid og personnivå P_Si — vektor). Vår `D`/`P` i koden tilsvarer personnivå.
- **Likning 6** korrigert: inneholder også `τ·φ_PDI` som **direkte regressor**, ikke instrument — institusjonell begrunnelse (PDI på 430 kontor vs VR på 152 kontor). I vår basis-versjon dropper vi PDI bevisst.
- **Kalibrering av hazard**: tabell h → andel behandlet ble lagt inn i skriptet som referanse. Formel `h = 1 - (1 - andel)^(1/T)`.
- **Bias-formel**: `bias = lambda_w · cov(P, w | x) / var(P | x)`. Brukt til å justere `lambda_w` opp fra 10 til 50 for synlig bias.

## Filer endret/opprettet

- `scripts/R/2026-05-12_replikasjon_basis.R` (renamed + utvidet med forklaringer underveis i økten — flere edit-runder med rikere kommentarblokker)
- `scripts/R/arv/` (7 nye filer flyttet inn)
- `CLAUDE.md` (Skript-oversikt oppdatert med tabell over arv)
- `README.md` (filstruktur + arkiv-tabell + status)
- `log/2026-05-12_basisreplikasjon_og_opprydding.md` (denne fila)

## Til neste økt

- **Utvidelse til to tiltak** (S ∈ {VR1, VR2}) som bro mot full M&R-replikasjon
- **Klyngestandardfeil** på kontornivå (M&R klynger på kontor × år)
- **Flere kovariater**: alder, regional ledighet, tidligere inntekt
- **Pedagogisk tabell over modellene** (kort tolkning av hver kolonne i stargazer-outputen)
- **Eventuelt: ekstrahere kalibrerings-tabellen til eget forklarings-skript** (idé fra tidligere økt)
