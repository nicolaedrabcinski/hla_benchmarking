# Figure 7 supplement (redesigned): per-dataset independent top-N miscalled alleles

**Author:** `hla-benchmark-scientist` · **Date:** 2026-07-22
**Script:** `notebooks/fig7_per_dataset_top_alleles.py`
**Figure:** `Figures/miscalled_alleles_top_per_dataset.png` (+ `.svg`)
**Tables:** `results/allele_miscall_top_per_dataset_own_ranking.csv`,
`results/allele_miscall_recurring_across_own_topN.csv`

> **STATUS: NOT YET REVIEWED.** No number in this note may enter the manuscript,
> a caption or a figure before `statistics-reviewer` sign-off. A re-derivation
> request is already in flight as a separate task.

---

## 1. What this figure is, and how it differs from the earlier heatmap

Nick's review of the first supplementary version
(`Figures/fig7_supp_a_heatmap.png`) was that the heatmap is too
dense and too unfamiliar a chart type. It was also structurally sparse, and for a
reason worth stating: it took the **pooled** top-20 ranking and re-sliced it by
dataset, but most pooled-top alleles occur in only one cohort's gold standard, so
most cells were "not present" hatching rather than data.

The redesign keeps the original Figure 7's chart grammar — a horizontal bar
chart of the top-N alleles by misclassification rate, sorted descending, bars
coloured by locus from the notebook's `palette` dict, x-axis "% of calls
mispredicted", allele names on y — and simply **repeats it once per dataset**,
as a small-multiples grid. Crucially the aggregation is different, not just the
layout: **each panel is that dataset's own independent ranking**, computed from
that dataset's own samples and predictions alone. The old heatmap and allele-wise
bar files are retained unchanged as an alternate supplementary view.

**The scoring contract is untouched.** Per-(Dataset, Locus, Allele) `Total`/`Mis`
tallies are read verbatim from `results/allele_miscall_by_dataset.csv`
(resolution = 2, `filter_option = True`, canonical `reformat_allele` / `gs_set` /
`pred_set` / hit logic), whose per-dataset decomposition is already asserted to
sum exactly back to the verbatim pooled Figure-7 aggregator. This script only
re-ranks and re-plots. It re-checks on load that
`MisclassificationRate% == 100 × Mis / Total` for every row, so a stale or
hand-edited tally cannot silently reach a figure.

## 2. Choice of N per dataset

The original pooled figure used N = 20. Four datasets cannot support 20
categories, so N is set by data volume rather than by convention:

    N(dataset) = min(20, number of alleles with ≥ 6 evaluable tool×sample calls)

| Dataset | Rankable alleles | N shown | Loci in gold standard | Note |
|---|---|---|---|---|
| D1 | 278 | 20 | A, B, C, DRB1, DQB1 | selective (20 of 278) |
| D2 | 11 | **11** | DRB1 only | **entire pool shown** |
| D3 | 54 | 20 | A, B, C | selective (20 of 54) |
| D4 | 8 | **8** | DRB1 only | **entire pool shown** |
| D5 | 2 | **2** | C only | **entire pool shown** |
| D6 | 4 | **4** | A, B | **entire pool shown** |
| D7 * | 41 (of 86) | 20 | all five | reduced coverage, 6/12 tools |

The ≥6-call floor is inherited unchanged from the first version. In D1–D6 it is
inert (the smallest observed denominator is already 12 = 1 sample × 12 tools);
it binds only in D7, where 6-tool coverage and 1–2-sample alleles give
denominators as low as 3, and where it removes 45 of 86 alleles that would
otherwise fill the panel with nominal 100% bars resting on 3–5 calls. Every bar
is annotated with its raw `miscalled/evaluable` denominator so that a 100%-on-12
bar can never be read as equivalent to a 57%-on-84 bar. D7 is drawn inside a
dashed amber frame and labelled "OUTSIDE D1–D6 MAIN SCOPE"; it is shown for
transparency and excluded from every statement below unless explicitly flagged.

## 3. Do the same alleles recur across datasets' own top-N lists?

This is the universal-vs-dataset-specific question, and the figure now makes it
visually checkable: scan the panels for a repeated allele label.

Raw counts over D1–D6: the union of the six own-top-N lists is **54 distinct
alleles**; **34** are rankable in ≥2 datasets (i.e. could recur at all); **11**
actually appear in ≥2 datasets' own top-N lists. Taken at face value that is
11/34 ≈ 32% recurrence — **and that face value is misleading in a way that must
not be reported without the qualification below.**

**The dominant constraint is opportunity, not difficulty.** The six cohorts
barely share allele repertoires, and in several cases barely share *loci*: D2 and
D4 are DRB1-only, D5 is C-only, D6 is A/B-only, D3 is Class I-only. Whole panels
are therefore non-comparable by construction — D2 vs D3, D2 vs D5, D3 vs D4 and
D4 vs D6 share **zero** rankable alleles, so their top-N lists could not overlap
under any tool behaviour whatsoever.

**The second constraint is selectivity.** In D2, D4, D5 and D6, N equals the
*entire* rankable pool. For those panels "in the top-N" carries no information
beyond "present and evaluable" — it is not a selection. All 5 alleles shared
between D2 and D4 are shared trivially for this reason. Only **D1 (20 of 278)**
and **D3 (20 of 54)** have genuinely selective top-N lists.

Applying both filters gives the honest result:

> **Between the only two datasets whose top-N lists are genuine selections
> (D1 and D3), the overlap is zero — 0 shared alleles out of 50 that are
> rankable in both.** Every one of the 11 "recurring" alleles involves at least
> one non-selective panel.

**Where an allele *is* comparable, the dataset effect dominates the allele
effect.** The recurring alleles are not stably hard; their rates move by a factor
of two to three across cohorts:

| Allele | D1 | D2 | D4 | D3 | D6 |
|---|---|---|---|---|---|
| DRB1\*14:01 | 25.6% (83/324) | 35.0% (21/60) | **77.3% (17/22)** | – | – |
| DRB1\*03:01 | 24.5% (300/1224) | 27.6% (165/598) | **71.2% (47/66)** | – | – |
| DRB1\*01:01 | 24.4% (264/1080) | 29.4% (53/180) | **64.7% (44/68)** | – | – |
| DRB1\*15:01 | 24.5% (335/1368) | 26.4% (57/216) | **56.5% (26/46)** | – | – |
| DRB1\*11:04 | 27.1% (78/288) | – | **56.5% (13/23)** | – | – |
| B\*51:01 | 10.4% (70/672) | – | – | 28.3% (17/60) | 8.3% (1/12) |

DRB1\*14:01 is rank 1 in D4 (17/22 calls missed) but does not enter D1's top-20
at all, despite D1 carrying roughly fifteen times as many evaluable calls for it
(324 vs 22). The ordering of D4's panel is essentially
D4's overall Class II difficulty showing through, not a property of those
particular alleles.

**Conclusion.** The per-dataset rankings are **dataset-specific, not universal**.
No allele is independently identified as most-miscalled by two datasets that were
both in a position to make a genuine selection. This is consistent with, and
strengthens, the earlier heatmap analysis's finding that no allele is elevated in
≥3 datasets. It should be read as a statement about **cohort design** — six
cohorts with near-disjoint allele repertoires and unequal locus coverage cannot
demonstrate universality — and **not** as evidence that no universally hard
alleles exist. The design simply has no power to detect them.

**Note for `scientific-writer`:** any Discussion sentence framing specific
alleles as intrinsically "hard to call" across the benchmark is unsupported by
this analysis. The supportable claim is at **locus** level (Class II, especially
DRB1 and DQB1, is consistently worse across every cohort that contains it),
which is visible directly in the figure as the orange/purple bars occupying the
top of the D1, D2 and D4 panels.

*Sensitivity, D7 (excluded from the above):* 10 of D7's 20 top alleles also
appear in some D1–D6 own-top-N list (B\*35:01, B\*44:02, B\*44:03, C\*05:01,
C\*07:01, C\*12:03, C\*16:01, DQB1\*02:01, DRB1\*04:01, DRB1\*08:04). This does
not change the conclusion: D7 runs 6 of 12 tools on 1–7 samples per allele, so
its ranking is not comparable to the 12-tool panels and is reported for
transparency only.

## 4. Carried-over caveats (unchanged, still open)

These are properties of the underlying tally, documented in
`.claude/memory/KNOWN_BUGS.md`, and they apply to this figure exactly as they
applied to the heatmap:

1. **Per-allele rate is a per-sample-locus miss attributed to every true allele
   at that locus** — a panel bar is "fraction of calls at this locus, in samples
   carrying this allele, that missed the locus entirely", not "fraction of times
   this specific allele was got wrong". Contract deliberately unchanged.
2. **Malformed gold-standard tokens** `B*55:xx` and `A*68:xx` in
   `datasets/3_gs.csv` are scored as real alleles and are visible in the D3
   panel. No tool can emit `xx`, so they are guaranteed misses.
3. **Ties** are broken deterministically (rate desc, `Total` desc, allele asc);
   in the small panels many alleles share a denominator, so the *within-panel
   order* among equal rates is a convention, not a result.
