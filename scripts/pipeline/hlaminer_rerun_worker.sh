#!/bin/bash
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
# Re-run HLAminer and PHLAT on one D1-D6 sample, downloading the reads once. HLAminer uses the
# commands of the D1 spot-check re-run (the original hlaminer_d*.csv calls match nobody's gold standard); PHLAT
# runs from the chrisamiller/phlat:1.1_withindex image, since the official index is no longer
# downloadable.
# Args: dataset number, sample id as in the gold standard, run accession(s) joined by ';'.
set -uo pipefail
DS="$1"; ID="$2"; RUNS="$3"
cd ${REPO_ROOT}/data/input/raw
T=8
O=rerun_hlaminer/d${DS}/${ID}
P=rerun_phlat/d${DS}/${ID}
FQ=rerun_hlaminer/reads/${ID}
REF=${REPO_ROOT}/tools/HLAminer/HLAminer-1.4/database/HLA-I_II_CDS.fasta
PHLAT_IMAGE=chrisamiller/phlat:1.1_withindex
log() { echo "=== $(date) [D${DS} ${ID}] $* ==="; }
hlaminer_done() { [ -s "$O/HLAminer_HPRA.csv" ]; }
phlat_done() { [ -s "$P/${ID}_HLA.sum" ]; }

mkdir -p "$O" "$P"
# D1 spot-check samples were already re-run with these commands
if [ "$DS" = 1 ]; then
  if ! hlaminer_done && [ -s "d1_spotcheck_hlaminer/${ID}/HLAminer_HPRA.csv" ]; then
    cp "d1_spotcheck_hlaminer/${ID}/HLAminer_HPRA.csv" "$O/"
    log "HLAminer copied from the D1 spot-check run"
  fi
  if ! phlat_done && [ -s "phlat_docker_test/${ID}_HLA.sum" ]; then
    cp "phlat_docker_test/${ID}_HLA.sum" "$P/"
    log "PHLAT copied from the D1 spot-check run"
  fi
fi
hlaminer_done && phlat_done && { log "already done"; exit 0; }
mkdir -p "$FQ"

log "download $RUNS"
for R in ${RUNS//;/ }; do
  prefetch --max-size 50G -O "$FQ" "$R" > "$FQ/${R}.prefetch.log" 2>&1
  fasterq-dump --split-3 -e 4 -O "$FQ" "$FQ/${R}/${R}.sra" > "$FQ/${R}.dump.log" 2>&1
  rm -rf "${FQ:?}/${R}"
done
# a sample with several runs is typed from all of them together
cat "$FQ"/*_1.fastq > "$FQ/all_1.fq" 2>/dev/null
cat "$FQ"/*_2.fastq > "$FQ/all_2.fq" 2>/dev/null
cat $(ls "$FQ"/*.fastq 2>/dev/null | grep -v -E '_[12]\.fastq$') /dev/null > "$FQ/all_se.fq"
rm -f "$FQ"/*.fastq
if [ -s "$FQ/all_1.fq" ] && [ -s "$FQ/all_2.fq" ]; then PE=1
elif [ -s "$FQ/all_se.fq" ]; then PE=0
else log "DOWNLOAD FAILED"; rm -rf "${FQ:?}"; exit 1
fi

rc=0
if ! hlaminer_done; then
  log "HLAminer"
  if [ "$PE" = 1 ]; then
    bwa aln -e 0 -o 0 -t $T "$REF" "$FQ/all_1.fq" > "$O/aln1.sai" 2>"$O/bwa_aln1.log"
    bwa aln -e 0 -o 0 -t $T "$REF" "$FQ/all_2.fq" > "$O/aln2.sai" 2>"$O/bwa_aln2.log"
    bwa sampe -o 1000 "$REF" "$O/aln1.sai" "$O/aln2.sai" "$FQ/all_1.fq" "$FQ/all_2.fq" > "$O/aln.sam" 2>"$O/bwa_sampe.log"
  else
    bwa aln -e 0 -o 0 -t $T "$REF" "$FQ/all_se.fq" > "$O/aln1.sai" 2>"$O/bwa_aln1.log"
    bwa samse "$REF" "$O/aln1.sai" "$FQ/all_se.fq" > "$O/aln.sam" 2>"$O/bwa_samse.log"
  fi
  (cd "$O" && perl ${REPO_ROOT}/tools/HLAminer/HLAminer-1.4/bin/HLAminer.pl -a aln.sam -h "$REF" \
    -p ${REPO_ROOT}/tools/HLAminer/HLAminer-1.4/database/hla_nom_p.txt -s 500 > hlaminer_run.log 2>&1)
  rc=$?
  rm -f "$O/aln.sam" "$O"/aln*.sai
fi

if ! phlat_done; then
  log "PHLAT"
  # the image ships PHLAT's modules as .pyo files, which python2.7 only loads with -O
  if [ "$PE" = 1 ]; then READS=(-1 /in/all_1.fq -2 /in/all_2.fq -pe 1); else READS=(-1 /in/all_se.fq -pe 0); fi
  /usr/bin/docker run --rm --user "$(id -u):$(id -g)" -v "$PWD/$FQ:/in:ro" -v "$PWD/$P:/out" "$PHLAT_IMAGE" \
    python2.7 -O /opt/dist/PHLAT.py "${READS[@]}" -index /opt/b2folder -b2url /usr/bin/bowtie2 \
    -tag "$ID" -p $T -e /opt -o /out > "$P/phlat_run.log" 2>&1
  prc=$?
  [ $prc -ne 0 ] && rc=$prc
fi
rm -rf "${FQ:?}"
log "done (exit $rc)"
exit $rc
