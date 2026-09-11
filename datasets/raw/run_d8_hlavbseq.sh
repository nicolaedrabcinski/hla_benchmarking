#!/bin/bash
set -e
cd /home/nicolaedrabcinski/hla_benchmarking/repo/datasets/raw
REF=/home/nicolaedrabcinski/hla_benchmarking/tools/HLA-VBSeq/hla_all_v2.fasta
CP="/tmp/claude-1003/-home-nicolaedrabcinski-hla-benchmarking/8fcb41b2-c02a-483f-8c0b-91eb720ffa51/scratchpad/hlavbseq_extract:/tmp/claude-1003/-home-nicolaedrabcinski-hla-benchmarking/8fcb41b2-c02a-483f-8c0b-91eb720ffa51/scratchpad/hlavbseq_extract/picard-1.74.jar:/tmp/claude-1003/-home-nicolaedrabcinski-hla-benchmarking/8fcb41b2-c02a-483f-8c0b-91eb720ffa51/scratchpad/hlavbseq_extract/args4j-2.0.21.jar:/tmp/claude-1003/-home-nicolaedrabcinski-hla-benchmarking/8fcb41b2-c02a-483f-8c0b-91eb720ffa51/scratchpad/hlavbseq_extract/commons-math3-3.0.jar:/tmp/claude-1003/-home-nicolaedrabcinski-hla-benchmarking/8fcb41b2-c02a-483f-8c0b-91eb720ffa51/scratchpad/hlavbseq_extract/sam-1.74.jar:/tmp/claude-1003/-home-nicolaedrabcinski-hla-benchmarking/8fcb41b2-c02a-483f-8c0b-91eb720ffa51/scratchpad/hlavbseq_extract/ssj.jar"
for SAMPLE in mother father daughter; do
  echo "=== $(date) HLA-VBSeq bwa mem: $SAMPLE ==="
  bwa mem -t 16 -P -L 10000 -a $REF d8_rnaseq/${SAMPLE}.final.1.fastq d8_rnaseq/${SAMPLE}.final.2.fastq > d8_hlavbseq/${SAMPLE}.sam
  echo "=== $(date) HLA-VBSeq typing: $SAMPLE ==="
  java -cp "$CP" org.csml.tigar2.Test $REF d8_hlavbseq/${SAMPLE}.sam d8_hlavbseq/${SAMPLE}_result.txt --alpha_zero 0.01 --is_paired
  echo "=== $(date) finished HLA-VBSeq: $SAMPLE ==="
done
echo "=== $(date) ALL D8 HLAVBSEQ DONE ==="
