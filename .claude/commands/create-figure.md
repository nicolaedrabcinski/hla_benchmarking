---
description: Generate or regenerate a manuscript figure from current, approved data, following the project's established palette and style conventions
argument-hint: <figure-name-or-number>
---

# /create-figure

## Purpose
Produce a new figure or regenerate an existing one, always from current pipeline
output and always following the shared visual conventions defined in
`notebooks/accuracy_fixed_executed.ipynb` cells 9-11 (the `palette` dict and
seaborn/matplotlib theme).

## Inputs
- `$1`: figure name or number (e.g., "Figure 14", "novel-allele-tradeoff").
- Implicit inputs: `results_summary.md` or the specific upstream table/cell it
  depends on.

## Workflow
1. Invoke **figure-designer**.
2. Confirm the upstream data source carries current sign-off from
   **hla-benchmark-scientist** and **statistics-reviewer** — refuse to render
   against unapproved or stale data.
3. Reuse the shared `palette` dict and theme settings; do not fork a local palette
   copy.
4. Render at manuscript-final specifications (300 DPI, consistent font scale).
5. Check color-blind accessibility and legibility at print size.
6. Save to the canonical figure output location (per
   `agents/figure-designer.md`'s consolidation responsibility) with a clear,
   numbered filename.
7. Draft a caption and hand it to **scientific-writer**.

## Expected Outputs
- A rendered figure file in the canonical output location.
- A caption draft.
- A note of the exact upstream data/cell it was generated from (for future
  regeneration and for the reproducibility record).
