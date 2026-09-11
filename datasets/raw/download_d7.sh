#!/bin/bash
cd /home/nicolaedrabcinski/hla_benchmarking/repo/datasets/raw
SRA_DIR=d7_sra
FASTQ_DIR=d7_rnaseq
mkdir -p $SRA_DIR $FASTQ_DIR
while read -r ACC; do
  [ -z "$ACC" ] && continue
  echo "=== $(date) prefetch: $ACC ==="
  prefetch --max-size 50G -O $SRA_DIR $ACC
  echo "=== $(date) fasterq-dump: $ACC ==="
  fasterq-dump --split-files -e 32 -O $FASTQ_DIR $SRA_DIR/$ACC/$ACC.sra
  gzip -f $FASTQ_DIR/${ACC}_1.fastq $FASTQ_DIR/${ACC}_2.fastq
  rm -rf $SRA_DIR/$ACC
  echo "=== $(date) done: $ACC ==="
done < /tmp/claude-1003/-home-nicolaedrabcinski-hla-benchmarking/8fcb41b2-c02a-483f-8c0b-91eb720ffa51/scratchpad/d7_remaining.txt
echo "=== $(date) ALL D7 DOWNLOADS DONE ==="
