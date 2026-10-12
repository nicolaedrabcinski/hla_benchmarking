#!/bin/bash
set -uo pipefail
cd /home/nicolaedrabcinski/hla_benchmarking/datasets/raw

extract_one() {
  local SRR="$1"
  local BAM="d7_bams/${SRR}_Aligned.sortedByCoord.out.bam"
  local OUT="d7_t1k_fastq"
  echo "=== $(date) start $SRR ==="
  samtools fastq -@ 4 "$BAM" -0 "${OUT}/${SRR}.fastq" -n 2>"${OUT}/${SRR}.fastq.log"
  echo "=== $(date) done $SRR (exit $?) ==="
}
export -f extract_one

cat /home/nicolaedrabcinski/hla_benchmarking/accession/d7_list.txt | parallel -j 10 extract_one {}
echo "=== $(date) ALL D7 FASTQ EXTRACTION DONE ==="
