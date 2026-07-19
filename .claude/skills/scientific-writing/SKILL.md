---
name: scientific-writing
description: Genomics-manuscript writing conventions - structure, claim scoping, avoiding unsupported generalization, keeping prose synchronized with data. Generic, reusable for any computational biology manuscript. Use whenever drafting or editing manuscript text.
---

# Scientific Writing for Computational Biology Manuscripts

Generic writing discipline, illustrated with this project's own manuscript
(`HLA stage 2 manuscript (CURRENT 2024).docx`) as a live example of both good and
missing practice.

## Numbers Must Trace to a Source

Every number in a manuscript should be traceable to a specific table, figure, or
data file — not retyped from memory or a prior draft. This project's manuscript
currently has a live counterexample: the Abstract states 682 samples, the
Introduction states 652, an internal inconsistency that predates any pipeline
update. When editing a section, always re-derive its numbers from the current
canonical source rather than copy-editing around an old number.

## Claim Scope Must Match Evidence Scope

- State the denominator/scope of every quantitative claim: which datasets,
  how many samples, what resolution. "Callers are less accurate for African-ancestry
  samples" needs the qualifier "(measured on Dataset 1, N=X European / N=Y Yoruba
  samples)" directly attached, not buried in the Methods section only.
- Do not let a finding computed on a subset silently read as a whole-cohort claim
  in the Discussion or Abstract, even if the Methods section technically discloses
  the scope elsewhere. Readers of an abstract rarely read the full Methods.

## Distinguish Description from Recommendation

- "Tool X achieved 95.3% accuracy" is a description, fully supported by data.
- "We recommend Tool X" is a judgment call weighing accuracy against coverage,
  compute cost, and use case — flag these sentences distinctly, since they carry
  different evidentiary requirements and (in this project's operating model)
  different sign-off requirements. See `agents/scientific-writer.md`'s Forbidden
  Decisions.

## Never Leave Placeholders in a Circulating Draft

Literal placeholder text (`** include information on what metrics we evaluated on`,
`MORE FIGURES TO BE ADDED…`) should never persist in a draft under active review —
either fill it immediately or convert it into an explicitly tracked open item (this
project uses `BACKLOG.md` for exactly this).

## Citation Discipline

- Every claim of novelty ("first benchmark since 2016," "8 of 12 tools never
  previously evaluated") needs a citation and needs re-verification close to
  submission time — literature moves, and a claim true at first-draft time can
  become false by submission.
- Standardize terminology once, early, and apply it everywhere (this project has an
  open item to choose between "1-field/2-field" and "2-digit/4-digit" — pick one
  per the current decision in `BACKLOG.md` and never mix them in new text).

## Limitations Section Discipline

A good limitations paragraph doesn't just list caveats — it states, for each one,
what a reader should and shouldn't conclude given the caveat. Compare:
- Weak: "The ancestry analysis is limited to one dataset."
- Strong: "The ancestry analysis is limited to Dataset 1 (N=X/Y per group); we
  therefore report this as a directional finding warranting confirmation on
  additional cohorts, not as a fully generalized claim across all ancestries this
  benchmark's tools might encounter."
