#!/bin/bash
cd /home/nicolaedrabcinski/hla_benchmarking/repo/datasets/raw
export PATH=/home/nicolaedrabcinski/hla_benchmarking/tools/hisat-genotype:/home/nicolaedrabcinski/hla_benchmarking/tools/hisat-genotype/hisat2:$PATH
export PYTHONPATH=/home/nicolaedrabcinski/hla_benchmarking/tools/hisat-genotype/hisatgenotype_modules:$PYTHONPATH
for SAMPLE in mother father daughter; do
  echo "=== $(date) HISAT-genotype: $SAMPLE ==="
  mkdir -p d8_hisatgeno/${SAMPLE}
  hisatgenotype -x genotype_genome --base hla \
    -1 d8_rnaseq/${SAMPLE}.final.1.fastq -2 d8_rnaseq/${SAMPLE}.final.2.fastq \
    --out-dir d8_hisatgeno/${SAMPLE} -p 16
  echo "=== $(date) finished HISAT-genotype: $SAMPLE ==="
done
echo "=== $(date) ALL D8 HISATGENO DONE ==="
