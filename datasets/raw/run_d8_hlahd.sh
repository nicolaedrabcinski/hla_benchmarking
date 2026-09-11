#!/bin/bash
export PATH=/home/nicolaedrabcinski/hla_benchmarking/tools/hlahd.1.7.1/bin:$PATH
cd /home/nicolaedrabcinski/hla_benchmarking/tools/hlahd.1.7.1
for SAMPLE in mother father daughter; do
  echo "=== $(date) HLA-HD: $SAMPLE ==="
  mkdir -p /home/nicolaedrabcinski/hla_benchmarking/repo/datasets/raw/d8_hlahd/${SAMPLE}
  bash bin/hlahd.sh -t 16 -m 100 -f freq_data/ \
    /home/nicolaedrabcinski/hla_benchmarking/repo/datasets/raw/d8_rnaseq/${SAMPLE}.final.1.fastq \
    /home/nicolaedrabcinski/hla_benchmarking/repo/datasets/raw/d8_rnaseq/${SAMPLE}.final.2.fastq \
    HLA_gene.split.txt dictionary/ ${SAMPLE} \
    /home/nicolaedrabcinski/hla_benchmarking/repo/datasets/raw/d8_hlahd/
  echo "=== $(date) finished HLA-HD: $SAMPLE ==="
done
echo "=== $(date) ALL D8 HLAHD DONE ==="
