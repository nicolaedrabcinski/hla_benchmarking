#!/bin/bash
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
export PATH=${REPO_ROOT}/tools/hlahd.1.7.1/bin:$PATH
cd ${REPO_ROOT}/tools/hlahd.1.7.1
for SAMPLE in mother father daughter; do
  echo "=== $(date) HLA-HD: $SAMPLE ==="
  mkdir -p ${REPO_ROOT}/data/input/raw/d8_hlahd/${SAMPLE}
  bash bin/hlahd.sh -t 16 -m 100 -f freq_data/ \
    ${REPO_ROOT}/data/input/raw/d8_rnaseq/${SAMPLE}.final.1.fastq \
    ${REPO_ROOT}/data/input/raw/d8_rnaseq/${SAMPLE}.final.2.fastq \
    HLA_gene.split.txt dictionary/ ${SAMPLE} \
    ${REPO_ROOT}/data/input/raw/d8_hlahd/
  echo "=== $(date) finished HLA-HD: $SAMPLE ==="
done
echo "=== $(date) ALL D8 HLAHD DONE ==="
