#!/bin/bash
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
cd ${REPO_ROOT}/data/input/raw
export PATH=${REPO_ROOT}/tools/hisat-genotype:${REPO_ROOT}/tools/hisat-genotype/hisat2:$PATH
export PYTHONPATH=${REPO_ROOT}/tools/hisat-genotype/hisatgenotype_modules:$PYTHONPATH
for SAMPLE in mother father daughter; do
  echo "=== $(date) HISAT-genotype: $SAMPLE ==="
  mkdir -p d8_hisatgeno/${SAMPLE}
  hisatgenotype -x genotype_genome --base hla \
    -1 d8_rnaseq/${SAMPLE}.final.1.fastq -2 d8_rnaseq/${SAMPLE}.final.2.fastq \
    --out-dir d8_hisatgeno/${SAMPLE} -p 16
  echo "=== $(date) finished HISAT-genotype: $SAMPLE ==="
done
echo "=== $(date) ALL D8 HISATGENO DONE ==="
