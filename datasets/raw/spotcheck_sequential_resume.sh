#!/bin/bash
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
# Strictly sequential: one (tool, sample) job at a time, each using up to 60 threads.
set -uo pipefail
cd ${REPO_ROOT}/datasets/raw
MAMBA=mamba
T=60
SAMPLES_FILE=/tmp/d1_spotcheck_samples.txt

log() { echo "=== $(date) $* ==="; }

run_hlaforest() {
  local S="$1"
  [ -f "d1_spotcheck_hlaforest/${S}/haplotypes.txt" ] && { log "skip hlaforest $S"; return; }
  mkdir -p "d1_spotcheck_hlaforest/${S}"
  log "hlaforest $S start"
  "$MAMBA" run -n hlaforest bash ${REPO_ROOT}/tools/hlaforest/scripts/CallHaplotypesPE.sh \
    "d1_spotcheck_hlaforest/${S}/" "d1_spotcheck_rnaseq/${S}_1.fastq" "d1_spotcheck_rnaseq/${S}_2.fastq" \
    > "d1_spotcheck_hlaforest/${S}.log" 2>&1
  log "hlaforest $S done (exit $?)"
}

run_t1k() {
  local S="$1"
  [ -f "d1_spotcheck_t1k/${S}_genotype.tsv" ] && { log "skip t1k $S"; return; }
  log "t1k $S start"
  "$MAMBA" run -n t1k run-t1k -1 "d1_spotcheck_rnaseq/${S}_1.fastq" -2 "d1_spotcheck_rnaseq/${S}_2.fastq" \
    -f t1k_ref/hlaidx_rna_seq.fa --preset hla -t $T \
    -o "$S" --od "d1_spotcheck_t1k/" > "d1_spotcheck_t1k/${S}.log" 2>&1
  log "t1k $S done (exit $?)"
}

run_hlavbseq() {
  local S="$1"
  [ -f "d1_spotcheck_hlavbseq/${S}_result.txt" ] && { log "skip hlavbseq $S"; return; }
  local REF=${REPO_ROOT}/tools/HLA-VBSeq/hla_all_v2.fasta
  local EXTRACT_DIR=/tmp/claude-1003/-home-nicolaedrabcinski-hla-benchmarking/8fcb41b2-c02a-483f-8c0b-91eb720ffa51/scratchpad/hlavbseq_extract2
  local CP="${EXTRACT_DIR}:${EXTRACT_DIR}/picard-1.74.jar:${EXTRACT_DIR}/args4j-2.0.21.jar:${EXTRACT_DIR}/commons-math3-3.0.jar:${EXTRACT_DIR}/sam-1.74.jar:${EXTRACT_DIR}/ssj.jar"
  log "hlavbseq $S bwa mem start"
  bwa mem -t $T -P -L 10000 -a "$REF" "d1_spotcheck_rnaseq/${S}_1.fastq" "d1_spotcheck_rnaseq/${S}_2.fastq" > "d1_spotcheck_hlavbseq/${S}.sam" 2>"d1_spotcheck_hlavbseq/${S}.bwa.log"
  log "hlavbseq $S typing start"
  java -cp "$CP" org.csml.tigar2.Test "$REF" "d1_spotcheck_hlavbseq/${S}.sam" "d1_spotcheck_hlavbseq/${S}_result.txt" --alpha_zero 0.01 --is_paired > "d1_spotcheck_hlavbseq/${S}.typing.log" 2>&1
  rm -f "d1_spotcheck_hlavbseq/${S}.sam"
  log "hlavbseq $S done (exit $?)"
}

run_hlaminer() {
  local S="$1"
  [ -f "d1_spotcheck_hlaminer/${S}/HLAminer_HPRA.csv" ] && { log "skip hlaminer $S"; return; }
  local REF=${REPO_ROOT}/tools/HLAminer/HLAminer-1.4/database/HLA-I_II_CDS.fasta
  local HLAMINER=${REPO_ROOT}/tools/HLAminer/HLAminer-1.4/bin/HLAminer.pl
  local PDB=${REPO_ROOT}/tools/HLAminer/HLAminer-1.4/database/hla_nom_p.txt
  local O="d1_spotcheck_hlaminer/${S}"
  mkdir -p "$O"
  log "hlaminer $S bwa start"
  bwa aln -e 0 -o 0 -t $T "$REF" "d1_spotcheck_rnaseq/${S}_1.fastq" > "$O/aln1.sai" 2>"$O/bwa_aln1.log"
  bwa aln -e 0 -o 0 -t $T "$REF" "d1_spotcheck_rnaseq/${S}_2.fastq" > "$O/aln2.sai" 2>"$O/bwa_aln2.log"
  bwa sampe -o 1000 "$REF" "$O/aln1.sai" "$O/aln2.sai" "d1_spotcheck_rnaseq/${S}_1.fastq" "d1_spotcheck_rnaseq/${S}_2.fastq" > "$O/aln.sam" 2>"$O/bwa_sampe.log"
  log "hlaminer $S predicting"
  (cd "$O" && perl "$HLAMINER" -a aln.sam -h "$REF" -p "$PDB" -s 500 > hlaminer_run.log 2>&1)
  rm -f "$O/aln.sam" "$O/aln1.sai" "$O/aln2.sai"
  log "hlaminer $S done (exit $?)"
}

run_t1k() {
  local S="$1"
  [ -f "d1_spotcheck_t1k/${S}_genotype.tsv" ] && { log "skip t1k $S"; return; }
  log "t1k $S start"
  "$MAMBA" run -n t1k run-t1k -1 "d1_spotcheck_rnaseq/${S}_1.fastq" -2 "d1_spotcheck_rnaseq/${S}_2.fastq" \
    -f t1k_ref/hlaidx_rna_seq.fa --preset hla -t $T \
    -o "$S" --od "d1_spotcheck_t1k/" > "d1_spotcheck_t1k/${S}.log" 2>&1
  log "t1k $S done (exit $?)"
}

run_seq2hla() {
  local S="$1"
  [ -f "d1_spotcheck_seq2hla/${S}-ClassI-class.HLAgenotype4digits" ] && { log "skip seq2hla $S"; return; }
  log "seq2hla $S start"
  "$MAMBA" run -n seq2hla seq2HLA -1 "d1_spotcheck_rnaseq/${S}_1.fastq" -2 "d1_spotcheck_rnaseq/${S}_2.fastq" \
    -r "d1_spotcheck_seq2hla/${S}" -p $T > "d1_spotcheck_seq2hla/${S}.log" 2>&1
  log "seq2hla $S done (exit $?)"
}

run_hlahd() {
  local S="$1"
  [ -f "d1_spotcheck_hlahd/${S}/result/${S}_Class_all.txt" ] && { log "skip hlahd $S"; return; }
  log "hlahd $S start"
  "$MAMBA" run -n hlahd bash ${REPO_ROOT}/tools/hlahd.1.7.1/bin/hlahd.sh -t $T \
    -f ${REPO_ROOT}/tools/hlahd.1.7.1/freq_data \
    "d1_spotcheck_rnaseq/${S}_1.fastq" "d1_spotcheck_rnaseq/${S}_2.fastq" \
    ${REPO_ROOT}/tools/hlahd.1.7.1/HLA_gene.split.txt \
    ${REPO_ROOT}/tools/hlahd.1.7.1/dictionary \
    "$S" d1_spotcheck_hlahd > "d1_spotcheck_hlahd/${S}.log" 2>&1
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
    ${REPO_ROOT}/datasets/raw/hlapers_index.idx \
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
  STAR --runThreadN $T --genomeDir ${REPO_ROOT}/datasets/raw/star_index \
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

export -f log run_hlaforest run_t1k run_hlavbseq run_hlaminer run_seq2hla run_hlahd run_hisatgenotype run_hlapers run_phlat run_optitype run_arcashla
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
    local wall user sys cpu rss
    wall=$(grep "Elapsed (wall clock)" "$TIMELOG" | awk -F': ' '{print $2}')
    # convert h:mm:ss or m:ss to seconds
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
for tool in t1k hlavbseq hlahd hisatgenotype hlapers phlat optitype arcashla; do
  while read -r S; do
    timed_run "$tool" "$S"
  done < "$SAMPLES_FILE"
  log "TOOL $tool FULLY DONE"
done
log "ALL SPOTCHECK SEQUENTIAL DONE"
