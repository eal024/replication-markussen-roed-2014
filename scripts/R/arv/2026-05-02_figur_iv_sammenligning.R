# Figur — sammenligning av OLS-oracle, OLS-endogen og 2SLS mot sann β
#
# Henter estimater fra hovedskriptet (samme DGP, samme seed). Kjører feols
# for korrekte 2SLS-standardfeil. Plotter punktestimater med 95%-CI per
# VR-type, og tegner sann β som referanselinje.


# 1. Pakker og data -------------------------------------------------------

library(tidyverse)
library(fixest)
library(broom)
library(here)

source(here::here("scripts/R/2026-04-30_dgp_bias_minimal.R"))


# 2. Estimer modellene med feols (riktige standardfeil) -------------------

m_oracle  <- feols(
    y ~ age + kvinne + helse + vr1 + vr2 + vr3 + vr4,
    data = df, vcov = "iid"
)

m_endogen <- feols(
    y ~ age + kvinne + vr1 + vr2 + vr3 + vr4,
    data = df, vcov = "iid"
)

m_iv <- feols(
    y ~ age + kvinne | vr1 + vr2 + vr3 + vr4 ~ z1 + z2 + z3 + z4,
    data = df, vcov = "iid"
)


# 3. Hent ut estimater og 95%-CI ------------------------------------------

hent_vr <- function(model, label) {
    tidy(model, conf.int = TRUE) |>
        filter(str_detect(term, "vr[1-4]$")) |>
        mutate(
            vr     = str_extract(term, "vr[1-4]"),
            modell = label
        ) |>
        select(vr, modell, estimate, conf.low, conf.high)
}

resultater <- bind_rows(
    hent_vr(m_oracle,  "OLS oracle (med helse)"),
    hent_vr(m_endogen, "OLS endogen (uten helse)"),
    hent_vr(m_iv,      "2SLS (instrumentert)")
) |>
    mutate(
        modell = factor(modell, levels = c(
            "OLS oracle (med helse)",
            "OLS endogen (uten helse)",
            "2SLS (instrumentert)"
        ))
    )

sann_beta <- tibble(
    vr   = paste0("vr", 1:4),
    beta = c(57, -46, 59, -48)
)


# 4. Plot ----------------------------------------------------------------

figur <- ggplot(resultater, aes(x = modell, y = estimate, color = modell)) +
    geom_hline(
        data        = sann_beta,
        mapping     = aes(yintercept = beta),
        linetype    = "dashed",
        color       = "grey30"
    ) +
    geom_errorbar(
        mapping  = aes(ymin = conf.low, ymax = conf.high),
        width    = 0.25,
        linewidth = 0.8
    ) +
    geom_point(size = 3) +
    facet_wrap(~ vr, scales = "free_y", nrow = 2) +
    scale_color_manual(values = c(
        "OLS oracle (med helse)"   = "#2c7a3d",
        "OLS endogen (uten helse)" = "#c0392b",
        "2SLS (instrumentert)"     = "#2c5aa0"
    )) +
    labs(
        title    = "Sammenligning av estimater for VR-effekter",
        subtitle = "Stiplet linje = sann beta fra DGP. Vertikale linjer = 95 %-konfidensintervall.",
        x        = NULL,
        y        = "Estimert beta (1000 NOK)",
        color    = NULL,
        caption  = "Kilde: simulering basert på Markussen & Røed (2014), Tabell 4."
    ) +
    theme_light(base_size = 11) +
    theme(
        legend.position = "bottom",
        axis.text.x     = element_blank(),
        axis.ticks.x    = element_blank(),
        panel.grid.minor = element_blank(),
        strip.text      = element_text(face = "bold")
        )

ggsave(
    filename = here::here("output/iv_estimater_sammenligning.png"),
    plot     = figur,
    width    = 10,
    height   = 6,
    dpi      = 150
)

print(figur)


# 5. Forklaring til figuren ----------------------------------------------
#
# Hva vi ser:
#   - OLS oracle (grønn): treffer sann β (stiplet linje). Dette er
#     forventet — modellen har tilgang til helse og kontrollerer den ut.
#     Fungerer som referansepunkt for hva en unbiased estimator skal nå.
#
#   - OLS endogen (rød): systematisk forskjøvet bort fra sann β i alle
#     fire VR-grupper. Avviket er biasen fra uobservert helse: helse er
#     korrelert med både VR og y, så uten helse-kontroll "stjeler" VR-
#     dummyene helse-effekten. Konfidensintervallene inkluderer ikke
#     sannheten — biasen er statistisk identifiserbar.
#
#   - 2SLS (blå): gjenfinner sann β innenfor konfidensintervallet.
#     Punktestimatet kan være forskjøvet noen enheter (sampling-støy
#     i førstesteget), men intervallet dekker sannheten. Dette er
#     den kausale fortolkningen som er gyldig.
#
# Pris for IV: bredere konfidensintervaller enn OLS. Det er fordi IV bruker
# kun den eksogene delen av variasjonen i vr (driven av kontor-kultur).
# Det er prisen vi betaler for kausal identifikasjon når en uobservert
# konfounder er til stede.


# 6. Hvorfor endogen-bias går "i samme retning som sannheten" -----------
#
# Observasjon i figuren: rød (endogen) ligger lengre fra null enn grønn
# (sann β) i alle fire panel. VR1 og VR3 (gode tiltak) ser enda bedre ut;
# VR2 og VR4 (dårlige tiltak) ser enda dårligere ut. Hvorfor?
#
# OLS-bias-formelen (omitted variable):
#     bias(β̂_k) ≈ cov(vr_k, helse) · λ
#
# Med vår kalibrering:
#     helse_load = c(0, -0.3, 0.6, -0.2, 0.4)   # vr0..vr4
#     λ          = -50                           # dårlig helse senker y
#
# Mekanisme 1 — seleksjon på helse:
#     VR1: sykere unngår   → cov(vr1, helse) < 0
#     VR2: sykere oftere   → cov(vr2, helse) > 0
#     VR3: sykere unngår   → cov(vr3, helse) < 0
#     VR4: sykere oftere   → cov(vr4, helse) > 0
#
# Mekanisme 2 — helse på utfall (λ < 0):
#     dårlig helse senker inntekt direkte, uavhengig av tiltak.
#
# Multipliser:
#     VR1: neg · neg = +bias  → β̂ blir mer positiv enn β       (+57 → +71)
#     VR2: pos · neg = -bias  → β̂ blir mer negativ enn β       (-46 → -74)
#     VR3: neg · neg = +bias  → β̂ blir mer positiv enn β       (+59 → +68)
#     VR4: pos · neg = -bias  → β̂ blir mer negativ enn β       (-48 → -68)
#
# Intuisjon:
#   - Gode tiltak (VR1, VR3) tiltrekker friskere folk som ville klart seg
#     uansett. OLS attributerer deres høye y til tiltaket → overestimerer.
#   - Dårlige tiltak (VR2, VR4) får sykere folk som ville hatt lav y
#     uansett. OLS attributerer deres lave y til tiltaket → overestimerer
#     i negativ retning.
#
# Kjernen i seleksjonsproblemet: deltakerne i ulike tiltak er ikke
# sammenlignbare *før* behandling. En naiv OLS blander tiltakseffekt med
# "hvem som havnet hvor". Hadde seleksjonsmønsteret vært motsatt (sykere
# i VR1), ville endogen β̂ ligget *mellom* null og sann β — biasens
# retning følger seleksjonsmønsteret, ikke tiltakets virkelige effekt.
