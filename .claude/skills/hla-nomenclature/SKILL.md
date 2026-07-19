---
name: hla-nomenclature
description: IPD-IMGT/HLA allele nomenclature, resolution fields, gene classes, and notation rules. Use whenever parsing, comparing, reformatting, or writing about HLA allele strings, or explaining resolution levels in manuscript text.
---

# HLA Nomenclature

Reference knowledge for any agent handling allele strings in this repository
(`datasets/*_gs.csv`, `results/standard/*.csv`).

## Allele String Structure

`HLA-A*02:01:01:01` (or without the `HLA-` prefix, as used throughout this repo's
CSVs: `A*02:01:01:01`):

- **Gene**: `A` — one of the classical loci this benchmark tracks:
  `A`, `B`, `C` (Class I), `DRB1`, `DQB1` (Class II). (`DPB1` is Class II but not
  currently in this benchmark's 5-locus scope.)
- **Field 1** ("1-field", historically "2-digit"): `02` — serologically/broadly
  defined allele group.
- **Field 2** ("2-field", historically "4-digit"): `01` — specific protein
  sequence; the clinically relevant resolution for transplant matching.
- **Field 3**: synonymous DNA substitutions within the same protein.
- **Field 4**: differences in non-coding regions.

This project's scoring (see the `benchmark-methodology` skill) only operates at
1-field and 2-field resolution — fields 3 and 4 are truncated during comparison via
`reformat_allele()`.

**Nomenclature note (open in `BACKLOG.md`):** "1-field/2-field" is the current
IPD-IMGT-preferred terminology; "2-digit/4-digit" is the older, still-common informal
term. This repository's manuscript has not yet standardized on one — check
`BACKLOG.md` before introducing either term in new text, and prefer whichever the
most recent resolution recorded there specifies.

## Class I vs. Class II

- **Class I** (`A`, `B`, `C`): expressed on nearly all nucleated cells; generally
  easier for computational callers (see `results_summary.md` — Class I accuracy is
  consistently higher across tools than Class II).
- **Class II** (`DRB1`, `DQB1`): expressed on antigen-presenting cells; harder for
  callers, especially `DQB1` (the lowest-accuracy locus for most tools in this
  benchmark).

## Ambiguity and Ploidy

- Every classical locus is diploid: a sample has two alleles (maternal/paternal),
  represented in this repo's CSVs as two columns (`A`, `A.1`).
- **Phase-ambiguous entries**: lower-resolution typing methods (PCR-SSP/SSOP, used
  for Datasets 1-4 in this project) sometimes cannot resolve which of several
  possible alleles is truly present, represented as a slash-delimited list, e.g.
  `A*01:01/A*01:04/A*01:22`. See the `benchmark-methodology` skill for how this
  project's scoring handles >2-allele ambiguous gold-standard entries.
- **Monoallelic samples**: homozygous individuals have the same allele on both
  chromosomes; some gold-standard sources report this as a single value rather than
  a duplicated pair.

## Reference Databases

- **IPD-IMGT/HLA** (`https://www.ebi.ac.uk/ipd/imgt/hla/`) — the authoritative
  allele database; this repo caches it locally as `datasets/hla.dat` (~338MB,
  downloaded from `https://ftp.ebi.ac.uk/pub/databases/ipd/imgt/hla/hla.dat`).
  Always cite as "IPD-IMGT/HLA" (not "IMGT/HLA" alone) per `BACKLOG.md`'s citation
  standardization item, with the Nucleic Acids Research reference (D1152) at first
  mention.
- Over 25,000 alleles are currently catalogued — the database is a living,
  continuously-updated resource, which is directly relevant to this project's
  "novel allele" scoring: an allele absent from this benchmark's cohort-based valid
  set may still be a real, IMGT-catalogued allele. See `benchmark-methodology`.

## Clinical Matching Standards (for framing, not for scoring)

- US standard: 8/8 allele match required across `A`, `B`, `C`, `DRB1` for unrelated
  donor hematopoietic cell transplantation (`DQB1`/`DPB1` typed and considered when
  feasible).
- European standard: 10/10 allele match across `A`, `B`, `C`, `DRB1`, `DQB1`.
- These thresholds are about per-locus exact matches at 2-field resolution between
  donor and recipient — they are a different quantity from this benchmark's
  "accuracy" (fraction of predicted alleles matching gold standard across many
  samples). Never conflate the two in manuscript text — see
  `agents/clinical-and-equity-reviewer.md`.
