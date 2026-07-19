---
description: Keep the repository's README.md (currently one line) synchronized with the project's current state, tools, and datasets
---

# /update-readme

## Purpose
`repo/README.md` currently contains a single line: the project title. For a
multi-year, multi-maintainer project, this is a reproducibility and onboarding gap.
This command brings it up to the standard expected of a public benchmark reference
repository.

## Inputs
- Implicit inputs: `results_summary.md`, `memory/PROJECT_MEMORY.md`,
  `memory/SUPPORTED_TOOLS.md`, `environment.yml`, `accession/`, `LICENSE`.

## Workflow
1. Invoke **reproducibility-manager** to confirm the current, accurate setup
   instructions (environment creation, data access, how to reproduce
   `results_summary.md`).
2. Pull the current tool list, dataset list, and headline accuracy summary from
   `memory/SUPPORTED_TOOLS.md` and `results_summary.md`.
3. Draft/update sections: Project summary, Supported tools, Datasets, Setup &
   reproduction instructions, Citation, License, Contact/maintainer.
4. Verify every setup instruction by checking it against what
   **reproducibility-manager** has actually validated — never document a step that
   hasn't been confirmed to work from a clean checkout.
5. Cross-link to the manuscript and to `results_summary.md`.

## Expected Outputs
- Updated `repo/README.md` covering: what this is, current tool/dataset counts,
  how to set up and reproduce results, citation info, license, contact.
- A note of any setup step that could not be verified, flagged rather than
  documented as if confirmed.
