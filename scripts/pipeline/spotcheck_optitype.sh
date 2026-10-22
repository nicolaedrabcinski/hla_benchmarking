#!/bin/bash
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
set -uo pipefail
cd ${REPO_ROOT}/data/input/raw
MAMBA=mamba
FASTQ_DIR="d1_spotcheck_rnaseq"
OUT=d1_spotcheck_optitype
mkdir -p "$OUT"
run_one() {
  local S="$1"
  local O="$OUT/${S}"
  if [ -f "${O}/${S}_result.tsv" ]; then
    echo "=== $(date) skip (done): $S ==="
    return 0
  fi
  mkdir -p "$O"
  echo "=== $(date) OptiType: $S ==="
  "$MAMBA" run -n optitype optitype run \
    -i "${FASTQ_DIR}/${S}_1.fastq" -i "${FASTQ_DIR}/${S}_2.fastq" \
    --rna -o "$O" -p "$S" -b 0.009 --solver cbc --threads 6 \
    > "${O}/run.log" 2>&1
  echo "=== $(date) finished $S (exit $?) ==="
}
export -f run_one
export MAMBA FASTQ_DIR OUT
cat /tmp/d1_spotcheck_samples.txt | parallel -j 4 run_one {}
echo "=== $(date) ALL SPOTCHECK OPTITYPE DONE ==="
