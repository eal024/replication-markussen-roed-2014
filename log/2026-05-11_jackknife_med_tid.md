# 2026-05-11 — Jackknife med tidsdimensjon (videreføring av 2026-05-08)

## Bakgrunn

Brukeren leste gjennom `2026-05-08_iv_jackknife_minimal.R` og oppdaget
en svakhet: skriptet behandler D som en kontinuerlig "intensitet" og
hopper helt over person-måned-laget. Det er pedagogisk misvisende —
hele M&R-konstruksjonen hviler på ligning 2 estimert på person-måned-
data, residualer summert per person, og deretter jackknife over kontor.

Beslutning: lag et nytt skript som tar tidsdimensjonen seriøst, holder
seg til ett tiltak, og bruker M&R-notasjonen direkte.

## Hva ble gjort

### Nytt skript — `2026-05-08_iv_jackknife_med_tid.R`

Komplett kjede ligning 2 → 3 → 4/5 isolert til ett tiltak (S = VR1) og
50 kontor à 30 personer. Notasjon strikt M&R:

- `i, j, d, S` — indekser
- `P_id` — hendelsesindikator (= 1 i overgangs-måneden)
- `D_vr1` — personnivå-deltakelsesdummy (ligning 6)
- `u_id` — residual fra ligning 2
- `u_sum` (≡ u_Si) — sum over måneder (ligning 3)
- `phi_naive` (ligning 4), `phi_jack` (ligning 5), `phi_truth` (fasit)

DGP-elementene:

- Hazard: `h_i = 0.010 + 0.002·female + 0.001·(year_school−10) + z_office + δ·η`
- Hendelse-tidspunkt: `t_i ~ Geom(h_i) + 1`, sensurert ved 24 mnd
- Y = β·D + x·γ + λ·η + ε, sann β = 30, λ = −50

Sentral kodeblokk (`uncount` ekspanderer rundt sluttdatoen for hver person):

```r
df_pm <- df_person |>
    mutate(last_month = if_else(is.na(d_vr1), max_months, d_vr1)) |>
    uncount(last_month, .id = "d") |>
    mutate(P = as.integer(D_vr1 == 1L & d == d_vr1))

mod_lig2 <- lm(P ~ factor(d) + female + year_school, data = df_pm)
df_pm    <- df_pm |> mutate(u = resid(mod_lig2))

df_resid <- df_pm |>
    summarise(u_sum = sum(u), .by = c(id, office_id)) |>
    mutate(
        phi_naive = sum(u_sum) / n(),
        phi_jack  = (sum(u_sum) - u_sum) / (n() - 1),
        .by = office_id
    )
```

### Resultater

Sanitet:

```
share_treated = 0.269   (27 % får VR1 innen 24 mnd — rimelig)
mean(u_sum)   = 0       (residual-egenskap, sjekker at ligning 2 er OLS)
sd(u_sum)     = 0.515
```

Diagnose-korrelasjoner (én run, derfor utvalgsstøy):

```
cor_truth_eta  -0.042
cor_naive_eta  -0.028   ← litt mindre negativ enn jack
cor_jack_eta   -0.033   ← jackknife fjerner egen-bidraget
cor_naive_D     0.535   ← stor relevans (men inneholder egen u_Si)
cor_jack_D      0.489   ← litt svakere relevans, men eksogent
```

Det interessante pedagogiske poenget: `phi_naive` ser sterkere ut som
instrument enn `phi_jack`, fordi personens egen `u_Si` smugles inn i
snittet. Det er nettopp den endogene komponenten vi vil bli kvitt.

IV-tabell (sann β = 30):

```
                OLS    IV truth    IV naiv    IV jack
              20.57      33.92      30.09      31.29
              (3.45)    (6.78)     (6.49)     (7.11)
```

OLS klart biased nedover. Alle tre IV-versjonene lander rundt 30 — som
ventet. Forskjellen mellom naïv og jack er liten ved N_j = 30, fordi
1/N_j-biasen er liten. 1/N_j-mønsteret er allerede demonstrert i
Monte Carlo-bonusen i `2026-05-08_iv_jackknife_minimal.R`.

## Pedagogiske valg

- **Holdt notasjonen strikt M&R** — brukeren ba om det
- **Kun ett tiltak (S = VR1)** — unngår multi-endogen-kompleksiteten,
  fokuset er på selve konstruksjonen
- **Fokus på "første del"** — ligning 2 → 3 → 4/5. IV-tabellen er kort
  sanity check, ikke hovedsalgspunktet.
- **Beholder phi_truth (sann z_office)** som fasit — pedagogisk verdifullt,
  selv om det ikke er observerbart i ekte data

## Spørsmål til neste økt

1. Skal IV-tabellen kuttes helt i dette skriptet? (Fokus på konstruksjon
   alene — IV-eksperimentet sitter allerede i `iv_jackknife_minimal.R`.)
2. Er det interesse for en utvidelse til to tiltak (S ∈ {VR1, VR2}) som
   bro til det fulle 5-behandlingsskriptet?
3. Hva med klyngestandardfeil på kontornivå?
4. Skal vi koble inn varighetsdummyer som faktor explicit, eller skifte
   til et mer kompakt baseline-hazard-design?

## Filer endret/opprettet

- `scripts/R/2026-05-08_iv_jackknife_med_tid.R` (ny)
- `log/2026-05-11_jackknife_med_tid.md` (ny — denne fila)
- `log/todo.md` (2b+ delvis krysset av; nye punkter notert)
- `CLAUDE.md` (Tilstand nå + skript-oversikt)
- `README.md` (filstruktur + status)
