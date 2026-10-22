#!/bin/bash
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
set -uo pipefail
cd ${REPO_ROOT}/datasets/raw
OUT=d1_spotcheck_seq2hla
mkdir -p "$OUT"
run_one() {
  local S="$1"
  echo "=== $(date) seq2HLA: $S ==="
  mamba run -n seq2hla seq2HLA \
    -1 "d1_spotcheck_rnaseq/${S}_1.fastq" -2 "d1_spotcheck_rnaseq/${S}_2.fastq" \
    -r "$OUT/${S}" -p 6 > "$OUT/${S}.log" 2>&1
  echo "=== $(date) finished seq2HLA: $S (exit $?) ==="
}
export -f run_one
export OUT
cat /tmp/d1_spotcheck_samples.txt | parallel -j 6 run_one {}
echo "=== $(date) ALL SPOTCHECK SEQ2HLA DONE ==="
