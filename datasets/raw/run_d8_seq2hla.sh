#!/bin/bash
set -e
cd /home/nicolaedrabcinski/hla_benchmarking/repo/datasets/raw
mkdir -p d8_seq2hla
for SAMPLE in mother father daughter; do
  echo "=== $(date) seq2HLA: $SAMPLE ==="
  /home/nicolaedrabcinski/miniforge3/bin/mamba run -n seq2hla seq2HLA \
    -1 d8_rnaseq/${SAMPLE}.final.1.fastq -2 d8_rnaseq/${SAMPLE}.final.2.fastq \
    -r d8_seq2hla/${SAMPLE} -p 16
  echo "=== $(date) finished seq2HLA: $SAMPLE ==="
done
echo "=== $(date) ALL D8 SEQ2HLA DONE ==="
