# Simulerer datasett med utfall (Y), sann behandlingseffekt (β) og
# leave-one-out-instrument (Z). Klargjør datagrunnlaget for reduced form
# (tabell 3) og IV (tabell 4) i Markussen & Røed (2014).
#
# Forskjellen fra 2026-04-09_replikasjon_hazard_event_data.R:
#   - Legger til uobservert heterogenitet η som påvirker BÅDE seleksjon
#     (hvem som får behandling) OG utfall (Y) → gir OLS-skjevhet
#   - Innfører sann behandlingseffekt β_S per behandling
#   - Genererer Y = α + Σ β_S · D_S + γ·x + λ·η + ε
#   - Lagrer ferdig persondatasett (Y, D, x, Z) til data/
#
# Modelleringen (OLS, RF, IV) ligger i 2026-04-10_estimering_rf_iv.R
# slik at modellskriptet starter med innlesing av data.

# 1. Pakker ----------------------------------------------------------------

library(tidyverse)

# 2. Parametere ------------------------------------------------------------

set.seed(20260410)

n_persons  <- 50000
max_months <- 24
treatments <- c("vr1", "vr2", "vr3", "vr4", "pdi")

# Sann behandlingseffekt på post-TDI årlig arbeidsinntekt (1 000 NOK).
# Disse er hva IV-estimatoren skal gjenfinne.
#   VR1 (formidling)         positiv  — hjelper folk i jobb
#   VR2 (lønnstilskudd)      sterk positiv — direkte jobbeffekt
#   VR3 (utdanning)          positiv, men forsinket
#   VR4 (kurs)               liten positiv
#   PDI (varig uføre)        sterkt negativ — forlater arbeidsmarkedet
# β_PDI er kalibrert såpass sterk at PDI-mottakere ofte havner under
# null på den latente skalaen og dermed sensureres til 0 (se seksjon 6).
beta_true <- c(vr1 = 25, vr2 = 40, vr3 = 15, vr4 = 10, pdi = -200)

# Uobservert helse/motivasjon (η):
#   Høy η = dårlig underliggende tilstand
#   → øker hazard for behandling (mer alvorlige saker behandles raskere)
#   → reduserer utfallet Y (dårligere baseline jobbutsikter)
# Dette er kilden til OLS-skjevhet: behandlede har systematisk høyere η,
# så naiv OLS undervurderer den sanne β.
sigma_eta   <- 1
lambda_eta  <- -60   # η inn i utfall: −60 × η
delta_eta   <- 0.004 # η inn i hazarder: +0.004 × η

# 3. Kontorkultur ----------------------------------------------------------
# Samme 10-kontor-struktur som i 2026-04-09-skriptet (kalibrert mot tabell 2).
# Identisk seed-uavhengig av hazardskriptet — vi skal bruke disse til å
# konstruere eksogen variasjon i Z.

office_culture <- tibble(
    office_id = 1:10,
    z_vr1 = c(0.012, 0.003, 0.005, 0.004, 0.007, 0.008, 0.002, 0.010, 0.003, 0.001),
    z_vr2 = c(0.002, 0.008, 0.002, 0.003, 0.004, 0.005, 0.001, 0.002, 0.007, 0.001),
    z_vr3 = c(0.010, 0.012, 0.025, 0.015, 0.016, 0.020, 0.008, 0.018, 0.014, 0.006),
    z_vr4 = c(0.002, 0.002, 0.003, 0.008, 0.003, 0.004, 0.001, 0.003, 0.002, 0.001),
    z_pdi = c(0.006, 0.008, 0.010, 0.009, 0.018, 0.014, 0.005, 0.008, 0.016, 0.004)
)

pdi_spillover <- 0.1   # se 2026-04-09-skriptet for begrunnelse

# 4. Persondata ------------------------------------------------------------
# Hver person får tildelt kontor, kjønn, utdanning og en uobservert
# helsekomponent η. η er nøkkelen til både seleksjonen og bias-en i OLS.
#
# Utdanning konstrueres i antall år skolegang etter SSB-konvensjon
# (verdier kan justeres senere):
#   10 = grunnskole
#   13 = videregående  (10 + 3)
#   16 = bachelor / 1.-3.-årig høyskole  (10 + 6)
#   18 = master / 4.-5.-årig høyskole  (10 + 8)
# Andelene speiler en TDI-populasjon med lavere utdanning enn snittet:
#   grunnskole 35 %, vgs 45 %, bachelor 15 %, master 5 %.
# Den binære educ_high (≥16) avledes for hazardene — den bevarer
# kalibreringen av tabell 2 fra 2026-04-09-skriptet.

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

# 5. Hazarder + competing risks --------------------------------------------
# Månedlig hazard avhenger nå av η i tillegg til x og kontorkultur.
# Maks(.,1e-6) for å unngå numeriske problemer hvis hazard blir negativ
# på halen av η-fordelingen.

df_person <- df_person |>
    mutate(
        h_vr1 = pmax(0.002 + 0.0010 * female + 0.0010 * educ_high + z_vr1 + pdi_spillover * z_pdi + delta_eta * eta, 1e-6),
        h_vr2 = pmax(0.001 + 0.0005 * female + 0.0005 * educ_high + z_vr2 + pdi_spillover * z_pdi + delta_eta * eta, 1e-6),
        h_vr3 = pmax(0.003 + 0.0020 * female + 0.0010 * educ_high + z_vr3 + pdi_spillover * z_pdi + delta_eta * eta, 1e-6),
        h_vr4 = pmax(0.001 + 0.0005 * female + 0.0005 * educ_high + z_vr4 + pdi_spillover * z_pdi + delta_eta * eta, 1e-6),
        h_pdi = pmax(0.002 + 0.0010 * female + 0.0010 * educ_high + z_pdi + delta_eta * eta, 1e-6),
        t_vr1 = rgeom(n(), h_vr1) + 1L,
        t_vr2 = rgeom(n(), h_vr2) + 1L,
        t_vr3 = rgeom(n(), h_vr3) + 1L,
        t_vr4 = rgeom(n(), h_vr4) + 1L,
        t_pdi = rgeom(n(), h_pdi) + 1L,
        t_first = pmin(t_vr1, t_vr2, t_vr3, t_vr4, t_pdi),
        event_type = case_when(
            t_first > max_months ~ "none",
            t_first == t_vr1     ~ "vr1",
            t_first == t_vr2     ~ "vr2",
            t_first == t_vr3     ~ "vr3",
            t_first == t_vr4     ~ "vr4",
            t_first == t_pdi     ~ "pdi"
        ),
        event_month = if_else(t_first <= max_months, t_first, NA_integer_),
        # Treatment-dummyer (D_S = 1 hvis personen ble plassert i S)
        D_vr1 = as.integer(event_type == "vr1"),
        D_vr2 = as.integer(event_type == "vr2"),
        D_vr3 = as.integer(event_type == "vr3"),
        D_vr4 = as.integer(event_type == "vr4"),
        D_pdi = as.integer(event_type == "pdi")
    )

# Sjekk: behandlingsfordeling
df_person |>
    count(event_type) |>
    mutate(andel = n / sum(n))

# 6. Utfall Y — post-TDI årlig arbeidsinntekt (1 000 NOK) -----------------
#
# DGP — latent lineær modell:
#   y* = α + Σ β_S · D_S + γ_female · female + γ_school · (year_school − 10)
#        + λ_η · η + ε
#
# Observert inntekt: y = max(0, y*). Sensureringen ved 0 gir den
# karakteristiske venstre-trunkerte fordelingen med opphopning av nuller —
# typisk for PDI-mottakere som forlater arbeidsmarkedet (mange har null
# arbeidsinntekt selv om de fortsatt er i datasettet).
#
# Forenkling: faktisk arbeidsinntekt er log-normal i den positive halen,
# mens vår DGP er lineær med additivt normalstøy. Lineariteten er valgt
# for å holde IV-identifikasjonen ren — censureringen introduserer en
# liten Tobit-skjevhet i estimater nær terskelen, men den er pedagogisk
# tolerabel. Parametere kan justeres senere.
#
# Skjevhetsmekanismen i OLS: behandlede har systematisk høyere η (dårligere
# tilstand). Naiv OLS av Y på D fanger både β og λ_η · cov(D, η), som
# drar koeffisientene nedover.
#
# Tegn på kontrollvariablene følger arbeidslivsøkonomi:
#   kvinne (female=1)        →  lavere inntekt  (γ_female  < 0)
#   flere år utdanning       →  høyere inntekt  (γ_school  > 0)

alpha_y       <- 250
gamma_female  <- -25     # kjønnsgap i 1000 NOK
gamma_school  <-  15     # avkastning per år utdanning utover grunnskole
sigma_eps     <-  50

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
        y = pmax(0, round(y_latent))    # sensurering ved 0
    )

# Råsjekk: gjsn. Y, andel nuller og η per behandling
# Forventning: PDI har mange nuller; behandlede har høyere η enn ubehandlede
df_person |>
    summarise(
        n          = n(),
        y_mean     = round(mean(y), 1),
        zero_share = round(mean(y == 0), 3),
        y_pos_mean = round(mean(y[y > 0]), 1),
        eta_mean   = round(mean(eta), 2),
        .by = event_type
    ) |>
    arrange(event_type)

# 7. Person-måned-data → ligning 2 → residualer ---------------------------
# Helt parallelt med 2026-04-09-skriptet: konstruer person-måned-data,
# estimer ligning 2 per behandling, hent residualer, summer per person.

df_pm <- df_person |>
    mutate(last_month = if_else(is.na(event_month), max_months, event_month)) |>
    select(id, office_id, female, year_school, event_type, event_month, last_month) |>
    uncount(last_month, .id = "time") |>
    mutate(
        P_vr1 = as.integer(event_type == "vr1" & time == event_month),
        P_vr2 = as.integer(event_type == "vr2" & time == event_month),
        P_vr3 = as.integer(event_type == "vr3" & time == event_month),
        P_vr4 = as.integer(event_type == "vr4" & time == event_month),
        P_pdi = as.integer(event_type == "pdi" & time == event_month)
    )

# Ligning 2 bruker year_school (samme kontroll som IV-regresjonen) slik
# at residualene er ortogonale på de kovariatene IV-modellen partialler ut.
models_lig2 <- map(treatments, \(trt) {
    fml <- reformulate(c("factor(time)", "female", "year_school"), paste0("P_", trt))
    lm(fml, data = df_pm)
}) |>
    set_names(treatments)

# 8. Residualer summert per person ----------------------------------------

resid_cols <- map(models_lig2, resid) |>
    set_names(paste0("resid_", treatments)) |>
    as_tibble()

df_pm <- bind_cols(df_pm, resid_cols)

df_resid <- df_pm |>
    summarise(
        across(starts_with("resid_"), sum),
        .by = c(id, office_id)
    ) |>
    rename_with(\(x) str_replace(x, "resid_", "u_"), starts_with("resid_"))

# Frigjør person-måned-data — vi trenger ikke disse videre
rm(df_pm, resid_cols)
gc()

# 9. Leave-one-out instrument (ligning 5) ---------------------------------
# Z_Si = (Σ_{k på samme kontor} u_Sk − u_Si) / (n_kontor − 1)

df_resid <- reduce(treatments, \(df, trt) {
    u_col <- paste0("u_", trt)
    z_col <- paste0("Z_", trt)
    df |>
        mutate(
            !!z_col := (sum(.data[[u_col]]) - .data[[u_col]]) / (n() - 1),
            .by = office_id
        )
}, .init = df_resid)

# 10. Normalisering — min/maks-spenn per kontor ---------------------------
# Som i artikkelen: koeffisient på Z tolkes som «effekten av å gå fra
# minst til mest aktive kontor».

z_ranges <- map_dbl(treatments, \(trt) {
    z_col <- paste0("Z_", trt)
    office_means <- df_resid |>
        summarise(mean_z = mean(.data[[z_col]]), .by = office_id)
    max(office_means$mean_z) - min(office_means$mean_z)
}) |>
    set_names(treatments)

z_ranges

df_resid <- reduce(treatments, \(df, trt) {
    z_col      <- paste0("Z_", trt)
    z_norm_col <- paste0("Z_", trt, "_norm")
    df |> mutate(!!z_norm_col := .data[[z_col]] / z_ranges[trt])
}, .init = df_resid)

# 11. Sett sammen endelig persondatasett ----------------------------------
# Én rad per person med alt RF/IV-skriptet trenger:
#   id, office_id, x (female, educ_high), D_S, Y, Z_S_norm

df_data <- df_person |>
    select(id, office_id, female, year_school, educ_high, eta, event_type,
           event_month, starts_with("D_"), y, y_latent) |>
    left_join(
        df_resid |> select(id, starts_with("Z_") & ends_with("_norm")),
        by = "id"
    )

# Sannhetsverdier som metadata — leses inn av modellskriptet
attr(df_data, "beta_true")    <- beta_true
attr(df_data, "lambda_eta")   <- lambda_eta
attr(df_data, "alpha_y")      <- alpha_y
attr(df_data, "gamma_female") <- gamma_female
attr(df_data, "gamma_school") <- gamma_school

# 12. Lagre datasettet -----------------------------------------------------

dir.create(here::here("data"), showWarnings = FALSE)

saveRDS(df_data, here::here("data", "iv_replikasjon.rds"))

# Rask validering før slutt
glimpse(df_data)
