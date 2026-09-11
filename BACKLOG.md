# HLA Stage 2 Manuscript — Open Task Backlog

Source: Google Doc comments (111 total, 49 open as of 2026-07-26) + 82-comment
Word-doc audit (2026-07-21) + Serghei's ISMB 2026 slides + direct paragraph-by-
paragraph numbers audit (2026-07-27). Rewritten 2026-07-27 in compact technical
format (prior version: verbose narrative, ~50KB for 40 items). Full
investigation detail for any item is recoverable from git history of this
file plus `.claude/memory/KNOWN_BUGS.md`.

**Scope:** this file tracks manuscript text/phrasing/content decisions.
Pipeline/code/data-file defects → `.claude/memory/KNOWN_BUGS.md`.

**Status legend:** `[x]` closed · `[ ]` open. Each item: status/date, 1-3 line
technical summary, `Next:` if open.

**⚠ STANDING PROCESS RISK (2026-07-20/21, unresolved):** local `.docx` edits
are not synced back to the shared Google Doc. A prior re-export
(`HLA stage 2 manuscript (CURRENT 2024) (1).docx`) silently discarded several
already-applied fixes. Any `[x]` item below dated ≤2026-07-21 needs
re-verification against the current file before being relied on without
re-checking. Root-cause fix not yet decided — escalated to
`scientific-coordinator`/Human PI (options: edit Google Doc as single source
of truth; freeze re-exports during edit passes; maintain a re-apply
checklist). Not resolved by this rewrite.

---

## A — Solvable by Claude Code (data / code / text access)

- [x] **Tool count discrepancy** (2026-07-20) — verified 12 tools stated consistently everywhere (abstract, Methods, Table 2/Fig 12 captions). No change needed.
- [x] **Nomenclature standardization** (2026-07-20) — one stray "four-digit HLA calls" (P300) → "two-field HLA calls" to match established convention. Everything else already consistent.
- [ ] **IPD-IMGT/HLA naming + citation** — naming fixed (P171); citation source resolved: **Barker et al., NAR 2026, 54:D1152–D1158** (from Serghei's ISMB slides 3/7). Next: mechanically insert into reference list, point first-mention citation at it.
- [ ] **Pull current numbers from pipeline into manuscript prose** — superseded/subsumed by category E below (2026-07-27 paragraph audit found and itemized every stale-number location found so far). Next: apply E1-E7, E9-E12.
- [x] **Fig 7 supplementary family (panels a-e, per-dataset/per-allele miscall breakdown)** (DONE 2026-07-22, statistics-reviewer memo #2) — **CLEARED WITH CAVEATS**. Artifacts: `Figures/fig7_supp_{a,b,c,d,e}_*`, `results/allele_miscall_*.csv`. Headline: 0/20 top alleles "universal" (elevated in ≥3 datasets); claim supportable at locus level only, not per-allele. **Hard precondition P1 (blocks manuscript use of panels a-e):** `B*55:xx`/`A*68:xx` must be removed or visibly annotated in the top-20 rendering — needs `dataset-curator` fix + Human PI authorization (changes an already-reported top-20). **Text conditions C1-C4 (mandatory before citing):** C1 flag the 2 malformed tokens as uninterpretable; C2 quote distinct-sample-n inline per rate cited, no cross-dataset claim below ~10 samples; C3 state 55.4% of "miscalled" events are actually no-calls, reword axis/titles accordingly; C4 state pooled rates mix 12-tool D1-D6 with 6-tool D7. Migrated 2026-07-26 into `accuracy_fixed_executed.ipynb` (was a separate notebook); scoring contract unchanged throughout all revisions (re-verified by independent re-derivation, exact match). Full history: `Figures/miscalled_alleles_family_README.md`.
- [x] **Fig 6 absolute-numbers companion** (DONE 2026-07-26) — `Figures/fig6b_miscalled_absolute.{png,svg}`, companion to the existing %-stacked-bar `fig6b_miscalled_proportion`. Figure-numbering question ("Fig 6 or Fig 15?") unresolved — Serghei's own comment thread is inconsistent on this.
- [ ] **Identify "each sample" figure** — confirm if it's raw data behind Fig 6; explain x-axis in caption.
- [ ] **Redraw gene-coverage figure** — restrict to the 5 HLA genes stated in abstract (A, B, C, DRB1, DQB1).
- [ ] **Build supplementary table** — per Ram/Serghei request; exact contents TBD.
- [x] **Ancestry caption phrasing** (2026-07-20, Human PI approved per GOVERNANCE #5) — Fig 10 caption P506 clarified ("…precision of their inter-population differences" → "…statistical precision (standard error) of the estimated differences…").
- [x] **"Computational resources required" phrasing** (2026-07-20) — Methods heading P382 reworded for clarity, non-numeric.
- [ ] **STAR options documentation** — mostly resolved 2026-07-20 (6 of 6 doc discrepancies fixed: `--outReadsUnmapped` scope, `--quantMode GeneCounts`, `--sjdbOverhang 50`, GENCODE v34 vs p14 labeling). Next (needs Ram): genome-patch level is genuinely inconsistent across scripts (main index = GENCODE v34/GRCh38.p13; unmapped-read sub-experiment index labeled p14) — cannot be reconciled from local evidence alone.
- [ ] **Systematize citations** — pull PubMed IDs, consistent format. Standing style rule (Serghei, comment #18): never name a tool inline when citing it, citation alone suffices.

---

## B — Needs literature check / external lookup

- [ ] **Verify "limited gold standard" claim** — confirm comparator papers used limited GS, not long reads.
- [ ] **Check comparator paper accuracy metric** — what metric they report vs. ours.
- [ ] **Update co-author affiliation** — per their recent Nature Methods paper.

---

## C — Needs Serghei / Ram decision (not Claude-Code-solvable)

- [ ] **Optimized-parameter results** — confirm with Ram whether runs exist; if not, delete related text and revise Abstract claim.
- [ ] **Ambiguous "please check if this is true" comment** — locate exact claim in manuscript, flag for call.
- [ ] **"Let's discuss on the call" comments** — tied to specific figures; compile figure-number list before next call.
- [ ] **African-population-diversity hypothesis** (Dottie's suggestion) — decide whether to include in Discussion.
- [ ] **Figure placement decisions** — main vs. supplementary, multiple instances including the E-category promotion question (E-item below).
- [ ] **Solid-organ matching sentence, self-contradictory** (P184) — "…high-resolution allele matching…is not the standard, meaning allocation is based on an 8/8 or 10/10 allele rule" contradicts itself. Route to `clinical-and-equity-reviewer` for corrected wording, then Human PI sign-off (GOVERNANCE: clinical claim). UNOS citation withheld pending correction.
- [ ] **Figure promotion decision** (Ram #68, Serghei #69) — alternate figure with lower p-values; consider promoting to main, demoting current. Needs `figure-designer` input + human decision.
- [ ] **Log-scale vs linear conflict** — Serghei (#73) wants log scale; conflicts with already-implemented Ram decision (#54, linear only). Needs `scientific-coordinator` to settle before any re-plot.

---

## D — Admin / communication

- [ ] **Add names + affiliations** — Nick and Munteanu, relevant section.
- [ ] **Email co-authors** — confirm affiliations + funding info before next draft distribution.
- [ ] **Upload RNA-Seq and WGS PacBio data to SRA** — coordinate with Taras and Khrystyna for metadata.

---

## E — New findings, 2026-07-27 numbers/consistency audit (paragraph-by-paragraph check of Results against current pipeline)

*Every paragraph checked so far had at least one stale/incorrect number —
treat any not-yet-checked paragraph as likely affected too (see E15).
Numbers below are computed from the current, post-all-fixes pipeline
(D1-D6, HLApers/gold-standard/`:xx` fixes applied); none inserted into the
manuscript yet — all pending `hla-benchmark-scientist`/Serghei sign-off per
this project's standing rule on published numbers.*

- [x] **E1 — Section heading contradicts its own body text.** CONFIRMED FIXED (re-checked against live doc 2026-08-01): "HLA-B and HLA-DRB1" → "HLA-DQB1 and HLA-DRB1 loci are most commonly mispredicted."
- [x] **E2 — Stale per-locus accuracy numbers.** CONFIRMED FIXED: text now reads A 86.6/B 83.5/C 80.0/DRB1 76.3/DQB1 73.7% — matches the recomputed values exactly.
- [x] **E3 — Stale per-allele misclassification-rate numbers.** CONFIRMED FIXED: text now reads the recomputed values exactly (DQB1 52.4%/16.7%, DRB1 25.0%/17.1%, A 19.4%/7.8%, B 25.0%/10.1%, C 41.7%/9.2%). Figure-number question ("Fig 6" vs "Fig 7") still not addressed — minor, unresolved.
- [x] **E4 — HLA-VBseq "near-zero two-field accuracy" claim.** CONFIRMED FIXED 2026-08-01 — duplicate paragraph deleted (see E-DUP), claim no longer present anywhere in the section.
- [x] **E5 — "HLA-ND" typo.** CONFIRMED FIXED: 0 occurrences of "HLA-ND" in the live doc (was 1).
- [x] **E6 — "arcas…highest one-field (99.4%) and two-field (88.0%)".** CONFIRMED FIXED 2026-08-01 — section now correctly credits OptiType.
- [x] **E7 — "HLAforest leads [Class II] at both resolutions".** CONFIRMED FIXED 2026-08-01 — section now correctly credits T1K (95.0%, followed by HLA-HD/HISAT-genotype).
- [x] **E-DUP — Duplicate paragraph, self-contradicting.** CONFIRMED FIXED 2026-08-01 (Nick deleted the old paragraph, re-verified by re-fetching the live doc): exactly one "Among Class I tools…" paragraph remains, with the corrected numbers. Closed out E4/E6/E7 as predicted.
- [x] **E8 — "Table S2a–c" citation was a wrong table number.** CONFIRMED FIXED 2026-08-01 — real table found: **Table S5** ("accuracy for (a) class I (b) class II (c) overall", matching a/b/c structure and per-tool-accuracy content exactly; Table S2 is unrelated, accession numbers only). Text now reads "Table S5a-c". **New finding surfaced while locating it (not yet its own E-item, flagging here):** Table S5 itself lists only 9 tools (OptiType, arcasHLA, RNA2HLA, HLAforest, seq2HLA, HLA-HD, PHLAT, HLA-VBseq, HLAminer) — missing T1K, HLApers, HISAT-genotype, which the rest of the manuscript treats as part of the 12-tool set. Table S5 is likely itself stale (pre-dates those 3 tools being added) — needs regenerating, separate from the citation fix.
- [x] **E9 — Tool-name capitalization/naming inconsistent document-wide.** CONFIRMED FIXED 2026-08-01, verified document-wide (not just audited paragraphs): arcasHLA 21/0 bare, HLAminer 23/0 "HLAMiner", HISAT-genotype 11 uniform (1 remaining bare "HISAT" is legitimate — inside a reference title quoting "HISAT2 and HISAT-genotype"). No substring-collision damage from the Find&Replace (checked for "arcasHLAHLA"/"HISAT-genotype-genotype" — zero occurrences).
- [x] **E-FIG34 (new, DONE 2026-08-01) — "Filtered bulk accuracy"/"Filtered bulk + no-call rate" figure rebuilt on current data.** This two-panel chart is embedded directly in the manuscript (confirmed: zero matches for its title text anywhere in this repo, current or archived) — likely the source of the "(Fig 3-4)" citation and probably where the stale E4/E6/E7 numbers originated. Rebuilt in `accuracy_fixed_executed.ipynb` using the exact canonical scoring functions from cell 7 (copied verbatim, not reimplemented) — sanity-checked against the already-published `results_summary.md` Table 1/Table 3/Table 6-7 before saving (max deviation 0.05pp). Saved: `Figures/fig3_4_filtered_bulk_accuracy_nocall.{png,svg}`. Kept `rna2hla` (original chart's tool set omitted it, 11 vs our 12).
- [x] **E10 — Read-length paragraph: "12 samples" is wrong.** CONFIRMED FIXED 2026-08-01 — text now reads "11 samples", matches `datasets/readlength_gs.csv` row count.
- [x] **E11 — Read-length paragraph: "seven tools" is wrong.** CONFIRMED FIXED 2026-08-01 — now reads "ten tools" (small unrelated typo: double space "ten  tools", cosmetic only). Residual (not blocking, not its own E-item): seq2hla and rna2hla still not individually named in the per-tool breakdown sentence, only folded into the mean.
- [x] **E12 — Read-length paragraph: HLAPERS claim wrong.** CONFIRMED FIXED 2026-08-01 — text now reads "HLAPERS accuracy rising to 37% at 76 bp before falling to zero at 101 bp and beyond". (First attempt left a stale trailing fragment from the old sentence — caught on re-check and cleaned up.)
- [x] **E13 — HLAMiner read-length data.** FIXED 2026-08-01 (pipeline/data fix, full detail in `KNOWN_BUGS.md`) — the 5 `hlaminer_*.csv` files were transposed, not corrupted; converted to standard layout, originals backed up. Real accuracy now computed: **30.0% (36bp), 8.3% (51bp), 28.6% (76bp), 25.0% (101bp), 20.0% (126bp)**. `Figures/fig8_readlength_accuracy.png` regenerated with HLAminer included. **Manuscript-text consequence: CONFIRMED FIXED 2026-08-01** — "HLAMiner never exceeding 10%" → "HLAminer's accuracy stays low and fluctuates across read lengths (8-30%)".
- [x] **E14 — Introduction cited "(Fig S1)" for the field/digit-resolution mapping.** CONFIRMED FIXED 2026-08-01 — text now reads "(Figure 2)". Turned out Fig S1 does exist (caption: "accuracy for each dataset individually", 6-panel per-dataset breakdown) but is on a completely unrelated topic — the original citation was a genuine wrong-figure-number error, not a stale/dangling reference as first guessed.
- [x] **E15 — Ancestry Results subsection ("All HLA callers have higher accuracy on European than African samples").** CONFIRMED FIXED 2026-08-01, all 5 sub-findings resolved: sample counts (n=423/67) were already correct; HLA-VBseq DQB1 gap "+33pp"→"+23pp"; phlat C-gap example "+34pp" (actual 3.9pp) replaced with T1K "+9.3pp"; "favor Yorùbá at C" corrected to "at A" with real examples (HLApers -17.5pp, arcasHLA -5.5pp, HLAforest -2.6pp); "all callers" softened to "nearly all callers" noting rna2hla/seq2hla exceptions at DQB1; SE-claim explanation ("low overall accuracy"→"mid-range accuracy") also fixed. One self-inflicted mid-edit deletion (lost the back half of the Class-II sentence) caught on re-check and restored. CPU/RAM and Discussion-opening findings filed as new E23/E24 below; remaining Results/Discussion subsections still open — see E20.
- [ ] **E16 — "SCRNAseq performance" subsection appears to be an unfinished placeholder** — heading present, no body text under it.
- [ ] **E17 — "Unmapped performance" subsection appears to be an unfinished placeholder** — heading present, no body text under it (adjacent to E16, same "Parameter optimization" block).
- [ ] **E18 — Table 1 (dataset overview, main Tables section) not yet cross-checked** against actual current accession/sample-count files for D1-D8. PARTIAL PROGRESS 2026-09-02: `accession/d{N}_list.txt` files use a DIFFERENT (older/stale) dataset numbering than `datasets/{N}_gs.csv` and `results/standard/*_d{N}.csv` (which agree with each other and are presumably what the manuscript's numbering follows). Confirmed by exact sample-ID and row-count matching (every accession_list line count matches exactly one gs.csv row count once correctly paired): current D1=`d2_list.txt` (490 samples), D2=`d3_list.txt` (86), D3=`d1_list.txt` (50), D4=`d4_list.txt` (14, unchanged), D5=`d6_list.txt` (8), D6=`d5_list.txt` (4), D7=`d7_list.txt` (20, unchanged), D8=local PacBio trio (3 samples, no accession_list file). Benchmark accuracy numbers are NOT affected (gs.csv and results/standard already agree with each other on the current numbering) — this only matters for (a) Table 1's stated per-dataset sample counts, which should read 490/86/50/14/8/4/20/3 for D1-D8 respectively if Table 1 currently cites the accession_list files' own (stale) counts instead, and (b) anyone re-downloading raw data via `accession/d{N}_list.txt` expecting it to match "D{N}" as used elsewhere in the repo. RESOLVED 2026-09-02 (Drive access restored): fetched live Table 1 and compared. **D1-D7 rows are all correct** — Table 1 states 490/86/50/14/8/4/20 for D1-D7, exactly matching the confirmed gs.csv-based numbers above; the accession_list mismatch is a repo-only issue (raw-download bookkeeping), doesn't touch the manuscript. **D8 row is wrong / internally inconsistent**: Table 1 states D8 = **10** samples ("Data generated in house... Whole blood... n=10"), but (a) `8_gs.csv` has genotypes for only **3** real samples (mother/father/daughter trio; the other 10 rows in that file are empty `sample_1`...`sample_10` placeholders with no data — a separate known issue, not the source of this "10"), and (b) the manuscript's own intro paragraph states "whole blood (n = 3)" for D8, directly contradicting Table 1's row. Next: Human PI / Serghei call — either Table 1's "10" should become "3" (matching what's actually genotyped and used), or if 10 in-house samples were genuinely planned/collected and only 3 are typed so far, the text needs to say so explicitly and Table 1 should reflect current (3) not target (10) sample count, consistent with how every other row reports actual n. Separately (repo housekeeping, not manuscript): consider renaming the `accession/` files to match current numbering to prevent future confusion. **DONE 2026-09-10:** `accession/d{N}_list.txt` renamed via `git mv` (3-cycle d1→d3→d2→d1 + d5↔d6 swap; d4/d7 unchanged), each now matches `datasets/{N}_gs.csv` on row count and sample-ID; `accession/README.md` added with the mapping + history; no live script affected (`align_dataset.sh` reads an external `/scratch1/rayyala/...` path, the `run_d7_*.sh` scripts only touch d7). Trail in `.claude/memory/KNOWN_BUGS.md`. The D8 Table-1 "n=10 vs n=3" inconsistency above still needs a Human PI / Serghei call — untouched.
- [ ] **E19 — D1-D8 vs D1-D6 scope references not yet swept for consistency document-wide** — given the already-fixed Figure 7 pooled-scope bug (D7/D8 previously pooled on unequal footing), other mentions of dataset scope outside Figure 7 have not been checked for the same class of error.
- [ ] **E20 — Discussion section, partially checked.** Opening paragraph checked 2026-08-01, see E23. "Consistent of Tool Performance..." subsection: spot-checked "OptiType remains the most accurate tool for Class I genotypes" — **confirmed still true** (98.2%/98.9% depending on table, max in both). Rest of that subsection, plus "Ancestral Bias in HLA Typing" and "Limitations and Considerations" subsections — not yet checked.
- [ ] **E22 (new) — HISAT-genotype and RNA2HLA compute-resource numbers in Discussion are accurate, no fix needed** — confirmed while investigating E24: HISAT-genotype "median ~35,000s CPU, ~7.5GB RAM" matches computed 33,997s/7.38GB almost exactly; RNA2HLA "~420s CPU, <0.4GB RAM, 93.3% accuracy" all close to computed (470s median, 0.10GB, ~92.7% Table 2 Overall). Logged so these aren't re-flagged by a future audit pass.
- [ ] **E23 (new) — Discussion opening paragraph has 2 stale/wrong numbers.** (1) "82.6% - 98.3% accuracy" Class I range mixes two different tables (82.6%=hlaforest Table 2 unfiltered, 98.3%=seq2HLA/HLApers Table 3 filtered) and is contradicted by HLApers' own unfiltered Class I (69.3%, below the stated floor, despite not being in the stated exclusion list). Fix: "92.5% - 98.9%" (Table 3, filtered, single consistent source). (2) "arcasHLA... consistently high accuracy of 93.4% for both Class I and Class II" — 93.4% doesn't match arcasHLA anywhere; it's HLA-HD's Table 2 Overall value, likely a tool mixup. Fix: "~92% for both Class I (92.2%) and Class II (92.5%)" (Table 2 unfiltered — these two are genuinely close to each other, preserving the sentence's "consistent" framing, unlike the filtered table's 98.4%/94.7%).
- [ ] **E24 (new) — "Computational resource variability" section: 3 of 5 profiled tools have CPU/RAM numbers that don't match any computed statistic (median/mean/min/max).** Recomputed from `results/cpu_ram/runtime_data - ALL_{CPU,RAM}_DATA.csv` (12 samples/tool). HLApers CPU: claimed "under 10 seconds", actual median 197s / mean 252s / **min 56s** (off by 5-25x under every statistic). arcasHLA CPU: claimed "~30 seconds", actual median 353s / mean 402s / min 160s (off by ~5-13x). OptiType: claimed "~2,700s CPU, ~14GB RAM" and grouped with HISAT-genotype as "each exceed 30,000s" — actual median 3,767s CPU (mean 8,609s; only occasional individual runs top 30,000s, unlike HISAT-genotype's consistent ~34,000s), median RAM 5.5GB (mean 8.1GB, peak 25.2GB — the peak alone matches the separately-stated "over 25GB" RAM claim). "Five orders of magnitude" CPU span is actually ~3 orders (56s-43,503s across all runs). HISAT-genotype and RNA2HLA numbers are fine (see E22). Suggested full-paragraph rewrite given in chat 2026-08-01, not yet applied.
- [ ] **E25 (new) — HUMAN-PI DECISION 2026-09-11: D8 is to be INCLUDED in the main analysis.** Decision made by Nick (Human PI) after this session's tooling work gave D8 real prediction files for the first time (11/12 tools now have `results/standard/{tool}_d8.csv`). Per `GOVERNANCE.md` Non-Negotiable #3 / the "Adding a dataset" Decision Authority row. **PARTIALLY DONE 2026-09-11** (Nick, "Тоже делай"): `notebooks/accuracy_fixed_executed.ipynb`'s `DISPLAY_SCOPE` extended to D1-D8 (D8 shown in Figure 7's per-dataset panels, `fig6c_ridge_v1/v2`, `phase_ambiguity_summary.csv`; `MAIN_SCOPE` deliberately kept at D1-D6, i.e. D8 is displayed not pooled into the top-20 ranking, mirroring D7's own 2026-07-24 carve-out); cell 57's stale "D8 contributes nothing" comment fixed; a `T1K_d8.csv` filename-case bug that would have silently dropped T1K from D8 fixed; full notebook re-executed and committed. **Still open:** `results_summary.md`'s "D7 = scRNA-seq... and D8 = ... — both excluded from main analysis" prose line (~line 253) still needs rewriting to match — this is manuscript text, not touched here. Also still open: D8's shallow-read-depth caveat (197k-238k read pairs/sample vs millions for D1-D7, from `notebooks/d8_trio_accuracy.ipynb`) should be stated wherever D8 is now cited; and E19's broader D1-D8-vs-D1-D6 scope sweep, which overlaps this. Full trail: `.claude/memory/KNOWN_BUGS.md`, entry "HUMAN-PI DECISION 2026-09-11: D8 IS TO BE INCLUDED...".
- [x] **E21 — Table S5 (per-tool accuracy, Class I/II/Overall) was stale, missing 3 of 12 tools, AND its own a/b/c label order didn't match its content.** CONFIRMED FIXED 2026-08-01, two parts: (1) **label mismatch** — physical sub-tables A/B were swapped relative to the "(a) class I (b) class II" caption (proven two independent ways: OptiType, a genuine Class-I-only tool, scored 0/0/0 in "A" and 98.3% two-field in "B"; HLA-VBseq scored 92.6% inaccurate in "A", the exact signature of the pre-2026-07-15 DRB1/DQB1 column-swap bug, which was a Class-II-specific defect) — fixed by physically swapping the two sub-tables (not the caption) so A=Class I, B=Class II again. (2) **stale data** — all three sub-tables (a/b/c) recomputed on current pipeline (D1-D6, all fixes applied) with all 12 tools (added T1K, HLApers, HISAT-genotype); every row verified to sum to 1.0 (%inaccurate + %one-field + %two-field). Re-fetched live doc and confirmed all 36 values (12 tools x 3 metrics) landed correctly in all three sub-tables.

---

## Resolved (pipeline/investigative — no manuscript text pending)

- [x] **Novel-allele definition** — cohort-based (not IMGT-DB-based); confirmed via `gs_set` vs `valid_set` logic.
- [x] **HLA-VBSeq column-swap bug (pipeline)** — DRB1/DQB1 swapped in `hlavbseq_d1.csv`; fixed 2026-07-15. (Manuscript prose still not updated — see E4.)
- [x] **CLASS_I_ONLY_TOOLS bug** — `accuracy.ipynb` incorrectly listed `hlavbseq` as Class I-only; fixed.
- [x] **Over-calling investigation** — 3 tools can return >2 alleles/locus (HISAT-genotype, HLAminer, HLApers), each with its own native ranking score; top-2-by-score fallback always applicable.
- [x] **Allele count update** (2026-07-21) — "over 25,000" → "over 43,000" IPD-IMGT/HLA alleles, cited to Barker et al. 2026. Residual: reference-list reorder (folded into "Systematize citations"), title needs literature-surveillance confirmation.
- [x] **Clinical-matching-standard citations** (2026-07-21) — NMDP (US 8/8) and EBMT (EU 10/10) refs added to P184. UNOS/UC Davis/Merck Manual candidates deliberately not used (wrong context or non-authoritative).
- [x] **Per-locus unfiltered accuracy table** (2026-07-25) — published as `results_summary.md` Table 5; see E2 for the corresponding manuscript-prose update still pending.
- [x] **Dataset 8 gold standard, manuscript n** — unblocked: Serghei's ISMB slide 12 independently confirms D8 = n=3 (trio only); no longer needs a direct ask to Ram. Not yet applied to manuscript text.
