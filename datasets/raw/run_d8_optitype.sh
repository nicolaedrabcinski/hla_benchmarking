#!/bin/bash
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
set -e
cd ${REPO_ROOT}/datasets/raw
OPTITYPE="mamba run -n optitype optitype"
for SAMPLE in mother father daughter; do
  echo "=== $(date) OptiType: $SAMPLE ==="
  $OPTITYPE run -i d8_rnaseq/${SAMPLE}.final.1.fastq -i d8_rnaseq/${SAMPLE}.final.2.fastq \
    --rna -o d8_optitype/${SAMPLE}/ --threads 16 --solver cbc
  echo "=== $(date) finished OptiType: $SAMPLE ==="
done
echo "=== $(date) ALL D8 OPTITYPE DONE ==="
