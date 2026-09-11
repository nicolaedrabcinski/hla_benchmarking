#!/bin/bash
set -e
cd /home/nicolaedrabcinski/hla_benchmarking/repo/datasets/raw
OPTITYPE="/home/nicolaedrabcinski/miniforge3/bin/mamba run -n optitype optitype"
for SAMPLE in mother father daughter; do
  echo "=== $(date) OptiType: $SAMPLE ==="
  $OPTITYPE run -i d8_rnaseq/${SAMPLE}.final.1.fastq -i d8_rnaseq/${SAMPLE}.final.2.fastq \
    --rna -o d8_optitype/${SAMPLE}/ --threads 16 --solver cbc
  echo "=== $(date) finished OptiType: $SAMPLE ==="
done
echo "=== $(date) ALL D8 OPTITYPE DONE ==="
