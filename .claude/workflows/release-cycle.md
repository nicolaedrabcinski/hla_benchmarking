# Workflow: Benchmark Release Cycle

Turning validated repository state into a versioned, citable release — code,
environments, results, and (post-publication) data.

```
Release trigger (new tool merged, manuscript milestone, scheduled cadence)
        │
        ▼
Full benchmark re-run  ─────────────────  commands/update-results.md
        │
        ▼
Reproducibility test (clean-checkout regen) ─  reproducibility-manager
        │
        ▼
Cross-implementation final validation ──  pipeline-integrity-auditor
        │
        ▼
Consistency check: results_summary.md ↔ figures ↔ manuscript
        │
        ▼
Changelog drafted
        │
        ▼
Release checklist run in full  ─────────  checklists/release-checklist.md
        │
        ▼
Release package summary produced for human review
        │
        ▼
Human approval
        │
        ▼
Human executes: git tag, git push, (post-publication) SRA/Zenodo deposition
        │
        ▼
memory/PUBLICATION_STATUS.md and memory/SUPPORTED_TOOLS.md updated
```

## Non-Negotiable Gates

- **No agent ever executes `git push` to the public remote, tags a release, or
  deposits data publicly.** `/prepare-release` produces the package; a human
  executes the irreversible step.
- The reproducibility test in step 2 must be a real attempt (per
  `commands/reproduce-results.md`), not an assertion.
- The release package summary must explicitly list anything not ready, not just
  what is ready — silence is not a pass.

## Post-Release

- Update `memory/PROJECT_MEMORY.md` with the new version/state.
- Confirm `memory/KNOWN_BUGS.md` reflects current status (nothing marked "fixed"
  that isn't actually in the released version).
- If this release corresponds to a manuscript milestone, hand off to
  `workflows/manuscript-update-cycle.md`.
