#!/bin/bash
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
set -uo pipefail
cd ${REPO_ROOT}/datasets/raw
HG=${REPO_ROOT}/tools/hisat-genotype/hisatgenotype
IXDIR=${REPO_ROOT}/tools/hisat-genotype/indicies
OUT=d1_spotcheck_hisatgenotype
mkdir -p "$OUT"
run_one() {
  local S="$1"
  local O="$OUT/${S}"
  mkdir -p "$O"
  echo "=== $(date) HISAT-genotype: $S ==="
  mamba run -n hisatgeno \
    "$HG" -1 "d1_spotcheck_rnaseq/${S}_1.fastq" -2 "d1_spotcheck_rnaseq/${S}_2.fastq" \
    --base genotype_genome -z "$IXDIR" --out-dir "$O" -p 6 \
    --locus-list A,B,C,DRB1,DQB1 \
    > "$OUT/${S}.log" 2>&1
  echo "=== $(date) finished HISAT-genotype: $S (exit $?) ==="
}
export -f run_one
export HG IXDIR OUT
cat /tmp/d1_spotcheck_samples.txt | parallel -j 4 run_one {}
echo "=== $(date) ALL SPOTCHECK HISATGENOTYPE DONE ==="
