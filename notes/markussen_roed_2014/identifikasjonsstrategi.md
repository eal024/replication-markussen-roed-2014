# Identifikasjonsstrategien i Markussen & Røed (2014) — oppsummert

*Opprettet: 2026-04-29*

> Pedagogisk gjennomgang av hvordan likning 6 (utfallslikningen) er bygget,
> hvordan instrumentet φ konstrueres, hvor endogenitetsproblemet sitter, og
> hvordan IV/2SLS løser det. Variablene kobles til konvensjonell IV-notasjon.
>
> Likning 6 i WP-versjonen mangler residualleddet i selve grafikken (typo);
> korrekt form er y = Xγ + P'δ + τ·φ_PDI + η.

---

## 1. Utfallslikningen (likning 6) — det vi vil estimere

$$y_{ki} = X_i'\gamma_k + P_i'\delta_k + \tau_k\,\varphi_{PDI,-i} + \eta_{ki}$$

Strukturlikningen sier at utfallet *y* skapes av observerte kjennetegn (X), faktisk behandling (P), kontorets PDI-praksis (φ_PDI direkte regressor) og alt uobservert (η). δ er parameteren vi vil ha — kausal effekt av faktisk VR-behandling.

**Tabell 1.** Notasjon i Markussen & Røed sammenstilt med konvensjonell IV-notasjon. Kolonne 1 viser hvordan variabelen er skrevet i artikkelen, kolonne 2 hva den representerer økonomisk, og kolonne 3 hva den ville hett i en standard IV-fremstilling (Y, X, D, Z). Tabellen er en oversettelsesnøkkel — ingen ny informasjon, men gjør det lettere å gå mellom artikkelen og lærebok-notasjonen.

| M&R | Rolle | Konvensjonell IV-notasjon |
|---|---|---|
| y_ki | Utfall k for individ i | Y |
| X_i | Observerte kjennetegn | X eller W (eksogen kontroll) |
| P_i = (P_1, P_2, P_3, P_4) | Faktisk VR-deltakelse, **endogen** | D |
| φ_PDI,-i | Lokal PDI-strenghet, eksogen kontroll | (atypisk — brukes som regressor) |
| η_ki | Alt uobservert | ε / u |

**Hva endogeniteten består i.** Problemet sitter i P. Faktisk VR-deltakelse er korrelert med η fordi uobservert helse og motivasjon styrer både *hvem* som blir behandlet (seleksjonen) og *hvordan det siden går* (utfallet). Konkret: cov(P, η) ≠ 0, slik at OLS av y på P + X fanger både den kausale effekten δ og denne seleksjonskanalen — δ̂_OLS blir skjev. Det er nettopp dette IV med φ_VR som instrument korrigerer for. Mekanismen utdypes i blokk 3.

**Hvorfor er φ_PDI på høyresiden av (6) og ikke et instrument?** Institusjonelt: PDI-beslutninger ble tatt på sosialforsikringskontor (430 kontor) mens VR ble forvaltet av arbeidskontor (152 kontor) — PDI-administrasjonen lå altså på et **mer lokalt** nivå (fotnote 3, s. 10). M&R har derfor valgt å la φ_PDI virke direkte gjennom sin egen koeffisient τ, mens P_VR1..P_VR4 er endogene og instrumenteres med de fire φ_VR-ene. Fotnote 6 (s. 20) — knyttet til tabell 2 — viser at φ_PDI har distinkt prediktiv kraft for *programdeltakelse* selv betinget på φ_VR; det er det samme administrative nivå-skillet som ligger bak begge designvalgene.

---

## 2. Hvordan φ konstrueres (likning 2–5) — instrumentet bygges

φ er ikke direkte observerbar; den må bygges som proxy for kontorets praksis. M&R bruker **residualer fra en hjelpemodell**, aggregert per kontor.

**Likning 2 — LPM-hazard, en per behandling S, OLS på person-måned-data:**

$$P_{Sijd} = d'\alpha + X_i'\beta + u_{Sijd}$$

Det vi vil ha er ikke prediksjonen p̂_Sijd, men **residualen** u_Sijd — det som er igjen etter at varighet (d) og kjennetegn (X) er trukket fra. Tolkning: kontorets bidrag pluss støy.

**Hvorfor LPM?** To grunner (s. 15, fotnote 4): (a) lineær form gjør leave-one-out beregnbart analytisk (Sherman-Morrison), (b) unngår at funksjonell form driver resultatene (jf. Angrist & Pischke 2009, kap. 3.4.2).

**Likning 3 — summer residualer per person:** û_Si = Σ_d û_Sijd

**Likning 4–5 — snitt per behandlingsmiljø, leave-one-out (jackknife):**

$$\varphi_{Si} = \frac{1}{N_j-1}\sum_{i' \neq i,\, i' \in j} \hat{u}_{Si'}$$

der **j = lokal administrativ enhet × inngangsår** (s. 14). For VR er enheten arbeidskontor (152 × 10 ≈ 1500 celler); for PDI er enheten sosialforsikringskontor (430 × 10 ≈ 4300 celler).

| M&R | Rolle | Konvensjonell |
|---|---|---|
| P_Sijd | Hendelses-indikator (person × måned) | (hazard-spesifikk, ingen IV-pendant) |
| d | Varighetsdummyer | Tidsdummyer |
| X_i | Samme kontroller som i (6) | X / W |
| p̂_Sijd | OLS-prediksjon — *ikke* brukt videre | — |
| u_Sijd, û_Si | Mellomtrinn-residualer | — |
| φ_Sj | Naivt kontor-snitt (har endogenitetsproblem) | — |
| φ_Si | **Jackknife — selve instrumentet** | Z |

**Skalering (s. 19):** φ-ene er normalisert slik at én enhet tilsvarer forskjellen mellom kontoret som bruker strategien minst og det som bruker den mest (snitt over 10 år). Koeffisientene i tabell 2/3/4 leses derfor som "effekten av å flytte en klient fra det minst aktive til det mest aktive kontoret".

---

## 3. Endogenitetsproblemet i (6)

OLS på likning 6 forutsetter cov(P, η) = 0. Det holder ikke: η rommer uobservert helse, motivasjon, saksbehandlervurdering — som styrer både hvem som får hvilken behandling og hvordan det siden går. Følgen er at OLS-δ er skjeve. P er endogen.

| Symbol | Hva problemet er |
|---|---|
| η_ki | Inneholder uobservert seleksjons- og utfallskanal |
| P_i | Korrelert med η ⇒ cov(P, η) ≠ 0 |
| OLS δ̂ | Skjev (klassisk seleksjons-bias) |

**To grunner til at IV trengs — ikke bare én:**

1. **Endogenitet** av P (cov(P, η) ≠ 0), slik beskrevet over.
2. **Målefeil i φ.** φ er en støyete proxy for sann uobservert lokal strategi (s. 17–18). I reduced form (likning 1) gir det attenuasjon mot null. I likning 6 korrigerer 2SLS for målefeilen gjennom førstesteg-projeksjonen, der P regreseres på φ + X (s. 18, linje 270): "the measurement error is corrected for through the first step estimation".

Begge motiverer IV; de er separate argumenter.

---

## 4. IV / 2SLS — løsningen

Erstatt P med P̂ predikert fra noe som er ortogonalt på η. Det "noe" er φ_VR1–4 (bygget i blokk 2).

**Førstesteg** (4 parallelle OLS):

$$P_{si} = X_i'\pi_X + \varphi_i'\pi_\varphi + \nu_{si}\quad\Rightarrow\quad \hat{P}_{si}$$

**Andresteg** (likning 6 med plug-in):

$$y_{ki} = X_i'\gamma_k + \hat{P}_i'\delta_k + \tau_k\,\varphi_{PDI,-i} + \eta_{ki}$$

Antakelsene som må holde for at δ̂ er konsistent:

| Antakelse | Kort sagt | Kilde i artikkelen |
|---|---|---|
| Eksogenitet | cov(φ_VR, η \| X) = 0 | Eksplisitt s. 17 — krever at X er rik nok til å fange residential sortering |
| Eksklusjon | φ_VR påvirker y kun via P | Eksplisitt s. 18–19 |
| Relevans | π_φ ≠ 0 | Verifisert i tabell 2 |
| Monotonisitet | Ingen "defiers" | Implisitt via LATE-rammeverket; ikke eksplisitt diskutert |

**Inferens.** Standardfeil er klyngret på behandlingsmiljø (lokal administrativ enhet × år) i alle hovedtabeller — eksplisitt i tabellnotene 2 og 3.

**LATE-tolkning.** Fotnote 5 (s. 18) bekrefter at δ_kS estimerer behandlingseffekten *relativt til ikke-behandlet* for hver behandlings-spesifikke complier-gruppe. M&R har verifisert tolkningen via en Monte Carlo-simulering med tilsvarende DGP.

---

## Samlet kategorisering

| M&R-symbol | Rolle i strategien | Konvensjonell IV |
|---|---|---|
| y_ki | Utfall | Y |
| X_i | Eksogen kontroll | X / W |
| P_si | **Endogen** behandling | D |
| φ_VR1,…,VR4 | **Instrument** for P | Z |
| φ_PDI | Eksogen kontroll (egen strukturkoeffisient τ) | — (atypisk) |
| u_Sijd, û_Si | Hjelpetrinn for å bygge φ | — |
| η_ki | Residual i (6) — kilden til endogeniteten | ε |

Tre blokker, to lesninger:

- **Konstruksjon (2–5):** lager φ ut av residualer og jackknife — egen, separat øvelse, gjøres én gang.
- **Estimering (1, 6):** bruker det ferdige φ — enten direkte som regressor (RF, likning 1) for å få totaleffekt, eller som instrument for P (IV, likning 6) for å få behandlingseffekt.

---

## Hva dokumentet ikke dekker

Bevisst forbigått, men relevant for fullstendig forståelse av identifikasjonen:

- **Robusthetstester** (tabell 5–7): tidskonstant instrument; placebo med tidligere inntekt; placebo med ikke-klienter. Disse er *del av* identifikasjonens troverdighet, ikke bare tilleggsanalyser.
- **Begrensning ved leave-one-out i små miljøer**: kontor-år-celler med få klienter gir støyete instrumenter — ikke diskutert eksplisitt av M&R, men en åpenbar svakhet.
- **Detaljerte LATE-tolkninger ved multi-treatment** — Kirkeboen, Leuven & Mogstad (2016) går grundigere inn på dette enn M&R selv gjør; nyttig referanse.
