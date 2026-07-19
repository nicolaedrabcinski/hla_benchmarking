# HLA Stage 2 Manuscript — Open Task Backlog

Source: Google Doc comments (read 2026-07-15), 50 open threads  
Last updated: 2026-07-16

*Scope note: this file tracks manuscript reviewer/co-author comment threads only.
Technical/data defects in the pipeline itself (code, scoring output, data-file
bugs) are tracked in `.claude/memory/KNOWN_BUGS.md` instead — see that file if a
comment thread below turns out to be a genuine pipeline bug rather than a text/
phrasing issue.*

---

## A — Solvable by Claude Code (data / code / text access)

- [ ] **Tool count discrepancy** — resolve 11 vs. 12 tools in text/table (`accuracy.ipynb` had 11, `accuracy_fixed.ipynb` has 12 incl. rna2hla)
- [ ] **Nomenclature standardization** — global find+replace: 1-field = 2-digit, 2-field = 4-digit; eliminate "1.2 digits" phrasing
- [ ] **IPD-IMGT/HLA naming** — standardize across manuscript + insert citation (Nucleic Acids Research, D1152) at first mention
- [ ] **Pull current numbers from pipeline** — rerun `accuracy_fixed.ipynb` after HLA-VBSeq column-swap fix; update all stale statistics in manuscript
- [ ] **Split allele novelty analysis per dataset** — generate supplementary figures (dataset-specific vs. universal novel alleles)
- [ ] **Regenerate % figure as absolute counts** — likely Fig 15; confirm figure numbering first
- [ ] **Identify "each sample" figure** — confirm if it's the raw data behind Fig 6; explain x-axis in caption
- [ ] **Redraw gene-coverage figure** — show only the 5 HLA genes stated in abstract (A, B, C, DRB1, DQB1)
- [ ] **Build supplementary table** — per Ram/Serghei request; confirm exact contents needed
- [ ] **Rewrite ancestry phrasing** — "precision of their inter-population differences" / ancestry-groups sentence
- [ ] **Rewrite "computational resources required" phrasing**
- [ ] **Verify STAR options** — cross-check Dottie's comment against pipeline config files
- [ ] **Systematize citations** — pull PubMed IDs, format consistently (placeholder scheme until final pass)

---

## B — Needs literature check / external lookup

- [ ] **Verify "limited gold standard" claim** — confirm comparator papers used limited GS and not long reads
- [ ] **Check comparator paper accuracy metric** — what metric do they use vs. ours
- [ ] **Update co-author affiliation** — per their recent Nature Methods paper

---

## C — Needs Serghei / Ram decision (not Claude Code solvable)

- [ ] **Optimized-parameter results** — confirm with Ram whether runs exist; if not, delete related text and revise Abstract claim
- [ ] **Ambiguous "please check if this is true" comment** — locate in manuscript, flag for call
- [ ] **"Let's discuss on the call" comments** — tied to specific figures; list figure numbers before next call
- [ ] **African-population-diversity hypothesis** — Dottie's suggestion; decide whether to include
- [ ] **Figure placement decisions** — main vs. supplementary (multiple instances)

---

## D — Admin / communication

- [ ] **Add names + affiliations** — Nick and Munteanu to relevant section
- [ ] **Email co-authors** — confirm affiliations + funding info before next draft distribution
- [ ] **Upload RNA-Seq and WGS PacBio data to SRA** — coordinate with Taras and Khrystyna for metadata

---

## Resolved

- [x] **Novel-allele definition** — cohort-based (not IMGT-DB-based); confirmed via Ram's inline explanation of `gs_set` vs `valid_set` logic
- [x] **HLA-VBSeq column-swap bug** — DRB1/DQB1 columns were swapped in `hlavbseq_d1.csv`; fixed 2026-07-15, backup saved as `.bak`
- [x] **CLASS_I_ONLY_TOOLS bug** — `accuracy.ipynb` incorrectly listed `hlavbseq` as Class I-only; fixed in Cell 23
- [x] **Over-calling investigation** — only HISAT-genotype returns >2 alleles/locus; it has a score (abundance %); no tool without a score over-calls; Methods sentence drafted
