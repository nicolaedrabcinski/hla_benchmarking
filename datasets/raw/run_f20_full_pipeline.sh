#!/bin/bash
set -uo pipefail
cd /home/nicolaedrabcinski/hla_benchmarking/datasets/raw

echo "=== $(date) waiting for all 50 FASTQ pairs ==="
while true; do
  N1=$(ls d1_optim_rnaseq/*_1.fastq 2>/dev/null | wc -l)
  N2=$(ls d1_optim_rnaseq/*_2.fastq 2>/dev/null | wc -l)
  if [ "$N1" -ge 50 ] && [ "$N2" -ge 50 ]; then
    echo "=== $(date) all 50 pairs present ==="
    break
  fi
  echo "=== $(date) progress: ${N1}/50 _1, ${N2}/50 _2 ==="
  sleep 120
done

echo "=== $(date) STAGE 1: RNA2HLA (3 trim values, parallel) ==="
./run_f20_rna2hla.sh
echo "=== $(date) STAGE 1 DONE ==="

echo "=== $(date) STAGE 2: OptiType (3 betas x 50 samples, j=16) ==="
./run_f20_optitype.sh
echo "=== $(date) STAGE 2 DONE ==="

echo "=== $(date) F20 FULL PIPELINE COMPLETE ==="
