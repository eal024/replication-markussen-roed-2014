# Person-måned-data for diskret varighetsmodell (ligning 2, M&R 2014)
# Utforsking av datastruktur med right-censoring

# 1. Pakker ------------------------------------------------------------------

library(tidyverse)

# 2. Simuler persondata ------------------------------------------------------

set.seed(42)

n_persons <- 400
max_months <- 24

# Kontorkultur (uobservert) — ulik behandlingstilbøyelighet per kontor
# Kalibrert mot tabell 2: gjsn. månedlig overgangssannsynlighet
#   VR1 = 0.76 %, VR2 = 0.35 %
office_culture <- tibble(
    office_id = c("A", "B", "C", "D"),
    z1        = c(0.08, 0.02, 0.05, 0.01),  # VR1-kultur — sterkere kontraster
    z2        = c(0.01, 0.07, 0.02, 0.04)  # VR2-kultur — annen profil enn VR1
)

df_person <- tibble(
    id        = 1:n_persons,
    office_id = sample(c("A", "B", "C", "D"), n_persons, replace = TRUE),
    female    = sample(0:1, n_persons, replace = TRUE),
    educ_high = sample(0:1, n_persons, replace = TRUE)
) |>
    left_join(office_culture, by = "office_id")

# Forenkling: bestem først HVILKET tiltak personen skal på, deretter NÅR
# Kontorkultur påvirker hvem som får hva — kontor med høy z1 sender flere til VR1
df_person <- df_person |>
    mutate(
        prob_vr1 = 0.05 + 2 * z1,   # kontor A (z1=0.08): 21 %, kontor D (z1=0.01): 7 %
        prob_vr2 = 0.03 + 2 * z2,   # kontor B (z2=0.07): 17 %, kontor C (z2=0.02): 7 %
        prob_none = 1 - prob_vr1 - prob_vr2,
        treatment = pmap_chr(list(prob_vr1, prob_vr2, prob_none), \(p1, p2, p0) {
            sample(c("VR1", "VR2", "none"), 1, prob = c(p1, p2, p0))
        })
    )

# Sann DGP: hazard avhenger av x + kontorkultur (z1/z2)
# z er uobservert — havner i residualene når vi estimerer ligning 2
df_person <- df_person |>
    mutate(
        hazard = case_when(
            treatment == "VR1" ~ 0.002 + 0.001 * female + 0.001 * educ_high + z1,
            treatment == "VR2" ~ 0.002 + 0.001 * female + 0.001 * educ_high + z2,
            TRUE               ~ NA_real_
        ),
        event_month = map2_int(treatment, hazard, \(trt, h) {
            if (trt == "none") return(NA_integer_)
            for (d in 1:max_months) {
                if (runif(1) < h) return(d)
            }
            NA_integer_  # right-censored innen tiltak
        })
    )

# 3. Ekspander til person-måned-format ---------------------------------------

df_pm <- df_person |>
    mutate(
        last_month = ifelse(is.na(event_month), max_months, event_month),
        time = map(last_month, \(T) 1:T)
    ) |>
    unnest(time) |>
    mutate(
        P_vr1 = ifelse(treatment == "VR1" & !is.na(event_month) & time == event_month, 1, 0),
        P_vr2 = ifelse(treatment == "VR2" & !is.na(event_month) & time == event_month, 1, 0)
    ) |>
    select(id, office_id, time, P_vr1, P_vr2, female, educ_high)

# 4. Inspiser ----------------------------------------------------------------

df_pm

# 5. Estimer ligning 2 (LPM), uten residualer ----------------------------------

model_vr1 <- df_pm |> lm(data = _, P_vr1 ~ as.factor(time) + female + educ_high)

# stargazer::stargazer(list(model_vr1), type = "text")

# 6. Hent residualer ---------------------------------------------------------

df_pm$residual <- resid(model_vr1)

# 7. Summer residualer per person --------------------------------------------

df_resid <- df_pm |>
    group_by(id, office_id) |>
    summarise(u_sum = sum(residual), .groups = "drop")

df_resid

# 8. Leave-one-out instrument per person -------------------------------------

df_resid <- df_resid |>
    group_by(office_id) |>
    mutate(
        n_office  = n(),
        sum_office = sum(u_sum),
        Z_vr1 = (sum_office - u_sum) / (n_office - 1)  # alle andres gjennomsnitt # Dette er likning (5)
    ) |>
    ungroup() |>
    select(id, office_id, u_sum, Z_vr1)

df_resid

# 7. Estimere likning 2, med residualene

# 1) 
df_pm1 <- df_pm |> left_join( df_resid |> select(id, Z_vr1), join_by(id))



model_tabell2 <- df_pm1 |> lm(data = _, P_vr1 ~ as.factor(time) + female + educ_high + Z_vr1)

stargazer::stargazer( model_tabell2, omit = "as.", type = "text")

# Hvor mye forklart av Z_vr1
anova( model_vr1, model_tabell2)