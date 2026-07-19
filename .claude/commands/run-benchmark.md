---
description: Run (or re-run) the full accuracy benchmark across all tools and datasets and regenerate results_summary.md
argument-hint: [tool-subset] [dataset-subset]
---

# /run-benchmark

## Purpose
Recompute accuracy, no-call, and novel-allele metrics from current
`results/standard/*.csv` and `datasets/*_gs.csv`, and regenerate
`results_summary.md`. This is the command to run after any standardized-output
change, gold-standard correction, or scoring-logic fix.

## Inputs
- `$1` (optional): comma-separated tool subset (e.g., `T1K,arcas,hisat`). Default:
  all 12 tools currently tracked in `notebooks/accuracy_fixed_executed.ipynb`.
- `$2` (optional): comma-separated dataset numbers (e.g., `1,2,3`). Default:
  datasets 1-6 (the main-analysis set; D7/D8 are handled by their own workflows).
- Implicit inputs: `results/standard/*.csv`, `datasets/*_gs.csv`.

## Workflow
1. Invoke **pipeline-integrity-auditor** to schema-validate every standardized CSV
   in scope before scoring anything.
2. If validation fails for any file, stop and report — do not score against known-bad
   input.
3. Invoke **hla-benchmark-scientist** to run the canonical scoring engine
   (1-field and 2-field, filtered and unfiltered) over the requested tool/dataset
   scope, using `notebooks/accuracy_fixed_executed.ipynb`'s current logic.
4. Cross-check the result against the Julia implementation
   (`notebooks/accuracy_julia_executed.ipynb`) for the same scope; report any
   delta > 0.1pp to **pipeline-integrity-auditor**.
5. Invoke **statistics-reviewer** to independently re-derive the headline numbers
   before they're written anywhere durable.
6. Regenerate `results_summary.md` (Tables 1-6) with a timestamp and a note of what
   changed since the last version.
7. Report a diff summary: which numbers changed, by how much, and why.

## Expected Outputs
- Updated `results_summary.md`.
- A validation report from pipeline-integrity-auditor (pass/fail per file).
- A statistics-reviewer sign-off memo.
- A plain-language diff summary of what changed vs. the previous run.

## Notes
- This command never touches the manuscript — see `/update-paper` for that.
- This command never regenerates figures — see `/create-figure` for that.
- If no upstream data changed, this command should produce byte-identical output;
  a difference with no upstream change is itself a bug to report.
