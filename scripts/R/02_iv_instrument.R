# IV-instrumentkonstruksjon for Markussen & Røed (2014)
# Kontor, behandlingsstrategi og leave-one-out instrument.
# Starter enkelt: 4 kontor, binær behandling (VR vs. ikke), 10 år.

# 1. Pakker og data ----------------------------------------------------

library(tidyverse)

if (!exists("df_sim")) source(here::here("scripts", "R", "01_simuler_data.R"))

# 2. Kontor og inngangsår ----------------------------------------------
# 152 kontor i artikkelen — starter med 4 for å bygge intuisjon

n_offices    <- 4
years        <- 1996:2005
office_probs <- c(0.40, 0.25, 0.20, 0.15)  # ulik størrelse (by vs. distrikt)

df_sim <- df_sim |>
    mutate(
        office_id  = sample(1:n_offices, n(), replace = TRUE, prob = office_probs),
        year_entry = sample(years, n(), replace = TRUE)
    )

# 3. Sann kontorspesifikk behandlingsstrategi --------------------------
#
# Hvert kontor har en uobserverbar strategi-funksjon:
# P(VR=1 | X, kontor j) = plogis(α_j + β_j' * X)
#
# Ulike kontor vekter individkjennetegn ulikt — dette er den lokale
# praksisvariasjonen som artikkelen utnytter som eksogen variasjon.
#
# Kontor 1: "Aktiv"     — høy VR-rate, favoriserer unge
# Kontor 2: "Bred"      — høyest rate, lite seleksjon
# Kontor 3: "Restriktiv" — lav VR-rate
# Kontor 4: "Selektiv"  — middels rate, sender færre innvandrere

office_strategy <- tibble(
    office_id = 1:4,
    alpha     = c( 0.3,  0.5, -0.8, -0.1),
    b_age     = c(-0.04, -0.01, -0.02, -0.01),
    b_female  = c( 0.0,   0.1,   0.0,  -0.1),
    b_immig   = c( 0.0,   0.0,  -0.1,  -0.3)
)

df_sim <- df_sim |>
    left_join(office_strategy, by = "office_id") |>
    mutate(
        # Sann latent indeks — uobserverbar for forskeren
        vr_latent = alpha +
            b_age * (age - 40) / 10 +
            b_female * female +
            b_immig * immigrant,
        vr_prob    = plogis(vr_latent),
        vr_treated = rbinom(n(), 1, vr_prob)
    ) |>
    select(-alpha, -b_age, -b_female, -b_immig)

# Sjekk: behandlingsrate per kontor
df_sim |>
    summarise(vr_rate = mean(vr_treated), n = n(), .by = office_id) |>
    arrange(office_id)

# 4. Leave-one-out instrument (ligning 5 i artikkelen) -----------------
#
# For person i: snitt VR-rate blant alle ANDRE på samme kontor × år.
# Fjerner i's egen påvirkning — sikrer eksogenitet.

df_sim <- df_sim |>
    mutate(
        env_n   = n(),
        env_sum = sum(vr_treated),
        .by = c(office_id, year_entry)
    ) |>
    mutate(
        Z_loo = (env_sum - vr_treated) / (env_n - 1)
    )

# Sjekk: variasjon i instrumentet
df_sim |>
    summarise(Z_mean = mean(Z_loo), Z_sd = sd(Z_loo), n = n(),
              .by = office_id) |>
    arrange(office_id)
