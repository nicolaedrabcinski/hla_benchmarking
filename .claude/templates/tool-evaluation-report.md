# Tool Evaluation Report Template

Produced by `/add-tool` for every new tool candidate, before any human decision on
official inclusion.

---

**Tool:** `<name>` `<version>`
**Evaluated by:** tool-integration-engineer / hla-benchmark-scientist
**Date:**

## Integration Status
- [ ] Conda environment builds cleanly (`scripts/environmental_files/<tool>.yml`)
- [ ] Standardization script written and validated
      (`scripts/standardization_scripts/<tool>_standardize.*`)
- [ ] Schema-validated by pipeline-integrity-auditor
- [ ] Smoke-tested on 3-5 samples, hand-verified against native output

## Locus Coverage
| Locus | Supported? | Notes |
|---|---|---|
| A | | |
| B | | |
| C | | |
| DRB1 | | |
| DQB1 | | |

## Accuracy (full-cohort run, D1-D6)

| Metric | This tool | Current best (`results_summary.md`) | Current worst |
|---|---|---|---|
| 1-field overall | | | |
| 2-field overall, unfiltered | | | |
| 2-field overall, filtered | | | |
| No-call rate | | | |
| Novel-allele rate | | | |

## Per-Locus Accuracy (2-field, filtered)
| Locus | This tool | Cohort median (existing 12 tools) |
|---|---|---|

## Compute Cost
| Metric | This tool | Cohort median |
|---|---|---|
| CPU time (median, s) | | |
| RAM (median, GB) | | |

## Statistical Sign-off
- [ ] statistics-reviewer independently re-derived headline numbers
- [ ] pipeline-integrity-auditor cross-implementation check (if applicable)

## Recommendation for Human Decision

State plainly: does this tool outperform, match, or underperform the current
recommended tool(s)? Does it fill a coverage gap (e.g., a currently-underserved
locus)? This is a factual summary for the human decision — not itself a decision.

## Open Issues / Caveats
