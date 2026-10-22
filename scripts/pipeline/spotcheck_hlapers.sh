#!/bin/bash
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
set -uo pipefail
cd ${REPO_ROOT}/data/input/raw
SCRIPT=${REPO_ROOT}/tools/HLApers/script/run_genotypingkallisto.sh
GENOR=${REPO_ROOT}/tools/HLApers/script/genotype_kallisto.R
INDEX=${REPO_ROOT}/data/input/raw/hlapers_index.idx
OUT=d1_spotcheck_hlapers
mkdir -p "$OUT"
run_one() {
  local S="$1"
  local O="$OUT/${S}"
  mkdir -p "$O"
  echo "=== $(date) HLApers: $S ==="
  mamba run -n hlapers \
    bash "$SCRIPT" "$INDEX" "d1_spotcheck_rnaseq/${S}_1.fastq" "d1_spotcheck_rnaseq/${S}_2.fastq" "$O" 6 \
    > "$OUT/${S}.log" 2>&1
  echo "=== $(date) finished HLApers: $S (exit $?) ==="
}
export -f run_one
export SCRIPT GENOR INDEX OUT
cat /tmp/d1_spotcheck_samples.txt | parallel -j 6 run_one {}
echo "=== $(date) ALL SPOTCHECK HLAPERS DONE ==="
