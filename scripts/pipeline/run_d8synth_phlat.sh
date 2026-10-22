#!/bin/bash
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
set -uo pipefail
cd ${REPO_ROOT}/data/input/raw
B2="$(command -v bowtie2 || mamba run -n bowtie2 command -v bowtie2)"
PY2="mamba run -n phlat python2.7"
PHLAT_DIST=${REPO_ROOT}/tools/phlat/phlat-release
FQ=d8_synthetic_rnaseq
OUT=d8_synth_phlat
mkdir -p "$OUT"
for S in mother father daughter; do
  echo "=== $(date) PHLAT (SYNTHETIC): $S ==="
  $PY2 "$PHLAT_DIST/dist/PHLAT.py" \
    -1 "$FQ/${S}.synth_R1.fastq" -2 "$FQ/${S}.synth_R2.fastq" \
    -index phlat_index_build/index4phlat_current -b2url "$B2" \
    -tag "$S" -p 16 -e "$PHLAT_DIST" -o "$OUT" -pe 1 \
    > "$OUT/${S}.log" 2>&1
  echo "=== $(date) finished PHLAT (SYNTHETIC): $S ==="
done
echo "=== $(date) ALL D8-SYNTH PHLAT DONE ==="
