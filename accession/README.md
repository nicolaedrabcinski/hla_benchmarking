# Accession lists

`d{N}_list.txt` — one SRA/ENA/GEO run accession per line, for dataset **D{N}**
as that number is used everywhere else in the repo (`datasets/{N}_gs.csv`,
`results/standard/*_d{N}.csv`, the manuscript's Table 1).

| file | dataset | samples | gold standard |
|---|---|---|---|
| `d1_list.txt` | D1 | 490 | `datasets/1_gs.csv` |
| `d2_list.txt` | D2 | 86  | `datasets/2_gs.csv` |
| `d3_list.txt` | D3 | 50  | `datasets/3_gs.csv` |
| `d4_list.txt` | D4 | 14  | `datasets/4_gs.csv` |
| `d5_list.txt` | D5 | 8   | `datasets/5_gs.csv` |
| `d6_list.txt` | D6 | 4   | `datasets/6_gs.csv` |
| `d7_list.txt` | D7 | 20  | `datasets/7_gs.csv` |

D8 (in-house PacBio family trio, n=3) has no accession list — the raw data is
local, not fetched from a public archive.

Each `d{N}_list.txt` is verified to match its `datasets/{N}_gs.csv` on both row
count and sample-ID membership.

## History

Before 2026-09-10 these files used an **older, different numbering** than the
rest of the repo: the file named `d1_list.txt` actually held D3's samples,
`d2_list.txt` held D1's, `d3_list.txt` held D2's, and `d5_list.txt` / `d6_list.txt`
were swapped (`d4`/`d7` were already correct). This was a repo-only bookkeeping
drift — no gold standard or accuracy number was ever affected, because
`datasets/{N}_gs.csv` and `results/standard/` always agreed with each other.
The files were renamed to the table above on 2026-09-10 (`git mv` through temp
names). See `.claude/memory/KNOWN_BUGS.md` for the full trail.

Other files here (`optimization_accessions.txt`, `rl_accessions_11samples.txt`,
`unmapped_accessions.txt`) are auxiliary subsets from earlier experiments, not
tied to the D1–D8 numbering.
