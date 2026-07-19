---
description: Full adversarial + technical review pass over the current manuscript draft, without editing it
argument-hint: [section-name]
---

# /review-paper

## Purpose
A read-only, pre-submission-quality review pass, distinct from `/update-paper`
(which edits). Use this before every internal milestone and always before
submission.

## Inputs
- `$1` (optional): restrict review to one section.
- Implicit inputs: the manuscript `.docx`, `results_summary.md`, `BACKLOG.md`.

## Workflow
1. Invoke **statistics-reviewer** to re-verify every statistic in scope against
   current `results_summary.md` — flag any manuscript number that has drifted from
   source.
2. Invoke **statistics-reviewer** specifically to check the ancestry-disparity
   claim's Dataset-1-only scope is stated everywhere it's cited, not just once.
3. Invoke **clinical-and-equity-reviewer** to check clinical/recommendation
   language and ancestry-equity framing against cited standards.
4. Invoke **devils-advocate** for a full adversarial pass.
5. Grep for known-unfinished markers (`** include`, `MORE FIGURES TO BE ADDED`,
   `TODO`, `TBD`, `[citation needed]`) and report every remaining instance.
6. Cross-check every open `BACKLOG.md` item against the section(s) in scope; report
   which are still blocking.
7. Compile a single Review Report: technical accuracy issues, scope/caveat issues,
   clinical issues, adversarial concerns, unfinished markers, and open backlog
   blockers — each with a severity (blocking / should-fix / nice-to-have).

## Expected Outputs
- A single structured Review Report, most severe first.
- No manuscript edits — this command only produces findings, ever.
