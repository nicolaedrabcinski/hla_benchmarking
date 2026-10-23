#!/bin/bash
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
# PHLAT on D8 (real trio, local FASTQ) and D7 (10x 3' scRNA-seq, re-downloaded because its BAMs are
# gone), from the chrisamiller/phlat:1.1_withindex image used for D1-D6 and MAGE.
set -uo pipefail
cd ${REPO_ROOT}/data/input/raw
T=8
PHLAT_IMAGE=chrisamiller/phlat:1.1_withindex
log() { echo "=== $(date) $* ==="; }

# args: input dir, output dir, sample, read 1 (in the input dir), read 2 or "" for single-end
phlat() {
  local IN="$1" OUT="$2" S="$3" A="$4" B="$5" READS
  if [ -n "$B" ]; then READS=(-1 "/in/$A" -2 "/in/$B" -pe 1); else READS=(-1 "/in/$A" -pe 0); fi
  mkdir -p "$OUT"
  # the image ships PHLAT's modules as .pyo files, which python2.7 only loads with -O
  /usr/bin/docker run --rm --user "$(id -u):$(id -g)" -v "$PWD/$IN:/in:ro" -v "$PWD/$OUT:/out" "$PHLAT_IMAGE" \
    python2.7 -O /opt/dist/PHLAT.py "${READS[@]}" -index /opt/b2folder -b2url /usr/bin/bowtie2 \
    -tag "$S" -p $T -e /opt -o /out > "$OUT/${S}.log" 2>&1
  log "PHLAT $S exit $?"
}

for S in father mother daughter; do
  [ -s "d8_phlat/${S}_HLA.sum" ] || phlat d8_rnaseq d8_phlat "$S" "${S}.final.1.fastq" "${S}.final.2.fastq"
done

d7_one() {
  local ACC="$1" FQ="d7_phlat_reads/$1"
  [ -s "d7_phlat/${ACC}_HLA.sum" ] && return 0
  mkdir -p "$FQ"
  log "download $ACC"
  prefetch --max-size 100G -O "$FQ" "$ACC" > "$FQ/prefetch.log" 2>&1
  fasterq-dump --split-3 -e 4 -O "$FQ" "$FQ/$ACC/$ACC.sra" > "$FQ/dump.log" 2>&1
  rm -rf "${FQ:?}/$ACC"
  if [ -s "$FQ/${ACC}_1.fastq" ] && [ -s "$FQ/${ACC}_2.fastq" ]; then
    # 10x read 1 holds only the cell barcode and UMI; type from the cDNA read alone
    local len
    len=$(head -n 4000 "$FQ/${ACC}_1.fastq" | awk 'NR%4==2 {n++; s+=length($0)} END {print int(s/n)}')
    if [ "$len" -le 30 ]; then phlat "$FQ" d7_phlat "$ACC" "${ACC}_2.fastq" ""
    else phlat "$FQ" d7_phlat "$ACC" "${ACC}_1.fastq" "${ACC}_2.fastq"; fi
  elif [ -s "$FQ/${ACC}.fastq" ]; then
    phlat "$FQ" d7_phlat "$ACC" "${ACC}.fastq" ""
  else
    log "DOWNLOAD FAILED $ACC"
  fi
  rm -rf "${FQ:?}"
}
export -f d7_one phlat log
export T PHLAT_IMAGE
tail -n +2 ${REPO_ROOT}/data/gold_standard/7_gs.csv | cut -d, -f1 | xargs -P 2 -I{} bash -c 'd7_one {}'
log "D7 and D8 PHLAT finished"
