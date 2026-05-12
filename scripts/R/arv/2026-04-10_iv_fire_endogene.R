# Multi-endogen IV med fire behandlinger — utvidelse av iv_to_endogene.R.
#
# Notasjon følger Markussen & Røed (2014):
#   P_k    endogen behandling k = 1, 2, 3, 4 (her kontinuerlig "intensitet")
#   φ_k    instrument — lokal behandlingsstrategi (jackknifet hos M&R)
#   y      utfall (post-TDI inntekt, 1 000 NOK)
#   x      kontroller (female, year_school)
#   β_k    sann behandlingseffekt
#   η      uobservert heterogenitet — kanal for OLS-skjevhet
#
# Strukturen er identisk med iv_to_endogene.R; vi har bare lagt til to
# behandlinger og to instrumenter. 2SLS-mekanikken er upåvirket — fortsatt
# samme oppskrift: ett førstesteg per endogen, ett felles andresteg.
#
# Skriptet replikerer tre av artikkelens hovedtabeller:
#   FS1..FS4  →  Tabell 2 (relevanstest, "førstesteget")
#   rf        →  Tabell 3 (reduced form: y direkte på φ)
#   ss        →  Tabell 4 (IV/2SLS: y på faktisk P, instrumentert med φ)

library(tidyverse)
library(stargazer)

set.seed(20260410)

# 1. DGP -------------------------------------------------------------------

n      <- 5000
beta_1 <- 30      # sann effekt av P_1 (parallell til VR1)
beta_2 <- 50      # sann effekt av P_2 (parallell til VR2)
beta_3 <- 15      # sann effekt av P_3 (parallell til VR3)
beta_4 <- 10      # sann effekt av P_4 (parallell til VR4)

df <- tibble(
    eta         = rnorm(n),
    phi_1       = rnorm(n),
    phi_2       = rnorm(n),
    phi_3       = rnorm(n),
    phi_4       = rnorm(n),
    female      = sample(0:1, n, replace = TRUE),
    year_school = sample(c(10, 13, 16, 18), n, replace = TRUE),
    # Førstestegene: P_k avhenger av sin egen φ_k, av η og x
    P_1 = 0.5 * phi_1 + 0.3 * eta + 0.20 * female + 0.05 * (year_school - 10) + rnorm(n, 0, 0.5),
    P_2 = 0.5 * phi_2 + 0.3 * eta - 0.20 * female + 0.05 * (year_school - 10) + rnorm(n, 0, 0.5),
    P_3 = 0.5 * phi_3 + 0.3 * eta + 0.10 * female + 0.05 * (year_school - 10) + rnorm(n, 0, 0.5),
    P_4 = 0.5 * phi_4 + 0.3 * eta - 0.10 * female + 0.05 * (year_school - 10) + rnorm(n, 0, 0.5),
    # Utfall — sann β_k for hver behandling, η inn negativt (kilde til OLS-skjevhet)
    y = 250 + beta_1 * P_1 + beta_2 * P_2 + beta_3 * P_3 + beta_4 * P_4 -
        25 * female + 15 * (year_school - 10) - 50 * eta + rnorm(n, 0, 30)
)

# 2. Estimering ------------------------------------------------------------

# Naiv OLS — biased fordi alle P-er er korrelert med η
ols <- lm(y ~ P_1 + P_2 + P_3 + P_4 + female + year_school, data = df)

# Førstesteg: hvert P på ALLE fire φ + kontroller. Tilsvarer artikkelens TABELL 2
fs1 <- lm(P_1 ~ phi_1 + phi_2 + phi_3 + phi_4 + female + year_school, data = df)
fs2 <- lm(P_2 ~ phi_1 + phi_2 + phi_3 + phi_4 + female + year_school, data = df)
fs3 <- lm(P_3 ~ phi_1 + phi_2 + phi_3 + phi_4 + female + year_school, data = df)
fs4 <- lm(P_4 ~ phi_1 + phi_2 + phi_3 + phi_4 + female + year_school, data = df)

# Reduced form: y direkte på φ + kontroller. Tilsvarer artikkelens TABELL 3
rf <- lm(y ~ phi_1 + phi_2 + phi_3 + phi_4 + female + year_school, data = df)

# Andresteg i 2SLS: erstatt P med projeksjonene. Tilsvarer artikkelens TABELL 4
df$P_1_hat <- predict(fs1)
df$P_2_hat <- predict(fs2)
df$P_3_hat <- predict(fs3)
df$P_4_hat <- predict(fs4)
ss <- lm(y ~ P_1_hat + P_2_hat + P_3_hat + P_4_hat + female + year_school, data = df)

# 3. Resultat --------------------------------------------------------------

# Tabell 2 (M&R) — relevanstest / førstesteget
stargazer(fs1, fs2, fs3, fs4,
          type = "text", omit.stat = c("ser", "rsq", "f"), digits = 2,
          column.labels = c("FS1", "FS2", "FS3", "FS4"),
          notes = "Tilsvarer Tabell 2 i M&R (2014)")

# Tabell 3 + 4 (M&R) — naiv OLS, reduced form og IV side om side
stargazer(ols, rf, ss,
          type = "text", omit.stat = c("ser", "rsq", "f"), digits = 2,
          column.labels = c("Naiv OLS", "RF (T3)", "2SLS (T4)"),
          notes = paste0("Sann beta = ", beta_1, ", ", beta_2, ", ",
                         beta_3, ", ", beta_4,
                         ". RF tilsvarer T3, 2SLS tilsvarer T4 i M&R"))
