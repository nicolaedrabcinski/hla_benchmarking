# HLA Benchmarking — Results Summary

*Source: `accuracy_fixed_executed.ipynb` — 12 tools, datasets 1–6*  
*HLA-VBSeq column-swap fix applied 2026-07-15 (DRB1/DQB1 labels swapped in `hlavbseq_d1.csv`)*  
*HLApers DRB1/DQB1 column-swap fix applied 2026-07-22 (`results/standard/hlapers_d1..d6.csv`)*  
*":xx" gold-standard-suffix scoring fix applied 2026-07-25 (`B*55:xx`/`A*68:xx` excluded from 2-field scoring; verified zero effect on these particular tables — see notes)*  
*Regenerated 2026-07-25 using exact scoring logic from `accuracy_fixed_executed.ipynb` Cell 7 -- supersedes the 2026-07-17 version, which predated both the HLApers and ":xx" fixes above*

---

## Scoring definitions

| Term | Definition |
|------|-----------|
| **novel** | Predicted allele not present in the gold-standard cohort (absent from per-dataset valid set) |
| **miscalled** | Predicted allele is in the valid set but does not match the sample's true allele |
| **no-call** | Tool did not report an allele for this slot |
| **unfiltered** | Novel alleles counted as miscalled; denominator = all call slots |
| **filtered** | Novel alleles excluded from denominator; measures accuracy on cohort-known alleles only |
| **1-field** | Resolution to first field only (e.g. A\*01) |
| **2-field** | Resolution to second field (e.g. A\*01:01) |

---

## Table 1: Overall Accuracy — 1-field

| Tool | Class I | Class II | Overall |
|------|---------|----------|---------|
| T1K | 99.4% | 99.6% | 99.5% |
| arcas | 99.4% | 98.6% | 99.1% |
| hisat | 99.4% | 98.5% | 99.0% |
| hlahd | 98.6% | 98.8% | 98.7% |
| rna2hla | 99.0% | 97.1% | 98.2% |
| seq2hla | 99.0% | 95.1% | 97.4% |
| hlaforest | 98.5% | 99.6% | 98.9% |
| phlat | 97.9% | 85.3% | 92.9% |
| hlavbseq | 98.3% | 95.0% | 97.0% |
| hlapers | 84.1% | 99.5% | 90.2% |
| optitype | 99.5% | 0.0% | 59.8% |
| hlaminer | 20.4% | 32.5% | 25.3% |

*(Difference between unfiltered and filtered is negligible at 1-field — novel alleles are rare at this resolution)*


---

## Table 2: Overall Accuracy — 2-field, Unfiltered (primary metric)

*Novel alleles penalised as miscalled. This is the primary comparison metric.*

| Tool | Class I | Class II | Overall |
|------|---------|----------|---------|
| T1K | 95.6% | 95.0% | 95.3% |
| arcas | 92.2% | 92.5% | 92.3% |
| hisat | 94.6% | 93.2% | 94.1% |
| hlahd | 92.6% | 94.7% | 93.4% |
| rna2hla | 96.1% | 87.4% | 92.7% |
| seq2hla | 94.1% | 83.4% | 89.8% |
| hlaforest | 82.6% | 89.7% | 85.5% |
| phlat | 88.6% | 76.4% | 83.8% |
| hlavbseq | 89.8% | 85.5% | 88.1% |
| hlapers | 69.3% | 92.7% | 78.6% |
| optitype | 98.2% | 0.0% | 59.1% |
| hlaminer | 6.3% | 10.4% | 7.9% |

---

## Table 3: Overall Accuracy — 2-field, Filtered

*Novel alleles excluded from denominator. Measures accuracy on cohort-known alleles only.*

| Tool | Class I | Class II | Overall |
|------|---------|----------|---------|
| T1K | 98.6% | 95.7% | 97.4% |
| arcas | 98.4% | 94.7% | 96.9% |
| hisat | 98.4% | 94.9% | 97.0% |
| hlahd | 98.2% | 95.5% | 97.1% |
| rna2hla | 98.2% | 94.7% | 96.8% |
| seq2hla | 98.3% | 94.3% | 96.8% |
| hlaforest | 92.5% | 93.5% | 92.9% |
| phlat | 96.7% | 78.9% | 89.4% |
| hlavbseq | 95.4% | 86.6% | 91.8% |
| hlapers | 98.3% | 95.9% | 97.1% |
| optitype | 98.9% | 0.0% | 59.3% |
| hlaminer | 15.3% | 19.6% | 17.3% |

---

## Table 4: Per-Locus Accuracy — 2-field, Filtered

| Tool | A | B | C | DRB1 | DQB1 |
|------|---|---|---|------|------|
| T1K | 99.6% | 98.6% | 97.6% | 98.0% | 92.9% |
| arcas | 99.6% | 98.4% | 97.2% | 96.3% | 92.6% |
| hisat | 99.8% | 98.3% | 97.2% | 96.5% | 92.9% |
| hlahd | 99.5% | 98.5% | 96.6% | 97.5% | 93.1% |
| rna2hla | 99.5% | 97.4% | 97.5% | 95.4% | 93.8% |
| seq2hla | 99.7% | 97.6% | 97.7% | 94.8% | 93.8% |
| hlaforest | 98.9% | 89.2% | 89.0% | 96.0% | 90.7% |
| phlat | 98.8% | 94.5% | 96.7% | 97.1% | 58.2% |
| hlavbseq | 98.3% | 92.2% | 95.7% | 80.8% | 93.4% |
| hlapers | 99.5% | 98.4% | 96.0% | 98.5% | 92.8% |
| optitype | 99.6% | 98.2% | 98.7% | 0.0% | 0.0% |
| hlaminer | 16.7% | 11.4% | 17.0% | 12.6% | 24.6% |

---

## Table 5: Per-Locus Accuracy — 2-field, Unfiltered

*Novel alleles penalised as miscalled (denominator = all call slots). Added 2026-07-25 to check Serghei's ISMB 2026 slide 24 claim (`BACKLOG.md`: "Per-locus unfiltered accuracy table needed").*

| Tool | A | B | C | DRB1 | DQB1 |
|------|---|---|---|------|------|
| T1K | 98.2% | 95.4% | 93.2% | 97.1% | 92.3% |
| arcas | 91.2% | 93.6% | 91.8% | 95.8% | 88.5% |
| hisat | 95.7% | 97.5% | 90.7% | 94.7% | 91.4% |
| hlahd | 95.9% | 95.8% | 86.0% | 96.1% | 93.0% |
| rna2hla | 97.3% | 94.8% | 96.4% | 89.0% | 85.5% |
| seq2hla | 95.7% | 92.7% | 93.8% | 81.7% | 85.5% |
| hlaforest | 92.5% | 75.6% | 79.8% | 90.1% | 89.3% |
| phlat | 93.4% | 82.3% | 90.1% | 92.2% | 57.6% |
| hlavbseq | 95.4% | 85.0% | 89.0% | 79.3% | 93.1% |
| hlapers | 76.6% | 87.9% | 43.5% | 94.2% | 91.0% |
| optitype | 98.9% | 97.6% | 98.0% | 0.0% | 0.0% |
| hlaminer | 7.8% | 3.9% | 7.2% | 5.1% | 16.8% |
| **Mean (12 tools)** | **86.6%** | **83.5%** | **80.0%** | **76.3%** | **73.7%** |

*Comparison to Serghei's slide 24 (A=85.0%, B=82.0%, C=78.0%, DRB1=58.6%, DQB1=55.8%): Class I loci (A/B/C) are close, within 1.5-2.5pp. Class II loci (DRB1/DQB1) diverge by ~18-20pp. The most likely explanation is that the slide predates the 2026-07-22 HLApers DRB1/DQB1 column-swap fix — under the pre-fix data, HLApers scored 0% on both Class II loci, which would drag a 12-tool mean down by roughly 100%/12 ≈ 8pp per locus, and other tools' pre-swap-fix values compound further. This has not been confirmed against the slide's own source data, only inferred from the direction and rough magnitude of the gap — do not put these numbers in the manuscript without `hla-benchmark-scientist`/Serghei sign-off per the original BACKLOG.md instruction.*

---

## Table 6: Per-Locus Raw Counts — 2-field, Filtered

*Correct / Miscalled / Novel / No-call / Total (call slots) / Accuracy*

### Locus A

| Tool | Correct | Miscalled | Novel | No-call | Total | Accuracy |
|------|---------|-----------|-------|---------|-------|----------|
| T1K | 1063 | 4 | 15 | 0 | 1082 | 99.6% |
| arcas | 987 | 4 | 91 | 0 | 1082 | 99.6% |
| hisat | 1036 | 2 | 44 | 0 | 1082 | 99.8% |
| hlahd | 1038 | 5 | 39 | 0 | 1082 | 99.5% |
| rna2hla | 1053 | 5 | 24 | 0 | 1082 | 99.5% |
| seq2hla | 1035 | 3 | 44 | 0 | 1082 | 99.7% |
| hlaforest | 1001 | 11 | 70 | 0 | 1082 | 98.9% |
| phlat | 1011 | 12 | 59 | 0 | 1082 | 98.8% |
| hlavbseq | 1032 | 18 | 32 | 0 | 1082 | 98.3% |
| hlapers | 829 | 4 | 249 | 0 | 1082 | 99.5% |
| optitype | 1070 | 4 | 8 | 0 | 1082 | 99.6% |
| hlaminer | 84 | 412 | 578 | 8 | 1082 | 16.7% |

### Locus B

| Tool | Correct | Miscalled | Novel | No-call | Total | Accuracy |
|------|---------|-----------|-------|---------|-------|----------|
| T1K | 1036 | 15 | 35 | 0 | 1086 | 98.6% |
| arcas | 1017 | 17 | 52 | 0 | 1086 | 98.4% |
| hisat | 1059 | 18 | 9 | 0 | 1086 | 98.3% |
| hlahd | 1040 | 16 | 30 | 0 | 1086 | 98.5% |
| rna2hla | 1029 | 27 | 30 | 0 | 1086 | 97.4% |
| seq2hla | 1007 | 25 | 54 | 0 | 1086 | 97.6% |
| hlaforest | 821 | 99 | 166 | 0 | 1086 | 89.2% |
| phlat | 894 | 52 | 140 | 0 | 1086 | 94.5% |
| hlavbseq | 923 | 78 | 85 | 0 | 1086 | 92.2% |
| hlapers | 955 | 16 | 115 | 0 | 1086 | 98.4% |
| optitype | 1060 | 19 | 7 | 0 | 1086 | 98.2% |
| hlaminer | 42 | 322 | 716 | 6 | 1086 | 11.4% |

### Locus C

| Tool | Correct | Miscalled | Novel | No-call | Total | Accuracy |
|------|---------|-----------|-------|---------|-------|----------|
| T1K | 1021 | 25 | 50 | 0 | 1096 | 97.6% |
| arcas | 1006 | 29 | 61 | 0 | 1096 | 97.2% |
| hisat | 994 | 29 | 73 | 0 | 1096 | 97.2% |
| hlahd | 943 | 33 | 120 | 0 | 1096 | 96.6% |
| rna2hla | 1056 | 27 | 13 | 0 | 1096 | 97.5% |
| seq2hla | 1028 | 24 | 44 | 0 | 1096 | 97.7% |
| hlaforest | 875 | 108 | 113 | 0 | 1096 | 89.0% |
| phlat | 988 | 34 | 74 | 0 | 1096 | 96.7% |
| hlavbseq | 975 | 44 | 77 | 0 | 1096 | 95.7% |
| hlapers | 477 | 20 | 599 | 0 | 1096 | 96.0% |
| optitype | 1074 | 14 | 8 | 0 | 1096 | 98.7% |
| hlaminer | 79 | 367 | 632 | 18 | 1096 | 17.0% |

### Locus DRB1

| Tool | Correct | Miscalled | Novel | No-call | Total | Accuracy |
|------|---------|-----------|-------|---------|-------|----------|
| T1K | 1146 | 23 | 11 | 0 | 1180 | 98.0% |
| arcas | 1131 | 19 | 6 | 24 | 1180 | 96.3% |
| hisat | 1118 | 32 | 22 | 8 | 1180 | 96.5% |
| hlahd | 1134 | 19 | 17 | 10 | 1180 | 97.5% |
| rna2hla | 1050 | 51 | 79 | 0 | 1180 | 95.4% |
| seq2hla | 961 | 53 | 162 | 0 | 1176 | 94.8% |
| hlaforest | 1060 | 44 | 72 | 0 | 1176 | 96.0% |
| phlat | 1075 | 32 | 59 | 0 | 1166 | 97.1% |
| hlavbseq | 932 | 220 | 22 | 2 | 1176 | 80.8% |
| hlapers | 1111 | 17 | 52 | 0 | 1180 | 98.5% |
| optitype | 0 | 0 | 0 | 1180 | 1180 | 0.0% |
| hlaminer | 60 | 383 | 705 | 32 | 1180 | 12.6% |

### Locus DQB1

| Tool | Correct | Miscalled | Novel | No-call | Total | Accuracy |
|------|---------|-----------|-------|---------|-------|----------|
| T1K | 905 | 69 | 6 | 0 | 980 | 92.9% |
| arcas | 867 | 69 | 44 | 0 | 980 | 92.6% |
| hisat | 896 | 68 | 16 | 0 | 980 | 92.9% |
| hlahd | 911 | 68 | 1 | 0 | 980 | 93.1% |
| rna2hla | 838 | 55 | 87 | 0 | 980 | 93.8% |
| seq2hla | 838 | 55 | 87 | 0 | 980 | 93.8% |
| hlaforest | 875 | 90 | 15 | 0 | 980 | 90.7% |
| phlat | 564 | 405 | 11 | 0 | 980 | 58.2% |
| hlavbseq | 912 | 64 | 4 | 0 | 980 | 93.4% |
| hlapers | 892 | 69 | 19 | 0 | 980 | 92.8% |
| optitype | 0 | 0 | 0 | 980 | 980 | 0.0% |
| hlaminer | 165 | 491 | 308 | 16 | 980 | 24.6% |

---

## Table 7: Novel Allele and No-Call Rates — 2-field

*(Rates computed over all 5 loci combined from raw counts)*

| Tool | No-call % | Novel % | Unfiltered Overall | Filtered Overall | Δ |
|------|-----------|---------|-------------------|-----------------|---|
| T1K | 0.0% | 2.2% | 95.3% | 97.4% | +2.1pp |
| arcas | 0.4% | 4.7% | 92.3% | 96.9% | +4.5pp |
| hisat | 0.1% | 3.0% | 94.1% | 97.0% | +2.9pp |
| hlahd | 0.2% | 3.8% | 93.4% | 97.1% | +3.7pp |
| rna2hla | 0.0% | 4.3% | 92.7% | 96.8% | +4.2pp |
| seq2hla | 0.0% | 7.2% | 89.8% | 96.8% | +7.0pp |
| hlaforest | 0.0% | 8.0% | 85.5% | 92.9% | +7.5pp |
| phlat | 0.0% | 6.3% | 83.8% | 89.4% | +5.7pp |
| hlavbseq | 0.0% | 4.1% | 88.1% | 91.8% | +3.7pp |
| hlapers | 0.0% | 19.1% | 78.6% | 97.1% | +18.5pp |
| optitype | 39.8% | 0.4% | 59.1% | 59.3% | +0.3pp |
| hlaminer | 1.5% | 54.2% | 7.9% | 17.3% | +9.4pp |

---

---

## Notes

- **HLA-VBSeq (hlavbseq)**: DRB1/DQB1 column-swap fixed 2026-07-15. Pre-fix Class II accuracy was ~4.9% (1-field); all values above are post-fix and authoritative.
- **OptiType**: Class I-only tool. Class II = 0% because all DRB1/DQB1 slots are no-calls. Filtered overall still reflects 39.8% no-call drag.
- **HLApers**: DRB1/DQB1 column-swap fixed 2026-07-22 (root cause: `hlapers_standardize.sh` emitted columns in alphabetical order instead of this project's schema order). Prior to this regeneration, this file still published the pre-fix numbers (HLApers "Class II = 0.0%, reports Class I only") for three days after the fix — see Notes below. HLApers' real Class II accuracy is ~93-99% depending on filter/resolution; it is a full Class I + Class II tool, not Class I-only -- confirmed against the primary source (Aguiar et al., "Expression estimation and eQTL mapping for HLA genes with a personalized pipeline," *PLOS Genetics* 2019, PMC6497317), which explicitly covers 9 classical loci including Class II (*HLA-DRA/DRB1/DQA1/DQB1/DPA1/DPB1*), not just the 3 Class I loci.
- **HLAminer**: Very high novel rate (54.2%) due to older IMGT database version; 1-field accuracy is also low, suggesting systematic mistyping.
- **Filtered vs unfiltered difference**: Large gap indicates high novel rate. HLApers' gap shrank from +56.6pp to +18.5pp after its column-swap fix (the "novel" alleles were largely an artifact of scoring DQB1 predictions against the DRB1 valid set and vice versa); HLAminer remains the largest genuine gap (+9.4pp).
- **Datasets**: 1–6 = main benchmark cohort (652 RNA-seq samples, 12/12 tools). D7 = scRNA-seq (n=20, 6/12 tools) and D8 = in-house PacBio long-read family trio (n=3, mother/father/daughter) — both excluded from main analysis.

## Regeneration history (2026-07-25)

This file was regenerated for the first time since **2026-07-17** (Human-PI-authorized: Nick). Three data/scoring fixes were already applied to the underlying pipeline in the interim but had never been propagated into this document — this regeneration is a pure re-run of the existing, unchanged `Cell 7` scoring logic against current data; **no scoring contract or methodology changed**, only which already-authorized fixes are now reflected:

1. **HLApers `DRB1`/`DQB1` column-swap fix (2026-07-22)** — by far the largest change. HLApers' Class II accuracy moves from a published **0.0%** to its real value (~93-99% depending on table/filter), and its Overall accuracy rises correspondingly (e.g. Table 3 filtered: 98.2%→97.1% overall is actually a *decrease* here because the old "98.2%" was silently computed as Class-I-only with a zero/undefined Class II denominator, not a true blended overall — the new 97.1% is the first real blended figure this file has shown for HLApers).
2. **`datasets/1_gs.csv` `ERR188021`/`B.1` gold-standard correction (2026-07-22)** — a single corrupted cell (`B*1/B*2/B*1900 9:01`, an Excel text-to-date autocorrect artifact) fixed to `B*57:01:00`. Flips that one sample-locus from miss to hit for the ~10 tools that had already correctly called `B*57:01` there, visible as a uniform +1 correct / -1 miscalled shift at Locus B across most tools in Table 6.
3. **`:xx` gold-standard-suffix scoring fix (2026-07-25, same day as this regeneration)** — see `KNOWN_BUGS.md`. **Verified to have zero effect on every table in this file** (isolated by running the fix on/off against identical current data before regenerating) — Locus A and Locus C, which contain the two affected tokens (`A*68:xx`, `B*55:xx`), are byte-identical to the pre-regeneration file. The fix's only visible effect is on the separate per-allele Figure 7 / supplementary-figure analysis (`results/allele_miscall_*.csv`), not on this per-tool/per-locus summary.

**Addendum, later on 2026-07-25:** added new **Table 5 (Per-Locus Accuracy — 2-field, Unfiltered)**, computed on request to check Serghei's ISMB 2026 slide 24 per-locus numbers (`BACKLOG.md` item). Old Table 5/6 renumbered to 6/7. See Table 5's own caption for the comparison and its likely explanation (pre-HLApers-fix data on the slide). Not sign-off'd for manuscript use.

All three fixes were individually authorized and verified (with backups, diffs, and independent re-derivation) at the time each was made — see `.claude/memory/KNOWN_BUGS.md` for the full history of each. This regeneration is the first time their combined effect appears in the published summary table.
