# Replication: Markussen & Røed (2014)

Replikasjon av «The Impacts of Vocational Rehabilitation» (IZA DP No. 7892).

Formålet er å forstå IV-strategien i detalj ved å gjenskape analysen med simulerte data — som forberedelse til en egen IV-analyse av varig lønnstilskudd (VLT).

---

## Originalartikkel

- **Tittel:** The Impacts of Vocational Rehabilitation
- **Forfattere:** Simen Markussen & Knut Røed (Frischsenteret)
- **Publikasjon:** IZA Discussion Paper No. 7892, januar 2014
- **Data:** Administrative registerdata (SSB), TDI-inntreden 1996–2005, N = 345 000
- **Metode:** IV med lokal praksisvariasjoner (leave-one-out) som instrument

## Filstruktur

```
./
├── CLAUDE.md                          # Arbeidsregler for AI-assistenten
├── README.md                          # Dette dokumentet
├── econ5106_L08_late (3).pdf          # Forelesningsnotater om IV/LATE
├── scripts/R/
│   ├── 01_simuler_data.R             # Datagenerering (tabell 1, kovariater, utfall)
│   └── 02_iv_instrument.R            # Kontor, strategi, leave-one-out instrument
├── data/                              # Simulerte datasett
├── output/                            # Figurer og tabeller
├── notes/
│   ├── markussen_roed_2014/           # Artikkelnotater og full tekst
│   ├── data_dictionary.md             # Dokumentasjon av simulert datasett
│   └── oppskrift_replikasjon_data.md  # Generell oppskrift for replikasjon
└── log/                               # Arbeidslogg og TODO
```

## Status

Simulert datasett (N=345 107) med korrelert korrelasjonsstruktur er ferdig. IV-instrumentkonstruksjon er påbegynt: 4 kontor med ulik behandlingsstrategi og leave-one-out instrument. Neste steg er å la utfall avhenge av behandling med kjent β, og estimere OLS vs. IV.

## Dokumentasjon

- **Datadokumentasjon:** `notes/data_dictionary.md`
- **Lesenotater:** `notes/markussen_roed_2014/notes.md`
- **Replikasjonsoppskrift:** `notes/oppskrift_replikasjon_data.md`
- **IV/LATE-teori:** `econ5106_L08_late (3).pdf`
