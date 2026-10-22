#!/bin/bash
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
cd ${REPO_ROOT}/data/input/raw
export PATH=${REPO_ROOT}/tools/hlaforest/scripts:$PATH
for SAMPLE in father daughter; do
  echo "=== $(date) HLAforest: $SAMPLE ==="
  mkdir -p d8_hlaforest/${SAMPLE}
  mamba run -n hlaforest \
    bash ${REPO_ROOT}/tools/hlaforest/scripts/CallHaplotypesPE.sh \
    d8_hlaforest/${SAMPLE}/ d8_rnaseq/${SAMPLE}.final.1.fastq d8_rnaseq/${SAMPLE}.final.2.fastq
  echo "=== $(date) finished HLAforest: $SAMPLE ==="
done
echo "=== $(date) ALL D8 HLAFOREST DONE ==="
