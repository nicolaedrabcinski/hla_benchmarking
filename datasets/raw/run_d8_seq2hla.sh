#!/bin/bash
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
set -e
cd ${REPO_ROOT}/datasets/raw
mkdir -p d8_seq2hla
for SAMPLE in mother father daughter; do
  echo "=== $(date) seq2HLA: $SAMPLE ==="
  mamba run -n seq2hla seq2HLA \
    -1 d8_rnaseq/${SAMPLE}.final.1.fastq -2 d8_rnaseq/${SAMPLE}.final.2.fastq \
    -r d8_seq2hla/${SAMPLE} -p 16
  echo "=== $(date) finished seq2HLA: $SAMPLE ==="
done
echo "=== $(date) ALL D8 SEQ2HLA DONE ==="
