# Known Bugs & Resolutions

Every bug found in this pipeline, whether fixed, open, or unconfirmed. Never
delete a resolved entry — move it to the Resolved section with its fix date and
verification status. This file exists because this project has already had one bug
(HLA-VBSeq column swap) persist across multiple analysis cycles before being
caught, and one documentation/code mismatch that was marked "resolved" while a
contradicting statement remained elsewhere in the same notebook.

**Boundary with `BACKLOG.md`:** `BACKLOG.md` (repo root) tracks manuscript
reviewer/co-author comment threads — content, phrasing, and decision items from
the Google Doc review. This file tracks technical/data defects in the pipeline
itself — code, scoring output, or data-file bugs found by an agent or human during
routine work. An item can appear in both if a reviewer comment surfaces a genuine
pipeline bug — in that case, log the technical defect here and cross-reference this
file's entry from the corresponding `BACKLOG.md` item, rather than duplicating the
description in both places.

*Last updated: 2026-07-19*

## Open

### Standardization scripts missing for 10 of 12 tools
- **Found:** repository audit, 2026-07-19.
- **Description:** Only HLAforest and HLApers have a checked-in, reproducible
  standardization script. The remaining tools' native-output-to-common-schema
  conversion is not currently reproducible from the repository alone.
- **Owner:** tool-integration-engineer / reproducibility-manager.
- **Status:** Open. See `checklists/reproducibility-checklist.md`.

### Dataset 8 gold standard has empty sample rows
- **Found:** repository audit, 2026-07-19.
- **Description:** `datasets/8_gs.csv` has 3 fully-populated trio rows
  (mother/father/daughter) followed by 10 rows (`sample_1`...`sample_10`) with all
  genotype columns empty.
- **Owner:** dataset-curator.
- **Status:** Open — unclear whether these are planned-but-not-yet-typed
  placeholders or a data-loss artifact. D8 is currently excluded from the main
  analysis regardless.

### Manuscript internal sample-count inconsistency
- **Found:** repository audit, 2026-07-19.
- **Description:** Abstract states "682 RNA-seq samples," Introduction states "652
  RNA-seq samples." (652 = sum of D1-D6 accession counts: 50+490+86+14+4+8.)
- **Owner:** scientific-writer.
- **Status:** Open.

### Ancestry z-test computed on Dataset 1 only
- **Found:** repository audit, 2026-07-19.
- **Description:** Not a code bug, but a scope limitation not always visible where
  the finding is cited. `notebooks/accuracy_fixed_executed.ipynb` cell 60 hardcodes
  `pred = f"../results/standard/{t}_d1.csv"` for the Europe/Yoruba comparison.
- **Owner:** statistics-reviewer (statistical scope/power) / clinical-and-equity-reviewer (framing).
- **Status:** Open — not a defect to "fix" so much as a scope constraint to
  disclose consistently and, ideally, expand as more population-labeled data
  becomes available.

## Resolved

### `CLASS_I_ONLY_TOOLS` code/documentation mismatch (successor notebook)
- **Found:** repository audit, 2026-07-19.
- **Fixed:** 2026-07-19 by hla-benchmark-scientist.
- **What was wrong:** `notebooks/accuracy_fixed_executed.ipynb` cell 23 correctly
  defined `CLASS_I_ONLY_TOOLS = ['optitype']`, but the interpretation markdown in
  cell 25 twice referred to "Class I-only tools (Optitype, HLAvbseq)" — incorrectly
  listing HLA-VBSeq as Class I-only. The code and prose contradicted each other.
- **Evidence (which one was factually wrong):** `results_summary.md` shows HLA-VBSeq
  actively calls and scores well on Class II, so it is *not* Class I-only:
  - Table 4 (per-locus, 2-field filtered): HLA-VBSeq DRB1 = **80.8%**, DQB1 = **93.4%**.
  - Table 5 raw counts: DRB1 = 932 correct / 220 miscalled / 22 novel / **2 no-call**
    / 1176 total; DQB1 = 912 correct / 64 miscalled / 4 novel / **0 no-call** / 980
    total.
  - Contrast — genuine Class I-only tool OptiType: DRB1 = 0 correct / **1180 no-call**
    (100% no-call by design), DQB1 = 0 correct / **980 no-call**. HLA-VBSeq's
    near-zero Class II no-call rate and high accuracy confirm it is scored on Class II
    like the other multi-class tools.
  - Conclusion: the code list (`['optitype']`) was correct; the cell 25 markdown was
    the factually wrong side.
- **What was changed:** Edited only cell 25 markdown source in
  `accuracy_fixed_executed.ipynb` (all other cells, code, and outputs untouched). Both
  "(Optitype, HLAvbseq)" references now read "(Optitype)", and an explicit clarifying
  sentence was added noting HLA-VBSeq is *not* Class I-only (cites the 80.8%/93.4%
  filtered 2-field DRB1/DQB1 accuracy). Cell 23 was left unchanged because it was
  already correct.
- **Verification status:** Notebook re-parsed as valid JSON (91 cells intact); no
  remaining "Class I-only" reference lists HLA-VBSeq. `results_summary.md`'s Class I/II
  split for HLA-VBSeq is therefore consistent with the scoring code.

### HLA-VBSeq DRB1/DQB1 column swap
- **Found:** prior to 2026-07-15 (exact discovery date not recorded in repo).
- **Description:** DRB1 and DQB1 columns were swapped in
  `results/standard/hlavbseq_d1.csv`, producing incorrect (~4.9% 1-field) Class II
  accuracy for HLA-VBSeq pre-fix.
- **Fixed:** 2026-07-15. Backup preserved as `hlavbseq_d1.csv.bak`.
- **Verification status:** Fix applied and reflected in `results_summary.md`
  (generated 2026-07-17), but **the fix was found uncommitted in git** during the
  2026-07-19 audit (`git status` showed `modified: results/standard/hlavbseq_d1.csv`
  as unstaged). Confirm this has since been committed before treating it as durably
  fixed.

### `CLASS_I_ONLY_TOOLS` bug (original instance)
- **Description:** `accuracy.ipynb` (predecessor notebook) incorrectly listed
  `hlavbseq` as Class I-only.
- **Fixed:** In `accuracy.ipynb` Cell 23, per `BACKLOG.md`'s Resolved section.
- **Verification status:** The related but distinct inconsistency in the successor
  notebook (`accuracy_fixed_executed.ipynb` cell 25 markdown) was resolved 2026-07-19
  — see the "*(successor notebook)*" entry in this Resolved section.

### Over-calling investigation
- **Description:** Concern that some tools return more than 2 alleles per locus.
- **Resolution:** Only HISAT-genotype returns >2 alleles/locus; it provides a score
  (abundance %) to rank them. No tool without a score over-calls. Methods sentence
  drafted (per `BACKLOG.md`).
- **Verification status:** Resolved per BACKLOG; not independently re-verified
  during the 2026-07-19 audit.

### Novel-allele definition ambiguity
- **Description:** Whether "novel" should be defined relative to the IMGT database
  or the study cohort.
- **Resolution:** Cohort-based (`gs_set` vs. `valid_set` logic), confirmed via
  Ram's inline explanation, reviewer-driven.
- **Verification status:** Resolved and consistently implemented in the current
  scoring engine as of the last audit.
