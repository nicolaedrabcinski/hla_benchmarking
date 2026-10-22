
# HLA RNA-seq Benchmark

Benchmarking of 12 HLA genotyping tools on RNA-seq data across 8 datasets
(public cohorts and an in-house PacBio-validated trio), covering Class I
(A, B, C) and Class II (DRB1, DQB1) loci at 1- and 2-field resolution.

Accompanies a manuscript in preparation (Jagiellonian University).
Results and figures are reproduced here for methodology transparency;
headline findings are reported in the manuscript.

## Tools evaluated

arcasHLA, OptiType, seq2HLA, HLAminer, PHLAT, HLA-VBSeq, HLA-HD,
HISAT-genotype, HLAforest, HLApers, T1K, RNA2HLA.

## Repository layout

| Directory | Contents |
|---|---|
| `scripts/notebooks/accuracy.ipynb` | Main analysis: scoring, all figures, end-to-end reproducible |
| `data/gold_standard/` | Gold-standard genotypes (`*_gs.csv`) |
| `data/input/` | Accession lists and gold-standard provenance (`archive/`, see its own README) |
| `data/interim/` | Per-tool, per-dataset standardized predictions (`standard/`) and the read-length, unmapped-reads and CPU/RAM experiments |
| `data/final/` | Tables written by the notebook: the numbers behind the figures |
| `figures/` | Generated figures (main + supplementary) |
| `scripts/` | Caller runs (`pipeline/`), standardization scripts, per-tool conda environments |
| `docs/` | Presentations, manuscript drafts, detailed layout |

Raw sequencing data (`data/input/raw/`), aligner indices, and tool
installations are not tracked here (regenerable from `scripts/pipeline/*.sh`
+ public accessions); see "Installing the HLA callers" below and
`scripts/environments/`.

## Installing the HLA callers

Each tool runs in its own conda/mamba environment. Recreate one with:

```bash
mamba env create -f scripts/environments/<tool>.yml
```

(`scripts/environments/environments.txt` lists every exported
environment name.) The environment gives each tool's runtime dependencies;
the tool's own code is not bundled in this repo and has to be obtained
separately:

| Tool | Source |
|---|---|
| arcasHLA | `github.com/RabadanLab/arcasHLA` |
| HLAminer | `github.com/bcgsc/HLAminer` |
| HLApers | `github.com/genevol-usp/HLApers` |
| RNA2HLA | `github.com/Chelysheva/RNA2HLA` |
| HISAT-genotype | `github.com/DaehwanKimLab/hisat-genotype` |
| HLAforest | `github.com/FNaveed786/hlaforest` |
| T1K | installed directly into its conda environment via bioconda (`t1k` package) |

OptiType, seq2HLA, PHLAT, HLA-HD, and HLA-VBSeq are obtained from their own
publishers rather than a plain `git clone` (OptiType and seq2HLA from
their own GitHub repos; PHLAT, HLA-HD, and HLA-VBSeq from their academic
publishers' own pages, some of which are registration-gated) -- see each
tool's own documentation for the current download location.

## Reproducing the analysis

```bash
uv sync
uv run jupyter nbconvert --to notebook --execute scripts/notebooks/accuracy.ipynb
```

## Data sources

D1–D6: public bulk/scRNA-seq cohorts (Geuvadis, GEUVADIS-derived, etc.) with
PCR-based gold-standard typing. D7: public 3′ scRNA-seq (BMMCs). D8: in-house
whole-blood trio, PacBio HiFi WGS → hifiasm → Immuannot gold standard.

## License

MIT (see `LICENSE`). Copyright © Nicolae Drabcinski.

## Contact

Nicolae Drabcinski — nicolae.drabcinski@doctoral.uj.edu.pl
Anna Garbarz — anna.garbarz@doctoral.uj.edu.pl
Małopolska Centre of Biotechnology, Jagiellonian University
