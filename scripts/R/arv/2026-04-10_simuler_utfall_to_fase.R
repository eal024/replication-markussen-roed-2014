# To-fase-DGP for IV-replikasjon av Markussen & Røed (2014).
#
# Endring fra 2026-04-10_simuler_utfall_data.R (v1):
#   - PDI er ikke lenger en konkurrerende første-hendelse i fase 1.
#   - Fase 1: VR-tildeling — kun VR1..VR4 er competing risks i 24 mnd.
#   - Fase 2: PDI-overgang som separat utfall, modellert som funksjon av
#     VR-deltakelse, kontorkultur (z_pdi), η og x.
#   - Y avhenger nå av både D_VR_k og D_pdi, men D_pdi er strukturelt
#     forskjellig fra VR-deltakelse — det er en post-VR-overgang.
#
# Begrunnelse: Den realistiske mekanismen er at VR har som mål å forhindre
# PDI. Personer kan delta i VR og senere ha overgang til PDI, og det er en
# seleksjonsmekanisme: hvilken VR-type man tildeles avhenger av risiko, og
# selve VR-deltakelsen har en kausal effekt på PDI-sannsynligheten.
#
# Identifikasjonsantakelse: kontorenes VR-strategi (z_vr1..z_vr4) påvirker
# PDI-overgang KUN gjennom hvilken VR-type de tildeler — ikke direkte.
# Operasjonelt: z_pdi trekkes ortogonalt på z_vr-vektoren. Dette gir
# beviselig konsistente IV-estimater i fase 2.
#
# Output: data/iv_replikasjon_to_fase.rds

# 1. Pakker ----------------------------------------------------------------

library(tidyverse)

# 2. Parametere ------------------------------------------------------------

set.seed(20260410)

n_persons     <- 50000
max_months    <- 24
vr_treatments <- c("vr1", "vr2", "vr3", "vr4")

# Sann behandlingseffekt på Y (post-TDI årlig arbeidsinntekt, 1000 NOK).
# Identisk med v1 — det er disse IV-estimatoren skal gjenfinne.
beta_true <- c(vr1 = 25, vr2 = 40, vr3 = 15, vr4 = 10, pdi = -200)

# Sann kausal effekt av VR_k på Pr(D_pdi).
# Baseline (non-treated) er 0.30. Mønsteret reflekterer artikkelens funn:
#   VR1 (subsidiert ord. arb.)  reduserer PDI mest                (-0.15)
#   VR2 (vernet bedrift)        ØKER PDI — "PDI-track"            (+0.10)
#   VR3 (utdanning)             reduserer mest, langsiktig        (-0.18)
#   VR4 (kurs)                  mild beskyttelse                  (-0.05)
gamma_pdi_baseline <- 0.30
gamma_pdi          <- c(vr1 = -0.15, vr2 = +0.10, vr3 = -0.18, vr4 = -0.05)

# Uobservert heterogenitet (η) — samme komponent driver både VR-tildeling,
# PDI-overgang og Y. Dette er det som skaper endogenitet og motiverer IV.
sigma_eta     <- 1
lambda_eta    <- -60     # η inn i Y (negativ: høy η = lav inntekt)
delta_eta_vr  <- 0.004   # η inn i VR-hazarder (positiv: mer behandling)
gamma_eta_pdi <- 0.05    # η inn i PDI-overgang (positiv: mer PDI)

# 3. Kontorkultur ----------------------------------------------------------
# z_vr1..z_vr4 identisk med v1 (kalibrert mot tabell 2).
# z_pdi konstrueres som en sentrert vektor som er ALGEBRAISK ORTOGONAL på
# z_vr-rommet (residualen fra en regresjon av en tilfeldig kandidat på de
# fire z_vr-kolonnene). Da vet vi at IV-strategien er beviselig konsistent
# i fase 2, fordi kontorets VR-strategi ikke direkte korrelerer med dens
# PDI-strenghet.

office_culture <- tibble(
    office_id = 1:10,
    z_vr1 = c(0.012, 0.003, 0.005, 0.004, 0.007, 0.008, 0.002, 0.010, 0.003, 0.001),
    z_vr2 = c(0.002, 0.008, 0.002, 0.003, 0.004, 0.005, 0.001, 0.002, 0.007, 0.001),
    z_vr3 = c(0.010, 0.012, 0.025, 0.015, 0.016, 0.020, 0.008, 0.018, 0.014, 0.006),
    z_vr4 = c(0.002, 0.002, 0.003, 0.008, 0.003, 0.004, 0.001, 0.003, 0.002, 0.001)
)

# Generer z_pdi ortogonalt på z_vr-rommet via OLS-residual
local({
    set.seed(42)  # lokal seed — påvirker ikke hovedseed
    candidate <- runif(10, -0.07, 0.07)
    Z_vr <- as.matrix(office_culture[, c("z_vr1", "z_vr2", "z_vr3", "z_vr4")])
    Z_vr_c <- scale(Z_vr, center = TRUE, scale = FALSE)
    # Project ut z_vr-rommet — det som gjenstår er ortogonalt på z_vr
    fit <- lm(candidate ~ Z_vr_c)
    z_orth <- residuals(fit)
    # Skaler så spennet er ca ±0.07 (matcher antatt PDI-prob-variasjon)
    z_orth <- z_orth * (0.14 / (max(z_orth) - min(z_orth)))
    z_orth <- z_orth - mean(z_orth)  # eksakt sentrert
    office_culture$z_pdi <<- z_orth
})

# Verifiser at z_pdi er ortogonal på z_vr-kolonnene
cat("\n--- Korrelasjon kontorkultur (z_pdi mot z_vr) ---\n")
print(round(cor(office_culture[, -1])[, "z_pdi"], 3))
cat("z_pdi spenn:", round(max(office_culture$z_pdi) - min(office_culture$z_pdi), 3), "\n")

# 4. Persondata ------------------------------------------------------------

df_person <- tibble(
    id          = 1:n_persons,
    office_id   = sample(1:10, n_persons, replace = TRUE),
    female      = sample(0:1, n_persons, replace = TRUE),
    year_school = sample(c(10, 13, 16, 18), n_persons,
                         prob = c(0.35, 0.45, 0.15, 0.05), replace = TRUE),
    eta         = rnorm(n_persons, 0, sigma_eta)
) |>
    mutate(educ_high = as.integer(year_school >= 16)) |>
    left_join(office_culture, by = "office_id")

# 5. Fase 1 — VR-tildeling -------------------------------------------------
# Fire VR-typer som competing risks i 24 mnd. Ingen PDI her.
# Hver person ender med én av: D_vr1=1, D_vr2=1, D_vr3=1, D_vr4=1, eller
# alle null (ikke-VR-behandlet i 24-måneders-vinduet).

df_person <- df_person |>
    mutate(
        h_vr1 = pmax(0.002 + 0.0010 * female + 0.0010 * educ_high + z_vr1 + delta_eta_vr * eta, 1e-6),
        h_vr2 = pmax(0.001 + 0.0005 * female + 0.0005 * educ_high + z_vr2 + delta_eta_vr * eta, 1e-6),
        h_vr3 = pmax(0.003 + 0.0020 * female + 0.0010 * educ_high + z_vr3 + delta_eta_vr * eta, 1e-6),
        h_vr4 = pmax(0.001 + 0.0005 * female + 0.0005 * educ_high + z_vr4 + delta_eta_vr * eta, 1e-6),
        t_vr1 = rgeom(n(), h_vr1) + 1L,
        t_vr2 = rgeom(n(), h_vr2) + 1L,
        t_vr3 = rgeom(n(), h_vr3) + 1L,
        t_vr4 = rgeom(n(), h_vr4) + 1L,
        t_first = pmin(t_vr1, t_vr2, t_vr3, t_vr4),
        vr_event_type = case_when(
            t_first > max_months ~ "none",
            t_first == t_vr1     ~ "vr1",
            t_first == t_vr2     ~ "vr2",
            t_first == t_vr3     ~ "vr3",
            t_first == t_vr4     ~ "vr4"
        ),
        event_month = if_else(t_first <= max_months, t_first, NA_integer_),
        D_vr1 = as.integer(vr_event_type == "vr1"),
        D_vr2 = as.integer(vr_event_type == "vr2"),
        D_vr3 = as.integer(vr_event_type == "vr3"),
        D_vr4 = as.integer(vr_event_type == "vr4")
    )

# 6. Fase 2 — PDI-overgang -------------------------------------------------
# Lineær sannsynlighetsmodell på person-nivå. PDI inntreffer som et
# separat utfall etter VR-fasen, betinget på VR-deltakelse, kontorets
# PDI-strenghet (z_pdi), η og x.

df_person <- df_person |>
    mutate(
        p_pdi = gamma_pdi_baseline +
            gamma_pdi["vr1"] * D_vr1 +
            gamma_pdi["vr2"] * D_vr2 +
            gamma_pdi["vr3"] * D_vr3 +
            gamma_pdi["vr4"] * D_vr4 +
            gamma_eta_pdi * eta +
            z_pdi +                                       # kontorkultur
            (-0.05) * (year_school - 10) / 8 +            # mild utdanningseffekt
            0.02 * female,                                # mild kjønnsforskjell
        # Klipp ved [0.001, 0.999] for å unngå Bernoulli-feil i halen
        p_pdi = pmin(pmax(p_pdi, 0.001), 0.999),
        D_pdi = rbinom(n(), 1, p_pdi)
    )

# Sjekk: PDI-andel per VR-gruppe — skal være nær gamma_pdi_baseline + gamma_pdi[k]
cat("\n--- Sjekk: gjennomsnittlig Pr(D_pdi) per VR-gruppe ---\n")
target_lookup <- tibble(
    vr_event_type = c("none", "vr1", "vr2", "vr3", "vr4"),
    target_prob   = gamma_pdi_baseline + c(0, gamma_pdi[c("vr1", "vr2", "vr3", "vr4")])
)
df_person |>
    summarise(
        n         = n(),
        share_pdi = round(mean(D_pdi), 3),
        .by = vr_event_type
    ) |>
    left_join(target_lookup, by = "vr_event_type") |>
    mutate(target_prob = round(target_prob, 3)) |>
    arrange(vr_event_type) |>
    print()

# 7. Fase 3 — Y (post-TDI inntekt) ----------------------------------------
# Y avhenger nå av både D_VR_k og D_pdi. β_PDI = -200 trekker
# PDI-mottakere mot censureringsterskelen og gir den karakteristiske
# venstre-trunkerte fordelingen.

alpha_y      <- 250
gamma_female <- -25
gamma_school <-  15
sigma_eps    <-  50

df_person <- df_person |>
    mutate(
        y_latent = alpha_y +
            beta_true["vr1"] * D_vr1 +
            beta_true["vr2"] * D_vr2 +
            beta_true["vr3"] * D_vr3 +
            beta_true["vr4"] * D_vr4 +
            beta_true["pdi"] * D_pdi +
            gamma_female * female +
            gamma_school * (year_school - 10) +
            lambda_eta   * eta +
            rnorm(n(), 0, sigma_eps),
        y = pmax(0, round(y_latent))
    )

cat("\n--- Sjekk: Y, andel nuller, η per gruppe ---\n")
df_person |>
    summarise(
        n          = n(),
        y_mean     = round(mean(y), 1),
        zero_share = round(mean(y == 0), 3),
        eta_mean   = round(mean(eta), 2),
        pdi_share  = round(mean(D_pdi), 3),
        .by = vr_event_type
    ) |>
    arrange(vr_event_type) |>
    print()

# 8. Ligning 2 — VR-residualer i person-måned-format ---------------------
# Identisk pipeline som i v1: bygg person-måned-data, estimer LPM per
# VR-type, hent residualer, summer per person.

df_pm <- df_person |>
    mutate(last_month = if_else(is.na(event_month), max_months, event_month)) |>
    select(id, office_id, female, year_school, vr_event_type, event_month, last_month) |>
    uncount(last_month, .id = "time") |>
    mutate(
        P_vr1 = as.integer(vr_event_type == "vr1" & time == event_month),
        P_vr2 = as.integer(vr_event_type == "vr2" & time == event_month),
        P_vr3 = as.integer(vr_event_type == "vr3" & time == event_month),
        P_vr4 = as.integer(vr_event_type == "vr4" & time == event_month)
    )

models_lig2 <- map(vr_treatments, \(trt) {
    fml <- reformulate(c("factor(time)", "female", "year_school"), paste0("P_", trt))
    lm(fml, data = df_pm)
}) |>
    set_names(vr_treatments)

resid_cols <- map(models_lig2, resid) |>
    set_names(paste0("resid_", vr_treatments)) |>
    as_tibble()

df_pm <- bind_cols(df_pm, resid_cols)

df_resid_vr <- df_pm |>
    summarise(
        across(starts_with("resid_"), sum),
        .by = c(id, office_id)
    ) |>
    rename_with(\(x) str_replace(x, "resid_", "u_"), starts_with("resid_"))

rm(df_pm, resid_cols)
gc()

# 9. PDI-residual — person-nivå LPM ---------------------------------------
# PDI har ingen tidsdimensjon i vår to-fase-DGP, så vi konstruerer
# residualene fra en person-nivå LPM (D_pdi ~ x). Dette er den enkleste
# parallellen til ligning 2, og er fortsatt en gyldig leave-one-out-
# konstruksjon når den jackknifes per kontor i neste steg.

mod_pdi_lpm <- lm(D_pdi ~ female + year_school, data = df_person)
df_person$u_pdi <- as.numeric(resid(mod_pdi_lpm))

# 10. Leave-one-out instrument (ligning 5) -------------------------------
# Z_Si = (Σ_{k på samme kontor} u_Sk − u_Si) / (n_kontor − 1)

df_resid_vr <- reduce(vr_treatments, \(df, trt) {
    u_col <- paste0("u_", trt)
    z_col <- paste0("Z_", trt)
    df |>
        mutate(
            !!z_col := (sum(.data[[u_col]]) - .data[[u_col]]) / (n() - 1),
            .by = office_id
        )
}, .init = df_resid_vr)

df_person <- df_person |>
    mutate(
        Z_pdi = (sum(u_pdi) - u_pdi) / (n() - 1),
        .by = office_id
    )

# 11. Normalisering — min/maks-spenn per kontor --------------------------
# Identisk med v1: koeffisient på Z tolkes som «effekten av å gå fra
# minst til mest aktive kontor».

z_ranges_vr <- map_dbl(vr_treatments, \(trt) {
    z_col <- paste0("Z_", trt)
    office_means <- df_resid_vr |>
        summarise(mean_z = mean(.data[[z_col]]), .by = office_id)
    max(office_means$mean_z) - min(office_means$mean_z)
}) |>
    set_names(vr_treatments)

cat("\n--- Z-spenn per behandling ---\n")
print(round(z_ranges_vr, 4))

df_resid_vr <- reduce(vr_treatments, \(df, trt) {
    z_col      <- paste0("Z_", trt)
    z_norm_col <- paste0("Z_", trt, "_norm")
    df |> mutate(!!z_norm_col := .data[[z_col]] / z_ranges_vr[trt])
}, .init = df_resid_vr)

# Z_pdi normalisert
z_pdi_office_means <- df_person |>
    summarise(mean_z = mean(Z_pdi), .by = office_id)
z_pdi_range <- max(z_pdi_office_means$mean_z) - min(z_pdi_office_means$mean_z)

df_person <- df_person |>
    mutate(Z_pdi_norm = Z_pdi / z_pdi_range)

cat("Z_pdi-spenn:", round(z_pdi_range, 4), "\n")

# 12. Sett sammen endelig persondatasett ---------------------------------

df_data <- df_person |>
    select(id, office_id, female, year_school, educ_high, eta, vr_event_type,
           event_month, starts_with("D_"), y, y_latent, p_pdi, Z_pdi_norm) |>
    left_join(
        df_resid_vr |> select(id, starts_with("Z_") & ends_with("_norm")),
        by = "id"
    )

# Sannhetsverdier som metadata — leses inn av modellskriptet
attr(df_data, "beta_true")          <- beta_true
attr(df_data, "gamma_pdi")          <- c(baseline = gamma_pdi_baseline, gamma_pdi)
attr(df_data, "lambda_eta")         <- lambda_eta
attr(df_data, "alpha_y")            <- alpha_y
attr(df_data, "gamma_female")       <- gamma_female
attr(df_data, "gamma_school")       <- gamma_school

# 13. Lagre datasettet ---------------------------------------------------

dir.create(here::here("data"), showWarnings = FALSE)
saveRDS(df_data, here::here("data", "iv_replikasjon_to_fase.rds"))

cat("\n--- Endelig datasett ---\n")
glimpse(df_data)
