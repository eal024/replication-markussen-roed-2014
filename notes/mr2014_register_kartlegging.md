# Variabler i Markussen & Røed (2014) — kartlegging mot egne registre

> **Opphav:** replikasjonsrepoet `replication-markussen-roed-2014`
> **Filsti i opphav:** `notes/mr2014_register_kartlegging.md`
> **GitHub:** https://github.com/eal024/replication-markussen-roed-2014
> **Lokal sti (opphav):** `/home/eirik/Documents/replication-markussen-roed-2014`
> **Relaterte notater i opphav:**
> - `notes/markussen_roed_2014/notes.md` — sammendrag av artikkelen
> - `notes/markussen_roed_2014/identifikasjonsstrategi.md` — IV-strategien
> - `notes/data_dictionary.md` — simulerte datasett
> - `notes/markussen_roed_2014/kilde/Markussen_Roed_2014.md` — full artikkeltekst
>
> **Artikkel:** Markussen & Røed (2014), "The Impacts of Vocational Rehabilitation", IZA Discussion Paper No. 7892.
>
> **Formål:** Kartlegge variablene M&R bruker, og bygge bro til registervariabler for egen IV-analyse av varig lønnstilskudd (VLT).
>
> **Tilbakeflytting til phd-data-repo:** Filen er skrevet for å kunne flyttes uendret. Behold opphavslinjene over slik at koblingen til replikasjonsarbeidet er sporbar. Når filen flyttes, oppdater "Lokal sti (opphav)" og legg inn ny "Lokal sti (her)".

---

## Status

- [x] Variabler identifisert og gruppert (T/K/J/O/U)
- [ ] Kommentarrunde (rad-for-rad gjennomgang med PhD-student)
- [ ] Registerkilder fylt inn
- [ ] Variabelnavn / kodelister fylt inn
- [ ] Uthentingsstrategi per variabel
- [ ] Testkjøring mot register

## Konvensjoner

- **ID-prefiks:** `T` trygdeytelser/tiltak · `K` konstante · `J` jevnt endres · `O` kontor/lokalt · `U` utfall
- Tomme celler markeres med `–` til de fylles ut
- Hver tabell har faste kolonner: **Register** (kilde, f.eks. FD-Trygd, A-ordningen), **Variabelnavn** (eksakt feltnavn i registeret), **Notater** (uthentingsstrategi, kodelister, transformasjoner, fallback-kilder)

---

## Gruppe 1 — Trygdeytelser og tiltak (T)

Hendelser og tilstander som beskriver hvor i systemet personen er.

| ID | Variabel | Rolle hos M&R | Register | Variabelnavn | Notater |
|---|---|---|---|---|---|
| T1 | Sykepenger pre-TDI (forløp + uttømt rettighet) | Bakgrunn; "fraction with previous employment and exhausted sick pay" (tabell 1) | – | – | – |
| T2 | TDI-inntreden (dato) | Definerer t=0 og populasjon | – | – | – |
| T3 | TDI-spell-slutt (dato + flag observert/sensurert) | Spell-varighet og høyresensurering | – | – | – |
| T4 | TDI person-måned (avledet av T2+T3) | Datasett-format for likning 2 (hazardmodell) | – | – | – |
| T5 | VR1 — subsidiert ordinær jobb (startdato) | D_VR1; konkurrerende første-event | – | – | – |
| T6 | VR2 — skjermet (startdato) | D_VR2 | – | – | – |
| T7 | VR3 — utdanning (startdato) | D_VR3 | – | – | – |
| T8 | VR4 — målrettede kurs (startdato) | D_VR4 | – | – | – |
| T9 | PDI — varig uføretrygd (startdato) | D_PDI; også utfall (U2) | – | – | – |

## Gruppe 2 — Konstante kjennetegn (K)

Tidsuavhengige per person. M&R legger inn ikke-parametrisk (dummies).

| ID | Variabel | Rolle hos M&R | Register | Variabelnavn | Notater |
|---|---|---|---|---|---|
| K1 | Kjønn | 1 dummy | – | – | – |
| K2 | Fødselsår (gir alder via T2) | Inngår via alders-dummies (J1) | – | – | – |
| K3 | Innvandrerbakgrunn — 4 opprinnelseskategorier | 4 dummies (Europa/Nord-Amerika, Afrika, Asia, Sør-Amerika) | – | – | – |
| K4 | Utdanning ved inntreden — nivå × type | 19 dummies (NUS-koder); målt ved t=0 | – | – | – |

## Gruppe 3 — Variabler som endres jevnt (J)

Tidsvarierende på individnivå, men målt på/før inntredentidspunkt og holdt fast som kontroll.

| ID | Variabel | Rolle hos M&R | Register | Variabelnavn | Notater |
|---|---|---|---|---|---|
| J1 | Alder ved inntreden | 40 dummies (18–57) | – | – | – |
| J2 | Inntreden-måned | 115 månedsdummies; absorberer nasjonale trender | – | – | – |
| J3 | Tidligere arbeidsinntekt — sum siste 3 år | Residualisert mot alder+kjønn → 13 kategorier | – | – | – |
| J4 | Tidligere trygde-/sosialforsikringsoverføringer — sum siste 3 år | Residualisert → 12 kategorier | – | – | – |

## Gruppe 4 — Kontorrelaterte og lokale variabler (O)

Stedfestingen som hele identifikasjonsstrategien hviler på.

| ID | Variabel | Rolle hos M&R | Register | Variabelnavn | Notater |
|---|---|---|---|---|---|
| O1 | Arbeidskontor-ID ved inntreden (152 kontor i M&R) | Definerer behandlingsmiljø for VR1–VR4 | – | – | – |
| O2 | Lokalt trygdekontor-ID ved inntreden (430 kontor i M&R) | Definerer behandlingsmiljø for PDI-streng-praksis | – | – | – |
| O3 | Behandlingsmiljø = O1/O2 × inntredensår | Cellen leave-one-out beregnes innenfor | – | – | – |
| O4 | Bostedskommune | Grunnlag for lokale sosioøkonomiske rater | – | – | – |
| O5 | Travel-to-work-area / BA-region (40 regioner i M&R) | Grunnlag for konjunkturindikatorer | – | – | – |
| O6 | Lokale sosioøkonomiske rater (8 stk: uføreandel, dødelighet, inntekt, utdanning — på kommune- og kontornivå) | Kontrollvariabler | – | – | – |
| O7 | Lokale konjunkturindikatorer (44 dummies: ledighet, jobbfinning, jobbdestruksjon, ulike tidsvinduer) | Kontrollvariabler | – | – | – |
| O8 | φ_i — leave-one-out instrumenter for VR1, VR2, VR3, VR4, PDI (5 stk) | **Avledet variabel**, ikke direkte fra register; bygges av T5–T9 + O3 + x_i | – | – | – |

## Gruppe 5 — Utfallsvariabler (U)

To tidsperspektiv: kondisjonelt på spell-slutt (post-TDI) og ukondisjonelt (fra inntreden).

| ID | Variabel | Rolle hos M&R | Register | Variabelnavn | Notater |
|---|---|---|---|---|---|
| U1 | Sysselsatt 1. kalenderår etter spell-slutt | Binær, terskel 160 000 NOK arbeidsinntekt (2013-priser) | – | – | – |
| U2 | PDI-overgang 1. kalenderår etter spell-slutt | Binær | – | – | – |
| U3 | Arbeidsinntekt 1. kalenderår etter spell-slutt | Kroner | – | – | – |
| U4 | Trygdeoverføringer 1. kalenderår etter spell-slutt | Kroner | – | – | – |
| U5 | Gjennomsnittlig årlig arbeidsinntekt år 1–5 etter inntreden | Ukondisjonal — fanger lock-in | – | – | – |
| U6 | Gjennomsnittlig årlig trygdeinntekt år 1–5 etter inntreden | Ukondisjonal | – | – | – |
| U7 | Arbeidsinntekt år-for-år, år 1–7 etter inntreden | Profilanalyse | – | – | – |
| U8 | "Ferdig + ansatt uten subsidie" år-for-år, år 1–7 | Profilanalyse | – | – | – |

---

## Logg

| Dato | Endring |
|---|---|
| 2026-05-07 | Fil opprettet. Variabler identifisert og gruppert, kolonner Register/Variabelnavn/Notater står tomme. |
