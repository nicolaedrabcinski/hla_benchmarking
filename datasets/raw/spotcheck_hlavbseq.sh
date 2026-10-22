#!/bin/bash
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
set -uo pipefail
cd ${REPO_ROOT}/datasets/raw
REF=${REPO_ROOT}/tools/HLA-VBSeq/hla_all_v2.fasta
EXTRACT_DIR=/tmp/claude-1003/-home-nicolaedrabcinski-hla-benchmarking/8fcb41b2-c02a-483f-8c0b-91eb720ffa51/scratchpad/hlavbseq_extract2
CP="${EXTRACT_DIR}:${EXTRACT_DIR}/picard-1.74.jar:${EXTRACT_DIR}/args4j-2.0.21.jar:${EXTRACT_DIR}/commons-math3-3.0.jar:${EXTRACT_DIR}/sam-1.74.jar:${EXTRACT_DIR}/ssj.jar"
OUT=d1_spotcheck_hlavbseq
mkdir -p "$OUT"
run_one() {
  local S="$1"
  echo "=== $(date) HLA-VBSeq bwa mem: $S ==="
  bwa mem -t 8 -P -L 10000 -a "$REF" "d1_spotcheck_rnaseq/${S}_1.fastq" "d1_spotcheck_rnaseq/${S}_2.fastq" > "$OUT/${S}.sam" 2>"$OUT/${S}.bwa.log"
  echo "=== $(date) HLA-VBSeq typing: $S ==="
  java -cp "$CP" org.csml.tigar2.Test "$REF" "$OUT/${S}.sam" "$OUT/${S}_result.txt" --alpha_zero 0.01 --is_paired > "$OUT/${S}.typing.log" 2>&1
  rm -f "$OUT/${S}.sam"
  echo "=== $(date) finished HLA-VBSeq: $S (exit $?) ==="
}
export -f run_one
export REF CP OUT
cat /tmp/d1_spotcheck_samples.txt | parallel -j 4 run_one {}
echo "=== $(date) ALL SPOTCHECK HLAVBSEQ DONE ==="
