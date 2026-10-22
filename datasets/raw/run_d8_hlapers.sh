#!/bin/bash
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
cd ${REPO_ROOT}/datasets/raw
HLAPERS=${REPO_ROOT}/tools/HLApers/hlapers
INDEX=${REPO_ROOT}/datasets/raw/hlapers_index.idx
for SAMPLE in mother father daughter; do
  echo "=== $(date) HLApers genotype: $SAMPLE ==="
  $HLAPERS genotype -i $INDEX \
    -1 d8_rnaseq/${SAMPLE}.final.1.fastq -2 d8_rnaseq/${SAMPLE}.final.2.fastq \
    -p 16 -o d8_hlapers/${SAMPLE} --kallisto
  echo "=== $(date) finished HLApers: $SAMPLE ==="
done
echo "=== $(date) ALL D8 HLAPERS DONE ==="
