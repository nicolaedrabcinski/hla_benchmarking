#!/bin/bash
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
set -uo pipefail
cd ${REPO_ROOT}/data/input/raw

mkdir -p d1_spotcheck_sra d1_spotcheck_rnaseq

download_one() {
  local ACC="$1"
  local SRA_DIR="d1_spotcheck_sra"
  local FASTQ_DIR="d1_spotcheck_rnaseq"
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

cat /tmp/d1_spotcheck_samples.txt | parallel -j 8 download_one {}
echo "=== $(date) ALL D1 SPOTCHECK DOWNLOADS DONE ==="
