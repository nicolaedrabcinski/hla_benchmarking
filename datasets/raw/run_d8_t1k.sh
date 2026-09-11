#!/bin/bash
set -e
cd /home/nicolaedrabcinski/hla_benchmarking/repo/datasets/raw
T1K="/home/nicolaedrabcinski/miniforge3/bin/mamba run -n t1k run-t1k"
for SAMPLE in mother father daughter; do
  echo "=== $(date) T1K: $SAMPLE ==="
  $T1K -1 d8_rnaseq/${SAMPLE}.final.1.fastq -2 d8_rnaseq/${SAMPLE}.final.2.fastq \
       -f t1k_ref/hlaidx_rna_seq.fa \
       --preset hla -t 16 \
       -o ${SAMPLE} --od d8_t1k/
  echo "=== $(date) finished T1K: $SAMPLE ==="
done
echo "=== $(date) ALL D8 T1K DONE ==="
