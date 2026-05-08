# Jackknife-konstruksjon av instrumentet — minimalt eksempel.
#
# Pedagogisk skript 2b fra todo: viser ligning 5 i Markussen & Røed (2014)
# i den enkleste mulige settingen — én endogen behandling D, ett kontor-
# instrument φ. Bygger videre på 2026-04-10_iv_to_endogene.R, men
# erstatter det «himmelfallende» phi_k med en eksplisitt konstruksjon
# fra observerte D-er.
#
# Tre versjoner av instrumentet sammenlignes:
#   phi_truth — sann kontorkultur z_j (ikke observert i praksis, kun fasit)
#   phi_naive — kontor-snitt av D, INKLUDERT personen selv (ligning 4)
#   phi_jack  — kontor-snitt av D for ALLE ANDRE i kontoret (ligning 5)
#
# Hovedpoenget: phi_naive har en mekanisk korrelasjon med personens egen
# η fordi D_i selv er med i snittet. Jackknife fjerner akkurat dette
# leddet og gjenoppretter eksogeniteten betinget på x.
#
# Forenkling vs. M&R: artikkelen jackknifer RESIDUALER fra ligning 2
# (LPM-hazard) for å rense ut x og varighet før aggregering. Vi
# jackknifer D direkte. Mekanikken er identisk; bare hva som ligger
# i u_Si endres. Når x er kontrollert i utfallsligningen (slik vi
# gjør under), faller residualiseringen sammen med vår snarvei i
# stor N.

# 1. Pakker ----------------------------------------------------------------

library(tidyverse)
library(stargazer)

set.seed(20260508)

# 2. Parametere ------------------------------------------------------------
# Liten DGP: K kontor med sann kultur z_j; personer fordeles over kontorene.
# η går inn i BÅDE seleksjon (D) og utfall (Y) — det er kanalen som gjør
# at naiv OLS er biased og som jackknife må unngå å reintrodusere via φ.

n_offices  <- 50
n_per_off  <- 10           # bevisst lite — gjør 1/N_j-biasen synlig i én run
n_persons  <- n_offices * n_per_off

beta_true   <- 30          # sann effekt av D på Y
sigma_z     <- 1.0         # spennvidde på sann kontorkultur
sigma_eta   <- 1.0
delta_eta   <- 0.5         # η inn i D (seleksjonsskjevhet)
lambda_eta  <- -50         # η inn i Y (skaper OLS-bias)

# 3. Simuler kontor og personer -------------------------------------------

office <- tibble(
    office_id = 1:n_offices,
    z_office  = rnorm(n_offices, 0, sigma_z)        # sann kontorkultur
)

df <- tibble(
    id          = 1:n_persons,
    office_id   = rep(1:n_offices, each = n_per_off),
    eta         = rnorm(n_persons, 0, sigma_eta),
    female      = sample(0:1, n_persons, replace = TRUE),
    year_school = sample(c(10, 13, 16, 18), n_persons, replace = TRUE)
) |>
    left_join(office, by = "office_id") |>
    mutate(
        # Behandling D: sann kontorkultur + endogen η + x + støy
        D = 1.0 + z_office + delta_eta * eta +
            0.2 * female + 0.05 * (year_school - 10) +
            rnorm(n_persons, 0, 0.5),
        # Utfall Y: sann β·D + x + endogen η + støy
        y = 250 + beta_true * D - 25 * female + 15 * (year_school - 10) +
            lambda_eta * eta + rnorm(n_persons, 0, 30)
    )

# 4. Tre versjoner av instrumentet ----------------------------------------
# phi_truth: fasiten — sann kontorkultur. Brukes kun til sammenligning;
#            ville aldri vært observerbar i ekte data.
# phi_naive: kontor-snitt av D, der personen selv er med i snittet.
#            Ligning 4 i M&R: φ_Sj = (1/N_j) · Σ_{i ∈ j} u_Si.
# phi_jack:  ekskluder personen fra snittet — ligning 5.
#            Identisk uttrykk som i 2026-04-10_simuler_utfall_data.R, steg 9.

df <- df |>
    mutate(
        sum_D     = sum(D),
        n_office  = n(),
        phi_naive = sum_D / n_office,                              # ligning 4
        phi_jack  = (sum_D - D) / (n_office - 1),                  # ligning 5
        .by = office_id
    ) |>
    rename(phi_truth = z_office) |>
    select(-sum_D, -n_office)

# 5. Diagnose: hvorfor naiv er problematisk -------------------------------
# Mekanisk forventning: cov(phi_naive, η_i) = (1/N_j) · cov(D_i, η_i) > 0
# fordi D_i bidrar med 1/N_j til snittet og D_i selv er korrelert med η_i.
# Jackknife fjerner dette bidraget — phi_jack inneholder bare ANDRES η.

diagnose <- df |>
    summarise(
        cor_truth_eta = cor(phi_truth, eta),    # ≈ 0 by construction
        cor_naive_eta = cor(phi_naive, eta),    # > 0 — endogenitet smitter inn
        cor_jack_eta  = cor(phi_jack,  eta),    # ≈ 0 — leave-one-out fjerner det
        cor_naive_D   = cor(phi_naive, D),      # mekanisk høy
        cor_jack_D    = cor(phi_jack,  D)       # reell relevans
    )

print(diagnose)

# 6. IV-estimering med hver versjon ---------------------------------------
# OLS (referanse — biased), og 2SLS gjort manuelt så hvert steg er synlig:
# først førstesteget (D på φ + x), så predikere D̂, så andresteget.

ols <- lm(y ~ D + female + year_school, data = df)

fn_iv <- function(phi_name) {
    fs_fml <- reformulate(c(phi_name, "female", "year_school"), "D")
    fs     <- lm(fs_fml, data = df)
    df$D_hat <- predict(fs)
    ss     <- lm(y ~ D_hat + female + year_school, data = df)
    list(fs = fs, ss = ss)
}

iv_truth <- fn_iv("phi_truth")
iv_naive <- fn_iv("phi_naive")
iv_jack  <- fn_iv("phi_jack")

# 7. Rapport ---------------------------------------------------------------
# Forventning (sann β = 30):
#   OLS              :  biased nedover pga λ_η < 0
#   IV med phi_truth :  ≈ 30 (fasit — eksogen kontorkultur)
#   IV med phi_naive :  biased fordi instrumentet selv er korrelert med η
#   IV med phi_jack  :  ≈ 30 (jackknife gjenoppretter eksogeniteten)

stargazer(
    ols, iv_truth$ss, iv_naive$ss, iv_jack$ss,
    type          = "text",
    omit.stat     = c("ser", "rsq", "f"),
    digits        = 2,
    column.labels = c("OLS", "IV truth", "IV naiv", "IV jack"),
    keep          = c("D", "D_hat"),
    notes         = paste0("Sann beta = ", beta_true,
                           ". phi.naive bruker hele kontor-snittet,",
                           " phi.jack leaver out personen selv.")
)

# 8. Bonus: bias-skala 1/N_j (Monte Carlo) --------------------------------
# Naiv-biasen forventes å avta som 1/N_j fordi cov(phi_naive, η_i) er
# proporsjonal med 1/N_j. Én enkelt run er for støyete til å vise mønsteret;
# vi kjører derfor 100 replikasjoner per kontorstørrelse og rapporterer
# gjennomsnitt av β_IV med naiv vs jackknifet instrument.

fn_one_rep <- function(n_per_off_i) {
    df_i <- tibble(
        office_id = rep(1:n_offices, each = n_per_off_i),
        eta       = rnorm(n_offices * n_per_off_i, 0, sigma_eta)
    ) |>
        left_join(office, by = "office_id") |>
        mutate(
            D = 1.0 + z_office + delta_eta * eta + rnorm(n(), 0, 0.5),
            y = 250 + beta_true * D + lambda_eta * eta + rnorm(n(), 0, 30)
        ) |>
        mutate(
            sum_D     = sum(D),
            n_office  = n(),
            phi_naive = sum_D / n_office,
            phi_jack  = (sum_D - D) / (n_office - 1),
            .by = office_id
        )

    fn_beta <- function(phi_name) {
        fs <- lm(reformulate(phi_name, "D"), data = df_i)
        df_i$D_hat <- predict(fs)
        coef(lm(y ~ D_hat, data = df_i))[["D_hat"]]
    }

    c(naive = fn_beta("phi_naive"), jack = fn_beta("phi_jack"))
}

n_grid    <- c(5, 10, 25, 100)
n_reps    <- 100

bias_mc <- map(n_grid, \(n_i) {
    reps <- replicate(n_reps, fn_one_rep(n_i))
    tibble(
        n_per_off       = n_i,
        beta_naive_mean = mean(reps["naive", ]),
        beta_jack_mean  = mean(reps["jack",  ]),
        bias_naive      = mean(reps["naive", ]) - beta_true,
        bias_jack       = mean(reps["jack",  ]) - beta_true
    )
}) |>
    list_rbind()

print(bias_mc)

# Forventet: bias_naive er negativ og avtar (i absoluttverdi) som 1/N_j;
# bias_jack ligger nær 0 for alle N_j. Sann β = 30.
