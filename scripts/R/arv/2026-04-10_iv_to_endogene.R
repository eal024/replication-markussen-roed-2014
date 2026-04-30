# Multi-endogen IV med to behandlinger — minimalt eksempel.
#
# Notasjon følger Markussen & Røed (2014):
#   P_k    endogen behandling (her kontinuerlig "intensitet")
#   φ_k    instrument — lokal behandlingsstrategi (jackknifet hos M&R)
#   y      utfall (post-TDI inntekt, 1 000 NOK)
#   x      kontroller (female, year_school)
#   β_k    sann behandlingseffekt
#   η      uobservert heterogenitet — kanal for OLS-skjevhet
#
# DGP er rent lineær: P er kontinuerlig, så hele 2SLS-mekanikken vises uten
# LPM-klipping eller multinomialt trekkemønster.
#
# Skriptet replikerer i miniformat tre av artikkelens hovedtabeller:
#   FS1, FS2  →  Tabell 2 (relevanstest, "førstesteget")
#   rf        →  Tabell 3 (reduced form: y direkte på φ)
#   ss        →  Tabell 4 (IV/2SLS: y på faktisk P, instrumentert med φ)
#
# Wald-sammenheng for én Z og én D:  β_IV = β_RF / β_FS
#
# Utvidelse til 4 VR-programmer er triviell: legg til phi_3, phi_4, P_3, P_4
# i tibble-en, ta med dem i fs/rf/ss-formlene, og 2SLS-mekanikken er
# eksakt den samme — bare med fire førstesteg i stedet for to.

library(tidyverse)
library(stargazer)

set.seed(20260410)

# 1. DGP -------------------------------------------------------------------

n      <- 5000
beta_1 <- 30      # sann effekt av P_1
beta_2 <- 50      # sann effekt av P_2

df <- tibble(
    eta         = rnorm(n),
    phi_1       = rnorm(n), #
    phi_2       = rnorm(n),
    female      = sample(0:1, n, replace = TRUE),
    year_school = sample(c(10, 13, 16, 18), n, replace = TRUE),
    # Førstestegene: P_k avhenger av sin egen φ_k, av η (endogenitet) og x
    P_1 = 0.5 * phi_1 + 0.3 * eta + 0.2 * female + 0.05 * (year_school - 10) + rnorm(n, 0, 0.5),
    P_2 = 0.5 * phi_2 + 0.3 * eta - 0.2 * female + 0.05 * (year_school - 10) + rnorm(n, 0, 0.5),
    # Utfallsligning — sann effekt β_1, β_2; η går negativt inn (skjevhet)
    y   = 250 + beta_1 * P_1 + beta_2 * P_2 - 25 * female + 15 * (year_school - 10) - 50 * eta + rnorm(n, 0, 30)
)

# 2. Estimering ------------------------------------------------------------

# Naiv OLS — biased fordi P er korrelert med η
ols <- lm(y ~ P_1 + P_2 + female + year_school, data = df)

# Førstesteg: hvert P på BEGGE φ + kontroller. Tilsvarer artikkelens TABELL 2
fs1 <- lm(P_1 ~ phi_1 + phi_2 + female + year_school, data = df)
fs2 <- lm(P_2 ~ phi_1 + phi_2 + female + year_school, data = df)

# Reduced form: y direkte på φ + kontroller. Tilsvarer artikkelens TABELL 3
rf <- lm(y ~ phi_1 + phi_2 + female + year_school, data = df)

# Andresteg i 2SLS: erstatt P med projeksjonene. Tilsvarer artikkelens TABELL 4
df$P_1_hat <- predict(fs1)
df$P_2_hat <- predict(fs2)
ss <- lm(y ~ P_1_hat + P_2_hat + female + year_school, data = df)

# 3. Resultat --------------------------------------------------------------

# Tabell 2 (M&R) — relevanstest / førstesteget
stargazer(fs1, fs2,
          type = "text", omit.stat = c("ser", "rsq", "f"), digits = 2,
          column.labels = c("FS1", "FS2"),
          notes = "Tilsvarer Tabell 2 i M&R (2014)")

# Tabell 3 + 4 (M&R) — naiv OLS, reduced form og IV side om side
stargazer(ols, rf, ss,
          type = "text", omit.stat = c("ser", "rsq", "f"), digits = 2,
          column.labels = c("Naiv OLS", "RF (T3)", "2SLS (T4)"),
          notes = paste0("Sann beta1 = ", beta_1, ", beta2 = ", beta_2,
                         ". RF tilsvarer T3, 2SLS tilsvarer T4 i M&R"))
