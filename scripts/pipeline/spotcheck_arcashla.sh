#!/bin/bash
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
set -uo pipefail
cd ${REPO_ROOT}/data/input/raw
ARCAS=${REPO_ROOT}/tools/arcasHLA/arcasHLA
STARIDX=${REPO_ROOT}/data/input/raw/star_index
OUT=d1_spotcheck_arcashla
mkdir -p "$OUT"
run_one() {
  local S="$1"
  local O="$OUT/${S}"
  mkdir -p "$O"
  echo "=== $(date) STAR align: $S ==="
  STAR --runThreadN 6 --genomeDir "$STARIDX" \
    --readFilesIn "d1_spotcheck_rnaseq/${S}_1.fastq" "d1_spotcheck_rnaseq/${S}_2.fastq" \
    --outSAMtype BAM SortedByCoordinate \
    --outFileNamePrefix "$O/" \
    > "$O/star.log" 2>&1
  samtools index "$O/Aligned.sortedByCoord.out.bam" 2>> "$O/star.log"
  echo "=== $(date) arcasHLA extract: $S ==="
  "$ARCAS" extract "$O/Aligned.sortedByCoord.out.bam" -o "$O/extracted" -t 6 >> "$OUT/${S}.log" 2>&1
  echo "=== $(date) arcasHLA genotype: $S ==="
  "$ARCAS" genotype "$O/extracted/"*.1.fastq.gz "$O/extracted/"*.2.fastq.gz -o "$O/genotype" -t 6 >> "$OUT/${S}.log" 2>&1
  rm -f "$O/Aligned.sortedByCoord.out.bam" "$O/Aligned.sortedByCoord.out.bam.bai"
  echo "=== $(date) finished arcasHLA: $S (exit $?) ==="
}
export -f run_one
export ARCAS STARIDX OUT
cat /tmp/d1_spotcheck_samples.txt | parallel -j 3 run_one {}
echo "=== $(date) ALL SPOTCHECK ARCASHLA DONE ==="
