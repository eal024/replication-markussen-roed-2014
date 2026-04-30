# Estimering — Markussen & Røed (2014), to-fase-DGP
# Leser simulert datasett og estimerer:
#   1. Deskriptiv tabell  (sammenligning med tabell 1)
#   2. Naiv OLS           (Y på D + x)
#   3. Tabell 2           (relevanstest: D på alle Z + x)
#   4. Reduced form / tabell 3  (Y på Z + x)
#   5. IV / tabell 4      — TRE spesifikasjoner:
#        5a. HOVED   (artikkel-tro): 4 endogene VR, D_pdi som kontroll
#        5b. UTVIDET (test):         5 endogene inkl. D_pdi
#        5c. PDI-UTFALL (artikkel):  D_pdi som venstresidevariabel
#   6. Sammenligning med sann β
#
# DGP-en er to-fase: VR-tildeling (fase 1) → PDI-overgang (fase 2). Se
# 2026-04-10_simuler_utfall_to_fase.R for detaljer. Datasettet vi leser
# inn er data/iv_replikasjon_to_fase.rds.

# 1. Pakker og data --------------------------------------------------------

library(tidyverse)
library(fixest)

df <- readRDS(here::here("data", "iv_replikasjon_to_fase.rds"))

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

treatments    <- c("vr1", "vr2", "vr3", "vr4", "pdi")
vr_treatments <- c("vr1", "vr2", "vr3", "vr4")        # uten PDI — artikkelens P_i
d_cols        <- paste0("D_", treatments)
z_cols        <- paste0("Z_", treatments, "_norm")
d_vr_cols     <- paste0("D_", vr_treatments)
z_vr_cols     <- paste0("Z_", vr_treatments, "_norm")
controls      <- c("female", "year_school")

# Sann γ_VR_k for PDI-utfall (fase 2 i DGP-en) — for sammenligning i 7c
gamma_pdi_true <- attr(df, "gamma_pdi")

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
    ~vr_event_type, ~art_female, ~art_school, ~art_empl_post,
    "none",         0.572,       10.6,        0.462,
    "vr1",          0.526,       10.5,        0.476,
    "vr2",          0.485,       10.1,        0.204,
    "vr3",          0.521,       10.6,        0.598,
    "vr4",          0.516,       10.4,        0.504
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
        pdi_share      = round(mean(D_pdi), 3),
        duration_mean  = round(mean(if_else(is.na(event_month), 24L, event_month)), 1),
        .by = vr_event_type
    ) |>
    left_join(article_tab1, by = "vr_event_type") |>
    arrange(factor(vr_event_type, levels = c("none", "vr1", "vr2", "vr3", "vr4")))

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
# Multi-endogen IV. fixest-syntaks: y ~ eksogene | fe | endogene ~ instrumenter
# Ingen FE her, så | 0 |.
#
# Tre spesifikasjoner — se også log/2026-04-08_gjennomgang_empirisk_strategi.md
# for begrunnelsen av hver:
#
#   6a. HOVEDSPESIFIKASJON (artikkel-tro, ligning 6):
#       Kun fire endogene VR-dummyer (D_vr1..D_vr4) instrumentert med
#       Z_vr1..Z_vr4. PDI-personer beholdes i utvalget med alle fire
#       D = 0 → de havner i referansegruppen sammen med non-treated.
#       β_VR_k tolkes som «effekt av å starte med VR_k relativt til
#       ikke-VR-behandlet (inkluderer både non-treated og PDI)».
#
#   6b. UTVIDET SPESIFIKASJON (vår pedagogiske test):
#       Alle fem D-dummyer som endogene, instrumentert med fem Z.
#       Lar oss teste IV-recovery også for β_PDI = -200. Avvik fra
#       artikkelen: i M&R (2014) er PDI et utfall, ikke en behandling.
#
#   6c. PDI SOM UTFALL (artikkel-tro alternativ utfallsligning):
#       Venstresiden er D_pdi (havne på PDI). Endogene: D_vr1..D_vr4
#       instrumentert med Z_vr1..Z_vr4. Effekt av å starte med VR_k
#       på sannsynligheten for å havne på PDI — én av kolonnene i
#       artikkelens tabell 4. NB: i vår DGP er hver person enten VR
#       ELLER PDI (én hendelse pr. person), så denne effekten er
#       mekanisk competing-risks i utvalget vårt — ikke en
#       atferdsrespons. Tolkes med varsomhet.

# 6a. Hovedspesifikasjon — fire VR-endogene
fml_iv_main <- as.formula(
    paste0("y ~ ", paste(controls, collapse = " + "),
           " | 0 | ",
           paste(d_vr_cols, collapse = " + "),
           " ~ ",
           paste(z_vr_cols, collapse = " + "))
)
model_iv_main <- feols(fml_iv_main, data = df)

# 6b. Utvidet spesifikasjon — alle fem endogene
fml_iv_ext <- as.formula(
    paste0("y ~ ", paste(controls, collapse = " + "),
           " | 0 | ",
           paste(d_cols, collapse = " + "),
           " ~ ",
           paste(z_cols, collapse = " + "))
)
model_iv_ext <- feols(fml_iv_ext, data = df)

# 6c. PDI som utfall — D_pdi på venstre side
fml_iv_pdi_outcome <- as.formula(
    paste0("D_pdi ~ ", paste(controls, collapse = " + "),
           " | 0 | ",
           paste(d_vr_cols, collapse = " + "),
           " ~ ",
           paste(z_vr_cols, collapse = " + "))
)
model_iv_pdi_outcome <- feols(fml_iv_pdi_outcome, data = df)

# 7. Sammenligning sann β / OLS / RF / IV ---------------------------------
# 7a. Hovedtabell (artikkel-tro IV) — fire VR-behandlinger
# 7b. Utvidet IV-tabell (vår test) — alle fem behandlinger
# 7c. PDI som utfall — effekt av VR_k på Pr(PDI)

# 7a. Hovedspesifikasjon
ols_coef_main <- coef(model_ols)[d_vr_cols]
rf_coef_main  <- coef(model_rf)[z_vr_cols]
iv_coef_main  <- coef(model_iv_main)[paste0("fit_", d_vr_cols)]

ols_se_main <- sqrt(diag(vcov(model_ols)))[d_vr_cols]
rf_se_main  <- sqrt(diag(vcov(model_rf)))[z_vr_cols]
iv_se_main  <- sqrt(diag(vcov(model_iv_main)))[paste0("fit_", d_vr_cols)]

results_main <- tibble(
    treatment = toupper(vr_treatments),
    beta_true = beta_true[vr_treatments],
    ols_est   = round(ols_coef_main, 2),
    ols_se    = round(ols_se_main, 2),
    rf_est    = round(rf_coef_main, 2),
    rf_se     = round(rf_se_main, 2),
    iv_est    = round(iv_coef_main, 2),
    iv_se     = round(iv_se_main, 2),
    ols_bias  = round(ols_coef_main - beta_true[vr_treatments], 2),
    iv_bias   = round(iv_coef_main - beta_true[vr_treatments], 2)
)

cat("\n--- 3a. HOVEDSPESIFIKASJON (artikkel-tro): OLS, RF, IV per VR (1 000 NOK) ---\n")
cat("4 endogene VR. PDI-personer i referansegruppen sammen med non-treated.\n")
cat("Sann β vs. estimater. Forventning: OLS skjev nedover, IV gjenfinner β\n\n")
print(results_main, n = Inf)

# 7b. Utvidet spesifikasjon (alle fem)
ols_coef_ext <- coef(model_ols)[d_cols]
iv_coef_ext  <- coef(model_iv_ext)[paste0("fit_", d_cols)]
ols_se_ext   <- sqrt(diag(vcov(model_ols)))[d_cols]
iv_se_ext    <- sqrt(diag(vcov(model_iv_ext)))[paste0("fit_", d_cols)]

results_ext <- tibble(
    treatment = toupper(treatments),
    beta_true = beta_true,
    ols_est   = round(ols_coef_ext, 2),
    ols_se    = round(ols_se_ext, 2),
    iv_est    = round(iv_coef_ext, 2),
    iv_se     = round(iv_se_ext, 2),
    iv_bias   = round(iv_coef_ext - beta_true, 2)
)

cat("\n--- 3b. UTVIDET SPESIFIKASJON (vår test): IV med 5 endogene inkl. PDI ---\n")
cat("Avvik fra artikkelen — PDI som endogen behandling. Tester β_PDI = -200.\n\n")
print(results_ext, n = Inf)

# 7c. PDI som utfall
iv_coef_pdi <- coef(model_iv_pdi_outcome)[paste0("fit_", d_vr_cols)]
iv_se_pdi   <- sqrt(diag(vcov(model_iv_pdi_outcome)))[paste0("fit_", d_vr_cols)]

# Mekanisk benchmark: Pr(PDI | non-VR) i utvalget — siden vår DGP gir
# competing risks med kun én hendelse pr. person, vil VR_k = 1 mekanisk
# implisere D_pdi = 0. «Sann effekt» av VR_k på D_pdi er derfor ≈ −Pr(PDI)
# i kontrollgruppen. Reell M&R-tolkning krever flere overganger pr.
# person og lengre observasjonsvindu — vi har det ikke her.
pdi_rate_nonvr <- mean(df$D_pdi[df$D_vr1 == 0 & df$D_vr2 == 0 &
                                df$D_vr3 == 0 & df$D_vr4 == 0])

results_pdi_outcome <- tibble(
    treatment       = toupper(vr_treatments),
    iv_est          = round(iv_coef_pdi, 4),
    iv_se           = round(iv_se_pdi, 4),
    mech_benchmark  = round(-pdi_rate_nonvr, 4)
)

cat("\n--- 3c. PDI SOM UTFALL: D_pdi ~ D_vr1..D_vr4 (instrumentert) ---\n")
cat("Effekt av å starte med VR_k på Pr(D_pdi). Mekanisk benchmark =\n")
cat("  −Pr(PDI | ingen VR) =", round(-pdi_rate_nonvr, 4), "\n")
cat("(competing-risks-mekanikk i vår DGP, ikke en atferdsrespons —\n")
cat(" tolkes med varsomhet, se kommentar i kildekoden)\n\n")
print(results_pdi_outcome)

cat("\n--- 4. Naiv OLS (alle koeffisienter) ---\n")
summary(model_ols)

cat("\n--- 5a. IV hovedspesifikasjon (4 VR-endogene) ---\n")
summary(model_iv_main)

cat("\n--- 5b. IV utvidet spesifikasjon (5 endogene inkl. PDI) ---\n")
summary(model_iv_ext)

cat("\n--- 5c. IV PDI som utfall ---\n")
summary(model_iv_pdi_outcome)
