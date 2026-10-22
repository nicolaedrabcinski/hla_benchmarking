#!/bin/bash
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
set -uo pipefail
cd ${REPO_ROOT}/data/input/raw
MAMBA=mamba
FASTQ_DIR="$(pwd)/d8_synth_rna2hla_input"
cd ${REPO_ROOT}/tools/RNA2HLA
echo "=== $(date) RNA2HLA -g6 starting (SYNTHETIC, all 3 samples in one run) ==="
"$MAMBA" run -n RNA2HLA_env python2 RNA2HLA.py \
  -f "$FASTQ_DIR" -r d8synth -p 16 -3 0 -g 6 \
  > "$FASTQ_DIR/rna2hla_run.log" 2>&1
echo "=== $(date) RNA2HLA -g6 done (SYNTHETIC) ==="
