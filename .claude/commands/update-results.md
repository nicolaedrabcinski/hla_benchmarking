---
description: Propagate an upstream data or scoring change through results_summary.md, all figures, and flag manuscript passages that now need updating
argument-hint: [reason-for-update]
---

# /update-results

## Purpose
This is the "something changed, make everything downstream consistent again"
command — the single biggest recurring failure mode in this project's history is
exactly what this command exists to prevent (stale manuscript numbers after the
HLA-VBSeq fix, the 682-vs-652 sample count drift).

## Inputs
- `$1` (optional): free-text description of what changed (e.g., "HLA-VBSeq
  DRB1/DQB1 column-swap fix").
- Implicit inputs: current git diff/status of `results/standard/`, `datasets/`, and
  the notebooks.

## Workflow
1. Run `git status` and `git diff --stat` against `results/`, `datasets/`, and
   `notebooks/` to enumerate exactly what changed.
2. Invoke `/run-benchmark` to regenerate `results_summary.md`.
3. Diff the new `results_summary.md` against the previous version; produce a table
   of every number that moved, by how much.
4. Invoke **figure-designer** to regenerate every figure whose source data is in the
   changed set.
5. Grep the manuscript `.docx` (via **scientific-writer**) for every number that
   appears in the diff from step 3, and list every manuscript location that now
   disagrees with current data.
6. Invoke **statistics-reviewer** to confirm the new numbers.
7. Produce a single "propagation report": what changed upstream → what changed in
   results_summary.md → which figures were regenerated → which manuscript passages
   are now stale and need `/update-paper`.

## Expected Outputs
- Updated `results_summary.md`.
- Regenerated figures for affected data.
- A propagation report listing every stale manuscript passage, with old value, new
  value, and location.
- No manuscript text is edited by this command — it only identifies what
  `/update-paper` needs to fix.

## Appendix: Full Cycle Diagram

*(Merged in from the former `workflows/full-benchmark-cycle.md` — this command's
step list above and this diagram were fully redundant with each other; this is now
the single source.)*

```
Trigger: upstream data or logic change
        │
        ▼
git status / git diff --stat scoping  ──  reproducibility-manager
        │
        ▼
Schema + integrity validation ─────────  pipeline-integrity-auditor
        │
        ▼
Re-run canonical scoring ──────────────  hla-benchmark-scientist
        │
        ▼
Cross-implementation diff (Python/Julia) ─ pipeline-integrity-auditor
        │
        ▼
Independent statistical re-derivation ─  statistics-reviewer
        │
        ▼
Regenerate results_summary.md
        │
        ▼
Diff against previous results_summary.md
        │
        ▼
Regenerate affected figures ───────────  figure-designer
        │
        ▼
Grep manuscript for now-stale numbers ─  scientific-writer
        │
        ▼
Propagation report produced
        │
        ▼
Human decides: update manuscript now, or batch with other pending changes?
```

**When to run this command:** after any `results/standard/*.csv` change, after any
`datasets/*_gs.csv` change, after any edit to the scoring logic in
`notebooks/accuracy_fixed_executed.ipynb` or its Julia counterpart, before every
`/prepare-release`, and ideally on a scheduled cadence to catch silent drift even
with no known trigger (see `AUTOMATION_OPPORTUNITIES.md` Tier 2).

**Failure modes this command exists to catch:** a fix applied to one scoring
implementation but not the others; a data fix applied but never committed; a
manuscript number silently going stale relative to a data update — all three have
already happened once in this project's history.
