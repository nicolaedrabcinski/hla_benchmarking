#!/bin/bash
cd /home/nicolaedrabcinski/hla_benchmarking/repo/datasets/raw
HLAPERS=/home/nicolaedrabcinski/hla_benchmarking/tools/HLApers/hlapers
INDEX=/home/nicolaedrabcinski/hla_benchmarking/repo/datasets/raw/hlapers_index.idx
for SAMPLE in mother father daughter; do
  echo "=== $(date) HLApers genotype: $SAMPLE ==="
  $HLAPERS genotype -i $INDEX \
    -1 d8_rnaseq/${SAMPLE}.final.1.fastq -2 d8_rnaseq/${SAMPLE}.final.2.fastq \
    -p 16 -o d8_hlapers/${SAMPLE} --kallisto
  echo "=== $(date) finished HLApers: $SAMPLE ==="
done
echo "=== $(date) ALL D8 HLAPERS DONE ==="
