#!/bin/bash
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
set -uo pipefail
cd ${REPO_ROOT}/datasets/raw
T1K="mamba run -n t1k run-t1k"
OUT=d1_spotcheck_t1k
mkdir -p "$OUT"
run_one() {
  local S="$1"
  echo "=== $(date) T1K: $S ==="
  $T1K -1 "d1_spotcheck_rnaseq/${S}_1.fastq" -2 "d1_spotcheck_rnaseq/${S}_2.fastq" \
       -f t1k_ref/hlaidx_rna_seq.fa \
       --preset hla -t 6 \
       -o "$S" --od "$OUT/" > "$OUT/${S}.log" 2>&1
  echo "=== $(date) finished T1K: $S (exit $?) ==="
}
export -f run_one
export T1K OUT
cat /tmp/d1_spotcheck_samples.txt | parallel -j 6 run_one {}
echo "=== $(date) ALL SPOTCHECK T1K DONE ==="
