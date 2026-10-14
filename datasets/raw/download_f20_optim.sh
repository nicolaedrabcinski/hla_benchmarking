#!/bin/bash
set -uo pipefail
cd /home/nicolaedrabcinski/hla_benchmarking/datasets/raw

mkdir -p d1_optim_sra d1_optim_rnaseq

download_one() {
  local ACC="$1"
  local SRA_DIR="d1_optim_sra"
  local FASTQ_DIR="d1_optim_rnaseq"
  if [ -s "${FASTQ_DIR}/${ACC}_1.fastq" ] && [ -s "${FASTQ_DIR}/${ACC}_2.fastq" ]; then
    echo "=== $(date) skip (fastq exists): $ACC ==="
    return 0
  fi
  echo "=== $(date) prefetch: $ACC ==="
  prefetch --max-size 20G -O "$SRA_DIR" "$ACC" > "${FASTQ_DIR}/${ACC}.prefetch.log" 2>&1
  echo "=== $(date) fasterq-dump: $ACC ==="
  fasterq-dump --split-3 -e 4 -O "$FASTQ_DIR" "${SRA_DIR}/${ACC}/${ACC}.sra" > "${FASTQ_DIR}/${ACC}.dump.log" 2>&1
  rm -rf "${SRA_DIR:?}/${ACC}"
  echo "=== $(date) done $ACC ==="
}
export -f download_one

cat ../../accession/optimization_accessions.txt | parallel -j 10 download_one {}
echo "=== $(date) ALL F20 OPTIM DOWNLOADS DONE ==="
