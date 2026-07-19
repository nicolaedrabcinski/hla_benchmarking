# Experiment Report Template

Copy this for any discrete pipeline run (a new tool run, a read-length sweep, a
parameter-optimization sweep, etc.).

---

**Experiment ID:** `<short-slug>` (e.g., `hla-nova-full-cohort-2026-08`)
**Date:** `<YYYY-MM-DD>`
**Run by (agent/human):**
**Owning agent:** (e.g., hla-benchmark-scientist, tool-integration-engineer)

## Objective
What question does this run answer? What decision does it feed?

## Scope
- Tool(s):
- Dataset(s):
- Resolution(s) tested: 1-field / 2-field
- Filtered / unfiltered / both:

## Method
- Pipeline stage(s) invoked (link to relevant command, e.g. `/run-benchmark`):
- Any deviation from the standard pipeline (and why):
- Compute resources used (CPU-hours, RAM, wall-clock):

## Inputs
- Exact input file(s)/commit hash used:
- Environment/version pins used:

## Results
| Metric | Value | Source file/cell |
|---|---|---|
| | | |

## Validation
- [ ] Schema-validated by pipeline-integrity-auditor
- [ ] Cross-implementation checked (Python vs. Julia, if applicable)
- [ ] Independently re-derived by statistics-reviewer

## Interpretation
What does this result mean? What does it NOT show (scope limits)?

## Follow-up
- [ ] Does this change any headline number in `results_summary.md`? If yes, run
      `/update-results`.
- [ ] Does this require a manuscript update? If yes, run `/update-paper`.
- [ ] Does this belong in `memory/KNOWN_BUGS.md` or `memory/PROJECT_MEMORY.md`?

---

## Pre/Post-Run Checklist

*(Merged in from the former `checklists/run-experiment-checklist.md` — its items
were the same information this template already asks for above, just phrased as
checkboxes. One artifact now covers both planning and gating.)*

**Before running:**
- [ ] Objective and the decision it feeds are stated (see Objective section above)
- [ ] Scope (tools, datasets, resolution) explicitly defined, not left implicit
- [ ] Compute budget estimated for anything beyond a small smoke test
- [ ] Confirmed this doesn't duplicate an existing result already in `results/` —
      check `results/optimization/`, `results/read_length/`, `results/unmapped/`,
      `results/zymo/` first

**During:**
- [ ] Exact commit/data-state used is recorded
- [ ] Any deviation from the standard pipeline is logged with a reason

**After running:**
- [ ] Output saved to the correct `results/` subdirectory, following existing
      naming conventions
- [ ] pipeline-integrity-auditor schema-checked the new output
- [ ] Results interpreted with explicit scope statement (what this does and does
      not show)
