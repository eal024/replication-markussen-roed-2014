# Replikasjon av tabell 2 (M&R 2014): predikerer instrumentet behandling?
# Bygger diskret varighetsmodell (ligning 2) med competing risks for 5
# behandlinger (VR1–VR4, PDI), konstruerer leave-one-out-instrument
# (ligning 5) for hver, og tester 5×5-matrisen (tabell 2).
#
# Stegene i kortversjon:
#   1. Simuler personer med kontorkultur (z) i hazarden
#   2. Competing risks → person-måned-data
#   3. Ligning 2 (LPM uten kontor) → residualer fanger kontorkultur
#   4. Summer residualer per person, leave-one-out per kontor → instrument Z
#   5. Regresjon: P_S ~ Z → tabell 2 (predikerer Z behandling?)

# 1. Pakker ----------------------------------------------------------------

library(tidyverse)

# 2. Parametere ------------------------------------------------------------

set.seed(42)

n_persons  <- 50000
max_months <- 24   # maks TDI-varighet (forenklet fra 5 år i artikkelen)
treatments <- c("vr1", "vr2", "vr3", "vr4", "pdi")

# 3. Kontorkultur — 10 kontor med ulik behandlingsprofil -------------------
# Artikkelen har 152 arbeidskontor + 430 trygdekontor. Vi bruker 10 for å
# balansere mellom realisme og lesbarhet.
#
# Hver z-kolonne er kontorets «tilbøyelighet» til å sende klienter til den
# gitte behandlingen. Forskeren observerer ikke z — den er uobservert og
# havner i residualene fra ligning 2.
#
# Verdiene er kalibrert slik at gjsn. månedlig overgangsrate (baseline + z)
# samsvarer med artikkelens tabell 2 (nederst):
#   VR1 ≈ 0.76 %, VR2 ≈ 0.35 %, VR3 ≈ 1.86 %, VR4 ≈ 0.37 %, PDI ≈ 1.21 %
#
# Kontorprofilene er konstruert med ulike «personligheter»:
#   1: VR1-aktiv    2: VR2-fokus    3: utdanning(VR3)  4: kurs(VR4)
#   5: PDI-streng   6: balansert+   7: passiv-         8: VR1+VR3
#   9: PDI+VR2      10: minimalist

office_culture <- tibble(
    office_id = 1:10,
    z_vr1 = c(0.012, 0.003, 0.005, 0.004, 0.007, 0.008, 0.002, 0.010, 0.003, 0.001),
    z_vr2 = c(0.002, 0.008, 0.002, 0.003, 0.004, 0.005, 0.001, 0.002, 0.007, 0.001),
    z_vr3 = c(0.010, 0.012, 0.025, 0.015, 0.016, 0.020, 0.008, 0.018, 0.014, 0.006),
    z_vr4 = c(0.002, 0.002, 0.003, 0.008, 0.003, 0.004, 0.001, 0.003, 0.002, 0.001),
    z_pdi = c(0.006, 0.008, 0.010, 0.009, 0.018, 0.014, 0.005, 0.008, 0.016, 0.004)
)

# PDI-spillover-koeffisient (artikkelen s. 18):
# Kontor med streng PDI-praksis avklarer saker raskere → sender flere til
# arbeidskontoret → alle VR-rater øker. Koeffisienten 0.1 betyr at 10 %
# av PDI-kulturen «smitter over» til hver VR-hazard.
pdi_spillover <- 0.1

# 4. Simuler persondata ----------------------------------------------------

df_person <- tibble(
    id        = 1:n_persons,
    office_id = sample(1:10, n_persons, replace = TRUE),
    female    = sample(0:1, n_persons, replace = TRUE),
    educ_high = sample(0:1, n_persons, replace = TRUE)
) |>
    left_join(office_culture, by = "office_id")

# 5. Competing risks — alle er at risk for alle 5 behandlinger ------------
# Hver person har fem månedlige hazard-rater, én per behandling.
# Hazarden = baseline + individeffekt + kontorkultur(z) + PDI-spillover.
#
# PDI-spillover: kontor med høy z_pdi får et lite tillegg i alle VR-hazarder.
# Dette gjenskaper artikkelens funn (tabell 2): φ_PDI predikerer VR positivt.
# Tolkning: strenge PDI-kontor avklarer saker raskere — «presser» klienter
# mot tiltak i stedet for å la dem bli i TDI.
#
# rgeom(n, p) + 1 gir «hvilken måned skjer første hendelse?» ved
# konstant hazard p. Competing risks: tidligste av 5 hendelser vinner,
# resten sensureres. Intuitivt: 5 parallelle klokker tikker — den som
# ringer først bestemmer behandlingen.

df_person <- df_person |>
    mutate(
        # Hazard = baseline + individeffekt + kontorkultur + PDI-spillover
        h_vr1 = 0.002 + 0.0010 * female + 0.0010 * educ_high + z_vr1 + pdi_spillover * z_pdi,
        h_vr2 = 0.001 + 0.0005 * female + 0.0005 * educ_high + z_vr2 + pdi_spillover * z_pdi,
        h_vr3 = 0.003 + 0.0020 * female + 0.0010 * educ_high + z_vr3 + pdi_spillover * z_pdi,
        h_vr4 = 0.001 + 0.0005 * female + 0.0005 * educ_high + z_vr4 + pdi_spillover * z_pdi,
        h_pdi = 0.002 + 0.0010 * female + 0.0010 * educ_high + z_pdi,
        # Potensielle hendelsestidspunkt (geometrisk fordeling)
        t_vr1 = rgeom(n(), h_vr1) + 1L,
        t_vr2 = rgeom(n(), h_vr2) + 1L,
        t_vr3 = rgeom(n(), h_vr3) + 1L,
        t_vr4 = rgeom(n(), h_vr4) + 1L,
        t_pdi = rgeom(n(), h_pdi) + 1L,
        # Competing risks — tidligste hendelse vinner
        t_first = pmin(t_vr1, t_vr2, t_vr3, t_vr4, t_pdi),
        event_type = case_when(
            t_first > max_months ~ "none",
            t_first == t_vr1     ~ "VR1",
            t_first == t_vr2     ~ "VR2",
            t_first == t_vr3     ~ "VR3",
            t_first == t_vr4     ~ "VR4",
            t_first == t_pdi     ~ "PDI"
        ),
        event_month = if_else(t_first <= max_months, t_first, NA_integer_)
    )

# Sjekk: behandlingsrater per kontor — bør gjenspeile kontorkultur
office_rates <- df_person |>
    summarise(
        n    = n(),
        VR1  = mean(event_type == "VR1") * 100,
        VR2  = mean(event_type == "VR2") * 100,
        VR3  = mean(event_type == "VR3") * 100,
        VR4  = mean(event_type == "VR4") * 100,
        PDI  = mean(event_type == "PDI") * 100,
        None = mean(event_type == "none") * 100,
        .by = office_id
    ) |>
    arrange(office_id)

office_rates

# 6. Person-måned-format ---------------------------------------------------
# Ligning 2 krever person-periode-data (Singer & Willett 2003, kap. 11).
# Hver person bidrar med rader fra d=1 til hendelsesmåned (eller d=24 ved
# sensurering). P_vr1 = 1 kun i hendelsesmåneden, 0 ellers — tilsvarende
# for de andre behandlingene.
#
# uncount() er effektivt: den kopierer raden «last_month» ganger,
# og .id = "time" gir en teller 1, 2, ..., last_month.

df_pm <- df_person |>
    mutate(last_month = if_else(is.na(event_month), max_months, event_month)) |>
    select(id, office_id, female, educ_high, event_type, event_month, last_month) |>
    uncount(last_month, .id = "time") |>
    mutate(
        P_vr1 = as.integer(event_type == "VR1" & time == event_month),
        P_vr2 = as.integer(event_type == "VR2" & time == event_month),
        P_vr3 = as.integer(event_type == "VR3" & time == event_month),
        P_vr4 = as.integer(event_type == "VR4" & time == event_month),
        P_pdi = as.integer(event_type == "PDI" & time == event_month)
    ) |>
    select(id, office_id, time, starts_with("P_"), female, educ_high)

# Gjsn. månedlig overgangsrate — sammenlign med tabell 2 (nederst)
monthly_rates <- tibble(
    treatment    = toupper(treatments),
    rate_sim     = map_dbl(treatments, \(t) mean(df_pm[[paste0("P_", t)]]) * 100),
    rate_article = c(0.76, 0.35, 1.86, 0.37, 1.21)
)

monthly_rates

# 7. Ligning 2 — lineær diskret varighetsmodell (LPM) ---------------------
# P_Sijd = d'α + x'β + u_Sijd    (én modell per behandling S)
#
# Modellen inkluderer tidsdummyer (d) og individkjennetegn (x), men IKKE
# kontorkultur. Residualen u fanger dermed alt som skyldes kontoret —
# dvs. den uobserverte behandlingsstrategien z.
#
# LPM fremfor logit fordi:
#   (a) leave-one-out kan beregnes analytisk (Sherman-Morrison)
#   (b) unngår at funksjonell form driver resultater
#   (Angrist & Pischke 2009, kap. 3.4.2)
#
# map() estimerer alle 5 modellene i én operasjon.

models_lig2 <- map(treatments, \(trt) {
    fml <- reformulate(c("factor(time)", "female", "educ_high"), paste0("P_", trt))
    lm(fml, data = df_pm)
}) |>
    set_names(treatments)

# 8. Residualer — kovariatjustert overgangstilbøyelighet ------------------
# For hver behandling: hent residualer og summer per person.
#   û_Si = Σ_d û_Sijd
#
# Positiv u_sum betyr at personen hadde *mer* overgang til behandling S
# enn forventet gitt sine individkjennetegn (x) og tid (d).
# Aggregert over kontorkollegaer fanges kontorets systematiske praksis.
#
# bind_cols + map: lager alle residualkolonner uten løkke.

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

# 9. Leave-one-out instrument — ligning 5 ---------------------------------
# Z_Si = (1 / (n_j − 1)) × Σ_{k≠i} û_Sk
#
# For person i på kontor j: ta gjennomsnittet av alle ANDRE personers
# residualsum på samme kontor. Fjerner i sin egen påvirkning for å unngå
# mekanisk korrelasjon (jackknife IV, Angrist & Pischke 2009, kap. 4.6).
#
# Effektiv beregning: (kontorets totale sum − person i sin sum) / (n − 1)
# Med ~5000 personer per kontor er forskjellen mellom personers Z minimal,
# men leave-one-out er nødvendig for gyldig inferens.
#
# reduce() bygger opp kolonner sekvensielt: starter med df_resid og
# legger til én Z-kolonne per behandling.

df_resid <- reduce(treatments, \(df, trt) {
    u_col <- paste0("u_", trt)
    z_col <- paste0("Z_", trt)
    df |>
        mutate(
            !!z_col := (sum(.data[[u_col]]) - .data[[u_col]]) / (n() - 1),
            .by = office_id
        )
}, .init = df_resid)

# 10. Normaliser instrumentene som i artikkelen ----------------------------
# «A unit difference corresponds to the average difference (taken over all
#  10 years) between the two local administrations using the respective
#  strategies least and most.» (tabell 2, fotnote)
#
# I praksis: del Z på range(gjsn. Z per kontor). Da betyr koeffisienten
# «effekten av å gå fra minst til mest aktive kontor».
#
# imap() gir både verdi (trt) og indeks — her bruker vi set_names + map
# for å beregne range og normalisere i ett steg.

z_ranges <- map_dbl(treatments, \(trt) {
    z_col <- paste0("Z_", trt)
    office_means <- df_resid |>
        summarise(mean_z = mean(.data[[z_col]]), .by = office_id)
    max(office_means$mean_z) - min(office_means$mean_z)
}) |>
    set_names(treatments)

# Inspiser range per instrument
z_ranges

df_resid <- reduce(treatments, \(df, trt) {
    z_col      <- paste0("Z_", trt)
    z_norm_col <- paste0("Z_", trt, "_norm")
    df |> mutate(!!z_norm_col := .data[[z_col]] / z_ranges[trt])
}, .init = df_resid)

# Sjekk: gjsn. normalisert instrumentverdi per kontor — bør gjenspeile profil
office_z_summary <- df_resid |>
    summarise(
        across(ends_with("_norm"), mean),
        n = n(),
        .by = office_id
    ) |>
    arrange(office_id)

office_z_summary

# 11. Tabell 2 — predikerer instrumentet behandling? ----------------------
# Relevanstesten for IV: regresjon av månedlig overgang P_Sijd på
# alle 5 normaliserte instrumenter Z, pluss tidsdummyer og x.
#
# Artikkelen viser en 5×5-matrise der rader er utfall (P) og kolonner er
# instrumenter (φ). Vi forventer:
#   - Sterk positiv diagonal: φ_VR1 predikerer VR1, osv.
#   - Svake/insignifikante krysseffekter
#   - Unntak: φ_PDI bør predikere VR positivt (PDI-spillover i DGP)

z_norm_cols <- paste0("Z_", treatments, "_norm")

df_pm_iv <- df_pm |>
    select(id, office_id, time, starts_with("P_"), female, educ_high) |>
    left_join(
        df_resid |> select(id, all_of(z_norm_cols)),
        by = "id"
    )

models_tab2 <- map(treatments, \(trt) {
    fml <- reformulate(
        c("factor(time)", "female", "educ_high", z_norm_cols),
        paste0("P_", trt)
    )
    lm(fml, data = df_pm_iv)
}) |>
    set_names(treatments)

# 12. Formater som 5×5-matrise — sammenlignbar med artikkelen --------------
# Hent koeffisienter og standardfeil for instrumentvariablene.
# Vis som «koeffisient» med signifikansstjerner, i prosentpoeng.
#
# Ytre map: itererer over utfall (rader i tabell 2).
# Indre map: itererer over instrumenter (kolonner) og henter koeffisienten.

tab2_matrix <- map_dfr(treatments, \(outcome) {
    mod   <- models_tab2[[outcome]]
    coefs <- coef(mod)
    ses   <- sqrt(diag(vcov(mod)))

    row <- map_chr(treatments, \(instr) {
        z_name <- paste0("Z_", instr, "_norm")
        b  <- coefs[z_name]
        se <- ses[z_name]
        t  <- b / se
        sig <- case_when(
            abs(t) > 2.576 ~ "***",
            abs(t) > 1.960 ~ "**",
            abs(t) > 1.645 ~ "*",
            TRUE           ~ "   "
        )
        sprintf("%7.3f%s", b * 100, sig)  # × 100 = prosentpoeng
    })

    tibble(
        Utfall = toupper(outcome),
        VR1 = row[1], VR2 = row[2], VR3 = row[3], VR4 = row[4], PDI = row[5]
    )
})

# Artikkelens tabell 2 diagonal for sammenligning
tab2_article <- tibble(
    Utfall    = c("VR1", "VR2", "VR3", "VR4", "PDI"),
    Diagonal  = c("1.031***", "0.802***", "1.749***", "0.703***", "2.000***")
)

tab2_matrix
tab2_article

# Frigjør minne — person-måned-data er store
rm(df_pm, df_pm_iv, resid_cols)
gc()

# 13. Andel forklart varians av instrumentene ------------------------------
# Artikkelen (tabell 2, nederst): andel av variansen i predikerte
# overgangssannsynligheter som forklares av φ alene.
#   VR1: 12.5 %  VR2: 29.6 %  VR3: 5.0 %  VR4: 48.8 %  PDI: 5.5 %
#
# ΔR² = R²(full modell med Z) − R²(basismodell uten Z)

r2_summary <- tibble(
    treatment = toupper(treatments),
    r2_base   = map_dbl(models_lig2, \(m) summary(m)$r.squared),
    r2_full   = map_dbl(models_tab2, \(m) summary(m)$r.squared),
    delta_r2  = r2_full - r2_base,
    article   = c("12.50 %", "29.64 %", "4.98 %", "48.82 %", "5.53 %")
)

r2_summary
