# Docs

Presentations, manuscript drafts and figure legends live here.

## Repository layout

```
docs/                     presentations, manuscript drafts, figure legends
data/
  gold_standard/          {1..8}_gs.csv, readlength_gs.csv: lab HLA typing per dataset
  input/
    accessions/           SRA/ENA run lists per dataset
    archive/              original gold-standard files, SraRunTable metadata, D8 PacBio annotations
    raw/                  sequencing data, indices, raw caller outputs (not in git, except run logs)
  interim/
    standard/             standardized calls, one CSV per tool x dataset ({tool}_d{n}.csv)
    read_length/          read-length experiment calls
    unmapped/             unmapped-reads experiment calls
    cpu_ram/              runtime and memory measurements
  final/                  tables written by the notebook; the numbers behind the figures
scripts/
  pipeline/               download, alignment and caller runs (bash)
  standardization/        convert each caller's native output to data/interim/standard
  environments/           conda environments for the 12 callers
  notebooks/
    accuracy.ipynb        scoring, statistics, all figures and data/final tables
figures/                  Figure{N} composites and single panels (pdf/svg/png)
```

Run the notebook from `scripts/notebooks/`; all paths in it are relative to that folder.
