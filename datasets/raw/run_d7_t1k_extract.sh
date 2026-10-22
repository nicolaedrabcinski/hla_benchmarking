#!/bin/bash
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
set -uo pipefail
cd ${REPO_ROOT}/datasets/raw

extract_one() {
  local SRR="$1"
  local BAM="d7_bams/${SRR}_Aligned.sortedByCoord.out.bam"
  local OUT="d7_t1k_fastq"
  echo "=== $(date) start $SRR ==="
  samtools fastq -@ 4 "$BAM" -0 "${OUT}/${SRR}.fastq" -n 2>"${OUT}/${SRR}.fastq.log"
  echo "=== $(date) done $SRR (exit $?) ==="
}
export -f extract_one

cat ${REPO_ROOT}/accession/d7_list.txt | parallel -j 10 extract_one {}
echo "=== $(date) ALL D7 FASTQ EXTRACTION DONE ==="
