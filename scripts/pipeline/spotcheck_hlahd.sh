#!/bin/bash
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
set -uo pipefail
cd ${REPO_ROOT}/data/input/raw
HLAHD=${REPO_ROOT}/tools/hlahd.1.7.1/bin/hlahd.sh
SPLIT=${REPO_ROOT}/tools/hlahd.1.7.1/HLA_gene.split.txt
DICT=${REPO_ROOT}/tools/hlahd.1.7.1/dictionary
FREQ=${REPO_ROOT}/tools/hlahd.1.7.1/freq_data
OUT=d1_spotcheck_hlahd
mkdir -p "$OUT"
run_one() {
  local S="$1"
  echo "=== $(date) HLA-HD: $S ==="
  mamba run -n hlahd \
    bash "$HLAHD" -t 6 -f "$FREQ" \
    "d1_spotcheck_rnaseq/${S}_1.fastq" "d1_spotcheck_rnaseq/${S}_2.fastq" \
    "$SPLIT" "$DICT" "$S" "$OUT" \
    > "$OUT/${S}.log" 2>&1
  echo "=== $(date) finished HLA-HD: $S (exit $?) ==="
}
export -f run_one
export HLAHD SPLIT DICT FREQ OUT
cat /tmp/d1_spotcheck_samples.txt | parallel -j 4 run_one {}
echo "=== $(date) ALL SPOTCHECK HLAHD DONE ==="
