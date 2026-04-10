# Estimering — Markussen & Røed (2014)
# Leser simulert datasett og estimerer:
#   1. Deskriptiv tabell  (sammenligning med tabell 1)
#   2. Naiv OLS           (Y på D + x)
#   3. Tabell 2           (relevanstest: D på alle Z + x)
#   4. Reduced form / tabell 3  (Y på Z + x)
#   5. IV / tabell 4      (Y på D + x | Z + x)
#   6. Sammenligning med sann β
#
# All datakonstruksjon (DGP, ligning 2, jackknife) ligger i
# 2026-04-10_simuler_utfall_data.R. Dette skriptet inneholder ingen
# DGP-logikk — kun innlesning og estimering.

# 1. Pakker og data --------------------------------------------------------

library(tidyverse)
library(fixest)

df <- readRDS(here::here("data", "iv_replikasjon.rds"))

# Sann β er lagret som attributt på datarammen i dataskriptet
# (`attr(df_data, "beta_true") <- beta_true` før saveRDS).
#
# Hvorfor denne løsningen?
#   1. DRY: parameterverdiene defineres ÉN gang — i dataskriptet — og
#      «reiser med» datasettet via .rds-fila. Vi unngår å hardkode de
#      samme tallene to steder.
#   2. Selvkonsistens: hvis vi endrer beta_true i dataskriptet og
#      re-genererer datasettet, henter modellskriptet automatisk de
#      nye verdiene neste gang det kjører — sammenligningen
#      «sann β vs IV-estimat» kan aldri komme ut av synk.
#   3. Ren separasjon: dataskriptet kjenner DGP-en, modellskriptet
#      trenger bare lese sannheten ut for å validere mot estimatene.
#
# attr() er R-måten å henge metadata på et objekt uten å forstyrre
# innholdet — dataframen oppfører seg helt likt, men har en ekstra
# "beta_true"-lapp festet på.
beta_true <- attr(df, "beta_true")

treatments <- c("vr1", "vr2", "vr3", "vr4", "pdi")
d_cols     <- paste0("D_", treatments)
z_cols     <- paste0("Z_", treatments, "_norm")
controls   <- c("female", "year_school")

# 2. Deskriptiv tabell -----------------------------------------------------
# Verifiserer at simulerte data er nære artikkelens tabell 1 (s. 12).
# Datasettet inneholder kun et redusert sett kontrollvariabler:
#   female, year_school, eta, event_type, event_month
# Aldre, innvandring, tidligere inntekt mv. er ikke konstruert i denne
# DGP-strømmen — det ligger i 01_simuler_data.R og kan kobles inn senere.
#
# Forventning:
#   - Female-andel ~50 % i alle grupper (random tilordning, ikke korrelert
#     med behandling i vår DGP — i artikkelen varierer den 48–57 %)
#   - year_school-snitt ~12.6 (vår sample er 10/13/16/18 med vekter
#     35/45/15/5 — høyere enn artikkelens ~10.5 år)
#   - empl_post (proxy: y > 0) varierer mest mellom PDI og resten
#
# Artikkelverdier (tabell 1, s. 12):
#   non_treated: n=176340, female=0.572, school=10.6, empl_post=0.462
#   VR1:         n=38842,  female=0.526, school=10.5, empl_post=0.476
#   VR2:         n=19393,  female=0.485, school=10.1, empl_post=0.204
#   VR3:         n=92476,  female=0.521, school=10.6, empl_post=0.598
#   VR4:         n=18056,  female=0.516, school=10.4, empl_post=0.504

article_tab1 <- tribble(
    ~event_type, ~art_female, ~art_school, ~art_empl_post,
    "none",      0.572,       10.6,        0.462,
    "vr1",       0.526,       10.5,        0.476,
    "vr2",       0.485,       10.1,        0.204,
    "vr3",       0.521,       10.6,        0.598,
    "vr4",       0.516,       10.4,        0.504,
    "pdi",       NA,          NA,          NA
)

descriptive <- df |>
    summarise(
        n              = n(),
        share          = n() / nrow(df),
        female         = round(mean(female), 3),
        year_school    = round(mean(year_school), 2),
        empl_post      = round(mean(y > 0), 3),
        y_mean         = round(mean(y), 1),
        y_pos_mean     = round(mean(y[y > 0]), 1),
        duration_mean  = round(mean(if_else(is.na(event_month), 24L, event_month)), 1),
        .by = event_type
    ) |>
    left_join(article_tab1, by = "event_type") |>
    arrange(factor(event_type, levels = c("none", "vr1", "vr2", "vr3", "vr4", "pdi")))

cat("\n--- 1. Deskriptiv tabell ---\n")
cat("Vår DGP vs. artikkelens tabell 1 (kolonner med 'art_' er artikkelen)\n\n")
print(descriptive, n = Inf, width = Inf)

# 3. Naiv OLS --------------------------------------------------------------
# Y = α + Σ β_S · D_S + γ·x + u
#
# Forventning: koeffisientene er biased nedover fordi behandlede har
# systematisk høyere η (uobservert dårlig tilstand), og η går negativt
# inn i Y. cov(D, η) > 0 og λ_η < 0 ⇒ E[β̂_OLS] < β_sann.

fml_ols <- reformulate(c(d_cols, controls), "y")

model_ols <- feols(fml_ols, data = df)

# 4. Tabell 2 — relevanstest (5×5 matrise) --------------------------------
# Regresjon: D_S = α + Σ_k φ_k · Z_k_norm + γ·x + u, én per behandling.
# Diagonalen viser at φ_S predikerer D_S (egen instrument). Off-diagonal
# kan plukke opp PDI-spillover (artikkelen, s. 18: streng PDI-praksis →
# raskere overgang til alle VR-tiltak).
#
# I artikkelen estimeres dette på person-måned-data; vår tilsvarer det
# kumulative person-nivå-utvalget. Konseptuelt samme test: er instrumentet
# relevant for behandlingsplassering?

models_tab2 <- map(treatments, \(trt) {
    fml <- reformulate(c(z_cols, controls), paste0("D_", trt))
    feols(fml, data = df)
}) |>
    set_names(treatments)

# 5×5 koeffisientmatrise med signifikansstjerner
tab2_matrix <- map_dfr(treatments, \(outcome) {
    mod   <- models_tab2[[outcome]]
    coefs <- coef(mod)
    ses   <- sqrt(diag(vcov(mod)))

    row <- map_chr(treatments, \(instr) {
        z_name <- paste0("Z_", instr, "_norm")
        b   <- coefs[z_name]
        se  <- ses[z_name]
        t   <- b / se
        sig <- case_when(
            abs(t) > 2.576 ~ "***",
            abs(t) > 1.960 ~ "**",
            abs(t) > 1.645 ~ "*",
            TRUE           ~ "   "
        )
        sprintf("%7.3f%s", b, sig)
    })

    tibble(
        D_utfall = toupper(outcome),
        VR1 = row[1], VR2 = row[2], VR3 = row[3],
        VR4 = row[4], PDI = row[5]
    )
})

# F-statistikk per behandling (samlet test av alle Z)
fs_summary <- map_dfr(treatments, \(trt) {
    mod      <- models_tab2[[trt]]
    waldtest <- wald(mod, keep = "Z_", print = FALSE)
    tibble(
        treatment = toupper(trt),
        F_stat    = round(waldtest$stat, 1),
        p_value   = waldtest$p
    )
})

cat("\n--- 2. Tabell 2 — relevansmatrise (D_S på alle Z) ---\n")
cat("Diagonalen skal være sterk og signifikant; off-diagonal svak\n")
cat("(unntatt PDI-kolonnen som bør predikere VR positivt — spillover)\n\n")
print(tab2_matrix, n = Inf)

cat("\n--- Førstesteg F-statistikk per behandling ---\n")
print(fs_summary)

# 5. Reduced form (tabell 3) ----------------------------------------------
# Y = α + Σ φ_S · Z_S + γ·x + v
#
# Totaleffekten av kontorets behandlingsstrategi på utfallet — uten å
# gå via faktisk deltakelse. Krever IKKE eksklusjonsrestriksjonen, så
# tolkes som en intent-to-treat-effekt: «hvor mye påvirker det å bli
# plassert på et aktivt kontor utfallet, gjennom alle kanaler?»

fml_rf <- reformulate(c(z_cols, controls), "y")

model_rf <- feols(fml_rf, data = df)

# 6. IV — 2SLS (tabell 4) -------------------------------------------------
# Multi-endogen IV: D_vr1, ..., D_pdi instrumentert med Z_vr1_norm, ..., Z_pdi_norm.
# fixest-syntaks: y ~ eksogene | fe | endogene ~ instrumenter
# Ingen FE her, så | 0 |.

fml_iv <- as.formula(
    paste0("y ~ ", paste(controls, collapse = " + "),
           " | 0 | ",
           paste(d_cols, collapse = " + "),
           " ~ ",
           paste(z_cols, collapse = " + "))
)

model_iv <- feols(fml_iv, data = df)

# 7. Sammenligning sann β / OLS / RF / IV ---------------------------------

ols_coef <- coef(model_ols)[d_cols]
rf_coef  <- coef(model_rf)[z_cols]
iv_coef  <- coef(model_iv)[paste0("fit_", d_cols)]

ols_se <- sqrt(diag(vcov(model_ols)))[d_cols]
rf_se  <- sqrt(diag(vcov(model_rf)))[z_cols]
iv_se  <- sqrt(diag(vcov(model_iv)))[paste0("fit_", d_cols)]

results <- tibble(
    treatment = toupper(treatments),
    beta_true = beta_true,
    ols_est   = round(ols_coef, 2),
    ols_se    = round(ols_se, 2),
    rf_est    = round(rf_coef, 2),
    rf_se     = round(rf_se, 2),
    iv_est    = round(iv_coef, 2),
    iv_se     = round(iv_se, 2),
    ols_bias  = round(ols_coef - beta_true, 2),
    iv_bias   = round(iv_coef - beta_true, 2)
)

cat("\n--- 3. OLS, RF og IV per behandling (1 000 NOK) ---\n")
cat("Sann β vs. estimater. Forventning: OLS skjev nedover, IV gjenfinner β\n\n")
print(results, n = Inf)

cat("\n--- 4. Naiv OLS (alle koeffisienter) ---\n")
summary(model_ols)

cat("\n--- 5. IV (2SLS) ---\n")
summary(model_iv)
