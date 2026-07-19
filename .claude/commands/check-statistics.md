---
description: Independently re-derive and stress-test a specific statistic or set of statistics before they're trusted
argument-hint: [table-or-figure-reference]
---

# /check-statistics

## Purpose
On-demand invocation of the independent-verification discipline this project needs
everywhere — use this any time a specific number ("is Table 4's DQB1 accuracy for
T1K really 92.9%?", "is the ancestry p-value for arcasHLA still significant after
correcting for 12 comparisons?") needs a direct answer.

## Inputs
- `$1`: a specific table, figure, or claim to check (e.g., "Table 6 Δ column",
  "ancestry z-test for hisat").
- Implicit inputs: `results/standard/`, `datasets/*_gs.csv`, `results_summary.md`.

## Workflow
1. Invoke **statistics-reviewer** to independently re-derive the requested number
   from raw standardized CSVs + gold standard, using a code path different from the
   one that originally produced it.
2. If the check touches ancestry, **statistics-reviewer** applies its ancestry
   scope/power discipline directly (this is now a standing part of its mandate,
   not a separate co-review) — no second agent invocation needed.
3. Report: original value, independently re-derived value, agreement/disagreement,
   sample size / denominator used, and any power or multiple-comparisons caveat.
4. If a disagreement is found, route it to **pipeline-integrity-auditor** as a
   formal finding, and to **hla-benchmark-scientist** as the owning agent.

## Expected Outputs
- A signed verification memo (per `agents/statistics-reviewer.md`'s operating
  instructions): statistic, source, re-derived value, verdict, caveats.
- If a discrepancy is found: a structured bug report, not just a note.
