# Figure 7 per-dataset breakdown — methods note and interpretation

*Produced by `hla-benchmark-scientist`, 2026-07-22, in response to Serghei's Word
comment #64 / `BACKLOG.md` category-A item "Split allele novelty analysis per
dataset".*

**Status: NOT yet reviewed.** These numbers have not been through
`statistics-reviewer` re-derivation and must not be placed in the manuscript,
a figure, or a slide until they have. Two items below are flagged for
`scientific-coordinator` / Human PI.

---

## What was produced

| Artefact | Path |
|---|---|
| Re-runnable analysis script | `notebooks/fig7_per_dataset_miscall.py` |
| Heatmap (allele × dataset) | `Figures/fig7_supp_a_heatmap.png` |
| Small-multiple bar charts | `Figures/fig7_supp_b_small_multiples.png` |
| Full per-(Dataset, Locus, Allele) tally | `results/allele_miscall_by_dataset.csv` |
| Top-20 × dataset breakdown | `results/allele_miscall_top20_by_dataset.csv` |
| Top-20 universal/dataset-specific classification | `results/allele_miscall_top20_classification.csv` |

Re-run with `python notebooks/fig7_per_dataset_miscall.py` (no arguments; paths
resolve relative to the script).

## Scoring contract: unchanged

The per-dataset tally is the Figure-7 aggregator from
`notebooks/accuracy_fixed_executed.ipynb` cell 41 with **exactly one change** —
the tally key gains a `Dataset` dimension. Reformatting/resolution, `gs_set` and
`pred_set` construction, monoallelic duplication, the cohort-based novel-allele
filter and the hit/miss rule are all byte-for-byte identical. Parameters as
specified: `resolution=2`, `filter_option=True`.

This is deliberately **not** a second implementation of the scoring contract. The
script carries the verbatim pooled function alongside the extended one and
**asserts on every run** that summing the per-dataset table over `Dataset`
reproduces the pooled function's `Total` and `Mis` exactly. Current run:

```
PASS — 284 (Locus, Allele) keys agree exactly on Total and Mis.
```

If that assertion ever fails, the extension has drifted from the canonical
contract and the outputs are void. (Longer term this duplication should be
removed by promoting the aggregator into the canonical scoring module rather than
copying it a fifth time; logged as a follow-up, not done here.)

---

## Scope decision (task item 4) — flagged, not silently resolved

The existing Figure 7 passes `datasets = list(range(1,9))`, i.e. D1–D8, whereas
`results_summary.md` (line 224) scopes the main analysis to D1–D6, with "D7 =
family trio, D8 = WGS/long-read — excluded from main analysis".

**What the data actually shows** (script section `[1]`):

| Dataset | Gold standard | Tools with prediction files |
|---|---|---|
| D1–D6 | yes | 12 / 12 |
| D7 | yes | **6 / 12** |
| D8 | yes | **0 / 12** |

Three findings that should be recorded regardless of which convention is adopted:

1. **D8 contributes nothing to the existing Figure 7.** There are no
   `*_d8.csv` files under `results/standard/`, so the `except FileNotFoundError:
   continue` branch skips it silently. `range(1,9)` therefore *reads* as D1–D8
   but *computes* D1–D7. Any caption or Methods sentence claiming Figure 7 covers
   eight datasets would be wrong.
2. **D7 is included on an unequal footing** — 6 of 12 tools. Pooling it with
   D1–D6 mixes a 12-tool denominator with a 6-tool denominator.
3. **D7 materially changes the ranking.** Recomputing the top-20 on D1–D6 only
   shares just **13 of 20** alleles with the D1–D8 top-20. Seven of the twenty
   currently-plotted alleles owe their position partly or wholly to D7.

**Decision taken: option (b) — the classification is computed on D1–D6**, the
project's main-analysis convention, so this supplementary figure is directly
comparable with `results_summary.md`, Tables 1–4 and the per-locus figures.
**However, D7 is still drawn**, as a column to the right of a dashed rule, marked
`D7 *` and excluded from the classification. Dropping it entirely would have
hidden the fact that D7 supplies the single largest miscall signals in the
current pooled figure (B\*15:16 100%, DRB1\*08:04 100%, C\*18:02 80%) — that is a
finding, not noise to be suppressed. Both classifications (D1–D6 primary, D1–D7
sensitivity) are in `allele_miscall_top20_classification.csv`.

**FLAG for `scientific-coordinator` → Human PI:** whether the *main* Figure 7
itself should be re-scoped to D1–D6 is a change to a previously-reported figure
and therefore not mine to make unilaterally. If it is re-scoped, 7 of the 20
plotted alleles change and the figure's headline allele changes from B\*82:01
(which exists **only** in D7) to a D1/D2/D3 allele. Per the operating
instructions this is a "would silently alter a previously-reported number"
situation and is being escalated rather than applied.

---

## Classification rule (task item 3) — stated explicitly

Applied to the 20 alleles of the current pooled Figure 7, over D1–D6:

- **elevated in a dataset** = misclassification rate **> 30 %** in that dataset,
  computed only where the allele has **≥ 6 evaluable calls** (tool × sample). Six
  is one half of the 12-tool panel, i.e. the allele must occur in at least one
  sample scored by a reasonable share of tools; below that a "rate" is one or two
  events and not interpretable.
- **universal** = elevated in **≥ 3** datasets where present.
- **dataset-specific** = elevated in **exactly 1** dataset, and present in **≥ 2**.
- **partially shared** = elevated in exactly 2.
- **not assessable (single dataset)** = present in only **one** D1–D6 gold
  standard, so universality is undefined — this is a real, common outcome here
  and is reported as its own category rather than being forced into either bin.

Crucially, "**not present in this dataset's gold standard**" is derived from the
gold-standard files alone (`build_gs_presence`), independently of any tool
output, and is rendered as a hatched grey cell — never as 0 %. A third state,
"present but < 6 evaluable calls", is rendered near-white and labelled `n<6`. The
three states are visually distinct in both figures.

---

## Results

### The top-20 list is not a stable ranking

**20 alleles tie at or above the 20th-place rate (29.2 %).** The notebook's
`nlargest(20, ...)` therefore returns an arbitrary tie-broken sample of a larger
set, and the identity of the bottom half of Figure 7 is not reproducible across
pandas versions. This script uses a deterministic tie-break (rate desc, then
`Total` desc, then allele name asc) and reports the tie count. *This is a
property of the existing figure, not something introduced here.*

### 17 of 20 top-miscalled alleles occur in only one dataset

| Classification (D1–D6) | n |
|---|---|
| not assessable (single dataset) | **17** |
| dataset-specific | 2 |
| partially shared | 1 |
| **universal** | **0** |

Per-dataset rates for the three multi-dataset alleles:

| Allele | D1 | D2 | D4 | Classification |
|---|---|---|---|---|
| DRB1\*04:08 | 25 % (n=48) | **39 %** (n=36) | — | dataset-specific |
| DRB1\*14:01 | 26 % (n=324) | **35 %** (n=60) | **77 %** (n=22) | partially shared |
| DRB1\*11:04 | 27 % (n=288) | — | **57 %** (n=23) | dataset-specific |

### No universal allele exists anywhere in the table, not just in the top 20

Extending the test to all 283 (Locus, Allele) keys scorable in D1–D6:

- 219 are scorable in exactly **1** dataset
- 54 in **2**
- 10 in **3**
- 0 in 4, 5 or 6
- **0 alleles are elevated (> 30 %) in ≥ 3 datasets.**

The "universal" category is therefore **empty by cohort design**, not by
biology — the six cohorts barely share allele repertoires, so there is almost no
opportunity to observe the same allele failing repeatedly across datasets. That
limitation must be stated wherever this analysis is reported.

### Where the signal sits

- **19 of 20** top alleles draw their D1–D6 signal from **D1 (n=490)** or
  **D3 (n=50)**; D2 and D4 add a second data point for three alleles.
- **D5 (n=8) and D6 (n=4) contain none of the top-20 alleles at all** — they are
  too small to contribute to this analysis.
- **15 of 20** are Class II (12 DRB1, 3 DQB1), consistent with the Class II
  accuracy deficit already in Tables 1–4.

---

## Interpretation (task item 6)

Misclassification in this benchmark is **not** driven by a set of universally
hard-to-call alleles: across all 283 alleles scorable in D1–D6 there is not a
single allele that is miscalled at > 30 % in three or more datasets, and 17 of
the 20 alleles in the current Figure 7 appear in only one dataset's gold standard
at all. The pooled top-20 is therefore best read as a list of **rare alleles
observed in one cohort**, in which a handful of missed samples produces an
extreme rate — nearly all of it coming from D1 (n=490) and D3 (n=50), while
D5 (n=8) and D6 (n=4) contribute no top-20 allele whatsoever. Where the same
allele *can* be compared across datasets, the dataset effect visibly dominates
the allele effect: DRB1\*14:01 is miscalled at 26 % in D1, 35 % in D2 and 77 % in
D4, and DRB1\*11:04 at 27 % in D1 versus 57 % in D4 — the same allele, the same
tools, three-fold different rates. This is the signature of dataset-level
properties (gold-standard typing resolution and ambiguity, cohort size, sequencing
protocol) rather than of intrinsic allele difficulty, and it is reinforced by the
D7 comparison, where the six tools run on scRNA-seq miss B\*15:16 and DRB1\*08:04
in 100 % of calls while the same alleles are missed in only 8 % and 33 % of D1
calls. The one robust, genuinely cross-dataset pattern is at the **locus**, not
the allele, level: 15 of the 20 worst alleles are Class II (12 DRB1, 3 DQB1),
matching the Class II deficit already reported in Tables 1–4. **The honest
conclusion is that the current design cannot answer the universal-versus-specific
question at allele resolution** — the six cohorts share too little allele
repertoire for any allele to be observed failing in three or more of them — and
the supplementary figure should be presented as showing precisely that, i.e. that
the pooled Figure 7 ranking is dominated by single-cohort rare alleles and should
not be read as a list of "hard alleles" generalising beyond the cohort each was
observed in.

---

## Two defects surfaced by this analysis

Both logged in `.claude/memory/KNOWN_BUGS.md`; neither is fixed here.

1. **`B*55:xx` is a malformed gold-standard token** in `datasets/3_gs.csv`. It
   survives `reformat_allele` unchanged and is scored as a real allele, appearing
   in Figure 7 at 50 % miscalled. No tool can ever match `xx`.
2. **Per-allele rates are attributed from a per-sample-locus hit.** The tally
   credits a miss to *every* true allele in `gs_set` whenever the sample's
   `pred_set` fails to intersect it, so an allele's rate is really "the rate at
   which sample-loci carrying this allele were missed entirely", including misses
   attributable to the partner allele. This is the existing contract and is
   **not** changed here, but the Methods wording must describe the quantity
   actually computed. Any change is a scoring-contract change requiring
   `devils-advocate` review and Human PI sign-off.

## Recommended next steps

1. `statistics-reviewer` — independent re-derivation of the per-dataset tally and
   of the 0-universal-alleles result before any of it is used.
2. `scientific-coordinator` / Human PI — the Figure 7 scope question above.
3. `devils-advocate` — is a 30 % / ≥3-dataset rule the right cut, given that no
   allele reaches ≥3 datasets? An alternative framing (report per-locus,
   per-dataset rates instead of per-allele) may be the more defensible figure.
