#!/bin/bash
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
set -uo pipefail
cd ${REPO_ROOT}/datasets/raw
B2="$(command -v bowtie2 || mamba run -n bowtie2 command -v bowtie2)"
PY2="mamba run -n phlat python2.7"
OUT=d1_spotcheck_phlat
mkdir -p "$OUT"
run_one() {
  local S="$1"
  echo "=== $(date) PHLAT: $S ==="
  $PY2 /tmp/phlat_custom_current/dist/PHLAT.py \
    -1 "d1_spotcheck_rnaseq/${S}_1.fastq" -2 "d1_spotcheck_rnaseq/${S}_2.fastq" \
    -index phlat_index_build/index4phlat_current -b2url "$B2" \
    -tag "$S" -p 6 -e /tmp/phlat_custom_current -o "$OUT" -pe 1 \
    > "$OUT/${S}.log" 2>&1
  echo "=== $(date) finished PHLAT: $S (exit $?) ==="
}
export -f run_one
export B2 PY2 OUT
cat /tmp/d1_spotcheck_samples.txt | parallel -j 4 run_one {}
echo "=== $(date) ALL SPOTCHECK PHLAT DONE ==="
