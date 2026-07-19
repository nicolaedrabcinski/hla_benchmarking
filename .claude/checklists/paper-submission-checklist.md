# Checklist: Paper Submission Readiness

Run via `/review-paper` before any real submission (or major internal milestone).
Every item blocking unless explicitly waived by a human with a logged reason.

## Data Integrity
- [ ] Every number in the manuscript traces to a current `results_summary.md`
      table/cell (no stale statistics — check specifically for the
      known-historical 682-vs-652 sample count class of error)
- [ ] No literal placeholder text remains (`** include`, `MORE FIGURES TO BE
      ADDED`, `TODO`, `TBD`, `[citation needed]`) — grep confirmed clean
- [ ] `results_summary.md` regenerated within the current revision cycle (not
      carried over from an earlier, potentially stale, run)

## Statistical Rigor
- [ ] Every statistic independently re-derived by statistics-reviewer
- [ ] Every test's sample size/scope explicitly stated where the result is cited
- [ ] Multiple-comparisons exposure addressed or explicitly justified
      (particularly the per-tool ancestry z-tests)
- [ ] Ancestry finding's Dataset-1-only scope is stated everywhere the finding
      is cited, not only in Methods

## Claims Discipline
- [ ] Every ranking/recommendation claim has explicit human sign-off logged
- [ ] Ancestry-disparity claim wording has explicit human sign-off logged
- [ ] Clinical claims cross-checked by clinical-and-equity-reviewer against
      cited matching standards (8/8, 10/10)
- [ ] Novelty claims ("first since 2016," "8 of 12 tools new") re-verified
      against current literature, not just first-draft-time literature

## Adversarial Review
- [ ] devils-advocate full pass complete, all major concerns addressed or
      explicitly accepted as a stated limitation
- [ ] Every acknowledged limitation states its consequence for interpretation,
      not just its existence

## Formatting
- [ ] Citation numbering/style consistent throughout; all placeholder citations
      resolved to real PubMed IDs
- [ ] Figure numbering internally consistent; every in-text figure reference
      resolves to an actual figure file
- [ ] All co-author affiliations current and confirmed by each co-author
- [ ] Data Availability and Code Availability sections point to real, resolvable
      locations (or explicitly state "pending deposition" with a tracked item)

## Backlog Closure
- [ ] Every `BACKLOG.md` category-A item resolved or explicitly deferred with
      reason
- [ ] Every category-B item has a literature answer attached
- [ ] Every category-C item has a logged human decision
- [ ] Every category-D item confirmed complete by a human

## Final Gate
- [ ] Target venue and formatting requirements confirmed
- [ ] Explicit human sign-off recorded before submission action is taken
