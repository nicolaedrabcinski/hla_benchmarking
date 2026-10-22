#!/bin/bash
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
set -uo pipefail
cd ${REPO_ROOT}/data/input/raw
ARCAS=${REPO_ROOT}/tools/arcasHLA/arcasHLA
STARIDX=${REPO_ROOT}/data/input/raw/star_index
FQ=d8_synthetic_rnaseq
OUT=d8_synth_arcashla
mkdir -p "$OUT"
for S in mother father daughter; do
  O="$OUT/${S}"
  mkdir -p "$O"
  echo "=== $(date) STAR align (SYNTHETIC): $S ==="
  STAR --runThreadN 16 --genomeDir "$STARIDX" \
    --readFilesIn "$FQ/${S}.synth_R1.fastq" "$FQ/${S}.synth_R2.fastq" \
    --outSAMtype BAM SortedByCoordinate \
    --outFileNamePrefix "$O/" \
    > "$O/star.log" 2>&1
  samtools index "$O/Aligned.sortedByCoord.out.bam" 2>> "$O/star.log"
  echo "=== $(date) arcasHLA extract (SYNTHETIC): $S ==="
  "$ARCAS" extract "$O/Aligned.sortedByCoord.out.bam" -o "$O/extracted" -t 16 >> "$OUT/${S}.log" 2>&1
  echo "=== $(date) arcasHLA genotype (SYNTHETIC): $S ==="
  "$ARCAS" genotype "$O/extracted/"*.1.fq.gz "$O/extracted/"*.2.fq.gz -o "$O/genotype" -t 16 >> "$OUT/${S}.log" 2>&1
  rm -f "$O/Aligned.sortedByCoord.out.bam" "$O/Aligned.sortedByCoord.out.bam.bai"
  echo "=== $(date) finished arcasHLA (SYNTHETIC): $S ==="
done
echo "=== $(date) ALL D8-SYNTH ARCASHLA DONE ==="
