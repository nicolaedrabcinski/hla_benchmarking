#!/bin/bash
set -uo pipefail
cd /home/nicolaedrabcinski/hla_benchmarking/datasets/raw
B2=/home/nicolaedrabcinski/miniforge3/envs/bowtie2/bin/bowtie2
PY2="/home/nicolaedrabcinski/miniforge3/bin/mamba run -n phlat python2.7"
SAMPLES="SRR5252835 SRR5252843 SRR5252844 SRR5252855 SRR5252860 SRR5252861 SRR5252862"

run_one() {
  local SAMPLE="$1"
  local INDEXVER="$2"
  local PHLATDIR="/tmp/phlat_custom_${INDEXVER}/dist"
  local OUT="d4_phlat_missing_${INDEXVER}"
  mkdir -p "$OUT"
  echo "=== $(date) PHLAT ($INDEXVER): $SAMPLE ==="
  $PY2 "$PHLATDIR/PHLAT.py" \
    -1 "d4_rnaseq/${SAMPLE}_1.fastq" -2 "d4_rnaseq/${SAMPLE}_2.fastq" \
    -index "phlat_index_build/index4phlat_${INDEXVER}" -b2url "$B2" \
    -tag "$SAMPLE" -p 60 -e "/tmp/phlat_custom_${INDEXVER}" -o "$OUT" -pe 1 \
    > "${OUT}/${SAMPLE}.log" 2>&1
  echo "=== $(date) finished PHLAT ($INDEXVER): $SAMPLE (exit $?) ==="
}
export -f run_one
export B2 PY2

for s in $SAMPLES; do echo "$s 380"; done > /tmp/f5_phlat_jobs.txt
for s in $SAMPLES; do echo "$s current"; done >> /tmp/f5_phlat_jobs.txt

cat /tmp/f5_phlat_jobs.txt | parallel -j 1 --colsep ' ' run_one {1} {2}
echo "=== $(date) ALL F5 PHLAT DONE ==="
