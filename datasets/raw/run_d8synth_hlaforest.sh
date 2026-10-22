#!/bin/bash
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
set -uo pipefail
cd ${REPO_ROOT}/datasets/raw
export PATH=${REPO_ROOT}/tools/hlaforest/scripts:$PATH
FQ=d8_synthetic_rnaseq
OUT=d8_synth_hlaforest
mkdir -p "$OUT"
for S in mother father daughter; do
  mkdir -p "$OUT/${S}"
  echo "=== $(date) HLAforest (SYNTHETIC): $S ==="
  mamba run -n hlaforest \
    bash ${REPO_ROOT}/tools/hlaforest/scripts/CallHaplotypesPE.sh \
    "$OUT/${S}/" "$FQ/${S}.synth_R1.fastq" "$FQ/${S}.synth_R2.fastq" \
    > "$OUT/${S}.log" 2>&1
  echo "=== $(date) finished HLAforest (SYNTHETIC): $S ==="
done
echo "=== $(date) ALL D8-SYNTH HLAFOREST DONE ==="
