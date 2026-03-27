# Replikasjon av Markussen & Røed (2014) — Claudes arbeidsskript
# Simulert datasett basert på tabell 1 (s. 12). Bygges opp stegvis.

# 1. Biblioteker -----------------------------------------------------

library(tidyverse)

# 2. Leave-one-out — minieksempel -----------------------------------

# Kontor 1 sender ofte folk til tiltak (3/5), kontor 2 sjelden (1/5).
df_loo <- tibble(
  id     = 1:10,
  kontor = c(rep(1, 5), rep(2, 5)),
  D      = c(1, 1, 1, 0, 0, 1, 0, 0, 0, 0)
  ) |>
  mutate(
    Z = (sum(D) - D) / (n() - 1),  # andel andre med tiltak
    .by = kontor
    )

# 3. Hjelpefunksjoner -----------------------------------------------

fn_bin <- function(n, p) {
  sample(0:1, n, prob = c(1 - p, p), replace = TRUE)
}

fn_cont <- function(n, m, sd, lo, hi) {
  pmin(pmax(round(rnorm(n, m, sd)), lo), hi)
}

# 4. Datasimulering — én gruppe av gangen ---------------------------

# Tar parametere fra tabell 1 som navngitt liste.
# Returnerer tibble med simulerte individdata.
sim_group <- function(category, n, female, age, school, immigrant,
                      earn_prior, labor_earn, transfer_prior,
                      duration, obs_end, multi_vr = NA,
                      earn_5yr, transfer_5yr, empl_post, pdi_post) {
  tibble(
    category         = category,
    female           = fn_bin(n, female),
    age              = fn_cont(n, age, 8, 18, 55),
    year_school      = fn_cont(n, school, 2, 7, 20),
    immigrant        = fn_bin(n, immigrant),
    earn_prior       = fn_cont(n, earn_prior, 150000, 0, 1500000),
    labor_earn_prior = fn_cont(n, labor_earn, 130000, 0, 1500000),
    transfer_prior   = fn_cont(n, transfer_prior, 40000, 0, 500000),
    duration_months  = fn_cont(n, duration, 15, 1, 120),
    observed_end     = fn_bin(n, obs_end),
    multi_vr         = if (!is.na(multi_vr)) fn_bin(n, multi_vr) else NA_real_,
    earn_5yr         = fn_cont(n, earn_5yr, 100000, 0, 1000000),
    transfer_5yr     = fn_cont(n, transfer_5yr, 80000, 0, 500000),
    empl_post        = fn_bin(n, empl_post),  # sysselsatt etter TDI
    pdi_post         = fn_bin(n, pdi_post)    # overgang til varig uføretrygd
  )
}

# 5. Parametere fra tabell 1, s. 12 (NOK i 2013-priser) -------------

params <- list(
  list(category = "non_treated", n = 176340,
       female = 0.572, age = 42.5, school = 10.6, immigrant = 0.130,
       earn_prior = 373901, labor_earn = 337368, transfer_prior = 36532,
       duration = 16.3, obs_end = 0.973,
       earn_5yr = 163146, transfer_5yr = 143873,
       empl_post = 0.462, pdi_post = 0.402),

  list(category = "VR1", n = 38842,
       female = 0.526, age = 37.1, school = 10.5, immigrant = 0.106,
       earn_prior = 312715, labor_earn = 262800, transfer_prior = 49916,
       duration = 32.9, obs_end = 0.658, multi_vr = 0.450,
       earn_5yr = 123840, transfer_5yr = 158811,
       empl_post = 0.476, pdi_post = 0.359),

  list(category = "VR2", n = 19393,
       female = 0.485, age = 38.4, school = 10.1, immigrant = 0.181,
       earn_prior = 271581, labor_earn = 209762, transfer_prior = 61819,
       duration = 35.0, obs_end = 0.629, multi_vr = 0.472,
       earn_5yr = 67990, transfer_5yr = 177030,
       empl_post = 0.204, pdi_post = 0.477),

  list(category = "VR3", n = 92476,
       female = 0.521, age = 35.0, school = 10.6, immigrant = 0.138,
       earn_prior = 339088, labor_earn = 287141, transfer_prior = 51946,
       duration = 38.1, obs_end = 0.599, multi_vr = 0.421,
       earn_5yr = 130694, transfer_5yr = 165574,
       empl_post = 0.598, pdi_post = 0.204),

  list(category = "VR4", n = 18056,
       female = 0.516, age = 37.3, school = 10.4, immigrant = 0.167,
       earn_prior = 331307, labor_earn = 277410, transfer_prior = 53896,
       duration = 35.3, obs_end = 0.599, multi_vr = 0.766,
       earn_5yr = 115189, transfer_5yr = 171175,
       empl_post = 0.504, pdi_post = 0.271)
)

# 6. Generer datasett ------------------------------------------------

set.seed(2014)

df_sim <- params |>
  map(\(p) do.call(sim_group, p)) |>
  bind_rows() |>
  mutate(
    id = row_number(),
    category = factor(category, levels = c("non_treated", "VR1", "VR2", "VR3", "VR4"))
    )

# 7. Verifiser mot tabell 1 -----------------------------------------

df_sim |>
  group_by(category) |>
  summarise(
    antall = n(),
    across(female:pdi_post, \(x) mean(x, na.rm = TRUE))
    ) |>
  pivot_longer(-category) |>
  pivot_wider(names_from = category, values_from = value)
