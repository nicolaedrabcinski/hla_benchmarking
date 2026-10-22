# Archive

Pre-processing provenance for the `datasets/{N}_gs.csv` gold standards, plus
one file that is a live pipeline dependency (not archival at all):

| file | status | what it is |
|---|---|---|
| `SraRunTableD1.txt` | **live dependency** | Run-to-BioSample mapping for D1, used by `notebooks/accuracy.ipynb`, `notebooks/R_plots/accuracy_figures.R`, `plot_fig8_13.R`, and `verification/recompute/section_*.py` for individual-level bootstrap CIs. Do not move or delete. |
| `2_gs.csv`, `2_gs_edited.csv`, `2_gs.xlsx` | provenance | Raw SRA run-table export (all metadata columns) and the manually-edited intermediate, before `gs_d1_convert.ipynb` reduced it to the clean `datasets/2_gs.csv`. |
| `3_gs.csv` | provenance | Raw intermediate consumed by `gs_d2_convert.ipynb` to produce `datasets/3_gs.csv`. |
| `4_gs.csv` | provenance | Raw intermediate consumed by `gs_d4_convert.ipynb` to produce `datasets/4_gs.csv`. |
| `7_gs_full.csv`, `readlength_gs_SRRonly.csv` | provenance | Earlier/fuller versions of D7's gold standard and the read-length experiment's run list. |
| `gs_d1_convert.ipynb`, `gs_d2_convert.ipynb`, `gs_d4_convert.ipynb` | provenance | One-off notebooks that performed the raw-to-clean conversion above. Not re-run as part of the regular pipeline. |
| `mother{1,2}.gtf`, `father{1,2}.gtf`, `daughter{1,2}.gtf` | provenance | Per-haplotype Immuannot gene annotations for the D8 trio (PacBio HiFi WGS -> hifiasm -> Immuannot), the source this trio's HLA consensus alleles were read off of to build `datasets/8_gs.csv`. Not raw sequencing data and not regenerable from a public accession -- moved here from `datasets/raw/` (which is otherwise untracked/regenerable) for that reason. The notebook that originally parsed these (a Google Colab notebook that also exposed a collaborator's name/account ID in its cell metadata) was removed from the repo entirely, history included, 2026-10-22; nothing in the current pipeline reads these files, they're kept purely as D8 gold-standard provenance. |

The naming (`{N}_gs...`) matches the convention used everywhere else in the
repo for dataset D{N} -- see `accession/README.md`.
