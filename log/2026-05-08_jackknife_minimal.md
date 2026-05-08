# 2026-05-08 — Pedagogisk minimal-IV: jackknife (todo 2b)

## Hva ble gjort

Lagt til frittstående mini-skript som viser ligning 5 i M&R (jackknife / leave-
one-out) i den enkleste mulige settingen. Bygget videre på
`2026-04-10_iv_to_endogene.R`, men erstattet det «himmelfallende» phi_k med
en eksplisitt konstruksjon fra observerte D-er.

### Skript — `2026-05-08_iv_jackknife_minimal.R`

Liten DGP med 50 kontor à 10 personer:

- Hvert kontor j får en sann kultur `z_office_j ~ N(0, 1)`
- Hver person har η_i som inngår i BÅDE D og Y → endogenitetskanal
- D = α + z_office + δ·η + x + støy  (δ = 0.5)
- Y = β·D + λ·η + x + støy           (β = 30, λ = −50)

Tre versjoner av instrumentet konstrueres side om side:

| Versjon | Formel | Status |
|---|---|---|
| `phi_truth` | z_office (sann kultur) | Fasit, ikke-observerbar i ekte data |
| `phi_naive` | (1/N_j) · Σ_k D_k | Ligning 4 hos M&R |
| `phi_jack`  | Σ_{k ≠ i} D_k / (N_j − 1) | Ligning 5 hos M&R |

Hovedpoenget er at `phi_naive` har en mekanisk korrelasjon med personens egen
η fordi D_i selv er med i snittet. Jackknife fjerner akkurat dette leddet.

### Resultater — én run

Diagnose-tabell:

```
cor_truth_eta   cor_naive_eta   cor_jack_eta   cor_naive_D   cor_jack_D
   0.004           0.055           0.012          0.853         0.815
```

`phi_naive` er målbart korrelert med egen η; `phi_jack` ligger nær null.
Relevansen mot D er praktisk talt uendret (0.85 → 0.82).

IV-tabell (sann β = 30):

```
              OLS    IV truth    IV naiv    IV jack
              14.2     28.6        26.5       28.5
```

OLS er kraftig biased nedover (λ_η < 0). IV med naiv-instrumentet er ~2 enheter
mer biased enn jack, fordi den endogene 1/N_j-komponenten i `phi_naive` smitter
inn i 2SLS-koeffisienten.

### Monte Carlo — 1/N_j-skala

100 replikasjoner per kontorstørrelse. Bias = E[β̂] − 30:

```
n_per_off   bias_naive   bias_jack
    5         −3.71         0.10
   10         −2.13        −0.14
   25         −0.38         0.45
  100         −0.21        −0.00
```

`bias_naive` avtar mot 0 omtrent som 1/N_j (forventet matematisk).
`bias_jack` ligger sentrert på 0 hele veien — uavhengig av N_j. Dette
illustrerer hvorfor M&R-jackknife er matematisk korrekt selv når kontorene
er små; ved store N_j blir forskjellen praktisk talt umerkelig.

## Pedagogiske valg

- **Jackknifer D direkte, ikke residualer fra ligning 2.** Fokuset er
  selve leave-one-out-mekanikken; residualiseringen ligger allerede
  dokumentert i `2026-04-10_simuler_utfall_data.R` steg 7–9.
- **`lm` + manuell 2SLS** istedenfor `feols`/`ivreg` — alle steg synlige,
  konsistent med `iv_minimal.R` og `iv_to_endogene.R`.
- **Liten kontorstørrelse (N_j = 10)** i hoveddemoen for å gjøre biasen
  synlig i én run. Realistisk for M&R er N_j mye større.

## Ting som ikke ble gjort i økten

- Klyngestandardfeil på `office_id` (relevant fordi instrumentet er definert
  på kontornivå)
- Jackknife på *residualer* fra en x-rensing — ville knyttet eksplisitt
  til M&R sin ligning 2 → 3 → 4 → 5-kjede
- Koble til `iv_to_endogene.R` ved å lage to jackknifede instrumenter
  for to behandlinger

## Filer endret/opprettet

- `scripts/R/2026-05-08_iv_jackknife_minimal.R` (ny)
- `log/2026-05-08_jackknife_minimal.md` (ny — denne fila)
- `log/todo.md` (todo 2b krysset av)
- `CLAUDE.md` (Tilstand nå + skriptoversikt oppdatert)
- `README.md` (status oppdatert)
