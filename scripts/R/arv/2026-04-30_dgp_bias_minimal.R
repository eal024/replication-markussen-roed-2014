# DGP for IV-replikasjon — Markussen & Røed (2014), likning 6
#
# Pedagogisk DGP som demonstrerer at OLS underestimerer kausal effekt
# av VR-behandling fordi uobservert helse styrer både seleksjon og utfall.
# Kontor-kultur som instrument gjenfinner sann β via 2SLS.
#
# DAG:
#       helse ───────→ vr ───────→ y
#         │                         ↑
#         └─────────────────────────┘   helse → y direkte (λ)
#
#       kontor (kultur) ──→ vr          ingen direkte pil til y
#                                       → eksklusjonsantakelsen
#
# Se notes/markussen_roed_2014/identifikasjonsstrategi.md for kalibrering
# mot artikkelens Tabell 1, 2 og 4.


# 1. Pakker og innstillinger ----------------------------------------------

library(tidyverse)
library(fixest)
set.seed(123)


# 2. Kontor-kultur — kilden til instrumentvariasjonen ---------------------
# Hvert kontor får sin egen behandlingskultur: en sannsynlighetsvektor
# over (vr0..vr4) som summerer til 1. Trekkes via gamma-trikset:
#     X_k ~ Gamma(α_k, 1) uavhengig  →  p_k = X_k / Σ X_k er Dirichlet(α).
# α = prob_snitt × konsentrasjon. prob_snitt fra Tabell 1; konsentrasjon
# styrer hvor like kontorene er (høy = like, lav = ulike kulturer).

n             <- 50000
n_kontor      <- 50
prob_snitt    <- c(176, 38, 19, 92, 18) / 343
konsentrasjon <- 50

g <- matrix(
    data  = rgamma(n_kontor*5, shape = prob_snitt*konsentrasjon, rate = 1),
    nrow  = n_kontor,
    ncol  = 5,
    byrow = TRUE
)

kultur <- g / rowSums(g)


# 3. Personer — random assignment + uobservert helse ----------------------
# Hver person tildeles ETT kontor uavhengig av egne kjennetegn. Det er
# denne uavhengigheten — kontor ⊥ helse — som senere gjør instrumentet
# eksogent. Helse er uobservert i estimeringsmodellen; vi bygger den
# inn i DGP-en for å demonstrere skjevheten.

kontor <- sample(1:n_kontor, size = n, replace = TRUE)
helse  <- rnorm(n, mean = 0, sd = 1)
kvinne <- rbinom(n, size = 1, prob = 0.5)


# 4. VR-behandling — funksjon av kultur, helse og kvinne ------------------
# Sannsynligheten for VR_k er kontorets kultur skalert med eksponentielle
# justeringer for individuelle egenskaper. Logikk:
#   - sykere (helse > 0) havner oftere i VR2/VR4, sjeldnere i VR1/VR3
#   - kvinner havner litt oftere i VR2/VR4 (Tabell 1: kjønnsforskjeller)
# helse er KILDEN til endogenitet (uobservert); kvinne er observert
# kontroll og inngår derfor i alle senere regresjoner.

helse_load  <- c(0, -0.3,  0.6, -0.2, 0.4)   # vr0..vr4
kvinne_load <- c(0,  0.0,  0.3,  0.0, 0.2)

vr_draw <- pmap_int(
    .l = list(kontor, helse, kvinne),
    .f = \(k, h, j) {
        p <- kultur[k, ] * exp(helse_load*h + kvinne_load*j)
        sample(0:4, size = 1, prob = p)
    }
)


# 5. Bygg datasett ---------------------------------------------------------
# Wide format: én rad per person, med dummyer vr0..vr4. Helse og kvinne
# beholdes som kolonner (helse "uobservert" i regresjonsforstand, men vi
# trenger den for oraklet og diagnostikken).

df <- tibble(fk = 1:n, kontor, helse, kvinne, vr_draw) |>
    mutate(value = 1) |>
    pivot_wider(names_from = vr_draw, values_from = value, values_fill = 0) |>
    select(fk, kontor, helse, kvinne,
           vr0 = `0`, vr1 = `1`, vr2 = `2`, vr3 = `3`, vr4 = `4`)


# 6. Alder — Tabell 1: behandlede er yngre --------------------------------
# Ubehandlet ankret på 42 år; behandlede 35–38 (per Tabell 1). Sd = 10.

df$age <- 42 -
    (42 - 37)*df$vr1 - (42 - 38)*df$vr2 -
    (42 - 35)*df$vr3 - (42 - 37)*df$vr4 +
    rnorm(n, mean = 0, sd = 10)


# 7. Utfall — likning 6 ---------------------------------------------------
#   y = α + Σ β_k·vr_k + γ·age + λ·helse + θ·kvinne + ε
# β fra Tabell 4 (sanne IV-estimater i 1000 NOK). λ < 0: dårlig helse
# senker inntekt. θ < 0: kjønnsgap. Kontor (kultur) inngår IKKE i y —
# det er eksklusjonsantakelsen som låser opp IV-en.

beta      <- c(VR1 = 57, VR2 = -46, VR3 = 59, VR4 = -48)
alpha     <-  163
gamma_age <-    0.5
lambda    <-  -50
theta_kv  <-   -8
sigma_eps <-   40

df$y <- alpha +
    beta["VR1"]*df$vr1 + beta["VR2"]*df$vr2 +
    beta["VR3"]*df$vr3 + beta["VR4"]*df$vr4 +
    gamma_age*df$age +
    lambda*df$helse +
    theta_kv*df$kvinne +
    rnorm(n, mean = 0, sd = sigma_eps)


# 8. Instrument — leave-one-out kontorrate --------------------------------
# Z_k for person i = andelen *andre* på kontor o som fikk VR_k. Empirisk
# proxy for kultur som forskeren faktisk kan beregne fra registerdata
# (kultur-matrisen er uobservert i ekte data). Leave-one-out unngår
# mekanisk selvkorrelasjon mellom Z og personens egen vr.

df <- df |>
    group_by(kontor) |>
    mutate(
        z1 = (sum(vr1) - vr1) / (n() - 1),
        z2 = (sum(vr2) - vr2) / (n() - 1),
        z3 = (sum(vr3) - vr3) / (n() - 1),
        z4 = (sum(vr4) - vr4) / (n() - 1)
    ) |>
    ungroup()


# 9. Estimering -----------------------------------------------------------
# Tre modeller for sammenligning:
#   - lm_true:  oraklet (med helse)         → forventet ≈ sann β
#   - endogen:  klassisk OLS (uten helse)   → skjev (helse-bias)
#   - 2SLS:     instrumenterer vr med Z     → forventet ≈ sann β
# Manuell 2SLS via predict() viser mekanikken; feols brukes til slutt
# for korrekte standardfeil.

lm_true <- lm(y ~ age + kvinne + helse + vr1 + vr2 + vr3 + vr4, data = df)
endogen <- lm(y ~ age + kvinne         + vr1 + vr2 + vr3 + vr4, data = df)

# Førstesteg — Tabell 2 i artikkelen: instrumentets relevans
fs_vr1 <- lm(vr1 ~ age + kvinne + z1 + z2 + z3 + z4, data = df)
fs_vr2 <- lm(vr2 ~ age + kvinne + z1 + z2 + z3 + z4, data = df)
fs_vr3 <- lm(vr3 ~ age + kvinne + z1 + z2 + z3 + z4, data = df)
fs_vr4 <- lm(vr4 ~ age + kvinne + z1 + z2 + z3 + z4, data = df)

df$vr1_hat <- predict(fs_vr1)
df$vr2_hat <- predict(fs_vr2)
df$vr3_hat <- predict(fs_vr3)
df$vr4_hat <- predict(fs_vr4)

model_2sls <- lm(
    y ~ age + kvinne + vr1_hat + vr2_hat + vr3_hat + vr4_hat,
    data = df
)

# Robusthet: feols-versjon med korrekte IV-standardfeil
model_iv <- feols(
    y ~ age + kvinne | vr1 + vr2 + vr3 + vr4 ~ z1 + z2 + z3 + z4,
    data = df
)

stargazer::stargazer(
    list("Oracle" = lm_true, "Endogen" = endogen, "2SLS" = model_2sls),
    type = "text"
)


# 10. Diagnostiske sjekker ------------------------------------------------
# Fire antakelser å verifisere — hver svarer til én pil i DAG-en.

# (a) Random assignment: kontor uavhengig av helse → cor ≈ 0
cat("\n(a) cor(kontor, helse) ≈ 0:                      ",
    round(cor(df$kontor, df$helse), 4), "\n")

# (b) Endogenitet: helse korrelert med vr → bias-kilde
cat("(b) cor(helse, vr2)  > 0  (sykere → vr2):        ",
    round(cor(df$helse, df$vr2), 4), "\n")
cat("    cor(helse, vr1)  < 0  (sykere unngår vr1):   ",
    round(cor(df$helse, df$vr1), 4), "\n\n")

# (c) Eksklusjon (mekanisk): Z mister forklaring når vr inkluderes
cat("(c) Eksklusjon — Z forklarer y kun via vr:\n")
sjekk_vr  <- lm(y ~ vr1 + vr2 + vr3 + vr4, data = df)
sjekk_z   <- lm(y ~ z1 + z2 + z3 + z4,    data = df)
sjekk_vrz <- lm(y ~ vr1 + vr2 + vr3 + vr4 + z1 + z2 + z3 + z4, data = df)
stargazer::stargazer(
    list("y~vr" = sjekk_vr, "y~z" = sjekk_z, "y~vr+z" = sjekk_vrz),
    type = "text"
)

# (d) Relevans: førstesteg-F > 10 (helst > 50)
cat("\n(d) Førstesteg-F (relevans):\n")
print(fitstat(model_iv, ~ ivf, simplify = TRUE))


# 11. Tolkning ------------------------------------------------------------
#
# Hva DGP-en gjør:
#   1. 50 kontor får hver sin behandlingskultur fra Dirichlet (steg 2).
#   2. Personer tildeles tilfeldig til kontor + trekker uobservert helse
#      og observert kjønn (steg 3) — RANDOM ASSIGNMENT av kontor.
#   3. VR-behandling avhenger av kultur (eksogent), helse (endogent) og
#      kjønn (observert). Helse er kilden til OLS-skjevheten.
#   4. Utfall y avhenger av vr, age, helse og kjønn — IKKE av kontor.
#      Det er EKSKLUSJONSANTAKELSEN som gjør Z gyldig.
#
# Hvorfor IV virker:
#   - Random assignment   kontor ⊥ helse                    → Z eksogent
#   - Relevans            kultur driver vr (F ≈ 200)        → instrument bite
#   - Eksklusjon          kontor ikke i y-likningen         → Z kun via vr
#
# Resultat (seed 123, n = 50 000):
#   sann β:     57.0, -46.0, 59.0, -48.0
#   lm_true ≈   55.8, -45.9, 59.0, -49.3   ← oraklet treffer (kontrollerer helse)
#   endogen ≈   71.3, -74.4, 67.5, -68.2   ← skjev: helse uobservert
#   2SLS    ≈   50.6, -43.5, 67.5, -43.2   ← konsistent for sann β
#                                            (SE ≈ 7–12, alle innenfor 1 SE)
#
# Det er den kausale fortolkningen Markussen & Røed (2014) henter ut: ved
# å bruke kontorets behandlingskultur som instrument fjerner de seleksjons-
# skjevheten som ellers ville rammet en naiv OLS-sammenligning av VR-grupper.
# Vår simulerte replikasjon viser mekanikken eksplisitt: vi vet sannheten,
# vi ser at OLS bommer, og vi ser at IV treffer.
