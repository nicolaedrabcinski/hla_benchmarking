# Publication Status

*Last updated: 2026-07-19*

## Current Draft

- **File:** `HLA stage 2 manuscript (CURRENT 2024).docx`
- **Title:** "A rigorous benchmarking of alignment-based HLA typing algorithms for
  RNA-seq data"
- **Stage:** Stage 2 draft, under internal co-author review (Google Doc comments).
- **Open review threads:** 50, tracked in `BACKLOG.md` (categories A-D).
- **Known unfinished content:** Methods section contains a literal placeholder
  (`** include information on what metrics we evaluated on`); Figures section
  contains `MORE FIGURES TO BE ADDED…`.
- **Target venue:** Not confirmed in repository materials — treat as an open
  question for the human PI (see `agents/*.md` pattern of escalating
  venue/deadline questions).
- **Target date:** Per prior project-memory context, "end of summer 2026" —
  unverified against any document in this repository; confirm with human before
  treating as fixed.

## Headline Claims (as drafted, subject to ongoing revision)

1. First RNA-seq-specific HLA-caller benchmark since a single 2016 study.
2. 8 of 12 evaluated tools had never been previously benchmarked.
3. arcasHLA recommended as best accuracy/coverage balance (93.4% Class I+II,
   per the draft's numbers — reconcile against current `results_summary.md`
   before citing).
4. RNA2HLA recommended for computational efficiency.
5. **All tools are more accurate on European-ancestry than African-ancestry
   samples** — the paper's most novel finding, currently evidenced only on
   Dataset 1 (see `memory/KNOWN_BUGS.md`, `agents/statistics-reviewer.md`).

Claims 3-5 all require **human sign-off** before being treated as final per the
corresponding agents' Forbidden Decisions — this file records what's currently
drafted, not what's approved.

## Pre-Submission Gate

Before this manuscript is considered submission-ready, `/review-paper` must return
no blocking findings, and every `BACKLOG.md` category-A/B item must be resolved or
explicitly deferred with a logged reason (category-C items always require a human
decision, category-D is administrative).

## Data/Code Availability (planned, not yet complete)

- Code: this repository, `Mangul-Lab-USC/HLA_benchmark` (public).
- In-house RNA-seq and WGS/PacBio data: not yet deposited to SRA
  (`BACKLOG.md` item D3) — coordination with Taras and Khrystyna required for
  metadata.
- No archival DOI (e.g., Zenodo) recorded yet.

## Post-Publication Plan

Not yet defined in repository materials. See `workflows/release-cycle.md` and
`agents/reproducibility-manager.md` for the mechanism this operating system
assumes will be used once a plan exists (versioned releases, community tool
submissions).
