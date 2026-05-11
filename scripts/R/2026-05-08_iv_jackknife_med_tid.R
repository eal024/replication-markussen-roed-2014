# Jackknife-konstruksjon MED tidsdimensjon — person-måned-basert.
#
# Justering av 2026-05-08_iv_jackknife_minimal.R som behandlet D som en
# kontinuerlig "intensitet" og hoppet over hele person-måned-laget. Her
# følger vi M&R sin konstruksjon trinn for trinn med ett enkelt tiltak.
#
# Notasjon (følger M&R seksjon 3 direkte):
#   i      individ
#   j      kontor
#   d      risikomåned, 1..24
#   S      tilstand/behandling — her kun S = VR1
#   P_Sid  hendelsesindikator (én rad per (i, d) at risk):
#          = 1 hvis i går over til S i måned d, ellers 0
#   D_Si   personnivå-deltakelsesdummy (ligning 6):
#          = 1 hvis i fikk S innen 24 mnd
#   x_i    kontroller (female, year_school)
#   u_Sid  residual fra ligning 2
#   u_Si   Σ_d u_Sid                (ligning 3)
#   φ_Sj   (1/N_j) Σ_{i ∈ j} u_Si   (ligning 4, naïv)
#   φ_Si   (1/(N_j−1)) Σ_{i'≠i} u_Si'   (ligning 5, jackknife)
#
# Skriptets fokus er FØRSTE DEL: gangen fra hendelser via person-måned
# til φ_Si. IV-tabellen til slutt er bare en sanity-check.

# 1. Pakker ----------------------------------------------------------------

library(tidyverse)
library(stargazer)

set.seed(20260508)

# 2. Parametere ------------------------------------------------------------
# Kontorstørrelsen er moderat (N_j = 20) slik at 1/N_j-effekten er synlig
# uten at hver enkelt regresjon blir for støyete.

n_offices  <- 50
n_per_off  <- 30           # nok per kontor til at jackknife er presis
n_persons  <- n_offices * n_per_off
max_months <- 24

beta_true   <- 30          # sann effekt av D_VR1 på Y
sigma_z     <- 0.015       # spennvidde i sann kontorkultur (matcher M&R-skala)
sigma_eta   <- 1.0
delta_eta   <- 0.004       # η inn i hazard (høy η → tidligere VR1)
lambda_eta  <- -50         # η inn i Y (skaper OLS-bias)

# 3. Kontor og persondata --------------------------------------------------
# z_office_j er sann kontorkultur — det φ skal estimere. η er uobservert
# heterogenitet og kanalen for OLS-skjevhet.

office <- tibble(
    office_id = 1:n_offices,
    z_office  = rnorm(n_offices, 0, sigma_z)
)

df_person <- tibble(
    id          = 1:n_persons,
    office_id   = rep(1:n_offices, each = n_per_off),
    eta         = rnorm(n_persons, 0, sigma_eta),
    female      = sample(0:1, n_persons, replace = TRUE),
    year_school = sample(c(10, 13, 16, 18), n_persons, replace = TRUE)
) |>
    left_join(office, by = "office_id")

# 4. Hazarder og hendelse-tidspunkt ----------------------------------------
# Konstant månedlig hazard per person → geometrisk fordelt overgangs-måned.
# rgeom(n, p) gir antall mislykkede forsøk før første suksess (= måned 0,
# 1, 2, ...), så vi legger til 1 for å få første-måned = 1.

df_person <- df_person |>
    mutate(
        h_vr1 = pmax(0.010 + 0.002 * female + 0.001 * (year_school - 10) +
                     z_office + delta_eta * eta, 1e-6),
        t_vr1 = rgeom(n(), h_vr1) + 1L,
        d_vr1 = if_else(t_vr1 <= max_months, t_vr1, NA_integer_),
        D_vr1 = as.integer(t_vr1 <= max_months)
    )

# Andel som faktisk får VR1 — sjekk at det ligger i et fornuftig intervall
df_person |> summarise(share_treated = mean(D_vr1))

# 5. Utfall Y --------------------------------------------------------------
# DGP: y = α + β·D + γ·x + λ·η + ε. Endogenitet via η i både hazard og y.

df_person <- df_person |>
    mutate(
        y = 250 + beta_true * D_vr1 - 25 * female + 15 * (year_school - 10) +
            lambda_eta * eta + rnorm(n(), 0, 30)
    )

# 6. Person-måned-ekspansjon -----------------------------------------------
# Hver person bidrar med rader fra d=1 til hendelse-måneden (eller 24 hvis
# sensurert). P_id er hendelsesindikatoren — = 1 kun i overgangs-måneden.
#
#  Eksempel:
#   person A fikk VR1 i d=3      → 3 rader, P = (0, 0, 1)
#   person B fikk aldri VR1      → 24 rader, P = (0, 0, ..., 0)
#   person C fikk VR1 i d=1      → 1 rad,    P = (1)

df_pm <- df_person |>
    mutate(last_month = if_else(is.na(d_vr1), max_months, d_vr1)) |>
    select(id, office_id, female, year_school, d_vr1, D_vr1, last_month) |>
    uncount(last_month, .id = "d") |>
    mutate(P = as.integer(D_vr1 == 1L & d == d_vr1))

# Sanity: total Σ P skal være lik antall behandlede personer
stopifnot(sum(df_pm$P) == sum(df_person$D_vr1))

# 7. Ligning 2 — LPM-hazard på person-måned -------------------------------
# P_id regresseres på varighetsdummyer (factor(d)) og x. Residualene u_id
# fanger det som er igjen etter at varighet og x er trukket fra: kontor-
# kultur + støy.

mod_lig2 <- lm(P ~ factor(d) + female + year_school, data = df_pm)

df_pm <- df_pm |>
    mutate(u = resid(mod_lig2))

# 8. Ligning 3 — summer residualer per person → u_Si ----------------------
# u_Si er kovariatjustert overgangstilbøyelighet på klientnivå.
# By construction: mean(u_Si) ≈ 0 over hele utvalget.

df_resid <- df_pm |>
    summarise(u_sum = sum(u), .by = c(id, office_id))

df_resid |> summarise(mean_u = mean(u_sum), sd_u = sd(u_sum))

# 9. Ligning 4 og 5 — naïv vs jackknife-aggregering -----------------------
# Tre versjoner av instrumentet:
#   phi_truth  = sann kontorkultur z_office  (fasit, ikke observerbar)
#   phi_naive  = (1/N_j) Σ_{i ∈ j} u_Si      (ligning 4 — INKLUDERER egen)
#   phi_jack   = (Σ_{i ∈ j} u_Si − u_Si) / (N_j − 1)   (ligning 5)

df_resid <- df_resid |>
    mutate(
        sum_office = sum(u_sum),
        n_office   = n(),
        phi_naive  = sum_office / n_office,
        phi_jack   = (sum_office - u_sum) / (n_office - 1),
        .by = office_id
    ) |>
    left_join(office, by = "office_id") |>
    rename(phi_truth = z_office) |>
    select(-sum_office, -n_office)

# 10. Sett φ tilbake på persondata -----------------------------------------

df_data <- df_person |>
    select(id, office_id, eta, female, year_school, D_vr1, y) |>
    left_join(df_resid, by = c("id", "office_id"))

# Diagnose: korrelasjon mellom hver φ-versjon og personens egen η.
# Forventning:
#   cor(phi_truth, eta)  ≈ 0          (kontorkultur trukket uavhengig av η)
#   cor(phi_naive, eta)  > 0          (egen u_Si er med i snittet → smitte)
#   cor(phi_jack,  eta)  ≈ 0          (jackknife fjerner smitten)

diagnose <- df_data |>
    summarise(
        cor_truth_eta = cor(phi_truth, eta),
        cor_naive_eta = cor(phi_naive, eta),
        cor_jack_eta  = cor(phi_jack,  eta),
        cor_naive_D   = cor(phi_naive, D_vr1),
        cor_jack_D    = cor(phi_jack,  D_vr1)
    )
print(diagnose)

# 11. Kort IV-sjekk --------------------------------------------------------
# Sanity: instrumentet skal kunne brukes til å gjenfinne sann β = 30.
# OLS er biased nedover, IV med phi_jack bør lande i nærheten av 30.

ols <- lm(y ~ D_vr1 + female + year_school, data = df_data)

fn_iv <- function(phi_name) {
    fs_fml <- reformulate(c(phi_name, "female", "year_school"), "D_vr1")
    fs <- lm(fs_fml, data = df_data)
    df_data$D_hat <- predict(fs)
    lm(y ~ D_hat + female + year_school, data = df_data)
}

iv_truth <- fn_iv("phi_truth")
iv_naive <- fn_iv("phi_naive")
iv_jack  <- fn_iv("phi_jack")

stargazer(
    ols, iv_truth, iv_naive, iv_jack,
    type          = "text",
    omit.stat     = c("ser", "rsq", "f"),
    digits        = 2,
    column.labels = c("OLS", "IV truth", "IV naiv", "IV jack"),
    keep          = c("D_vr1", "D_hat"),
    notes         = paste0("Sann beta = ", beta_true,
                           ". Hazard-DGP, ligning 2 paa person-maaned,",
                           " phi.jack via leave-one-out paa kontor.")
)
