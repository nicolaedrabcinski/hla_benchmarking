#!/bin/bash
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
set -uo pipefail
cd ${REPO_ROOT}/datasets/raw

download_one() {
  local ACC="$1"
  local SRA_DIR="$2"
  local FASTQ_DIR="$3"
  if [ -s "${FASTQ_DIR}/${ACC}_1.fastq" ] && [ -s "${FASTQ_DIR}/${ACC}_2.fastq" ]; then
    echo "=== $(date) skip (fastq exists): $ACC ==="
    return 0
  fi
  echo "=== $(date) prefetch: $ACC ==="
  prefetch --max-size 20G -O "$SRA_DIR" "$ACC" > "${FASTQ_DIR}/${ACC}.prefetch.log" 2>&1
  echo "=== $(date) fasterq-dump: $ACC ==="
  fasterq-dump --split-3 -e 8 -O "$FASTQ_DIR" "${SRA_DIR}/${ACC}/${ACC}.sra" > "${FASTQ_DIR}/${ACC}.dump.log" 2>&1
  rm -rf "${SRA_DIR:?}/${ACC}"
  echo "=== $(date) done $ACC ==="
}
export -f download_one

D4_SAMPLES="SRR5252835 SRR5252843 SRR5252844 SRR5252853 SRR5252855 SRR5252860 SRR5252861 SRR5252862"
D2_SAMPLES="SRR13280656 SRR13280726"

for s in $D4_SAMPLES; do echo "$s d4_sra d4_rnaseq"; done > /tmp/f5_download_jobs.txt
for s in $D2_SAMPLES; do echo "$s d2_sra d2_rnaseq"; done >> /tmp/f5_download_jobs.txt

cat /tmp/f5_download_jobs.txt | parallel -j 5 --colsep ' ' download_one {1} {2} {3}
echo "=== $(date) ALL F5 DOWNLOADS DONE ==="
