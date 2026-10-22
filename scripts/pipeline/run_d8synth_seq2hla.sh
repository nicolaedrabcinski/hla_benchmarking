#!/bin/bash
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
set -uo pipefail
cd ${REPO_ROOT}/data/input/raw
FQ=d8_synthetic_rnaseq
OUT=d8_synth_seq2hla
mkdir -p "$OUT"
for S in mother father daughter; do
  echo "=== $(date) seq2HLA (SYNTHETIC): $S ==="
  mamba run -n seq2hla seq2HLA \
    -1 "$FQ/${S}.synth_R1.fastq" -2 "$FQ/${S}.synth_R2.fastq" \
    -r "$OUT/${S}" -p 16 > "$OUT/${S}.log" 2>&1
  echo "=== $(date) finished seq2HLA (SYNTHETIC): $S ==="
done
echo "=== $(date) ALL D8-SYNTH SEQ2HLA DONE ==="
