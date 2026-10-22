#!/bin/bash
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
set -uo pipefail
cd ${REPO_ROOT}/data/input/raw
export PATH=${REPO_ROOT}/tools/hlaforest/scripts:$PATH
for SAMPLE in SRR5252855 SRR5252862; do
  echo "=== $(date) HLAforest: $SAMPLE ==="
  mkdir -p d4_hlaforest_missing/${SAMPLE}
  mamba run -n hlaforest \
    bash ${REPO_ROOT}/tools/hlaforest/scripts/CallHaplotypesPE.sh \
    d4_hlaforest_missing/${SAMPLE}/ d4_rnaseq/${SAMPLE}_1.fastq d4_rnaseq/${SAMPLE}_2.fastq \
    > d4_hlaforest_missing/${SAMPLE}.log 2>&1
  echo "=== $(date) finished HLAforest: $SAMPLE (exit $?) ==="
done
echo "=== $(date) ALL F5 HLAFOREST DONE ==="
