#!/bin/bash
set -uo pipefail
cd /home/nicolaedrabcinski/hla_benchmarking/datasets/raw
MAMBA=/home/nicolaedrabcinski/miniforge3/bin/mamba
FASTQ_DIR="d1_optim_rnaseq"
OUT_BASE="d1_optim_optitype"

run_one() {
  local ACC="$1"
  local BETA="$2"
  local OUT="${OUT_BASE}/${BETA}/${ACC}"
  if [ -f "${OUT}/${ACC}_result.tsv" ]; then
    echo "=== $(date) skip (done): $ACC beta=$BETA ==="
    return 0
  fi
  mkdir -p "$OUT"
  echo "=== $(date) OptiType RETRY beta=$BETA: $ACC ==="
  "$MAMBA" run -n optitype optitype run \
    -i "${FASTQ_DIR}/${ACC}_1.fastq" -i "${FASTQ_DIR}/${ACC}_2.fastq" \
    --rna -o "$OUT" -p "$ACC" -b "$BETA" --solver cbc --threads 3 \
    > "${OUT}/run.log" 2>&1
  echo "=== $(date) finished RETRY $ACC beta=$BETA (exit $?) ==="
}
export -f run_one
export MAMBA FASTQ_DIR OUT_BASE

cat /tmp/f20_optitype_missing.txt | parallel -j 5 --colsep ' ' run_one {1} {2}
echo "=== $(date) ALL F20 OPTITYPE RETRIES DONE ==="
