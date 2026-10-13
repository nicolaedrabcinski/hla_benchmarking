#!/bin/bash
set -uo pipefail
cd /home/nicolaedrabcinski/hla_benchmarking/datasets/raw
export PATH=/home/nicolaedrabcinski/hla_benchmarking/tools/hlaforest/scripts:$PATH
for SAMPLE in SRR5252855 SRR5252862; do
  echo "=== $(date) HLAforest: $SAMPLE ==="
  mkdir -p d4_hlaforest_missing/${SAMPLE}
  /home/nicolaedrabcinski/miniforge3/bin/mamba run -n hlaforest \
    bash /home/nicolaedrabcinski/hla_benchmarking/tools/hlaforest/scripts/CallHaplotypesPE.sh \
    d4_hlaforest_missing/${SAMPLE}/ d4_rnaseq/${SAMPLE}_1.fastq d4_rnaseq/${SAMPLE}_2.fastq \
    > d4_hlaforest_missing/${SAMPLE}.log 2>&1
  echo "=== $(date) finished HLAforest: $SAMPLE (exit $?) ==="
done
echo "=== $(date) ALL F5 HLAFOREST DONE ==="
