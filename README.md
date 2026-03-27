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
├── README.md          # Dette dokumentet
├── CLAUDE.md          # Arbeidsregler for AI-assistenten
├── scripts/           # R-skript for replikasjon
├── data/              # Simulerte/syntetiske data
├── output/            # Tabeller og figurer
└── notes/             # Notater om metode og valg underveis
```

## Status

Simulert datasett som replikerer tabell 1 (deskriptiv statistikk) er ferdig. Neste steg er instrumentkonstruksjon (leave-one-out) og IV-estimering.

## Kobling

Detaljerte lesenotater fra originalen finnes i `notes/markussen_roed_2014/notes.md` (kopiert fra research-project).
