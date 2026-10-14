#!/bin/bash
set -uo pipefail
cd /home/nicolaedrabcinski/hla_benchmarking/datasets/raw
MAMBA=/home/nicolaedrabcinski/miniforge3/bin/mamba
FASTQ_DIR="$(pwd)/d1_optim_rnaseq"

run_one() {
  local TRIM="$1"
  local RUNNAME="trim${TRIM}"
  echo "=== $(date) RNA2HLA -g6 trim=$TRIM starting (processes all 50 samples internally) ==="
  cd /home/nicolaedrabcinski/hla_benchmarking/tools/RNA2HLA
  "$MAMBA" run -n RNA2HLA_env python2 RNA2HLA.py \
    -f "$FASTQ_DIR" -r "$RUNNAME" -p 6 -3 "$TRIM" -g 6 \
    > "${FASTQ_DIR}/rna2hla_g6_trim${TRIM}.log" 2>&1
  echo "=== $(date) RNA2HLA -g6 trim=$TRIM done (exit $?) ==="
}
export -f run_one
export MAMBA FASTQ_DIR

echo "5 10 15" | tr ' ' '\n' | parallel -j 3 run_one {}
echo "=== $(date) ALL F20 RNA2HLA -g6 RUNS DONE ==="
