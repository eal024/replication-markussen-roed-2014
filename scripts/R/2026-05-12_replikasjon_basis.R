# Opprettet: 2026-05-11
# Redigert : 2026-05-12
#
# Markussen & Røed (2014) — replikasjon i miniformat
# =========================================================================
#
# FORMÅL
# Forstå hvordan IV med kontor-kulturen som instrument korrigerer for
# seleksjonsskjevhet. Forberedelse til egen IV-analyse av varig
# lønnstilskudd (VLT).
#
# ENDOGENITETEN — fortellingen
# ----------------------------
# La VR1 være et "opplæringstiltak". Tildelingen er IKKE tilfeldig:
# saksbehandlere foretrekker kandidater med høyere ability/motivasjon (w).
# Ability er uobservert av forskeren, men korrelert med y.
#
#   cov(P, w) > 0   — VR-deltakelse trekkes mot høye w-typer (seleksjon)
#   cov(w, y) > 0   — ability gir høyere y uavhengig av behandling
#   ⇒ cov(P, y | x) inneholder BÅDE kausal effekt av VR OG w-kanalen
#   ⇒ OLS gir biased β̂
#
# Sann utfallslikning (det vi ville sett om w var observerbar):
#     y = α + β·P + γ·year_school + δ·female + λ_w·w + ε
#
# Hva forskeren faktisk ser (w utelatt — havner i feilleddet):
#     y = α + β·P + γ·year_school + δ·female + (λ_w·w + ε)
#                                          └──── feilledd inneholder w ──┘
#
# IV-LØSNINGEN
# ------------
# Instrumentet er KONTOR-KULTUR z_office — kontorenes egen tilbøyelighet
# til å tildele VR, uavhengig av hvilken person som tilfeldigvis havner der.
# Vi observerer ikke z_office direkte; vi konstruerer φ som estimat for
# det fra observerte data via residualer fra en LPM-hazard, aggregert per
# kontor (M&R ligning 2 → 3 → 4 → 5).
#
#   Eksogenitet :  cor(z_office, w) = 0 — by construction (tilfeldig sampling)
#   Relevans    :  cov(z_office, P) > 0 — kontoret former tildelingen
#   Eksklusjon  :  z_office påvirker y kun gjennom P (institusjonell antagelse)
#
# REPLIKASJONENS FIRE BLOKKER
# ---------------------------
# (1) DGP            — generér personer, kontor, hazard, behandling, utfall
# (2) Instrumentet   — bygg φ via ligning 2→3→4→5 (jackknife per kontor)
# (3) Estimering     — OLS (biased), IV/2SLS (gjenfinner β), reduced form
# (4) Diagnose       — verifiser at instrumentet er relevant og eksogent

# 0. Rammen til simuleringen----------------------------

library(tidyverse)
set.seed(123)

# Individer og kontor
n_offices <- 50          # kontor
n_per_off <- 30          # antall personer per kontor.
N <- n_offices*n_per_off # Antall personer

# Parametre for DGP-en
# --------------------
# Alle parametre defineres her, øverst, slik at skriptet kan kjøres fra
# topp til bunn i ny R-sesjon uten forward-references.
#
# Kalibreringen av h_base, sigma_z og delta_w er gjort slik at vi får
# ~27 % behandlet (M&R-andel), beskjeden clipping av hazarden, OG
# tilstrekkelig seleksjonsstyrke til at OLS-bias blir synlig.

h_base     <- 0.01    # base-hazard per måned (~27 % behandlet over 24 mnd)
sigma_w    <- 1.0     # spredning i ability w (uobservert)
sigma_z    <- 0.010   # spredning i kontor-kultur z_office
delta_w    <- 0.005   # w → hazard: høy ability ⇒ tidligere VR1 (seleksjon)
lambda_w   <- 50      # w → y: høy ability ⇒ høyere y uansett behandling (bias-motor)
beta_true  <- 30      # SANN kausal effekt av VR1 på y (det vi vil gjenfinne)
max_months <- 24      # observasjonsvindu (sensurering ved 24 mnd)
rho_ws     <- 0.4     # korrelasjon mellom ability og skolegang (realisme)



# 1. PERSONER ------------------------------------------------------------
#
# Sammensetning av analyseutvalget: id, kontor-tildeling, kjønn, skolegang.
# Kontor-tildeling er TILFELDIG — det er antakelsen som gjør at φ kan brukes
# som instrument. (M&R argumenterer institusjonelt for at sortering på
# uobservert ability er begrenset; vi imiterer det med ren randomisering.)

df_person <- tibble(
    id          = 1:N,
    office_id   = sample(size = N, x = 1:n_offices, replace = TRUE),
    female      = sample(0:1, N, replace = TRUE),
    year_school = sample(c(10, 13, 16, 18), N, replace = TRUE)
)

# 1b. ABILITY w — korrelert med skolegang
# ---------------------------------------
# Intuisjon: mer ability fører til mer skolegang. I virkeligheten observerer
# vi skolegang, men ikke ability. Det betyr at year_school i regresjonen
# DELVIS kontrollerer for w — men ikke fullt ut (rho_ws < 1). Det er
# nettopp denne resterende w-variasjonen som skaper endogenitetsbiasen
# vi vil bekjempe med IV.
#
# Konstruksjon: w = ρ · standardisert_skole + √(1 − ρ²) · uavhengig_støy
# Dette gir cor(w, year_school) ≈ rho_ws, mens sd(w) = sigma_w uansett ρ.

df_person1 <- df_person |>
    mutate(
        school_c = (year_school - mean(year_school)) / sd(year_school),
        w        = sigma_w * (rho_ws * school_c + sqrt(1 - rho_ws^2) * rnorm(n(), 0, 1))
    ) |>
    select(-school_c)


# 1. Kontor-kultur: Tilfeldig--------------------------------------------

# Tilfeldig tildeling av kultur
df_office <- tibble(
    office_id = 1:n_offices,                         # id kontor
    z_office  = rnorm( n_offices, mean = 0, sigma_z) # Sann kultur
    )


# Slår sammen personer med kontor-kultur
df_person2 <- df_person1 |> left_join( df_office, join_by(office_id))


# Valgregel for VR: 
# h: andel som får tiltaket VRX
h_base   # base rate for h # base-hazard (kalibrert til ~27 % behandlet i 24 mnd)
sigma_w  # spredning i ability (uobservert av forsker)
sigma_z  # spredning i kontor-kultur
delta_w  # w inn i hazard — høy w (ability gir større sannsynlighet for VR1) → mer VR1
lambda_w # w inn i y     — høy w → høyere y (uavhengig av VR)
beta_true # sann effekt av VR1 på y
max_months # observasjonsvindu

# rgeom( n = 50, 0.01) # density function.
# Brukes i h. Alle har en ulik h (harzard-rate)

# Legger til valg-regel (hazard-rate) for tildeling av tiltak (h)
df_person3 <- df_person2 |> 
    mutate( 
        # h bestemt av female, year_schooling og evne. Men viktigst -- kultur på kontoret.
        h       = pmax(h_base + 0.002 * female + 0.001 * (year_school - 10) + z_office + delta_w * w, 1e-6),
        t_event = rgeom(n(), h) + 1L,
        d_vr    = ifelse(t_event <= max_months, t_event, NA_integer_), # 
        # Treatment
        P       = as.integer(!is.na(d_vr)),
        last_d  = if_else(is.na(d_vr), max_months, d_vr)
)


# (a) Sanity-blokk etter df_person3 (du har den i konsollen, men ikke i fila):

df_person3 |>
    summarise(
    share_treated  = mean(P),
    share_clipped  = mean(h <= 1e-6 + 1e-9),
    median_h       = median(h)
)

# Enkel figur som viser fordeling av tidspunktet får behandling (VR1) - teoretisk
df_person3 |>
    filter( t_event < 100) |> 
    ggplot(
        aes( x = t_event)
    ) +
    geom_histogram()


# 2. Konstruksjon Z: Paneldatasettet, person* max mnd -----------------------------

# a) Lager full sekvens for hver id
df_pm <- df_person3 |>
    # Gir alle sekvens på 24 (last_d), beholder variabelen last_d (remove = F) 
    uncount( last_d, .id = "d", .remove = F) |> 
    # Utfall VR
    # d_vr: deltar på tiltak?
    # Se ifelse-regel over: om t_event > max_months (24), da vr = t_event, hvis ikke NA 
    mutate(
        P = ifelse( !is.na(d_vr) & d == d_vr, 1, 0)
    )

# b) LPM
# Regresjonn P på varighet + x

# OLS på person-mnd-data.
# LMP for hazard. 
# Modellerer LMP per mnd. linear. 
# Linear for å få Frisch-Waugh-stegene

# u_id: fratrukket x, står igjen med u:
    # 1. kontor-kultur. -- som er det vi vil sile ut!
    # 2. uobservert heterogeitet n 
    # 3. rent støy

# Tar ikke med w, siden det er uobserverbar
summary(
    model_eq_2 <- lm( data = df_pm, P ~ factor(d) + female + year_school)
    )
# Bruker factor(d) -- gir baseline-haztad fri i form.

# c) Konstrurer likning 3.
df_pm1 <- df_pm |> 
    mutate(
        # Residual for hver enkel
        p_pred = predict(model_eq_2),  
        u = P - p_pred
    )

# Sjekk av verdi
# mean(df_pm1$u)      # nært null
# sd(df_pm1$u)        # liten
# summary(model_eq_2) # Skal være veldig liten

# Likning 3-------------------------------
# i: individ
# j: kontor
# s: tilstand (VR1, VR2 osv)
# d: Risiko mnd for overgang til VRX

# sum u(s,i,j): Kolapser en observasjon per person.
# Dette er konstruksjonen av instrumentet til personene.
df_resid <- df_pm1 |> 
    # Sammenpresser til en obs. per person og kontor.
    summarise(
        u_sji = sum(u), .by = c("id", "office_id")
    ) 

nrow(df_resid)                    # = N (= 50 i ditt oppsett)
mean(df_resid$u_sji)              # ~ 0 (residual-egenskap)
sd(df_resid$u_sji)                # gir et inntrykk av spredningen
sum(df_resid$u_sji) |> round(6)   # ~ 0 — eksakt i en LPM uten vekter


# Likning 4. Gjøre om til et snitt per kontor------------------

df_culture <- df_resid |> 
    summarise(
        phi_sj = mean(u_sji), .by = "office_id"
    )


# Likning 5. Jackknife leav out---------------------------------

df_phi <- df_resid |> 
    left_join(
        df_culture, join_by(office_id)
    ) |> 
    mutate(
        N_j = n_distinct(id), .by = "office_id"
    ) |> 
    mutate(
        phi_si_j = (N_j*phi_sj - u_sji)/(N_j -1)
    )

# Fungerer instrumentet som det skal?
# (b) Diagnose etter df_phi — viser at instrumentet faktisk fanger kontorkultur og er renset for w:

df_phi |>
    left_join(df_person3 |> select(id, w, z_office), join_by(id)) |>
    summarise(
        cor_naive_z = cor(phi_sj,   z_office),    # ~ 0.9 — relevans
        cor_jack_z  = cor(phi_si_j, z_office),    # ~ 0.9
        cor_naive_w = cor(phi_sj,   w),           # ~ 0 — eksogenitet
        cor_jack_w  = cor(phi_si_j, w)            # ~ 0
    )



## Tilbake til utfallslikning-------------------------------------------

beta_true <- 50 # Klar synlig effekt. eks.2 verdi = 10, liten effekt, 0 = nulleffekt

# Analyse-klar fil:
# Konstruerer utfallet
df_person4 <- df_person3 |> 
    mutate(
        y = 250 + beta_true*P - 25*female + 15*(year_school-10) + lambda_w*w + rnorm(n(), 0,30)
    ) |> # Legger til instrumentet
    left_join( df_phi, join_by(id, office_id))

# Modellene
model_true      <- lm( data = df_person4, y ~ P + female + year_school + w)
model_observert <- lm( data = df_person4, y ~ P + female + year_school)

# IV-steg

# steg 1 
model_first_stage <- lm( data = df_person4, P ~ female + year_school + phi_si_j )

df_person4$p_hat <- predict(model_first_stage)

# Stage 2 IV
model_iv <- lm( data = df_person4, y ~ female + year_school + p_hat)

# Reduce form equation
model_rf <- lm( data = df_person4, y ~ female + year_school + phi_si_j)

# Tolkning (1) viser sann modell. (2) endogen. (3) IV-resultat
# IV: justerer ned effekt fra 61 i endogen likning til 45
stargazer::stargazer( list(model_true, model_observert, model_iv, model_rf), type = "text")

# Innebygget pakke.
library(ivreg)

iv_correct <- ivreg(
    y ~ P + female + year_school | phi_si_j + female + year_school, 
    data = df_person4)

# Videre arbeid: 

