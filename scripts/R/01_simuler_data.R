# Simulert datasett for Markussen & Røed (2014)
# Gjenskaper tabell 1 (s. 12) med korrelert korrelasjonsstruktur

# 1. Pakker og hjelpefunksjoner ----------------------------------------

library(tidyverse)

fn_bin <- function(n, p) {
    sample(0:1, n, prob = c(1 - p, p), replace = TRUE)
}

fn_cont <- function(n, m, sd, lo, hi) {
    pmin(pmax(round(rnorm(n, m, sd)), lo), hi)
}

fn_lognorm <- function(n, m, sd) {
    # Parametrisert med ønsket mean/sd, konverterer til log-normal-parametre
    sigma_ln <- sqrt(log(1 + (sd / m)^2))
    mu_ln    <- log(m) - sigma_ln^2 / 2
    round(rlnorm(n, mu_ln, sigma_ln))
}

# 2. Inntektsmodell — koeffisienter ------------------------------------
# Felles log-lineær modell på tvers av grupper. Interceptet kalibreres
# per gruppe slik at E[earn_prior] matcher tabell 1.

b_age       <-  0.01
b_school    <-  0.05
b_female    <- -0.10
b_immigrant <- -0.15
sigma_earn  <-  0.40   # idiosynkratisk variasjon på log-skala

# 3. Simuleringsfunksjon per gruppe ------------------------------------

sim_group <- function(category, n, female, age, school, immigrant,
                      earn_prior, labor_earn, transfer_prior,
                      duration, obs_end, multi_vr = NA,
                      earn_5yr, transfer_5yr, empl_post, pdi_post) {

    # Eksogene demografiske variabler
    d_female    <- fn_bin(n, female)
    d_age       <- fn_cont(n, age, 8, 18, 55)
    d_immigrant <- fn_bin(n, immigrant)

    # Utdanning betinget på innvandring (-1.5 år for innvandrere)
    # Justerer base opp slik at gruppegjennomsnitt holdes
    school_base   <- school + immigrant * 1.5
    school_ind    <- school_base - 1.5 * d_immigrant
    d_year_school <- pmin(pmax(round(rnorm(n, school_ind, 2)), 7), 20)

    # earn_prior — log-lineær modell med kalibrert intercept
    xb <- b_age * d_age + b_school * d_year_school +
        b_female * d_female + b_immigrant * d_immigrant
    intercept    <- log(earn_prior) - mean(xb) - sigma_earn^2 / 2
    d_earn_prior <- round(exp(intercept + xb + rnorm(n, 0, sigma_earn)))

    # Dekomponering: arbeidsinntekt og overføringer
    # Labor-andel varierer med alder (eldre → mer overføringer) og utdanning
    target_labor_share <- labor_earn / earn_prior
    labor_logit <- qlogis(target_labor_share) +
        -0.02 * (d_age - age) +
        0.01 * (d_year_school - school) +
        rnorm(n, 0, 0.3)
    d_labor_share    <- plogis(labor_logit)
    d_labor_earn     <- round(d_earn_prior * d_labor_share)
    d_transfer_prior <- d_earn_prior - d_labor_earn

    # Øvrige kovariater
    d_duration <- fn_cont(n, duration, 15, 1, 120)
    d_obs_end  <- fn_bin(n, obs_end)
    d_multi_vr <- if (!is.na(multi_vr)) fn_bin(n, multi_vr) else NA_real_

    # Utfallsvariabler — foreløpig fra gruppegjennomsnitt, ikke DGP
    d_earn_5yr     <- fn_lognorm(n, earn_5yr, 100000)
    d_transfer_5yr <- fn_lognorm(n, transfer_5yr, 80000)
    d_empl_post    <- fn_bin(n, empl_post)
    d_pdi_post     <- fn_bin(n, pdi_post)

    # Post-TDI inntekt og overføringer (ikke i tabell 1)
    # Betinget på sysselsetting/PDI — artikkelen definerer sysselsatt som >160k
    d_labor_earn_post <- round(
        d_empl_post * rlnorm(n, log(220000), 0.5) +
        (1 - d_empl_post) * rlnorm(n, log(40000), 0.8)
    )

    d_transfer_post <- round(
        d_pdi_post * rlnorm(n, log(180000), 0.3) +
        (1 - d_pdi_post) * d_empl_post * rlnorm(n, log(20000), 0.8) +
        (1 - d_pdi_post) * (1 - d_empl_post) * rlnorm(n, log(90000), 0.5)
    )

    tibble(
        category         = category,
        female           = d_female,
        age              = d_age,
        year_school      = d_year_school,
        immigrant        = d_immigrant,
        earn_prior       = d_earn_prior,
        labor_earn_prior = d_labor_earn,
        transfer_prior   = d_transfer_prior,
        duration_months  = d_duration,
        observed_end     = d_obs_end,
        multi_vr         = d_multi_vr,
        earn_5yr         = d_earn_5yr,
        transfer_5yr     = d_transfer_5yr,
        empl_post        = d_empl_post,
        pdi_post         = d_pdi_post,
        labor_earn_post  = d_labor_earn_post,
        transfer_post    = d_transfer_post
    )
}

# 4. Parametere fra tabell 1, s. 12 (NOK i 2013-priser) ---------------

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

# 5. Generer datasett --------------------------------------------------

set.seed(2014)

df_sim <- params |>
    map(\(p) do.call(sim_group, p)) |>
    bind_rows() |>
    mutate(
        id = row_number(),
        category = factor(category,
                          levels = c("non_treated", "VR1", "VR2", "VR3", "VR4"))
    )

# 6. Verifiser mot tabell 1 --------------------------------------------

df_sim |>
    group_by(category) |>
    summarise(
        antall = n(),
        across(female:pdi_post, \(x) mean(x, na.rm = TRUE))
    ) |>
    pivot_longer(-category) |>
    pivot_wider(names_from = category, values_from = value)

# 7. Tetthetplot: earn_prior per gruppe --------------------------------

p_earn_prior <- df_sim |>
    ggplot(aes(x = earn_prior / 1000, fill = category)) +
    geom_density(alpha = 0.4) +
    labs(
        title = "Tetthetsfunksjon: total inntekt året før TDI-inntreden",
        subtitle = "Log-normalfordeling, simulerte data",
        x = "Inntekt (1 000 NOK, 2013-priser)",
        y = "Tetthet",
        fill = "Gruppe"
    ) +
    theme_minimal()

ggsave(here::here("output", "earn_prior_density.pdf"),
       p_earn_prior, width = 8, height = 5)

# IV-delen er i 02_iv_instrument.R
