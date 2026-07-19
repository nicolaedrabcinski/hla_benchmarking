# Checklist: Benchmark Release

Run via `/prepare-release`. This checklist gates the release *package*; the
irreversible actions themselves (tag, push, deposit) are always human-executed —
see `hooks/pre-git-action-check.sh` (the `git tag`/`git push` branch) for the
mechanical enforcement of this.

## Consistency
- [ ] `results_summary.md` regenerated in this cycle (not stale)
- [ ] Every figure regenerated from current data
- [ ] Manuscript (if this release corresponds to a manuscript milestone) matches
      current `results_summary.md` numbers
- [ ] No open `/update-results` propagation report left unresolved

## Reproducibility
- [ ] `checklists/reproducibility-checklist.md` passed in full
- [ ] `/reproduce-results` run this cycle with a passing (or explicitly
      documented partial) result

## Integrity
- [ ] pipeline-integrity-auditor final cross-implementation validation pass
      (Python vs. Julia scoring) completed with no unexplained discrepancies
- [ ] `git status` clean under `results/`, `notebooks/`, `datasets/`
      (no uncommitted load-bearing changes — this project has had this exact
      failure before)

## Documentation
- [ ] Changelog drafted: what's new/changed since the last tagged version
- [ ] `memory/SUPPORTED_TOOLS.md` current
- [ ] `memory/KNOWN_BUGS.md` current (nothing marked "fixed" that isn't actually
      in the release)
- [ ] `memory/PUBLICATION_STATUS.md` current

## Figure Hygiene
- [ ] Duplicate figure directories (`figures/`, `Figures/`, `pptx_images/`,
      `pptx_preview/`) have a documented canonical mapping, or have been
      consolidated

## Human Gate
- [ ] Full release package (changelog + all checklist results) presented
- [ ] Explicit human approval recorded before any `git tag`/`git push`
- [ ] (Post-publication only) explicit human approval recorded before any SRA/
      Zenodo deposition
