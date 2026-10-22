#!/bin/bash
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
set -uo pipefail
cd ${REPO_ROOT}/datasets/raw
export PATH=${REPO_ROOT}/tools/hlaforest/scripts:$PATH
OUT=d1_spotcheck_hlaforest
mkdir -p "$OUT"
run_one() {
  local S="$1"
  mkdir -p "$OUT/${S}"
  echo "=== $(date) HLAforest: $S ==="
  mamba run -n hlaforest \
    bash ${REPO_ROOT}/tools/hlaforest/scripts/CallHaplotypesPE.sh \
    "$OUT/${S}/" "d1_spotcheck_rnaseq/${S}_1.fastq" "d1_spotcheck_rnaseq/${S}_2.fastq" \
    > "$OUT/${S}.log" 2>&1
  echo "=== $(date) finished HLAforest: $S (exit $?) ==="
}
export -f run_one
export OUT
cat /tmp/d1_spotcheck_samples.txt | parallel -j 6 run_one {}
echo "=== $(date) ALL SPOTCHECK HLAFOREST DONE ==="
