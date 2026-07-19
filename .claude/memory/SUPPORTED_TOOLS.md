# Supported Tools

The 12 HLA typing tools currently in the official benchmark, per
`results_summary.md` and the manuscript's Introduction. Update this file via
`/add-tool` only after human approval of inclusion — see
`agents/tool-integration-engineer.md` Forbidden Decisions.

*Last updated: 2026-07-19*

| Tool | Locus scope | Env file | Standardization script | Notes |
|---|---|---|---|---|
| T1K | Class I + II | `scripts/environmental_files/` (verify present) | not confirmed checked-in | Highest overall accuracy in current results (95.3% 2-field unfiltered) |
| arcasHLA | Class I + II | `arcasHLA.yml` | not confirmed checked-in | Manuscript's recommended "best balance" tool |
| HISAT-genotype | Class I + II | `hisat2.yml` / `hisatgenotype.yml` | not confirmed checked-in | |
| HLA-HD | Class I + II | `hlahd.yml` | not confirmed checked-in | |
| RNA2HLA | Class I + II | `RNA2HLA_env.yml` | not confirmed checked-in | Manuscript's recommended "most compute-efficient" tool |
| seq2HLA | Class I + II | `Seq2HLA.yml` | not confirmed checked-in | |
| HLAforest | Class I + II | `hlaforest.yml` (+ `hlaforest_old.yml`) | `HLAforest_convert.ipynb` ✅ | |
| PHLAT | Class I + II | `phlat.yml` | not confirmed checked-in | Weak on DQB1 (58.2% per Table 4) |
| HLA-VBSeq | Class I + II | `hlavbseq.yml` | not confirmed checked-in | D1 DRB1/DQB1 column-swap bug fixed 2026-07-15 — see KNOWN_BUGS.md |
| HLApers | Class I only (in practice — Class II calls fall outside valid set) | `hlapers_env.yml` / `HLApers.yml` | `hlapers_standardize.sh` ✅ | High novel rate (57.6%) on Class II |
| OptiType | Class I only (by design) | `optitype.yml` | not confirmed checked-in | `CLASS_I_ONLY_TOOLS` code list currently only includes this tool — verify against HLAvbseq mismatch, see KNOWN_BUGS.md |
| HLAminer | Class I + II | `HLAminer.yml` | not confirmed checked-in | Very high novel rate (54.2%), low accuracy overall — likely outdated reference DB |

## Piloted but Not in the Official 12

Present under `scripts/environmental_files/` but not in the current tool list —
status unconfirmed, do not assume excluded-by-decision without checking with a
human: `HLAProfiler`, `bwakit`, `crest`, `danbing-tk`.

## Standardization Script Coverage Gap

As of the last audit, only 2 of 12 tools had a confirmed checked-in standardization
script (HLAforest, HLApers). This is a standing `reproducibility-manager` /
`tool-integration-engineer` priority — see `checklists/reproducibility-checklist.md`.

## Candidate Tools (proposed, not yet integrated)

None on file as of last audit. `literature-surveillance` files candidate notes to
`scientific-coordinator`, which triages them into the roadmap.
