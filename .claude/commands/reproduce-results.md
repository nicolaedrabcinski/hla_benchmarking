---
description: Attempt a from-scratch reproduction of results_summary.md using only what's checked into the repository, and report exactly where it breaks
---

# /reproduce-results

## Purpose
The direct test of this project's reproducibility claim. This command does not
assume the pipeline works from a clean checkout — it verifies it, the way an
external reader trying to reproduce the paper actually would.

## Inputs
- Implicit inputs: the full repository as checked in (no reliance on
  uncommitted/local state), `environment.yml`, `scripts/environmental_files/`.

## Workflow
1. Invoke **reproducibility-manager**.
2. Starting from a conceptually clean checkout (verify via `git status` that
   nothing relied upon is uncommitted), follow only the documented setup steps in
   `README.md`.
3. Attempt to regenerate, in order: standardized CSVs (if scripts exist for the
   tool in question) → `results_summary.md` → figures.
4. At each step, record: did it work using only checked-in artifacts and
   documented commands? If not, exactly what was missing (a hardcoded path, an
   undocumented manual step, a missing standardization script, an unpinned
   dependency).
5. Cross-check final `results_summary.md` output against the currently-committed
   version — flag any unexplained numeric drift.
6. Produce a Reproducibility Report: pass/fail per pipeline stage, with specific,
   fixable gaps listed (routed to the owning agent — **tool-integration-engineer**
   for missing standardization scripts, **reproducibility-manager** for env/path
   issues).

## Expected Outputs
- A Reproducibility Report with a stage-by-stage pass/fail and specific,
  actionable gaps.
- No silent "assume it works" — every claim of reproducibility must be backed by
  this command having actually been run since the last change to the pipeline.
