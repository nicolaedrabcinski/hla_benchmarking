# Workflow: Manuscript Revision / Reviewer-Response Cycle

The cycle for working through `BACKLOG.md`'s open threads or a real journal
reviewer-response round.

```
New comment thread(s) arrive (Google Doc / journal reviewer report)
        │
        ▼
Triage into categories A/B/C/D  ───────  scientific-writer (+ human for C/D)
        │
   ┌────┼─────────────┬──────────────┐
   A: solvable      B: needs        C: needs PI/co-author   D: admin/
   from repo data/  literature      decision                communication
   code             check
   │                │                │                       │
   ▼                ▼                ▼                       ▼
/update-paper   Human/literature-  Escalate to human,     Human handles
or /update-     watch resolves,    do not resolve          directly (not
results         then A-path        autonomously            agent-owned)
   │
   ▼
scientific-writer drafts change, sourcing every number from
results_summary.md / statistics-reviewer sign-off
        │
        ▼
Domain review as applicable:
  statistics-reviewer (ancestry statistical scope/power)
  clinical-and-equity-reviewer (clinical claims + ancestry framing)
        │
        ▼
devils-advocate adversarial pass
        │
        ▼
BACKLOG.md updated: item marked resolved (with resolution note) or
left open with status update
        │
        ▼
Batch of resolved items reaches a threshold → /review-paper full pass
        │
        ▼
Human review and approval
```

## Mapping to This Repository's Actual Backlog

- **Category A** (`BACKLOG.md`): tool-count discrepancy, nomenclature
  standardization, citation placement, pulling current numbers, novelty-analysis
  supplementary figures, figure renumbering, gene-coverage figure redraw,
  supplementary table build, ancestry/computational-resources phrasing, STAR
  options verification, citation systematization — all routed through
  `/update-paper`.
- **Category B**: comparator-paper claims, comparator accuracy metrics, co-author
  affiliation updates — require a literature check a human or literature-watch
  capability performs; `scientific-writer` integrates the result once available.
- **Category C**: optimized-parameter results decision, ambiguous "please check"
  comments, "let's discuss on the call" items, African-population-diversity
  hypothesis inclusion, figure placement decisions — always escalated, never
  resolved by an agent.
- **Category D**: author/affiliation additions, co-author emails, SRA upload
  coordination — administrative, human-executed.

## Exit Criteria

A revision cycle is complete when: every category-A item is resolved or has an
explicit reason it's blocked, every category-B item has a literature answer
attached, every category-C item has a logged human decision, and `/review-paper`
returns no blocking findings.
