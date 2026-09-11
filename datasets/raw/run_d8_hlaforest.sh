#!/bin/bash
cd /home/nicolaedrabcinski/hla_benchmarking/repo/datasets/raw
export PATH=/home/nicolaedrabcinski/hla_benchmarking/tools/hlaforest/scripts:$PATH
for SAMPLE in father daughter; do
  echo "=== $(date) HLAforest: $SAMPLE ==="
  mkdir -p d8_hlaforest/${SAMPLE}
  /home/nicolaedrabcinski/miniforge3/bin/mamba run -n hlaforest \
    bash /home/nicolaedrabcinski/hla_benchmarking/tools/hlaforest/scripts/CallHaplotypesPE.sh \
    d8_hlaforest/${SAMPLE}/ d8_rnaseq/${SAMPLE}.final.1.fastq d8_rnaseq/${SAMPLE}.final.2.fastq
  echo "=== $(date) finished HLAforest: $SAMPLE ==="
done
echo "=== $(date) ALL D8 HLAFOREST DONE ==="
