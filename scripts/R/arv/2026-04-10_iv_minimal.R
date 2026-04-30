# Klassisk IV i miniformat — én endogen behandling, ett instrument.
#
# Formål: isolere IV-mekanikken før vi går videre til leave-one-out-
# konstruksjonen og varighetsmodellen i Markussen & Røed (2014).
#
# Variabelnavn er valgt så de samsvarer med M&R-replikasjonen:
#   η  = uobservert heterogenitet (samme rolle som hos M&R)
#   D  = behandlingsdummy — deltakelse i ett (fiktivt) tiltak
#   Z  = eksogent instrument (her direkte trukket; hos M&R: leave-one-out
#        kontorgjennomsnitt av residualer fra ligning 2)
#   Y  = utfall (1 000 NOK, parallell til post-TDI inntekt)
#   β  = sann behandlingseffekt — det IV skal gjenfinne
#   λ  = effekt av η på Y
#
# Kobling til artikkelens ligninger:
#   • Førstesteget her tilsvarer M&Rs «D = α + φ·Z + γ·x + ν»
#     (men uten kontroller x, og uten varighetsdimensjon)
#   • Andresteget tilsvarer ligning 6: «y_ki = β·D_i + ε_ki»
#     (i M&R: vektor av fire D-er; her: én)
#
# DGP:
#   η ~ N(0,1)                          # uobservert "tilstand"
#   Z ~ N(0,1)                          # eksogent instrument
#   p_D = π_0 + π_1·Z + π_2·η            # LPM for behandlingsprob
#   D   = Bernoulli(p_D)                # binær behandling
#   Y   = α + β·D + λ·η + ε              # utfall
#
# IV-betingelser:
#   Relevans:    π_1 ≠ 0  ⇒ cov(Z, D) ≠ 0
#   Eksogenitet: cov(Z, η) = 0          (Z og η er uavhengige ved trekking)
#   Eksklusjon:  Z inngår IKKE i Y-ligningen direkte (kun via D)

# 1. Pakker ----------------------------------------------------------------

library(tidyverse)
library(fixest)

# 2. DGP-parametere --------------------------------------------------------

set.seed(20260410)

n         <- 5000

# Førstesteg
pi_0      <- 0.30    # baseline behandlingsrate (Pr(D=1) når Z=η=0)
pi_1      <- 0.20    # effekt av Z på Pr(D=1) — relevansen til instrumentet
pi_2      <- 0.10    # effekt av η på Pr(D=1) — endogenitetskanalen

# Utfallsligning
alpha     <- 250
beta      <- 30      # SANN behandlingseffekt
lambda    <- -50     # effekt av η på Y (negativ: høy η = dårlig tilstand)
sigma_eps <- 30

# 3. Simuler datasett ------------------------------------------------------

df <- tibble(
    eta = rnorm(n, 0, 1),
    Z   = rnorm(n, 0, 1),
    p_D = pmin(pmax(pi_0 + pi_1 * Z + pi_2 * eta, 0.001), 0.999),
    D   = rbinom(n, 1, p_D),
    Y   = alpha + beta * D + lambda * eta + rnorm(n, 0, sigma_eps)
)

cat("Andel D = 1:", round(mean(df$D), 3), "\n")
cat("Sann β     :", beta, "\n\n")

# 4. Naiv OLS — skjev ------------------------------------------------------
# Y = α + β·D + u, hvor u inneholder η. Siden cov(D, η) > 0 (via π_2)
# og λ < 0, blir koeffisienten på D trukket NEDOVER.
#
# Analytisk skjevhet (omtrentlig):
#   bias_OLS ≈ λ · cov(D, η) / var(D)
#            ≈ -50 · (π_2 · var(η)) / (p̄·(1-p̄))
#            ≈ -50 · 0.10 / 0.21  ≈  -24

ols <- feols(Y ~ D, data = df)

# 5. IV — manuell oppdeling i førstesteg + andresteg ---------------------
# Førstesteg:  D = π_0 + π_1·Z + ν      → hent prediksjonen D̂
# Andresteg:   Y = α + β·D̂ + e          → koeffisienten på D̂ er β̂_IV
#
# Den manuelle versjonen finnes kun for å se mekanikken. Standardfeilene
# fra `lm(Y ~ D_hat)` er FEIL (tar ikke hensyn til førstestegusikkerhet).
# I praksis brukes feols-IV-syntaks i seksjon 6.

first_stage  <- feols(D ~ Z, data = df)
df$D_hat     <- predict(first_stage)
second_stage <- feols(Y ~ D_hat, data = df)

first_stage_f <- wald(first_stage, keep = "Z", print = FALSE)$stat

cat("--- Førstesteg: D ~ Z ---\n")
print(coef(first_stage))
cat("F-stat:", round(first_stage_f, 1),
    "(må være > 10 for sterkt instrument)\n\n")

cat("--- Andresteg (manuell): Y ~ D_hat ---\n")
print(coef(second_stage))
cat("(NB: standardfeilene her er underestimert. Bruk seksjon 6.)\n\n")

# 6. IV — direkte med fixest -----------------------------------------------
# Syntaks: y ~ eksogene | fe | endogene ~ instrumenter
# Her: ingen eksogene kontroller, ingen FE.

iv <- feols(Y ~ 1 | 0 | D ~ Z, data = df)

# 7. Sammenligning sann β / OLS / IV ---------------------------------------

results <- tibble(
    metode    = c("Sann β", "OLS", "IV (2SLS)"),
    estimat   = c(beta,
                  coef(ols)[["D"]],
                  coef(iv)[["fit_D"]]),
    std_error = c(NA,
                  sqrt(diag(vcov(ols)))[["D"]],
                  sqrt(diag(vcov(iv)))[["fit_D"]]),
    bias      = c(0,
                  coef(ols)[["D"]] - beta,
                  coef(iv)[["fit_D"]] - beta)
) |>
    mutate(across(where(is.numeric), \(x) round(x, 2)))

cat("--- Sammenligning ---\n")
print(results)

# 8. IV-utskrift med F og Wu-Hausman --------------------------------------

cat("\n--- IV-detaljer (F-stat + Wu-Hausman) ---\n")
summary(iv)

# 9. Kort tolkning ---------------------------------------------------------

cat("\n--- Tolkning ---\n")
cat("• OLS-skjevheten kommer fra at D er korrelert med uobservert η,\n")
cat("  som påvirker Y gjennom λ. Bias ≈ λ·cov(D,η)/var(D).\n")
cat("• IV bruker den delen av D-variasjonen som er FORKLART av Z —\n")
cat("  og som derfor er ortogonal på η. Det gir konsistent β̂.\n")
cat("• Førstesteg-F > 10 ⇒ instrumentet er sterkt nok (Stock-Yogo).\n")
cat("• Wu-Hausman tester H0: OLS = IV. Lav p ⇒ endogenitet er reell.\n")
