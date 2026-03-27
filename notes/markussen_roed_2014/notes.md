# Notater: Markussen & Røed (2014) — The Impacts of Vocational Rehabilitation

IZA Discussion Paper No. 7892. Frischsenteret.

---

## 1. Forskningsspørsmål
Hva er effektene av ulike yrkesrettede rehabiliteringsstrategier (VR) på arbeidsmarkedsutfall for mottakere av midlertidig uførestønad (TDI) i Norge? Sammenligner fire strategier: (VR1) subsidiert arbeid i ordinære bedrifter, (VR2) skjermet sysselsetting, (VR3) ordinær utdanning, (VR4) målrettede kurs.

## 2. Målgruppe
Arbeidsmarkedsøkonomi, disability/social insurance-feltet. Direkte relevant for ALMP-policy i Norden.

## 3. Metode
**Identifikasjonsstrategi:** Lokal variasjon i rehabiliteringspraksis mellom arbeidskontor brukes som kilde til eksogen variasjon. Ideen: fra individets perspektiv er det et element av tilfeldig tildeling i lokale myndigheters behandlingsprioriteringer.

**To analyser:**
- **Reduced form:** Effekt av lokalt behandlingsmiljø på utfall for alle potensielle deltakere (ITT). Robust selv om behandlingsmiljøet påvirker gjennom andre kanaler enn faktisk deltakelse. Ulempe: måler «lokal strategi» med feil → bias mot null.
- **IV-analyse:** Lokal behandlingspraksis som instrument for faktisk deltakelse. Løser målefeil-problemet. Estimerer LATE for compliers. Forutsetter at behandlingsmiljøet kun påvirker utfall gjennom faktisk programdeltakelse.

Instrumentet: andelen som får ulike behandlingstyper blant *andre* personer registrert på samme kontor på omtrent samme tidspunkt (kontrollert for individkjennetegn og lokalt arbeidsmarked).

## 4. Data
- **Kilde:** Administrative registerdata, Norge (SSB)
- **Utvalg:** Komplett populasjon av TDI-inntreden 1996–2005, N = 345 000 spells
- **Oppfølging:** Til 2010 (opptil 7 år etter inntreden)
- **Behandlingsvariabler:** 4 VR-typer (VR1–VR4), basert på *første* tiltak
- **Utfall:** Sysselsetting, inntekt, trygdeavhengighet
- **152 arbeidskontor**, 430 lokale trygdekontor

## 5. Statistiske metoder

**Instrumentkonstruksjon:**
- For hver av 5 behandlinger (VR1–VR4 + PDI) estimeres lineære diskrete varighetsmodeller (ligning 2) med månedlige overgangssannsynligheter
- Residualsummer per person gir kovariat-justert overgangstilbøyelighet
- Lokalt behandlingsmiljø = gjennomsnitt av residualer blant *andre* klienter i samme miljø (leave-one-out, ligning 5)
- Behandlingsmiljø = arbeidskontor × inngangsår → utnytter både tverrsnitts- og tidsvariasjon (nasjonale trender absorbert av tidsdummies)
- Lineær modell valgt bevisst: forhindrer at forskjeller i funksjonell form driver resultatene

**Kontrollvariabler (svært rike):**
- Individ: alder, kjønn, utdanning, nasjonalitet, tidligere inntekt, tidligere trygdehistorikk
- Lokalt: gjennomsnittlig utdanning, inntekt, dødelighet, uføreandel (kommune + arbeidskontornivå, justert for kjønn/alder)
- Konjunktur: ledighetstrate, jobbfinningsrate, jobbdestruksjonsrate (arbeidsmarkedsregion, 6 mnd før til 18 mnd etter inntreden)
- Inntredningsmåned-dummies

**Førstesteg (tabell 2):**
- Sterke diagonale effekter: lokale strategiindikatorer predikerer faktisk behandling klart
- φ forklarer 5–49 % av variansen i predikerte overgangsrater (lavest for VR3, høyest for VR4)
- Høy PDI-tilbøyelighet → raskere overgang til *alle* VR-typer (tolkning: raskere saksbehandling generelt)

**Utfallsmål:**
- Post-TDI: sysselsetting (>160 000 NOK), arbeidsinntekt, PDI-overgang, trygdeoverføringer — alt første kalenderår etter avsluttet spell
- Ukondisjonal: gjennomsnittlig årlig arbeidsinntekt og trygd over 5 år etter inntreden
- År-for-år: arbeidsinntekt og «ferdig + ansatt uten subsidie» opptil 7 år etter inntreden

## 6. Funn

**Reduced form (tabell 3):**
- **VR1 (subsidiert ordinært arbeid):** +1,1 ppt sysselsetting, +5 000 NOK inntekt, −1,1 ppt PDI (post-TDI). +5 700 NOK/år over 5 år.
- **VR2 (skjermet):** −1,7 ppt sysselsetting, −4 400 NOK inntekt (post-TDI). −1 400 NOK/år over 5 år (n.s.).
- **VR3 (utdanning):** +1,3 ppt sysselsetting, +6 900 NOK inntekt, −2,7 ppt PDI (post-TDI). Men −6 200 NOK/år over 5 år (lock-in).
- **VR4 (kurs):** −0,7 ppt sysselsetting, −3 200 NOK inntekt (post-TDI). −2 700 NOK/år over 5 år.
- **Strengere PDI:** −1,7 ppt sysselsetting, +8,2 ppt PDI-overgang, −5 200 NOK/år arbeidsinntekt, +4 600 NOK/år trygd.

**Hovedkonklusjon:** Place-and-train (VR1) er overlegen. Utdanning (VR3) gir gode post-TDI-resultater, men med stor lock-in-kostnad. Skjermet sysselsetting (VR2) og kurs (VR4) er kontraproduktive. Strengere PDI-praksis reduserer innstrømming til PDI, men gir ikke mer arbeid — bare lengre TDI-spells.

**IV-estimater (tabell 4, post-TDI, vs. ikke-behandlet):**
- **VR1:** +11,7 ppt sysselsetting, +56 700 NOK inntekt, −12,9 ppt PDI, −61 800 NOK trygd
- **VR2:** −19,0 ppt sysselsetting, −45 700 NOK inntekt
- **VR3:** +10,7 ppt sysselsetting, +59 300 NOK inntekt, −22,7 ppt PDI, −29 400 NOK trygd
- **VR4:** −11,8 ppt sysselsetting, −47 700 NOK inntekt (n.s.)

Inntektsgevinst per ekstra ansatt: ~486 000 NOK (VR1) — nær gjennomsnittlig norsk årslønn.

**Robusthet (seksjon 6):**
- **Kun tverrsnitts-variasjon (tabell 5):** Tidskonstante instrumenter gir kvalitativt like resultater, men større koeffisienter og bredere KI. Hovedkonklusjoner uendret.
- **Placebo — tidligere inntekt (tabell 6):** Ingen signifikant korrelasjon mellom lokale strategier og inntekt 4–5 år *før* TDI-inntreden. Ingen tegn på seleksjonsbias.
- **Placebo — ikke-klienter (tabell 7):** Lokal VR1-intensitet korrelerer *negativt* med inntekt for matchede ikke-klienter — altså motsatt av hva vi frykter. VR2 og PDI-intensitet korrelerer positivt med inntekt for ordinære ledige (tolkning: frigjorte ressurser). Ingen tegn på at resultatene er drevet av uobserverte lokale arbeidsmarkedsforhold.

## 7. Bidrag
- Første studie med bred, populasjonsbasert identifikasjon av kausale effekter av ulike VR-strategier (N=345 000)
- Viser at place-and-train er overlegen train-and-place — bekrefter amerikanske RCT-funn i en nordisk kontekst
- Etablerer lokal praksisvariasjoner som troverdig instrument for ALMP-evaluering i Norge — direkte metodisk forbilde for videre IV-studier (inkl. VLT)
- Demonstrerer at strengere PDI-praksis har begrenset effekt på sysselsetting — de fleste går til andre ytelser, ikke til arbeid

## 8. Replikerbarhet
Administrative registerdata via SSB — ikke fritt tilgjengelig. Ingen replikasjonsarkiv nevnt. Monte Carlo-verifisering av IV med multiple behandlinger tilgjengelig: http://www.frisch.uio.no/docs/MC_multi_treatment.html

---

## Relevans for artikkel 2 (VLT)

**Direkte forbilde for IV-strategi:**
- Instrumentkonstruksjonen (leave-one-out, lokal tildelingspraksis) kan overføres nesten direkte til VLT
- Kontrollvariabel-oppsettet (individ, lokalt, konjunktur) setter standarden
- Robusthetsanalysen (placebo med tidligere inntekt, ikke-klienter) bør replikeres

**Viktige forskjeller fra VLT-artikkelen:**
- M&R sammenligner *fire* VR-strategier; VLT-artikkelen fokuserer på *ett* tiltak (VLT vs. ikke-VLT)
- M&R bruker TDI-populasjonen; VLT-artikkelen bruker personer med avklart nedsatt arbeidsevne (bredere?)
- VLT er et varig tiltak (etterspørselsside); M&R dekker primært tilbudsside-tiltak (VR3, VR4) og korttids etterspørselsside (VR1)

**Nøkkelreferanse:** Tabell 4 (IV-estimater) er den mest sammenlignbare for VLT-artikkelen — effekten av subsidiert ordinært arbeid (VR1) er nærmeste proxy.

---

*Fullstendig lest: alle 10 splits (37 sider).*
