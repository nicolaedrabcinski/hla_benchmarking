#!/bin/bash
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
set -uo pipefail
cd ${REPO_ROOT}/datasets/raw
export PATH=${REPO_ROOT}/tools/hlahd.1.7.1/bin:$PATH
HLAHD=${REPO_ROOT}/tools/hlahd.1.7.1/bin/hlahd.sh
SPLIT=${REPO_ROOT}/tools/hlahd.1.7.1/HLA_gene.split.txt
DICT=${REPO_ROOT}/tools/hlahd.1.7.1/dictionary
FREQ=${REPO_ROOT}/tools/hlahd.1.7.1/freq_data
FQ=d8_synthetic_rnaseq
OUT=d8_synth_hlahd
mkdir -p "$OUT"
for S in mother father daughter; do
  echo "=== $(date) HLA-HD (SYNTHETIC): $S ==="
  mamba run -n hlahd \
    bash "$HLAHD" -t 16 -f "$FREQ" \
    "$FQ/${S}.synth_R1.fastq" "$FQ/${S}.synth_R2.fastq" \
    "$SPLIT" "$DICT" "$S" "$OUT" \
    > "$OUT/${S}.log" 2>&1
  echo "=== $(date) finished HLA-HD (SYNTHETIC): $S ==="
done
echo "=== $(date) ALL D8-SYNTH HLAHD DONE ==="
