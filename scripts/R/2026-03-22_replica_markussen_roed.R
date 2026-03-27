# Replikasjon av Markussen & Røed (2014): "The Impacts of Vocational Rehabilitation"
# Simulert datasett for å forstå IV-strategien steg for steg.
# Bygges opp iterativt mens artikkelen leses.

# 1. Biblioteker -----------------------------------------------------

library(tidyverse)

# data

# individer
fk <- c(1:345107) # 6340 + 38842+19393+92476+18056
non_treated_n <- 176340
treated_n     <- length(fk) - non_treated_n


# 3. Hjelpefunksjoner for simulering --------------------------------

fn_binomial <- function(len, p_equal_1) {
  sample(x = c(0, 1), size = len, prob = c(1 - p_equal_1, p_equal_1), replace = TRUE)
}

fn_contin <- function(len, mean_c, sd_c, min_c, max_c) {
  pmin(pmax(round(rnorm(n = len, mean = mean_c, sd = sd_c)), min_c), max_c)
}


# Funksjonen tar verdier fra tabell 1 direkte som argumenter.
# Kalles én gang per gruppe (non_treated, VR1, VR2, ...).

fn_data_create <- function(
    # input variabler
    category, n, female, age, school, immigrant, earn_prior, labor_earn, transfer_prior, duration, obs_end, multi_vr = NA, earn_5yr, transfer_5yr, empl_post, pdi_post) {
  
  # Data som returnerer
  tibble(
    id                = 1:n,
    category          = category,
    female            = fn_binomial(n, female),
    age               = fn_contin(n, age, sd_c = 8, min_c = 18, max_c = 55),
    year_school       = fn_contin(n, school, sd_c = 2, min_c = 7, max_c = 20),
    immigrant         = fn_binomial(n, immigrant),
    earn_prior        = fn_contin(n, earn_prior, sd_c = 150000, min_c = 0, max_c = 1500000),
    labor_earn_prior  = fn_contin(n, labor_earn, sd_c = 130000, min_c = 0, max_c = 1500000),
    transfer_prior    = fn_contin(n, transfer_prior, sd_c = 40000, min_c = 0, max_c = 500000),
    duration_months   = fn_contin(n, duration, sd_c = 15, min_c = 1, max_c = 120),
    observed_end      = fn_binomial(n, obs_end),
    multi_vr          = if (!is.na(multi_vr)) fn_binomial(n, multi_vr) else rep(NA_real_, n),
    earn_5yr          = fn_contin(n, earn_5yr, sd_c = 100000, min_c = 0, max_c = 1000000),
    transfer_5yr      = fn_contin(n, transfer_5yr, sd_c = 80000, min_c = 0, max_c = 500000),
    empl_post         = fn_binomial(n, empl_post),  # sysselsatt første år etter TDI
    pdi_post          = fn_binomial(n, pdi_post)    # overgang til varig uføretrygd
  )

}

l_non_treated <- list(
    category = "non-treated",
    n = 176340,
    female = 0.572, 
    age = 42.5, 
    school = 10.6, 
    immigrant = 0.130,
    earn_prior = 373901, 
    labor_earn = 337368, 
    transfer_prior = 36532,
    duration = 16.3, 
    obs_end = 0.973,
    earn_5yr = 163146, 
    transfer_5yr = 143873,
    empl_post = 0.462, 
    pdi_post = 0.402
    ) 

l_vr1 <- list(
  category = "VR1", n = 38842,
  female = 0.526, age = 37.1, school = 10.5, immigrant = 0.106,
  earn_prior = 312715, labor_earn = 262800, transfer_prior = 49916,
  duration = 32.9, obs_end = 0.658, multi_vr = 0.450,
  earn_5yr = 123840, transfer_5yr = 158811,
  empl_post = 0.476, pdi_post = 0.359
)

l_vr2 <- list(
  category = "VR2", n = 19393,
  female = 0.485, age = 38.4, school = 10.1, immigrant = 0.181,
  earn_prior = 271581, labor_earn = 209762, transfer_prior = 61819,
  duration = 35.0, obs_end = 0.629, multi_vr = 0.472,
  earn_5yr = 67990, transfer_5yr = 177030,
  empl_post = 0.204, pdi_post = 0.477
)

l_vr3 <- list(
  category = "VR3", n = 92476,
  female = 0.521, age = 35.0, school = 10.6, immigrant = 0.138,
  earn_prior = 339088, labor_earn = 287141, transfer_prior = 51946,
  duration = 38.1, obs_end = 0.599, multi_vr = 0.421,
  earn_5yr = 130694, transfer_5yr = 165574,
  empl_post = 0.598, pdi_post = 0.204
)

l_vr4 <- list(
  category = "VR4", n = 18056,
  female = 0.516, age = 37.3, school = 10.4, immigrant = 0.167,
  earn_prior = 331307, labor_earn = 277410, transfer_prior = 53896,
  duration = 35.3, obs_end = 0.599, multi_vr = 0.766,
  earn_5yr = 115189, transfer_5yr = 171175,
  empl_post = 0.504, pdi_post = 0.271
)

# 6. Generer komplett datasett ---------------------------------------

set.seed(2014)

list_sample <- list(l_non_treated, l_vr1, l_vr2, l_vr3, l_vr4)

df_sim <- list_sample |>
  map(\(params) do.call(data_create, params)) |>
  bind_rows() |>
  mutate(id = row_number())


# tabell 1
