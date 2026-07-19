---
name: benchmark-methodology
description: The scoring contract this specific benchmark uses - resolution handling, correct/miscalled/novel/no-call taxonomy, filtered vs unfiltered accuracy, phase ambiguity, monoallelic duplication. Use whenever reasoning about, explaining, or modifying accuracy numbers in this repository.
---

# Benchmark Scoring Methodology

This is the canonical description of how this repository turns predicted HLA
alleles into an accuracy number, reverse-engineered from
`notebooks/accuracy_fixed_executed.ipynb`. **`agents/hla-benchmark-scientist.md`
owns this contract** — this skill is the shared reference every other agent reads
before reasoning about a number, not a license to reimplement it independently.

## The Comparison

For each sample × locus:
1. Gold standard (GS) has up to 2 alleles; prediction (PR) has up to 2 alleles.
2. Both reformatted to the target resolution (1-field or 2-field) via
   `reformat_allele()`.
3. **Monoallelic handling**: if either side has only 1 allele, it is duplicated to
   fill both slots.
4. **Comparison**: predicted pair vs. GS pair compared both in-order (parallel) and
   swapped (crosswise); the higher match count (0, 1, or 2) wins. Phase (which
   chromosome) is never required to be correct.
5. **Phase-ambiguous GS** (>2 distinct alleles after reformatting, from
   lower-resolution PCR typing): scoring switches to "does each predicted allele
   appear anywhere in the ambiguous GS set," rather than pairwise matching.

## Call Categories (per predicted allele)

- **Correct**: matches an allele in this specific sample's GS set.
- **Miscalled**: not in this sample's GS set, but *is* in the cohort-wide valid set
  for that locus (i.e., some other sample in the cohort was genuinely typed with
  this allele).
- **Novel**: not in the cohort-wide valid set at all — never observed in *any*
  sample's gold standard at that locus, in this benchmark's data. **This is a
  cohort-based definition, not an IMGT-database-based one** — a "novel" call may
  still be a real, catalogued IPD-IMGT allele that simply isn't represented in this
  specific cohort. This was a deliberate, reviewer-driven choice (see
  `BACKLOG.md`'s "Resolved" section) made because the legacy gold standard
  shouldn't be trusted as the arbiter of allele existence.
- **No-call**: tool produced no prediction for this slot.

## Filtered vs. Unfiltered Accuracy

- **Unfiltered**: novel calls counted as errors (denominator = all call slots).
  This is the stricter, "primary metric" convention per `results_summary.md`.
- **Filtered**: novel calls excluded from the denominator entirely (denominator =
  cohort-known alleles only). More forgiving; isolates "how good is this tool on
  alleles we know to exist in this cohort."
- Report both when writing about a tool's accuracy — the gap between them (see
  `results_summary.md` Table 6's `Δ` column) is itself informative: a large gap
  means a tool calls many alleles absent from the cohort (could be real rare
  alleles, could be errors, could be reference-database mismatch).

## Class I-only Tools

Some tools (confirmed: OptiType; **verify current status of any others** — this
was a known code/documentation inconsistency as of the last audit, see
`memory/KNOWN_BUGS.md`) only predict Class I loci. These tools are excluded from
Class II no-call penalties in the adjusted accounting (they're not being
"punished" for not attempting DRB1/DQB1), but Class II *is* shown as 0%/100%
no-call in raw heatmaps to reveal true scope.

## Statistical Testing Convention

Ancestry comparisons (Europe vs. Yoruba, currently Dataset 1 only — see
`agents/statistics-reviewer.md`) use a two-proportion z-test
(`statsmodels.stats.proportion.proportions_ztest`) per tool, per resolution level,
uncorrected for the resulting multiple comparisons as of the last audit.

## Known Fragile Points (do not treat as settled)

- Read-length accuracy (`compute_readlength_accuracy` in the notebook) uses a
  simpler convention: it does not count a locus with zero predicted alleles as a
  no-call in the denominator, unlike the main scoring engine — this is a real
  methodological inconsistency between sub-analyses, not a bug per se, but it means
  read-length accuracy numbers are not directly comparable to the main accuracy
  numbers without noting this.
- The ambiguous-match and monoallelic-duplication conventions are both
  accuracy-permissive by design and self-described by the prior maintainer as
  "not perfect, but no better alternative found" — do not present them as
  methodologically unassailable in manuscript text.
