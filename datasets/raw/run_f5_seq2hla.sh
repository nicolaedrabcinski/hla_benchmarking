#!/bin/bash
set -uo pipefail
cd /home/nicolaedrabcinski/hla_benchmarking/datasets/raw
mkdir -p d2_seq2hla_missing
for SAMPLE in SRR13280656 SRR13280726; do
  echo "=== $(date) seq2HLA: $SAMPLE ==="
  /home/nicolaedrabcinski/miniforge3/bin/mamba run -n seq2hla seq2HLA \
    -1 d2_rnaseq/${SAMPLE}_1.fastq -2 d2_rnaseq/${SAMPLE}_2.fastq \
    -r d2_seq2hla_missing/${SAMPLE} -p 16 > d2_seq2hla_missing/${SAMPLE}.log 2>&1
  echo "=== $(date) finished seq2HLA: $SAMPLE (exit $?) ==="
done
echo "=== $(date) ALL F5 SEQ2HLA DONE ==="
