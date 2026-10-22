#!/bin/bash
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
set -uo pipefail
cd ${REPO_ROOT}/data/input/raw
REF=${REPO_ROOT}/tools/HLA-VBSeq/hla_all_v2.fasta
DEPS=${REPO_ROOT}/tools/HLA-VBSeq/deps
CP="${REPO_ROOT}/tools/HLA-VBSeq/HLAVBSeq.jar:${DEPS}/picard-1.74.jar:${DEPS}/sam-1.74.jar:${DEPS}/args4j-2.0.23.jar:${DEPS}/commons-math3-3.0.jar:${DEPS}/ssj-2.5.jar"
FQ=d8_synthetic_rnaseq
OUT=d8_synth_hlavbseq
mkdir -p "$OUT"
S="$1"
echo "=== $(date) HLA-VBSeq bwa mem (SYNTHETIC): $S ==="
bwa mem -t 16 -P -L 10000 -a "$REF" "$FQ/${S}.synth_R1.fastq" "$FQ/${S}.synth_R2.fastq" > "$OUT/${S}.sam" 2>"$OUT/${S}.bwa.log"
echo "=== $(date) HLA-VBSeq typing (SYNTHETIC): $S ==="
java -cp "$CP" org.csml.tigar2.Test "$REF" "$OUT/${S}.sam" "$OUT/${S}_result.txt" --alpha_zero 0.01 --is_paired > "$OUT/${S}.typing.log" 2>&1
rm -f "$OUT/${S}.sam"
echo "=== $(date) finished HLA-VBSeq (SYNTHETIC): $S ==="
