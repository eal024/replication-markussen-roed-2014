# Diagnoseplott for DGP — Markussen & Røed (2014) replikasjon
#
# Frittstående skript som leser det simulerte datasettet og lager
# figurer som verifiserer at:
#   1. Inntektsfordelingen Y har riktig form (mass at 0 for PDI, normal kropp)
#   2. Overgangsratene matcher artikkelens tabell 2 (bunnrad)
#
# Brukes etter at 2026-04-10_simuler_utfall_data.R har generert datasettet.
# Kjører ingen estimering — kun deskriptiv visualisering.
#
# Figurer lagres i output/.

# 1. Pakker og data --------------------------------------------------------

library(tidyverse)

df <- readRDS(here::here("data", "iv_replikasjon.rds"))

dir.create(here::here("output"), showWarnings = FALSE)

group_levels <- c("none", "vr1", "vr2", "vr3", "vr4", "pdi")
group_labels <- c("Ubehandlet", "VR1", "VR2", "VR3", "VR4", "PDI")

df <- df |>
    mutate(group = factor(event_type, levels = group_levels, labels = group_labels))

# 2. Inntekt — overall histogram + tetthet --------------------------------
# Forventning:
#   - Hovedmasse rundt 250–300 (1 000 NOK), kropp tilnærmet normal
#   - Tydelig venstre-mass på 0 (PDI-mottakere som er sensurert)
#   - Hale på høyre side er for tynn sammenlignet med ekte arbeidsinntekt
#     (som er log-normal). Dette er en bevisst forenkling for å holde
#     lineær DGP og ren IV-identifikasjon.

p_inntekt_total <- df |>
    ggplot(aes(x = y)) +
    geom_histogram(aes(y = after_stat(density)),
                   bins = 60, fill = "steelblue", alpha = 0.5) +
    geom_density(colour = "firebrick", linewidth = 0.8) +
    labs(
        title = "Inntektsfordeling — alle observasjoner",
        subtitle = "Y = post-TDI årlig arbeidsinntekt (1 000 NOK). Spike på 0 fra sensurering.",
        x = "Y (1 000 NOK)",
        y = "Tetthet",
        caption = "Lineær DGP med Tobit-sensurering — log-normal hale mangler bevisst"
    ) +
    theme_minimal()

ggsave(here::here("output", "diagnose_inntekt_total.pdf"),
       p_inntekt_total, width = 8, height = 5, device = cairo_pdf)

# 3. Inntekt — per behandlingsgruppe ---------------------------------------
# Forventning:
#   - none, vr1, vr2, vr3, vr4: tilnærmet normal kropp uten nullmasse
#   - pdi: bimodal — store opphopning ved 0 + en svak hale rundt 100

p_inntekt_per <- df |>
    ggplot(aes(x = y, fill = group)) +
    geom_histogram(bins = 50, alpha = 0.8) +
    facet_wrap(~group, scales = "free_y") +
    labs(
        title = "Inntektsfordeling per behandlingsgruppe",
        subtitle = "PDI har klar opphopning ved 0; øvrige grupper er tilnærmet normale",
        x = "Y (1 000 NOK)",
        y = "Antall"
    ) +
    theme_minimal() +
    theme(legend.position = "none")

ggsave(here::here("output", "diagnose_inntekt_per_gruppe.pdf"),
       p_inntekt_per, width = 9, height = 6, device = cairo_pdf)

# 4. Overgangsmønster — kumulativ andel per måned -------------------------
# Konstant månedshazard betyr at andelen ubehandlet faller eksponentielt:
#   S(d) = (1 - h_total)^d, der h_total = h_vr1 + h_vr2 + h_vr3 + h_vr4 + h_pdi
#
# Med kalibrerte rater (artikkelens tabell 2 bunn) er h_total ≈ 4.5 % per
# måned, så S(24) ≈ (1 − 0.045)^24 ≈ 33 %. Vi forventer at ~30–35 % er
# fortsatt ubehandlet ved måned 24.
#
# I virkeligheten er det duration dependence (raskere overgang tidlig,
# saktere senere) — det vil ikke vises her, og er en kjent forenkling.

months <- 1:24

df_cum <- map_dfr(months, \(m) {
    df |>
        summarise(
            month     = m,
            Ubehandlet = mean(is.na(event_month) | event_month > m),
            VR1       = mean(event_type == "vr1" & !is.na(event_month) & event_month <= m),
            VR2       = mean(event_type == "vr2" & !is.na(event_month) & event_month <= m),
            VR3       = mean(event_type == "vr3" & !is.na(event_month) & event_month <= m),
            VR4       = mean(event_type == "vr4" & !is.na(event_month) & event_month <= m),
            PDI       = mean(event_type == "pdi" & !is.na(event_month) & event_month <= m)
        )
})

df_cum_long <- df_cum |>
    pivot_longer(-month, names_to = "treatment", values_to = "share") |>
    mutate(treatment = factor(treatment, levels = c("Ubehandlet", "VR1", "VR2", "VR3", "VR4", "PDI")))

p_overgang <- df_cum_long |>
    ggplot(aes(x = month, y = share, colour = treatment)) +
    geom_line(linewidth = 0.8) +
    geom_point(size = 1.4) +
    scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
    scale_x_continuous(breaks = seq(0, 24, 4)) +
    labs(
        title = "Overgangsmønster — kumulativ andel per måned",
        subtitle = "Konstant månedshazard → eksponentielt fall i ubehandlet-andelen",
        x = "Måneder siden TDI-inngang",
        y = "Kumulativ andel",
        colour = NULL,
        caption = "Mangler duration dependence — kjent forenkling"
    ) +
    theme_minimal()

ggsave(here::here("output", "diagnose_overgangsrater.pdf"),
       p_overgang, width = 9, height = 5, device = cairo_pdf)

# 5. Verifikasjon — månedsrater vs artikkelen -----------------------------
# Tabell 2 (bunn) i Markussen & Røed (2014):
#   VR1 0.76 %, VR2 0.35 %, VR3 1.86 %, VR4 0.37 %, PDI 1.21 %
#
# Reproduseres ved å beregne person-måned-rate: antall hendelser per type
# delt på totalt antall person-måneder at risk.

person_months_at_risk <- df |>
    mutate(last_month = if_else(is.na(event_month), 24L, event_month)) |>
    summarise(total = sum(last_month)) |>
    pull(total)

monthly_rates <- df |>
    filter(!is.na(event_month)) |>
    count(event_type) |>
    mutate(
        rate_sim_pct      = round(n / person_months_at_risk * 100, 2),
        rate_artikkel_pct = c(pdi = 1.21, vr1 = 0.76, vr2 = 0.35,
                              vr3 = 1.86, vr4 = 0.37)[event_type]
    ) |>
    arrange(event_type)

cat("\n--- Månedlige overgangsrater (% per måned) ---\n")
cat("Sammenlignet med tabell 2 (bunn) i Markussen & Røed (2014)\n\n")
print(monthly_rates)

cat(sprintf("\nTotalt person-måneder at risk: %s\n",
            format(person_months_at_risk, big.mark = " ")))
cat(sprintf("Andel fortsatt ubehandlet ved måned 24: %.1f %%\n",
            mean(df$event_type == "none") * 100))

# 6. Verifikasjon — inntekt per gruppe vs artikkelen -----------------------
# Tabell 1 i artikkelen oppgir 'earn_5yr' (NOK):
#   non_treated 163k, VR1 124k, VR2 68k, VR3 131k, VR4 115k
#
# MERK: Dette er årlig snitt over 5 år etter TDI. Vi har bare ett post-TDI
# snitt, så tallene er ikke direkte sammenlignbare. Brukes for grovt nivå.

income_check <- df |>
    summarise(
        n           = n(),
        y_mean      = round(mean(y), 1),
        y_pos_mean  = round(mean(y[y > 0]), 1),
        zero_share  = round(mean(y == 0), 3),
        .by = event_type
    ) |>
    mutate(
        artikkel_y_5yr = c(none = 163, vr1 = 124, vr2 = 68,
                           vr3 = 131, vr4 = 115, pdi = NA)[event_type]
    ) |>
    arrange(event_type)

cat("\n--- Inntekt per gruppe (1 000 NOK) ---\n")
cat("Sammenlignet med tabell 1 (earn_5yr) i Markussen & Røed (2014)\n")
cat("MERK: y_mean er årlig, artikkel-tall er 5-års snitt — kun grovt nivå\n\n")
print(income_check)

cat("\n--- Diagnoseplott lagret i output/ ---\n")
cat("- diagnose_inntekt_total.pdf      (overall fordeling)\n")
cat("- diagnose_inntekt_per_gruppe.pdf (faceted per behandling)\n")
cat("- diagnose_overgangsrater.pdf     (kumulativ andel per måned)\n")
