---
description: Package a versioned benchmark release (code, environments, results, changelog) and produce a human-approval checklist before anything is pushed or published
argument-hint: <version-tag>
---

# /prepare-release

## Purpose
Turn the current, validated state of the repository into a citable, versioned
release — without performing any of the actual public/irreversible actions
(git push, SRA/Zenodo deposition), which always require explicit human execution.

## Inputs
- `$1`: proposed version tag (e.g., `v1.3-hla-nova`).
- Implicit inputs: full repo state, `checklists/release-checklist.md`,
  `checklists/reproducibility-checklist.md`.

## Workflow
1. Invoke **reproducibility-manager** to run the full reproducibility checklist:
   clean-checkout regeneration test, environment file validation, no uncommitted
   load-bearing changes, `.gitignore` hygiene.
2. Invoke **pipeline-integrity-auditor** for a final cross-implementation
   validation pass (Python vs. Julia scoring agreement).
3. Confirm `results_summary.md`, all figures, and the manuscript are mutually
   consistent (no `/update-results` propagation report left unresolved).
4. Draft a changelog: what's new/changed since the last tagged version (tools,
   datasets, scoring-logic fixes, figure updates).
5. Run `checklists/release-checklist.md` end to end and report status per item.
6. Produce a release package summary for human review: changelog, checklist
   results, and an explicit list of anything not yet ready.
7. Stop. Do not tag, push, or publish anything — present the package and wait for
   explicit human approval and execution.

## Expected Outputs
- A complete, human-readable release package summary.
- A fully-checked reproducibility and release checklist.
- A drafted (not published) changelog.
- An explicit, itemized request for human approval before any public action.
