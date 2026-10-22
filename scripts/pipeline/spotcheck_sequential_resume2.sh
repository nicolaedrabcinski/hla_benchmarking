#!/bin/bash
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
# Strictly sequential: one (tool, sample) job at a time, each using up to 60 threads.
# Resume after server reboot (2026-10-15). hlaforest/t1k/hlavbseq/hlaminer/seq2hla/rna2hla already 15/15 done.
set -uo pipefail
cd ${REPO_ROOT}/data/input/raw
MAMBA=mamba
T=60
SAMPLES_FILE=/tmp/d1_spotcheck_samples.txt

log() { echo "=== $(date) $* ==="; }

run_hlahd() {
  local S="$1"
  local HLAHD_BIN=${REPO_ROOT}/tools/hlahd.1.7.1/bin
  [ -f "d1_spotcheck_hlahd/${S}/result/${S}_final.result.txt" ] && { log "skip hlahd $S"; return; }
  log "hlahd $S start"
  # FIXED 2026-10-15: (1) PATH did not include hlahd's own bin/ (pm_extract/split_pm_read/
  # split_shell/hla_est/stfr/drop_intron_map/pick_up_allele/get_diff_fasta called by bare name,
  # "command not found" after the reboot); (2) default -m 100 (minimum_tag_size) is longer than
  # this D1 cohort's 75bp reads, so `stfr -L 100` filtered out every read -> empty R1/R2.fastq ->
  # "Not typed" for every locus. -m 50 lets 75bp reads pass. Verified end-to-end on ERR188101
  # (real A/B/C/DRB1/DQB1 calls, DONE_EXIT=0, ~56 min wall at -t 60).
  "$MAMBA" run -n hlahd bash -c "
    export PATH=\"\$PATH:$HLAHD_BIN\"
    bash $HLAHD_BIN/hlahd.sh -t $T -m 50 \
      -f $HLAHD_BIN/../freq_data \
      'd1_spotcheck_rnaseq/${S}_1.fastq' 'd1_spotcheck_rnaseq/${S}_2.fastq' \
      $HLAHD_BIN/../HLA_gene.split.txt \
      $HLAHD_BIN/../dictionary \
      '$S' d1_spotcheck_hlahd
  " > "d1_spotcheck_hlahd/${S}.log" 2>&1
  log "hlahd $S done (exit $?)"
}

run_hisatgenotype() {
  local S="$1"
  local O="d1_spotcheck_hisatgenotype/${S}"
  [ -d "$O" ] && [ -n "$(find "$O" -iname '*.report' 2>/dev/null)" ] && { log "skip hisatgenotype $S"; return; }
  mkdir -p "$O"
  log "hisatgenotype $S start"
  "$MAMBA" run -n hisatgeno ${REPO_ROOT}/tools/hisat-genotype/hisatgenotype \
    -1 "d1_spotcheck_rnaseq/${S}_1.fastq" -2 "d1_spotcheck_rnaseq/${S}_2.fastq" \
    --base genotype_genome -z ${REPO_ROOT}/tools/hisat-genotype/indicies \
    --out-dir "$O" -p $T --locus-list A,B,C,DRB1,DQB1 \
    > "d1_spotcheck_hisatgenotype/${S}.log" 2>&1
  log "hisatgenotype $S done (exit $?)"
}

run_hlapers() {
  local S="$1"
  local O="d1_spotcheck_hlapers/${S}"
  [ -f "${O}_hlaquant.tsv" ] && { log "skip hlapers $S"; return; }
  log "hlapers $S start"
  "$MAMBA" run -n hlapers bash ${REPO_ROOT}/tools/HLApers/script/run_genotypingkallisto.sh \
    ${REPO_ROOT}/data/input/raw/hlapers_index.idx \
    "d1_spotcheck_rnaseq/${S}_1.fastq" "d1_spotcheck_rnaseq/${S}_2.fastq" "$O" $T \
    > "d1_spotcheck_hlapers/${S}.log" 2>&1
  log "hlapers $S done (exit $?)"
}

run_phlat() {
  local S="$1"
  [ -f "d1_spotcheck_phlat/${S}_HLA.sum" ] && { log "skip phlat $S"; return; }
  log "phlat $S start"
  "$MAMBA" run -n phlat python2.7 /tmp/phlat_custom_current/dist/PHLAT.py \
    -1 "d1_spotcheck_rnaseq/${S}_1.fastq" -2 "d1_spotcheck_rnaseq/${S}_2.fastq" \
    -index phlat_index_build/index4phlat_current -b2url "$(command -v bowtie2 || mamba run -n bowtie2 command -v bowtie2)" \
    -tag "$S" -p $T -e /tmp/phlat_custom_current -o d1_spotcheck_phlat -pe 1 \
    > "d1_spotcheck_phlat/${S}.log" 2>&1
  log "phlat $S done (exit $?)"
}

run_optitype() {
  local S="$1"
  local O="d1_spotcheck_optitype/${S}"
  [ -f "${O}/${S}_result.tsv" ] && { log "skip optitype $S"; return; }
  mkdir -p "$O"
  log "optitype $S start"
  "$MAMBA" run -n optitype optitype run \
    -i "d1_spotcheck_rnaseq/${S}_1.fastq" -i "d1_spotcheck_rnaseq/${S}_2.fastq" \
    --rna -o "$O" -p "$S" -b 0.009 --solver cbc --threads $T \
    > "$O/run.log" 2>&1
  log "optitype $S done (exit $?)"
}

run_arcashla() {
  local S="$1"
  local O="d1_spotcheck_arcashla/${S}"
  [ -d "${O}/genotype" ] && [ -n "$(find "${O}/genotype" -iname '*.json' 2>/dev/null)" ] && { log "skip arcashla $S"; return; }
  mkdir -p "$O"
  log "arcashla $S STAR start"
  STAR --runThreadN $T --genomeDir ${REPO_ROOT}/data/input/raw/star_index \
    --readFilesIn "d1_spotcheck_rnaseq/${S}_1.fastq" "d1_spotcheck_rnaseq/${S}_2.fastq" \
    --outSAMtype BAM SortedByCoordinate --outFileNamePrefix "$O/" > "$O/star.log" 2>&1
  samtools index "$O/Aligned.sortedByCoord.out.bam" 2>> "$O/star.log"
  log "arcashla $S extract"
  ${REPO_ROOT}/tools/arcasHLA/arcasHLA extract "$O/Aligned.sortedByCoord.out.bam" -o "$O/extracted" -t $T >> "d1_spotcheck_arcashla/${S}.log" 2>&1
  log "arcashla $S genotype"
  ${REPO_ROOT}/tools/arcasHLA/arcasHLA genotype "$O/extracted/"*.1.fastq.gz "$O/extracted/"*.2.fastq.gz -o "$O/genotype" -t $T >> "d1_spotcheck_arcashla/${S}.log" 2>&1
  rm -f "$O/Aligned.sortedByCoord.out.bam" "$O/Aligned.sortedByCoord.out.bam.bai"
  log "arcashla $S done (exit $?)"
}

export -f log run_hlahd run_hisatgenotype run_hlapers run_phlat run_optitype run_arcashla
export MAMBA T

RESOURCE_CSV=d1_spotcheck_resource_usage.csv
if [ ! -f "$RESOURCE_CSV" ]; then
  echo "Tool,Sample,Wall_s,User_s,Sys_s,CPU_pct,MaxRSS_KB" > "$RESOURCE_CSV"
fi

timed_run() {
  local tool="$1" S="$2"
  local TIMELOG=$(mktemp)
  /usr/bin/time -v -o "$TIMELOG" bash -c "run_${tool} '$S'"
  if [ -s "$TIMELOG" ] && grep -q "Elapsed (wall clock)" "$TIMELOG"; then
    local wall user sys cpu rss wall_s
    wall=$(grep "Elapsed (wall clock)" "$TIMELOG" | awk -F': ' '{print $2}')
    wall_s=$(echo "$wall" | awk -F: '{if(NF==3) print $1*3600+$2*60+$3; else print $1*60+$2}')
    user=$(grep "User time" "$TIMELOG" | awk -F': ' '{print $2}')
    sys=$(grep "System time" "$TIMELOG" | awk -F': ' '{print $2}')
    cpu=$(grep "Percent of CPU" "$TIMELOG" | awk -F': ' '{print $2}' | tr -d '%')
    rss=$(grep "Maximum resident set size" "$TIMELOG" | awk -F': ' '{print $2}')
    echo "${tool},${S},${wall_s},${user},${sys},${cpu},${rss}" >> "$RESOURCE_CSV"
  else
    echo "${tool},${S},NA,NA,NA,NA,NA" >> "$RESOURCE_CSV"
  fi
  rm -f "$TIMELOG"
}
export -f timed_run

# --- master sequential loop: finish each tool across all 15 samples before moving to the next ---
for tool in hlahd hisatgenotype hlapers phlat optitype arcashla; do
  while read -r S; do
    timed_run "$tool" "$S"
  done < "$SAMPLES_FILE"
  log "TOOL $tool FULLY DONE"
done
log "ALL SPOTCHECK SEQUENTIAL DONE"
