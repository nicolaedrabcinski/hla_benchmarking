# Caption draft — Supplementary Figure: per-dataset/per-allele miscall analysis (5 panels)

**Prepared by:** `figure-designer`, 2026-07-22, for `scientific-writer`.

> **DO NOT PUBLISH THIS CAPTION, OR ANY NUMBER IN IT, YET.**
> All five panels are built from `results/allele_miscall_by_dataset.csv` and its
> derived tables. Per `.claude/memory/KNOWN_BUGS.md`, this data has **not**
> received a fresh `statistics-reviewer` sign-off since the HLApers DRB1/DQB1
> column-swap fix — the prior sign-off was on pre-fix data and does not carry
> over. Three further, independent blockers from that reviewer also remain
> open: malformed gold-standard tokens (`B*55:xx`, `A*68:xx`, visible in
> panels a/c/d/e), `MisclassificationRate%` conflating no-calls with genuine
> miscalls, and small effective sample sizes (17 of the 20 pooled top alleles
> rest on ≤7 distinct biological samples). This draft is provided so
> `scientific-writer` has wording ready the moment clearance lands — it is
> not itself a clearance signal, and every number below must be re-verified
> against whatever table is current at that time before use.

---

## Suggested caption

**Supplementary Figure S[X]. Dataset- and allele-level breakdown of
HLA-calling misclassification, five complementary views of the same
underlying tally.**
All panels use 2-field (two-field) resolution, novel-allele-filtered calls,
pooled across the project's 12 benchmarked tools, and are derived from the
per-(dataset, locus, allele) misclassification tally described in Methods
(the same scoring contract as the main-text allele-miscall figure, extended
with a dataset dimension; verified to sum back to the pooled figure exactly).
D7 (family trio, scRNA-seq, 6 of 12 tools) is shown separately from the D1–D6
main-analysis scope throughout and is excluded from all cross-dataset claims
unless explicitly noted.

**(a)** Heatmap of the pooled top-20 most-frequently-miscalled alleles' rate
(% of calls mispredicted) by dataset. Grey hatching marks alleles absent from
a given dataset's gold standard; pale grey marks alleles present but with
fewer than 6 evaluable tool × sample calls (rate not scored); all other cells
are coloured by rate (white→dark red) with the value printed. Right-hand
column gives each allele's cross-dataset classification (elevated-rate count
/ datasets present, threshold >30%, D1–D6 only).

**(b)** The same pooled top-20 alleles' per-dataset rates, redrawn as one
small bar-chart panel per allele (bars = datasets, coloured by locus), for
readers who find the small-multiples layout easier to scan than the heatmap.

**(c)** The same chart grammar as the project's main-text allele-miscall
figure (horizontal bars, sorted descending, coloured by locus), but repeated
once per dataset, where **each panel's ranking is computed independently
from that dataset's own samples and predictions** rather than being a
re-slice of the pooled top-20 in (a)/(b). N per panel = min(20, alleles with
≥6 evaluable calls in that dataset), so panel size varies with each cohort's
own allele repertoire (D1/D3: 20; D2: 11; D4: 8; D6: 4; D5: 2). Every bar is
annotated with its raw miscalled/evaluable-call count so that, e.g., a 100%
bar resting on 3 calls is never visually equated with a 57% bar resting on 84.

**(d)** The pooled top-20 alleles again, as horizontal grouped bars — one
cluster per allele, one sub-bar per dataset in which the allele is scorable,
coloured by an ordinal dataset ramp (D1 lightest→D7 darkest); a dashed tick
per row marks the single pooled rate shown in the main-text figure, so panels
(a)/(b)/(d) can be cross-checked against it directly.

**(e)** The pooled top-20 alleles as a slope/dot plot (x = dataset, y = % of
calls mispredicted, coloured by locus, alleles direct-labelled). A line
segment is drawn only between two adjacent, both-scored datasets — gaps
(datasets where an allele is absent or under-powered) are never interpolated
through. Isolated points indicate an allele scorable in only one dataset, or
in non-adjacent datasets with no connecting claim possible.

**Interpretation (pending final sign-off; qualitative direction only).**
Across all five views, no allele in this cohort is elevated (>30% miscalled)
in three or more datasets — the "universal hard-to-call allele" category is
empty. Where an allele is scorable in more than one dataset, the between-
dataset spread in its rate is generally larger than any within-dataset
allele-to-allele spread, indicating the dominant source of variation is
cohort/dataset composition rather than an intrinsic property of the allele.
The only pattern that recurs consistently across panels and datasets is at
the **locus** level: Class II alleles (DRB1, DQB1) are disproportionately
represented among the highest-rate alleles in every dataset that includes
them. This should be read as a statement about the limited, largely
non-overlapping allele repertoires of the six cohorts (locus coverage alone
differs sharply: D2/D4 are DRB1-only, D5 is C-only, D6 is A/B-only, D3 is
Class-I-only) rather than as evidence against the existence of universally
hard-to-call alleles — the cohort design has limited power to detect them.

**Caveats (must remain in the final caption or accompanying text).**
(1) A "% misclassified" value for a given allele is the fraction of
sample-locus evaluations *containing* that allele in which no predicted
allele matched the sample's true genotype at that locus — not the fraction of
times that specific allele itself was called incorrectly (see Methods). (2)
Two gold-standard tokens visible in these panels (`B*55:xx`, `A*68:xx`, both
in dataset D3) are malformed and unmatchable by any tool by construction;
their rates are structurally inflated and pending correction from data
curation. (3) Effective sample sizes behind several headline alleles are
small (as low as a single biological sample); denominators are always
reported alongside rates in panels (c)–(e) for this reason. (4) D7 is shown
for transparency only (dashed/asterisked throughout) and is excluded from the
"no universal allele" and locus-level claims because it runs only 6 of the
project's 12 tools.

---

## Per-panel one-line captions (if the journal requires panels split out)

- **(a)** Pooled top-20 miscalled-allele rate by dataset, heatmap view.
- **(b)** Pooled top-20 miscalled-allele rate by dataset, per-allele
  small-multiples view.
- **(c)** Top miscalled alleles ranked independently within each dataset
  (small multiples; D7 shown separately, outside main scope).
- **(d)** Pooled top-20 miscalled-allele rate by dataset, grouped-bar view
  with pooled-rate reference ticks.
- **(e)** Pooled top-20 miscalled-allele rate across datasets, slope/dot view
  (adjacent-dataset segments only).

## Notes for `scientific-writer`

- Panel lettering is fixed a→e as defined in
  `Figures/miscalled_alleles_family_README.md`; please don't relabel without
  routing back through `figure-designer` first (a/e are load-bearing in the
  file-level `add_panel_label()` calls and the README's mapping table).
- If space is limited and the journal wants fewer than five panels, (a)/(b)
  and (d)/(e) are two redundant pairs of chart-grammar for the *same* pooled
  ranking — (c) is the only panel showing a structurally different
  (per-dataset-independent) ranking. Any subsetting decision is a "what the
  figure visually claims" change and needs the same sign-off chain as the
  underlying claim (`scientific-writer` + `statistics-reviewer` review,
  `scientific-coordinator` approval) — not a routine `figure-designer` call.
- None of these five panels touch the ancestry finding, so no
  `clinical-and-equity-reviewer` scope-caveat routing is needed for this
  family specifically.
