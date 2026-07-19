# HLA Benchmarking — Results Summary

*Source: `accuracy_fixed_executed.ipynb` — 12 tools, datasets 1–6*  
*HLA-VBSeq column-swap fix applied 2026-07-15 (DRB1/DQB1 labels swapped in `hlavbseq_d1.csv`)*  
*Generated 2026-07-17 using exact scoring logic from `accuracy_fixed_executed.ipynb` Cell 7*

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
| T1K | 99.4% | 99.6% | 99.4% |
| arcas | 99.4% | 98.6% | 99.1% |
| hisat | 99.4% | 98.4% | 99.0% |
| hlahd | 98.5% | 98.8% | 98.6% |
| rna2hla | 98.9% | 96.4% | 97.9% |
| seq2hla | 98.9% | 94.5% | 97.1% |
| hlaforest | 98.4% | 99.6% | 98.9% |
| phlat | 97.5% | 85.3% | 92.7% |
| hlavbseq | 98.2% | 94.3% | 96.7% |
| hlapers | 84.1% | 0.0% | 50.6% |
| optitype | 99.3% | 0.0% | 59.8% |
| hlaminer | 19.5% | 32.3% | 24.6% |

*(Difference between unfiltered and filtered is negligible at 1-field — novel alleles are rare at this resolution)*

---

## Table 2: Overall Accuracy — 2-field, Unfiltered (primary metric)

*Novel alleles penalised as miscalled. This is the primary comparison metric.*

| Tool | Class I | Class II | Overall |
|------|---------|----------|---------|
| T1K | 95.6% | 95.0% | 95.3% |
| arcas | 92.2% | 92.5% | 92.3% |
| hisat | 94.6% | 93.2% | 94.1% |
| hlahd | 92.5% | 94.7% | 93.4% |
| rna2hla | 96.1% | 87.4% | 92.6% |
| seq2hla | 94.0% | 83.4% | 89.8% |
| hlaforest | 82.6% | 89.7% | 85.4% |
| phlat | 88.6% | 76.4% | 83.8% |
| hlavbseq | 89.8% | 85.5% | 88.1% |
| hlapers | 69.2% | 0.0% | 41.7% |
| optitype | 98.1% | 0.0% | 59.1% |
| hlaminer | 6.3% | 10.4% | 7.9% |

---

## Table 3: Overall Accuracy — 2-field, Filtered

*Novel alleles excluded from denominator. Measures accuracy on cohort-known alleles only.*

| Tool | Class I | Class II | Overall |
|------|---------|----------|---------|
| T1K | 98.6% | 95.7% | 97.4% |
| arcas | 98.3% | 94.7% | 96.8% |
| hisat | 98.4% | 94.9% | 97.0% |
| hlahd | 98.2% | 95.5% | 97.1% |
| rna2hla | 98.1% | 94.7% | 96.8% |
| seq2hla | 98.3% | 94.3% | 96.8% |
| hlaforest | 92.5% | 93.5% | 92.9% |
| phlat | 96.7% | 78.9% | 89.4% |
| hlavbseq | 95.4% | 86.6% | 91.8% |
| hlapers | 98.2% | — | 98.2% |
| optitype | 98.8% | 0.0% | 59.3% |
| hlaminer | 15.3% | 19.6% | 17.3% |

---

## Table 4: Per-Locus Accuracy — 2-field, Filtered

| Tool | A | B | C | DRB1 | DQB1 |
|------|---|---|---|------|------|
| T1K | 99.6% | 98.5% | 97.6% | 98.0% | 92.9% |
| arcas | 99.6% | 98.3% | 97.2% | 96.3% | 92.6% |
| hisat | 99.8% | 98.2% | 97.2% | 96.5% | 92.9% |
| hlahd | 99.5% | 98.4% | 96.6% | 97.5% | 93.1% |
| rna2hla | 99.5% | 97.3% | 97.5% | 95.4% | 93.8% |
| seq2hla | 99.7% | 97.5% | 97.7% | 94.8% | 93.8% |
| hlaforest | 98.9% | 89.1% | 89.0% | 96.0% | 90.7% |
| phlat | 98.8% | 94.4% | 96.7% | 97.1% | 58.2% |
| hlavbseq | 98.3% | 92.2% | 95.7% | 80.8% | 93.4% |
| hlapers | 99.5% | 98.2% | 96.0% | — | — |
| optitype | 99.6% | 98.1% | 98.7% | 0.0% | 0.0% |
| hlaminer | 16.7% | 11.4% | 17.0% | 12.6% | 24.6% |

---

## Table 5: Per-Locus Raw Counts — 2-field, Filtered

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
| T1K | 1035 | 16 | 35 | 0 | 1086 | 98.5% |
| arcas | 1016 | 18 | 52 | 0 | 1086 | 98.3% |
| hisat | 1058 | 19 | 9 | 0 | 1086 | 98.2% |
| hlahd | 1039 | 17 | 30 | 0 | 1086 | 98.4% |
| rna2hla | 1028 | 28 | 30 | 0 | 1086 | 97.3% |
| seq2hla | 1006 | 26 | 54 | 0 | 1086 | 97.5% |
| hlaforest | 820 | 100 | 166 | 0 | 1086 | 89.1% |
| phlat | 893 | 53 | 140 | 0 | 1086 | 94.4% |
| hlavbseq | 923 | 78 | 85 | 0 | 1086 | 92.2% |
| hlapers | 954 | 17 | 115 | 0 | 1086 | 98.2% |
| optitype | 1059 | 20 | 7 | 0 | 1086 | 98.1% |
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
| hlapers | 0 | 0 | 1180 | 0 | 1180 | — |
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
| hlapers | 0 | 0 | 980 | 0 | 980 | — |
| optitype | 0 | 0 | 0 | 980 | 980 | 0.0% |
| hlaminer | 165 | 491 | 308 | 16 | 980 | 24.6% |

---

## Table 6: Novel Allele and No-Call Rates — 2-field

*(Rates computed over all 5 loci combined from raw counts)*

| Tool | No-call % | Novel % | Unfiltered Overall | Filtered Overall | Δ |
|------|-----------|---------|-------------------|-----------------|---|
| T1K | 0.0% | 2.2% | 95.3% | 97.4% | +2.1pp |
| arcas | 0.4% | 4.7% | 92.3% | 96.8% | +4.5pp |
| hisat | 0.1% | 3.0% | 94.1% | 97.0% | +2.9pp |
| hlahd | 0.2% | 3.8% | 93.4% | 97.1% | +3.7pp |
| rna2hla | 0.0% | 4.3% | 92.6% | 96.8% | +4.2pp |
| seq2hla | 0.0% | 7.2% | 89.8% | 96.8% | +7.0pp |
| hlaforest | 0.0% | 8.0% | 85.4% | 92.9% | +7.5pp |
| phlat | 0.0% | 6.3% | 83.8% | 89.4% | +5.7pp |
| hlavbseq | 0.0% | 4.1% | 88.1% | 91.8% | +3.7pp |
| hlapers | 0.0% | 57.6% | 41.7% | 98.2% | +56.6pp |
| optitype | 39.8% | 0.4% | 59.1% | 59.3% | +0.3pp |
| hlaminer | 1.5% | 54.2% | 7.9% | 17.3% | +9.4pp |

---

## Notes

- **HLA-VBSeq (hlavbseq)**: DRB1/DQB1 column-swap fixed 2026-07-15. Pre-fix Class II accuracy was ~4.9% (1-field); all values above are post-fix and authoritative.
- **OptiType**: Class I-only tool. Class II = 0% because all DRB1/DQB1 slots are no-calls. Filtered overall still reflects 39.8% no-call drag.
- **HLApers**: Reports Class I only; DRB1/DQB1 calls all fall outside valid set (counted as novel = 57.6%). Filtered Class II accuracy = NaN (denominator = 0).
- **HLAminer**: Very high novel rate (54.2%) due to older IMGT database version; 1-field accuracy is also low, suggesting systematic mistyping.
- **Filtered vs unfiltered difference**: Large gap indicates high novel rate (hlapers, hlaminer). Small gap (T1K, arcas, hisat, hlahd) indicates tools are consistent with cohort alleles.
- **Datasets**: 1–6 (D7 = family trio, D8 = WGS/long-read — excluded from main analysis).