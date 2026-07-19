# Benchmark Summary Template

Structure for any `results_summary.md`-style rollup. Follow the existing
`results_summary.md` conventions exactly for consistency.

---

# HLA Benchmarking — Results Summary

*Source: `<notebook/script>` — `<N>` tools, datasets `<range>`*
*Generated `<YYYY-MM-DD>` by `<agent/human>`*
*Changes since last version: `<one-line summary, or "none">`*

## Scoring Definitions
(Reuse the definitions table from the current `results_summary.md` verbatim unless
the scoring contract itself changed — if it did, that change must be approved per
`agents/hla-benchmark-scientist.md`'s Forbidden Decisions before this table
changes.)

## Table 1: Overall Accuracy — 1-field
| Tool | Class I | Class II | Overall |
|---|---|---|---|

## Table 2: Overall Accuracy — 2-field, Unfiltered (primary metric)
| Tool | Class I | Class II | Overall |
|---|---|---|---|

## Table 3: Overall Accuracy — 2-field, Filtered
| Tool | Class I | Class II | Overall |
|---|---|---|---|

## Table 4: Per-Locus Accuracy — 2-field, Filtered
| Tool | A | B | C | DRB1 | DQB1 |
|---|---|---|---|---|---|

## Table 5: Per-Locus Raw Counts — 2-field, Filtered
(Correct / Miscalled / Novel / No-call / Total / Accuracy, one subtable per locus)

## Table 6: Novel Allele and No-Call Rates — 2-field
| Tool | No-call % | Novel % | Unfiltered Overall | Filtered Overall | Δ |
|---|---|---|---|---|---|

## Notes
- Document every known caveat per tool (Class I-only scope, high novel rate causes,
  etc.) explicitly — do not let a reader infer these from the numbers alone.
- Document dataset scope/exclusions (e.g., "D7 = family trio, D8 = WGS/long-read —
  excluded from main analysis") explicitly at the bottom.

## Sign-offs
- [ ] hla-benchmark-scientist
- [ ] statistics-reviewer
- [ ] pipeline-integrity-auditor (cross-implementation check)
