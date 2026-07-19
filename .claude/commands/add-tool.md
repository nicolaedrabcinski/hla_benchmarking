---
description: Onboard a new HLA typing tool into the benchmark - environment, standardization script, validation, and a candidate report for human approval
argument-hint: <tool-name> <tool-repo-or-source>
---

# /add-tool

## Purpose
Take a candidate HLA typing tool from "exists on GitHub" to "validated, scored, and
ready for a human decision on official inclusion." This command never completes
inclusion on its own — see Forbidden Decisions in
`agents/tool-integration-engineer.md`.

## Inputs
- `$1`: tool name (used for file naming, e.g. `hla-nova`).
- `$2`: source repository URL or package reference.
- Implicit inputs: `scripts/environmental_files/` (naming/format convention),
  `results/standard/` (target schema), `checklists/add-tool-checklist.md`.

## Workflow
1. Invoke **tool-integration-engineer** to:
   - Build `scripts/environmental_files/<tool-name>.yml`.
   - Install and smoke-test the tool on 3-5 samples.
   - Inspect native output format against `results/standard/` conventions.
   - Draft `scripts/standardization_scripts/<tool-name>_standardize.*`.
2. Invoke **pipeline-integrity-auditor** to validate the standardized output against
   schema and spot-check the 3-5 samples by hand.
3. If validation passes, invoke a compute-budget estimate (Performance/HPC context)
   for a full 682-sample run across D1-D6, and report it — do not launch the full
   run without confirmation.
4. On confirmation, execute the full run; **dataset-curator** confirms all target
   accessions still resolve first.
5. Invoke **hla-benchmark-scientist** to score the new tool under the existing
   contract and determine locus coverage (does it support all 5 loci, or a subset
   like OptiType's Class I-only scope).
6. Produce a Tool Evaluation Report (`templates/tool-evaluation-report.md`) covering
   accuracy, no-call rate, novel-allele rate, and compute cost, benchmarked against
   the current 12 tools.
7. Run `checklists/add-tool-checklist.md` end to end and report status per item.
8. Stop. Present the full package to the human for the inclusion decision.

## Expected Outputs
- New env file and standardization script (checked in, pending human approval to
  merge into the "official" comparison).
- A validation report.
- A Tool Evaluation Report comparing the candidate to the existing 12 tools.
- A completed add-tool checklist.
- An explicit, unambiguous request for human sign-off on official inclusion.

## Notes
- Never add the tool to `results_summary.md`'s headline tables before human
  approval — a candidate evaluation lives in its own report until then.
