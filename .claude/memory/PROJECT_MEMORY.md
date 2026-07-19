# Project Memory

Persistent facts every agent (and every new human maintainer) should know without
re-deriving them. Update this file whenever a fact below goes stale — it is meant
to be maintained continuously, not written once.

*Last updated: 2026-07-19*

## What This Project Is

"A rigorous benchmarking of alignment-based HLA typing algorithms for RNA-seq
data" — a benchmark of 12 HLA typing tools across 682 RNA-seq samples / 8 datasets
with molecularly-defined gold standards at 5 classical loci (A, B, C, DRB1, DQB1).
Mangul Lab, USC. GitHub: `Mangul-Lab-USC/HLA_benchmark`.

## Ownership History

- **2023**: Dottie Yu (`ydottie`) — initial repo, accession lists, gold standards,
  early per-figure notebooks (`notebooks/dottie_scripts/`).
- **2024-2025**: Ram Ayyala (`ramayyala`) — core scoring engine, standardization,
  most figures, manuscript drafting.
- **2025-10-31 (most recent commit as of last audit)**: "novel calls" scoring
  adjustment (Figure 14).
- **Handover (see `conversation.md`)**: Ram → Nick. Nick's background is software
  engineering, not biology; his role is code/notebook cleanup and bringing the
  analysis to a polished, reproducible state. Ram covers biology and paper writing.
  Weekly sync established (Friday).

## Current Authoritative Source of Truth

- **Scoring/results**: `notebooks/accuracy_fixed_executed.ipynb` →
  `results_summary.md` (generated 2026-07-17, includes the HLA-VBSeq column-swap
  fix from 2026-07-15).
- **Open work items**: `BACKLOG.md` (50 threads from Google Doc review comments,
  read 2026-07-15).
- **Manuscript**: `HLA stage 2 manuscript (CURRENT 2024).docx` — a draft, not yet
  synchronized with the current pipeline's post-fix numbers.

## Key People (from manuscript author list / handover)

- Ram Ayyala — USC, co-first author, prior maintainer.
- Dottie Yu — USC, co-first author, original repo builder.
- Serghei (Mangul) — PI.
- Nick — current repo/code owner.
- Additional co-authors: Walter W. Wolfsberger, Khrystyna Shchubelka, Kenneth
  Hilkert, Sara Sadek, Likhitha Chittampalli, Junghyun Jung (Oakland University,
  CSU Fullerton, USC affiliations — see manuscript for full list).

## Standing Priorities (as of last audit)

1. Metric slide / current-numbers pass (BACKLOG category A).
2. Data transfer coordination with Ram (raw data on hard drive → Nick's HPC).
3. Manuscript submission — see `memory/PUBLICATION_STATUS.md` for the current
   target date and confirmation status. (Deliberately not restated here — this
   fact previously lived in both files independently, which is the exact
   single-source-of-truth violation this operating system exists to prevent
   elsewhere. `PUBLICATION_STATUS.md` is the owner; this file points to it.)

## Vision

The manuscript and project aim to become the reference RNA-seq HLA-typing
benchmark — a living resource other labs cite and, ideally, submit new tools to.
See `workflows/add-new-tool.md` for the intended long-term mechanism.
