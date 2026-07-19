# Checklist: Adding a New Tool

Run in full via `/add-tool`; every box must be checked (or explicitly marked N/A
with a reason) before the candidate package is presented for human inclusion
decision.

## Environment
- [ ] Conda env file created at `scripts/environmental_files/<tool>.yml`
- [ ] Env installs cleanly from scratch (not just "worked once locally")
- [ ] All dependencies pinned to specific versions

## Integration
- [ ] Tool successfully run on ≥3 smoke-test samples
- [ ] Native output format documented (example file saved for reference)
- [ ] Standardization script written:
      `scripts/standardization_scripts/<tool>_standardize.*`
- [ ] Standardization script is idempotent and requires no manual steps
- [ ] Output schema matches convention exactly (`Sample/Run,A,A.1,B,B.1,C,C.1,
      DRB1,DRB1.1,DQB1,DQB1.1`)
- [ ] Loci the tool does not support are left absent/blank, not zero-filled

## Validation
- [ ] pipeline-integrity-auditor schema validation passed
- [ ] ≥3 samples hand-verified against native output
- [ ] Locus coverage determined empirically (not assumed from tool docs)

## Scale-Up
- [ ] Compute budget estimated before full-cohort run requested
- [ ] dataset-curator confirmed target accessions resolve
- [ ] Full run executed across the intended dataset scope (state which datasets)

## Scoring
- [ ] hla-benchmark-scientist scored the tool under the existing contract
- [ ] Cross-implementation check run if applicable
- [ ] statistics-reviewer independently re-derived headline numbers

## Reporting
- [ ] Tool Evaluation Report completed (`templates/tool-evaluation-report.md`)
- [ ] Comparison against current best/worst tool included
- [ ] Compute cost comparison included

## Human Decision Gate
- [ ] Full package (env, script, validation, evaluation report) presented
- [ ] Explicit request for inclusion decision made — not assumed
- [ ] If approved: `memory/SUPPORTED_TOOLS.md` updated
- [ ] If declined: candidate archived with reason logged
