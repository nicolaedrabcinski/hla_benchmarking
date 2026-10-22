#!/bin/bash
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
set -uo pipefail
cd ${REPO_ROOT}/data/input/raw
SCRIPT=${REPO_ROOT}/tools/HLApers/script/run_genotypingkallisto.sh
INDEX=${REPO_ROOT}/data/input/raw/hlapers_index.idx
FQ=d8_synthetic_rnaseq
OUT=d8_synth_hlapers
mkdir -p "$OUT"
for S in mother father daughter; do
  O="$OUT/${S}"
  mkdir -p "$O"
  echo "=== $(date) HLApers (SYNTHETIC): $S ==="
  mamba run -n hlapers \
    bash "$SCRIPT" "$INDEX" "$FQ/${S}.synth_R1.fastq" "$FQ/${S}.synth_R2.fastq" "$O" 16 \
    > "$OUT/${S}.log" 2>&1
  echo "=== $(date) finished HLApers (SYNTHETIC): $S ==="
done
echo "=== $(date) ALL D8-SYNTH HLAPERS DONE ==="
