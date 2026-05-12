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


# 2. KONTOR-KULTUR --------------------------------------------------------
#
# z_office er hvert kontors faste "behandlingsiver" — uavhengig av hvem som
# tilfeldigvis ender opp der. Dette er HJERTET i identifikasjonsstrategien:
# z_office er eksogen by construction (trukket fra rnorm uavhengig av w),
# så variasjon i behandling drevet av z_office kan brukes som naturlig
# eksperiment.
#
# I virkeligheten observerer vi ikke z_office direkte. M&R-tricket er at vi
# senere konstruerer φ — et empirisk estimat av z_office — fra residualene
# i ligning 2. Det er nettopp dette ligning 4 og 5 gjør.

df_office <- tibble(
    office_id = 1:n_offices,
    z_office  = rnorm(n_offices, mean = 0, sigma_z)
)

# Sett z_office på persondata. Etter dette har hver person en (skjult)
# kontor-kultur knyttet til seg via office_id.
df_person2 <- df_person1 |> left_join(df_office, join_by(office_id))


# 3. HAZARD OG BEHANDLINGSTIDSPUNKT --------------------------------------
#
# Hver person har en månedlig sannsynlighet h for å gå over til VR1.
# Formelen kombinerer fire kanaler:
#
#   h_i = h_base                                  baseline (kalibrert til ~27 % i 24 mnd)
#       + 0.002 · female_i                        kjønnseffekt (kvinner litt mer)
#       + 0.001 · (year_school_i − 10)            skolegang (mer skole, mer VR)
#       + z_office_i                              KONTOR-KULTUR (eksogen, IV-kanalen)
#       + delta_w · w_i                           ABILITY (endogen, biaskanalen)
#
# pmax(..., 1e-6) er en numerisk sikkerhet — hvis summen blir negativ
# (sjelden, ved sterkt negativ z_office + lav ability), klippes hazarden
# til et lite positivt tall. Slike personer blir i praksis "aldri behandlet".
#
# Overgangstidspunktet trekkes fra GEOMETRISK fordeling:
#   t_event ~ rgeom(h) + 1L
# Tolkning: hver måned er en uavhengig "myntkast" med suksess-sannsynlighet h.
# rgeom returnerer antall feilet før første suksess; +1L flytter til
# kalenderbasis (måned 1, 2, 3, ...).
#
# Sensurering ved 24 mnd: hvis t_event > max_months får personen d_vr = NA
# (aldri behandlet i observasjonsvinduet) og P = 0. last_d styrer hvor mange
# rader personen får i person-måned-datasettet videre.

df_person3 <- df_person2 |>
    mutate(
        h       = pmax(h_base + 0.002 * female + 0.001 * (year_school - 10) +
                       z_office + delta_w * w, 1e-6),
        t_event = rgeom(n(), h) + 1L,
        d_vr    = if_else(t_event <= max_months, t_event, NA_integer_),
        P       = as.integer(!is.na(d_vr)),                              # personnivå-behandling
        last_d  = if_else(is.na(d_vr), max_months, d_vr)                 # antall at-risk-mnd
    )


# 3b. Sanity-blokk — bekreft at kalibreringen er fornuftig.
# Forventet med dagens parametre:
#   share_treated  ~ 0.27–0.32  (M&R-skala)
#   share_clipped  ~ 0.15–0.20  (akseptabelt; klipte personer blir aldri behandlet)
#   median_h       ~ 0.015      (sentrum av hazard-fordelingen)

df_person3 |>
    summarise(
        share_treated  = mean(P),
        share_clipped  = mean(h <= 1e-6 + 1e-9),
        median_h       = median(h)
    )

# Visuell sjekk av overgangs-tids-fordeling (filtrert for å unngå at de
# klipte personene med t_event i millioner ødelegger x-aksen).
df_person3 |>
    filter(t_event < 100) |>
    ggplot(aes(x = t_event)) +
    geom_histogram()


# =========================================================================
# 4. INSTRUMENTKONSTRUKSJON — Ligning 2 → 3 → 4 → 5
# =========================================================================
# Her bygger vi φ_Si trinn for trinn etter M&R-oppskriften.
# Ideen: vi observerer ikke z_office direkte, men kan ESTIMERE det ved å
# se på hvilke kontor som "produserer" flere behandlinger enn x og varighet
# tilsier — etter at vi har trukket fra det observerbare.

# 4a. PERSON-MÅNED-ekspansjon ---------------------------------------------
#
# Ligning 2 estimeres på person-måned-data: én rad per person × hver måned
# personen er at risk. Vi ekspanderer hver person fra én rad til last_d
# rader (= overgangs-måned hvis behandlet, ellers 24).
#
# Eksempel:
#   Person A behandles i d=3:  3 rader, P = (0, 0, 1)
#   Person B sensurert (last_d=24):  24 rader, P = (0, 0, ..., 0)
#
# .id = "d" gir en tellevariabel 1, 2, ..., last_d per person.
# P_id = 1 kun i overgangs-måneden (krever D == 1 OG d == d_vr).

df_pm <- df_person3 |>
    uncount(last_d, .id = "d", .remove = FALSE) |>
    mutate(
        P = if_else(!is.na(d_vr) & d == d_vr, 1L, 0L)
    )

# 4b. LIGNING 2 — LPM-hazard på person-måned ------------------------------
#
# Vi regresserer hendelsesindikatoren P på varighetsdummyer factor(d) og
# observerte kovariater. Residualene u_id inneholder DET SOM ER IGJEN
# etter at varighet og x er trukket fra — dvs.:
#
#   u_id =  z_office   (kontor-kultur, signalet vi vil ha)
#         + delta_w·w  (uobservert heterogenitet)
#         + støy
#
# w er IKKE med i regresjonen — den er uobserverbar. Den havner derfor i
# residualen. Det er nettopp dette jackknifet i ligning 5 skal kvitte oss
# med via leave-one-out-aggregering.
#
# HVORFOR LPM og ikke logit?
#   (a) Lineær form gjør Frisch-Waugh-stegene algebraisk transparente
#   (b) M&R argumenterer at funksjonell form ikke skal drive resultatet
#   (c) Jackknife-formelen i ligning 5 har eksakt analytisk form på OLS
#
# HVORFOR factor(d) (23 dummyer) i stedet for d (1 koeffisient)?
#   factor(d) lar baseline-hazarden være helt fri i form — vi antar ingen
#   spesifikk tidsstruktur. Bruker du `d` direkte antar du implisitt
#   konstant lineær endring per måned, som er en sterk antagelse.

model_eq_2 <- lm(P ~ factor(d) + female + year_school, data = df_pm)

# Sjekk koeffisientene på female og year_school — de skal ligne sann DGP
# (~0.002 og ~0.001 i hazarden, men her som koeffisient i LPM med fri
# baseline).
summary(model_eq_2)

# Beregn residualene u_id manuelt for å gjøre logikken eksplisitt
# (resid(model_eq_2) gir samme tall).
df_pm1 <- df_pm |>
    mutate(
        p_pred = predict(model_eq_2),
        u      = P - p_pred
    )


# 4c. LIGNING 3 — sum residualer per person → u_Si ------------------------
#
# Vi kollapser fra person-måned til personnivå ved å summere u_id over
# alle måneder personen er at risk:
#
#   u_Si = Σ_d u_Sid
#
# Tolkning: u_Si er personens samlede "uforklarte overgangs-tilbøyelighet"
# — det som ikke fanges av varighet eller x. Per definisjon av OLS er
# summen over alle personer eksakt null.
#
# HVORFOR SUMMERE I STEDET FOR GJENNOMSNITT?
# Personer som er at risk lenge bidrar med mer signal i summen. M&R bruker
# sum slik at kontorets totale "residual-masse" blir riktig vektet av
# eksponering — ikke per måned per person.
#
# Indekser i M&R-notasjon:
#   i = individ, j = kontor, S = tilstand (her kun VR1), d = risikomåned
#   u_Sid = residual på person-måned-nivå
#   u_Si  = u_Sij (j er implisitt via at i tilhører ett kontor)

df_resid <- df_pm1 |>
    summarise(u_sji = sum(u), .by = c(id, office_id))

# Sanity:
nrow(df_resid)                    # = N
mean(df_resid$u_sji)              # ≈ 0 (OLS-residual-egenskap)
sd(df_resid$u_sji)                # gir et inntrykk av spredningen
sum(df_resid$u_sji) |> round(6)   # = 0 eksakt i LPM uten vekter


# 4d. LIGNING 4 — naïv kontor-snitt φ_Sj ----------------------------------
#
#   φ_Sj = (1/N_j) · Σ_{i ∈ j} u_Si
#
# Dette er det "naïve" estimatet av kontor-kulturen: bare snittet av u_Si
# innad i kontoret. Det er PROBLEMATISK som instrument fordi personen
# selv inngår i snittet (med vekt 1/N_j), og personens egen u_Si inneholder
# personens egen w — som er nettopp det som gjør P endogen.
#
# Mekanisk: cov(φ_naïv_i, w_i) ≠ 0 fordi w_i bidrar til u_Si, som bidrar
# til snittet med vekt 1/N_j. Biasen avtar som 1/N_j men forsvinner aldri.

df_culture <- df_resid |>
    summarise(phi_sj = mean(u_sji), .by = office_id)


# 4e. LIGNING 5 — JACKKNIFE-versjonen (leave-one-out) ---------------------
#
#   φ_Si = (1/(N_j − 1)) · Σ_{i' ≠ i} u_Si'
#
# Her ekskluderer vi PERSONEN SELV fra kontor-snittet. Da inneholder φ_Si
# bare ANDRES u_Si — og siden andres w er uavhengig av min egen w
# (tilfeldig kontor-tildeling), er φ_Si eksogent med hensyn til min egen w.
#
# Algebraisk trick:
#   N_j · φ_naïv  =  Σ_i u_Si               (sum over alle)
#   N_j · φ_naïv − u_Si  =  Σ_{i' ≠ i} u_Si'   (sum unntatt selv)
#   ⇒ φ_jack_i = (N_j · φ_naïv − u_Si) / (N_j − 1)
#
# Det er det samme som å definere φ_jack direkte som leave-one-out, men
# beregningsmessig billigere — vi gjenbruker det vi allerede har regnet ut.

df_phi <- df_resid |>
    left_join(df_culture, join_by(office_id)) |>
    mutate(N_j = n_distinct(id), .by = office_id) |>
    mutate(phi_si_j = (N_j * phi_sj - u_sji) / (N_j - 1))


# 4f. DIAGNOSE — fungerer instrumentet? -----------------------------------
#
# To egenskaper må gjelde for at φ skal være et gyldig instrument:
#
#   RELEVANS:    cor(φ, z_office) > 0   — φ må faktisk fange kontor-kulturen
#   EKSOGENITET: cor(φ, w) ≈ 0          — φ må være renset for personens w
#
# Forventning med dagens kalibrering og N = 1500 (seed 123):
#   cor_naive_z ≈ 0.87   (sterk relevans — naïv fanger z_office godt)
#   cor_jack_z  ≈ 0.87   (jackknife marginalt lavere)
#   cor_naive_w ≈ 0.0    (ved store N_j er 1/N_j-biasen liten i utgangspunktet)
#   cor_jack_w  ≈ 0.0    (jackknife eksakt eksogen)
#
# Ved små N_j (f.eks. 5) ville naïv vise klart positiv cor med w, mens
# jack ble ved 0 — det er den klassiske demonstrasjonen av 1/N_j-bias.

df_phi |>
    left_join(df_person3 |> select(id, w, z_office), join_by(id)) |>
    summarise(
        cor_naive_z = cor(phi_sj,   z_office),
        cor_jack_z  = cor(phi_si_j, z_office),
        cor_naive_w = cor(phi_sj,   w),
        cor_jack_w  = cor(phi_si_j, w)
    )



# =========================================================================
# 5. UTFALLSLIKNINGEN OG ESTIMERING
# =========================================================================
#
# Med lambda_w = 50 og beta_true = 30 (seed 123) får vi:
#   model_true       β̂ ≈ 28   (baseline; sampling-støy rundt 30)
#   model_observert  β̂ ≈ 39   (OLS biased oppover, +9 fra omitted w)
#   model_iv         β̂ ≈ 25   (IV gjenfinner sann effekt, m/MC-støy)
#   model_rf         koef på φ ≈ 18 (sterk reduced form)
#   første-steg F          ≈ 84   (sterkt instrument)

# 5a. Konstruer y, og koble på instrumentet -------------------------------
#
# Utfallslikningen i DGP-en:
#   y_i = 250 + β·P_i + (−25)·female_i + 15·(year_school_i − 10)
#         + λ_w·w_i + ε_i,    ε ~ N(0, 30)
#
# w_i går inn med koeffisient λ_w = 50. Det er denne kanalen — uobservert
# for forskeren — som skaper OLS-biasen.

df_person4 <- df_person3 |>
    mutate(
        y = 250 + beta_true * P - 25 * female + 15 * (year_school - 10) +
            lambda_w * w + rnorm(n(), 0, 30)
    ) |>
    left_join(df_phi, join_by(id, office_id))


# 5b. FIRE MODELLER — hva de hver for seg viser ---------------------------
#
# (1) model_true       y ~ P + x + w
#     "Hva vi ville sett om w var observerbar." Fasit-modellen. β̂ ≈ 28
#     (sann β = 30, sampling-støy). Ikke realistisk i ekte data, men nyttig
#     som baseline.
#
# (2) model_observert  y ~ P + x
#     "Hva forskeren faktisk ser." Standard OLS, omitting w.
#     β̂ er BIASED. Hvor mye? = λ_w · cov(P, w | x) / var(P | x)
#     Med våre parametre ≈ +9 ⇒ β̂ ≈ 39. Dette er motiveringen for IV.
#
# (3) model_iv          y ~ p_hat + x   (manuelt 2SLS)
#     Vi instrumenterer P med φ_si_j i førstesteget, og bruker den
#     PREDIKERTE P̂ i andresteget. β̂ ≈ 25 — sann effekt gjenfunnet
#     innenfor MC-støy. ADVARSEL: SE er for små (lm tar ikke høyde for
#     førstesteg-usikkerhet).
#
# (4) model_rf          y ~ phi_si_j + x   (reduced form)
#     Den DIREKTE effekten av kontor-praksis på y, uten å gå via P.
#     Forventet å være signifikant — det er en sanity-sjekk (M&R tabell 3).

model_true      <- lm(y ~ P + female + year_school + w, data = df_person4)
model_observert <- lm(y ~ P + female + year_school,     data = df_person4)

# IV-steg 1: predikér P fra instrument + kontroller
model_first_stage <- lm(P ~ female + year_school + phi_si_j, data = df_person4)
df_person4$p_hat  <- predict(model_first_stage)

# IV-steg 2: y på predikert P + samme kontroller
model_iv <- lm(y ~ female + year_school + p_hat, data = df_person4)

# Reduced form: y direkte på instrumentet
model_rf <- lm(y ~ female + year_school + phi_si_j, data = df_person4)


# 5c. Sammenligning ------------------------------------------------------
#
# Forventet (sann β = 30, seed 123):
#   model_true       β̂ ≈ 28   (baseline, sampling-støy)
#   model_observert  β̂ ≈ 39   (OLS biased oppover via lambda_w · cov(P,w))
#   model_iv         β̂ ≈ 25   (IV gjenfinner sann effekt innen MC-støy)
#   model_rf         koef på phi ≈ 18 (sterk reduced form)
#
# Hvis dette mønsteret stemmer i din kjøring, er hele kjeden verifisert:
# ligning 2 → 3 → 4 → 5 produserer et eksogent instrument med relevans,
# og 2SLS gir konsistent β.

stargazer::stargazer(
    list(model_true, model_observert, model_iv, model_rf),
    type          = "text",
    column.labels = c("Sann (m/w)", "OLS (u/w)", "IV (2SLS)", "Reduced form"),
    keep          = c("P", "p_hat", "phi_si_j", "female", "year_school", "w"),
    digits        = 2
)


# 5d. KORREKTE STANDARDFEIL via ivreg ------------------------------------
#
# Manuelt 2SLS gir riktig punktestimat for β, men FOR SMÅ standardfeil
# i andresteget. Grunnen: lm() tar ikke høyde for at p_hat selv er
# estimert (med usikkerhet) i førstesteget. ivreg() gjør den korreksjonen
# automatisk og gir også weak-instrument-tester gratis.

library(ivreg)

iv_correct <- ivreg(
    y ~ P + female + year_school |              # ligning 6 (andresteg)
        phi_si_j + female + year_school,        # instrumenter for førstesteg
    data = df_person4
)

summary(iv_correct, diagnostics = TRUE)

# Diagnostiske tester man bør se på:
#   Weak instruments     — F-stat fra førstesteget; bør være >> 10
#   Wu-Hausman           — er endogenitet stort nok til at IV trengs?
#   Sargan               — overidentifiseringstest (her én-til-én, ikke relevant)


# =========================================================================
# 6. UTVIDELSER — hva som gjør eksempelet mer realistisk
# =========================================================================
# Dette skriptet er BASISVERSJONEN. Tre naturlige utvidelses-akser:
#
# A) FLERE VR-TILTAK (multi-endogen IV)
# -------------------------------------
# I dag har vi ett tiltak (VR1). M&R har fem: VR1–VR4 og PDI.
#
# Endring av DGP:
#   - Hvert kontor får én z_office_S per behandling S (matrise K × 5)
#   - Personene konkurrerer mellom behandlinger (competing risks) — typisk
#     ved at hver person trekker hazard for hver S og velger den som
#     "treffer" først, eller modelleres som multinomial logit
#   - Persondatasettet får én D_S per behandling
#
# Endring av instrumentkonstruksjon:
#   - Kjør ligning 2 én gang per behandling S
#   - Få fire (eller fem) sett av u_Sid → u_Si → φ_Sj → φ_Si
#   - Du ender med en MATRISE av instrumenter (én kolonne per S)
#
# Endring av estimering:
#   - Førstesteg blir fire (eller fem) parallelle LM: hver D_S regreseres
#     på alle fire φ-ene + x. Det fanger at instrumentene henger sammen
#     (et "VR1-kontor" kan også være et "PDI-kontor")
#   - Andresteg: y ~ D̂_VR1 + D̂_VR2 + ... + x   (+ τ·φ_PDI hvis PDI er med)
#
# Referanse: `scripts/R/arv/2026-04-10_iv_fire_endogene.R` har en
# pedagogisk versjon av dette med fire endogene.
#
# B) FLERE KOVARIATER (mer realistisk x)
# --------------------------------------
# I dag har vi female + year_school. Realistisk x i M&R inkluderer:
#
#   - alder (ofte som 5-års-kategorier)
#   - innvandrerstatus
#   - tidligere inntekt (forhåndsinntekt 2 år før TDI)
#   - regional ledighetsrate (konjunkturkontroll)
#   - sivilstand, barn, helseopplysninger
#   - inngangsmåned-dummyer (sesongkontroll)
#
# Implementering:
#   - Trekk hver kovariat i df_person med passende fordeling
#   - Legg dem inn både i hazard (DGP) og i ligning 2 (estimering) og y
#   - Pass på at antall kontrollvariabler er konsistent overalt
#
# Effekt:
#   - Mer realistisk OLS-bias (avhenger av hvilke x som korrelerer med w)
#   - Bedre identifikasjon hvis x fanger noe av w-kanalen
#   - Pedagogisk poeng: jo flere observerte kovariater, desto mindre er
#     gapet mellom OLS og IV — men det forsvinner ikke helt fordi
#     uobservert ability gjenstår
#
# C) FLERE OBSERVASJONER OG BEDRE INFERENS
# -----------------------------------------
# I dag har vi N = 1500 personer på K = 50 kontor (~30 per kontor).
# M&R har N = 345 000 og K = 152.
#
# Hva som endrer seg ved oppskalering:
#   - Lavere standardfeil — synlig dramatisk forskjell mellom OLS og IV
#   - Naïv-vs-jack-forskjellen blir mindre (1/N_j → 0)
#   - Førstesteg-F blir høyere (sterkere instrument-relevans)
#
# Inferens-utvidelser (uavhengig av N):
#   - KLYNGESTANDARDFEIL på kontor-nivå:
#       library(fixest)
#       feols(y ~ P + female + year_school | phi_si_j, data = ...,
#             vcov = "cluster", cluster = ~office_id)
#     M&R klynger på behandlingsmiljø × år. Vår enkleste analog er bare
#     office_id.
#   - WILD CLUSTER BOOTSTRAP for små antall klynger (få kontor):
#       library(fwildclusterboot)
#
# D) PEDAGOGISKE TILLEGG (ikke realisme, men forklaring)
# -------------------------------------------------------
#   - Monte Carlo over flere seed for å vise at IV er konsistent
#     (ikke bare riktig i én run — riktig i forventning)
#   - Sammenligning OLS / IV / "oracle" (= model_true) for flere
#     verdier av lambda_w — viser bias-skala empirisk
#   - Plotte phi_si_j mot z_office for å vise relevansen visuelt
#   - Plotte residualer u_Si mot w for å vise korrelasjonen før jackknife
#
# REKKEFØLGE JEG VILLE GJORT DEM I:
#   1. Klyngestandardfeil (én linje endring — gir korrekt inferens nå)
#   2. Utvide til to tiltak (VR1 + VR2) som bro til full multi-endogen
#   3. Berike x med 2–3 nye kovariater (alder, regional ledighet)
#   4. Eventuelt full M&R med PDI som τ·φ_PDI-regressor
