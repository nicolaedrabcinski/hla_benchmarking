#!/bin/bash
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
set -uo pipefail
cd ${REPO_ROOT}/data/input/raw
MAMBA=mamba
FQ=d8_synthetic_rnaseq
OUT=d8_synth_optitype
mkdir -p "$OUT"
for S in mother father daughter; do
  O="$OUT/${S}"
  mkdir -p "$O"
  echo "=== $(date) OptiType (SYNTHETIC): $S ==="
  "$MAMBA" run -n optitype optitype run \
    -i "$FQ/${S}.synth_R1.fastq" -i "$FQ/${S}.synth_R2.fastq" \
    --rna -o "$O" -p "$S" -b 0.009 --solver cbc --threads 16 \
    > "$O/run.log" 2>&1
  echo "=== $(date) finished OptiType (SYNTHETIC): $S ==="
done
echo "=== $(date) ALL D8-SYNTH OPTITYPE DONE ==="
