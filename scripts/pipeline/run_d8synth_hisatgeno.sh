#!/bin/bash
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
set -uo pipefail
cd ${REPO_ROOT}/data/input/raw
HG=${REPO_ROOT}/tools/hisat-genotype/hisatgenotype
IXDIR=${REPO_ROOT}/tools/hisat-genotype/indicies
FQ=d8_synthetic_rnaseq
OUT=d8_synth_hisatgeno
mkdir -p "$OUT"
for S in mother father daughter; do
  O="$OUT/${S}"
  mkdir -p "$O"
  echo "=== $(date) HISAT-genotype (SYNTHETIC): $S ==="
  mamba run -n hisatgeno \
    "$HG" -1 "$FQ/${S}.synth_R1.fastq" -2 "$FQ/${S}.synth_R2.fastq" \
    --base genotype_genome -z "$IXDIR" --out-dir "$O" -p 16 \
    --locus-list A,B,C,DRB1,DQB1 \
    > "$OUT/${S}.log" 2>&1
  echo "=== $(date) finished HISAT-genotype (SYNTHETIC): $S ==="
done
echo "=== $(date) ALL D8-SYNTH HISATGENO DONE ==="
