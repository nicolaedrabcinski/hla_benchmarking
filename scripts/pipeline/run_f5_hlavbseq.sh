#!/bin/bash
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
set -uo pipefail
cd ${REPO_ROOT}/data/input/raw
REF=${REPO_ROOT}/tools/HLA-VBSeq/hla_all_v2.fasta
EXTRACT_DIR=/tmp/claude-1003/-home-nicolaedrabcinski-hla-benchmarking/8fcb41b2-c02a-483f-8c0b-91eb720ffa51/scratchpad/hlavbseq_extract2
CP="${EXTRACT_DIR}:${EXTRACT_DIR}/picard-1.74.jar:${EXTRACT_DIR}/args4j-2.0.21.jar:${EXTRACT_DIR}/commons-math3-3.0.jar:${EXTRACT_DIR}/sam-1.74.jar:${EXTRACT_DIR}/ssj.jar"
mkdir -p d4_hlavbseq_missing
for SAMPLE in SRR5252855 SRR5252853; do
  echo "=== $(date) HLA-VBSeq bwa mem: $SAMPLE ==="
  bwa mem -t 16 -P -L 10000 -a "$REF" d4_rnaseq/${SAMPLE}_1.fastq d4_rnaseq/${SAMPLE}_2.fastq > d4_hlavbseq_missing/${SAMPLE}.sam 2>d4_hlavbseq_missing/${SAMPLE}.bwa.log
  echo "=== $(date) HLA-VBSeq typing: $SAMPLE ==="
  java -cp "$CP" org.csml.tigar2.Test "$REF" d4_hlavbseq_missing/${SAMPLE}.sam d4_hlavbseq_missing/${SAMPLE}_result.txt --alpha_zero 0.01 --is_paired > d4_hlavbseq_missing/${SAMPLE}.typing.log 2>&1
  echo "=== $(date) finished HLA-VBSeq: $SAMPLE (exit $?) ==="
done
echo "=== $(date) ALL F5 HLAVBSEQ DONE ==="
