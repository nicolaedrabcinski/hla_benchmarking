#!/bin/bash
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
set -uo pipefail
cd ${REPO_ROOT}/datasets/raw
MAMBA=mamba
FASTQ_DIR="$(pwd)/d1_optim_rnaseq"

run_one() {
  local TRIM="$1"
  local RUNNAME="trim${TRIM}"
  echo "=== $(date) RNA2HLA trim=$TRIM starting (processes all 50 samples internally) ==="
  cd ${REPO_ROOT}/tools/RNA2HLA
  "$MAMBA" run -n RNA2HLA_env python2 RNA2HLA.py \
    -f "$FASTQ_DIR" -r "$RUNNAME" -p 16 -3 "$TRIM" \
    > "${FASTQ_DIR}/rna2hla_trim${TRIM}.log" 2>&1
  echo "=== $(date) RNA2HLA trim=$TRIM done (exit $?) ==="
}
export -f run_one
export MAMBA FASTQ_DIR

echo "5 10 15" | tr ' ' '\n' | parallel -j 3 run_one {}
echo "=== $(date) ALL F20 RNA2HLA RUNS DONE ==="
