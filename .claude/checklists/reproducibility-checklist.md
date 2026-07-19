# Checklist: Reproducibility

Run via `/reproduce-results` and before every release.

## Principles

*(Merged in from the former `skills/reproducibility-checklist` skill — kept as one
file, one owner, to avoid the exact duplicate-implementation pattern this checklist
itself exists to catch.)*

- **Reproducibility is not a property you assert from reading code — it's a
  property you verify by attempting the reproduction with only what's checked in.**
  Every claim of "this is reproducible" below must be backed by a recent, actual
  attempt, not an inference from "the scripts are all there."
- **Common failure modes to check for on every pass:**
  - Hardcoded absolute paths that silently make a pipeline non-portable even
    though every script "looks complete."
  - Undocumented manual steps — a conversion performed once by hand and never
    scripted.
  - Unpinned or drifting dependencies — an environment file without exact
    versions will reproduce different results on a different day as upstream
    packages update.
  - Uncommitted load-bearing state — a fix or generated artifact that exists
    only in a working tree, never committed.
  - Silent manual data edits — any hand-edit to a CSV or notebook output that
    bypasses the documented pipeline breaks the provenance chain.
- **Provenance chains matter more than any single check.** Every reported number
  should have an unbroken, documented chain: raw data → processing step →
  processing step → final table/figure, with every step represented by a
  checked-in script or notebook cell — never a memory of "I think I ran X first."

## Clean-Checkout Test
- [ ] Attempted regeneration of `results_summary.md` using only checked-in
      artifacts and documented setup steps (not local/uncommitted state)
- [ ] Every step that failed or required an undocumented manual action is listed
      explicitly, not smoothed over

## Environment
- [ ] `environment.yml` (analysis environment) installs cleanly and is
      version-pinned
- [ ] Every tool in `memory/SUPPORTED_TOOLS.md` has a working, version-pinned
      `.yml` under `scripts/environmental_files/`
- [ ] No environment file present-but-broken (verified by actually installing,
      not just checking the file exists)

## Standardization Coverage
- [ ] Every tool in `memory/SUPPORTED_TOOLS.md` has a checked-in standardization
      script (as of the last audit, only 2 of 12 did — track progress against
      this specific gap)

## Path Portability
- [ ] No hardcoded absolute paths remain in `scripts/data_generation/` that would
      break on a different HPC environment (historical examples:
      `/scratch1/rayyala/...`, `/scratch1/dottieyu/...`)

## Provenance
- [ ] Every number in `results_summary.md` has an unbroken, documented chain back
      to raw standardized CSVs and gold-standard files — no hand-edited
      intermediate step

## Repo Hygiene
- [ ] No `.DS_Store`, `__pycache__`, or `.ipynb_checkpoints` tracked in git
- [ ] `git status` clean (no uncommitted load-bearing changes)
- [ ] `.bak` files reflect genuinely-superseded state, not silently-abandoned
      in-progress fixes

## Archival (pre-publication / release only)
- [ ] Code archival plan confirmed (e.g., Zenodo DOI tied to a release tag)
- [ ] Data deposition status confirmed (`memory/PUBLICATION_STATUS.md`)

## Sign-off
- [ ] reproducibility-manager confirms all above
- [ ] Any unresolved gap is logged in `memory/KNOWN_BUGS.md`, not silently
      dropped
