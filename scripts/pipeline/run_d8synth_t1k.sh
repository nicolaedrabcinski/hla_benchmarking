#!/bin/bash
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
set -uo pipefail
cd ${REPO_ROOT}/data/input/raw
T1K="mamba run -n t1k run-t1k"
FQ=d8_synthetic_rnaseq
OUT=d8_synth_t1k
mkdir -p "$OUT"
for S in mother father daughter; do
  echo "=== $(date) T1K (SYNTHETIC): $S ==="
  $T1K -1 "$FQ/${S}.synth_R1.fastq" -2 "$FQ/${S}.synth_R2.fastq" \
       -f t1k_ref/hlaidx_rna_seq.fa \
       --preset hla -t 16 \
       -o "$S" --od "$OUT/" > "$OUT/${S}.log" 2>&1
  echo "=== $(date) finished T1K (SYNTHETIC): $S ==="
done
echo "=== $(date) ALL D8-SYNTH T1K DONE ==="
