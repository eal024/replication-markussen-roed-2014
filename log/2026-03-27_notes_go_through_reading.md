# Lesenotater: Markussen & Røed (2014) — løpende gjennomgang

Dato startet: 2026-03-27

---

## Kommentarer underveis

### s. 7 — RF vs. IV: hvorfor RF er mer robust

RF estimerer totaleffekten av behandlingsmiljøet (Z → Y), uansett hvilken kanal effekten går gjennom. IV antar at Z kun påvirker Y *gjennom* faktisk deltakelse D (eksklusjonsrestriksjonen).

Problemet: et kontor med høy VR1-tilbøyelighet kan også påvirke utfall via andre kanaler — f.eks. endrede insentiver for jobbsøk, raskere saksbehandling, eller sterkere forventningssignaler. Hvis slike sidekanaler finnes, bryter IV-antakelsen sammen, men RF forblir gyldig.

RF er altså mer robust, men estimerer noe vagere: effekten av *miljøet*, ikke av *tiltaket i seg selv*.

### s. 7 — Hvorfor RF-koeffisienten er biased mot null (og motivasjon for IV)

Lokal strategi er uobserverbar — vi måler den med støy (hva andre på kontoret faktisk fikk). Klassisk målefeil i uavhengig variabel demper koeffisienten mot null: tilfeldig variasjon i hvem som får tiltak "vanner ut" den sanne sammenhengen mellom strategi og utfall.

IV løser dette: førstetrinnet modellerer Z → D eksplisitt, og andretrinnet bruker kun predikert variasjon i D (renset for støy). Derfor gir IV større og mer presise estimater enn RF.

### s. 7–8 — Utvalgskrav: RF vs. IV

RF trenger ikke observere behandlingsstatus D — ligningen er Y = α + πZ + γX + ε. Det holder å vite hvilket kontor personen tilhørte (for Z) og utfallet Y. Alle TDI-spells kan brukes.

IV krever D eksplisitt i førstetrinnet (D = α + φZ + γX + ν). For personer som fortsatt er i TDI er D sensurert — de kan fortsatt få tiltak. Derfor kan IV kun bruke fullførte spells der behandlingsstatus er kjent.

Eksklusjonsrestriksjonen for IV: behandlingsmiljøet Z kan kun påvirke Y *gjennom* faktisk deltakelse D. Denne antakelsen er ikke nødvendig for RF.

### s. 8 — Kobling til PDI/disability insurance-litteraturen

Ved å inkludere PDI-strenghet som femte «behandling» kobler studien seg til den internasjonale disability insurance-litteraturen (gatekeeping, avslag/søknad/arbeidstilbud — Bound, Maestas, Chen & van der Klaauw m.fl.). Løfter analysen utover ren VR-evaluering og gir den en bredere kontekst.

### Hovedfunn (IV-estimater, post-TDI)

- **VR1 (subsidiert ordinært arbeid):** Klart best. +12 ppt sysselsetting, +57 000 NOK inntekt, −13 ppt PDI. Place-and-train virker.
- **VR2 (skjermet sysselsetting):** Kontraproduktiv. −19 ppt sysselsetting, −46 000 NOK inntekt.
- **VR3 (ordinær utdanning):** Positiv post-TDI (+11 ppt sysselsetting), men stor lock-in-kostnad over 5 år.
- **VR4 (kurs):** Kontraproduktiv. −12 ppt sysselsetting.

### VR2 og seleksjon: er tiltaket skadelig, eller er det complier-gruppen?

IV-estimatet sier VR2 er kontraproduktivt (−19 ppt sysselsetting). Men VR2-gruppen har dårligst utgangspunkt: lavest utdanning, høyest innvandrerandel, lavest andel med tidligere jobb/sykepenger (58.7%). To innvendinger:

1. **LATE ≠ ATE.** IV estimerer effekten for compliers — de som marginalt skyves inn i VR2 av lokale praksisforskjeller. Disse kan være en helt annen gruppe enn de som alltid havner i VR2.
2. **Kontrafaktualet er uklart.** «Uten VR2» kan bety VR1, annet tiltak, eller ingenting. Hvis kontor med høy VR2-andel gjør det *istedenfor* VR1, er det kanskje fraværet av VR1 som driver det negative resultatet — ikke VR2 i seg selv.

Begrensning ved flertiltaks-IV: vanskelig å skille om VR2 er aktivt skadelig (innlåsing i skjermet sektor) fra at det fortrenger bedre alternativer.

### Interessant funn: strengere PDI-praksis

Strengere inngangsvilkår til PDI reduserer PDI-innstrømming kraftig, men har liten effekt på retur til arbeid. Folk ender ikke i jobb — de blir hengende i TDI eller havner på andre ytelser. Gatekeeping alene flytter folk mellom ordninger uten å løse sysselsettingsproblemet. Innstramming uten effektive tiltak (som VR1) gir lite. Relevant for den norske AAP-debatten.

---

## Institusjonell setting

- **TDI (midlertidig uførestønad):** Helserelatert ytelse for personer med nedsatt arbeidsevne. Midlertidig — skal i prinsippet avklares mot arbeid eller varig uføretrygd (PDI).
- **PDI (varig uføretrygd):** Permanent ytelse. Overgang fra TDI til PDI krever vedtak — lokal praksis varierer.
- **VR (yrkesrettet rehabilitering):** Fire typer tiltak tilbudt TDI-mottakere:
  - VR1: Subsidiert arbeid i ordinær bedrift (place-and-train)
  - VR2: Skjermet sysselsetting (vernet bedrift)
  - VR3: Ordinær utdanning
  - VR4: Målrettede kurs
- **Arbeidskontor:** 152 kontor med ansvar for VR-tildeling. Lokal praksis varierer betydelig — dette er kilden til eksogen variasjon.
- **Trygdekontor:** 430 lokale kontor med ansvar for PDI-vedtak. Separat fra arbeidskontor.
- **Populasjon:** 166 000 TDI-mottakere (2013-tall), hvorav ca. 60 000 deltok i VR.

