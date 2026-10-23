#!/bin/bash
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
# One MAGE run (D1 individual re-sequenced at 150 bp): download, all 12 callers, delete reads.
# Tools already finished for this run are skipped, so a re-queued run only redoes what failed.
set -uo pipefail
ACC="$1"
cd ${REPO_ROOT}/data/input/raw
# background jobs do not get the login shell's conda setup, so use absolute paths
MAMBA=${MAMBA:-$(command -v mamba || echo $HOME/miniforge3/bin/mamba)}
BOWTIE2=$(command -v bowtie2 || echo $HOME/miniforge3/envs/bowtie2/bin/bowtie2)
T=12
SRA=mage_sra
FQ=mage_rnaseq
R1="$FQ/${ACC}_1.fastq"
R2="$FQ/${ACC}_2.fastq"
RESOURCE_CSV=mage_resource_usage.csv
mkdir -p "$SRA" "$FQ"
[ -f "$RESOURCE_CSV" ] || echo "Tool,Sample,Wall_s,User_s,Sys_s,CPU_pct,MaxRSS_KB,Exit" > "$RESOURCE_CSV"

log() { echo "=== $(date) [$ACC] $* ==="; }

# wait until the machine has this much memory available (GB); HLA-HD on D8-synth shares it
wait_mem() {
  while [ "$(awk '/MemAvailable/ {print int($2/1048576)}' /proc/meminfo)" -lt "$1" ]; do sleep 60; done
}

run_t1k() {
  [ -f "mage_t1k/${ACC}_genotype.tsv" ] && return 0
  mkdir -p mage_t1k
  $MAMBA run -n t1k run-t1k -1 "$R1" -2 "$R2" -f t1k_ref/hlaidx_rna_seq.fa --preset hla -t $T \
    -o "$ACC" --od mage_t1k/ > "mage_t1k/${ACC}.log" 2>&1
}

run_seq2hla() {
  [ -f "mage_seq2hla/${ACC}-ClassI-class.HLAgenotype4digits" ] && return 0
  mkdir -p mage_seq2hla
  $MAMBA run -n seq2hla seq2HLA -1 "$R1" -2 "$R2" -r "mage_seq2hla/${ACC}" -p $T > "mage_seq2hla/${ACC}.log" 2>&1
}

run_optitype() {
  local O="mage_optitype/${ACC}"
  [ -f "$O/${ACC}_result.tsv" ] && return 0
  mkdir -p "$O"
  $MAMBA run -n optitype optitype run -i "$R1" -i "$R2" --rna -o "$O" -p "$ACC" -b 0.009 --solver cbc \
    --threads $T > "$O/run.log" 2>&1
}

run_hlaminer() {
  local O="mage_hlaminer/${ACC}"
  [ -f "$O/HLAminer_HPRA.csv" ] && return 0
  local REF=${REPO_ROOT}/tools/HLAminer/HLAminer-1.4/database/HLA-I_II_CDS.fasta
  mkdir -p "$O"
  bwa aln -e 0 -o 0 -t $T "$REF" "$R1" > "$O/aln1.sai" 2>"$O/bwa_aln1.log"
  bwa aln -e 0 -o 0 -t $T "$REF" "$R2" > "$O/aln2.sai" 2>"$O/bwa_aln2.log"
  bwa sampe -o 1000 "$REF" "$O/aln1.sai" "$O/aln2.sai" "$R1" "$R2" > "$O/aln.sam" 2>"$O/bwa_sampe.log"
  (cd "$O" && perl ${REPO_ROOT}/tools/HLAminer/HLAminer-1.4/bin/HLAminer.pl -a aln.sam -h "$REF" \
    -p ${REPO_ROOT}/tools/HLAminer/HLAminer-1.4/database/hla_nom_p.txt -s 500 > hlaminer_run.log 2>&1)
  local rc=$?
  rm -f "$O/aln.sam" "$O/aln1.sai" "$O/aln2.sai"
  return $rc
}

run_hlavbseq() {
  [ -f "mage_hlavbseq/${ACC}_result.txt" ] && return 0
  local REF=${REPO_ROOT}/tools/HLA-VBSeq/hla_all_v2.fasta
  local DEPS=${REPO_ROOT}/tools/HLA-VBSeq/deps
  local CP="${REPO_ROOT}/tools/HLA-VBSeq/HLAVBSeq.jar:${DEPS}/picard-1.74.jar:${DEPS}/sam-1.74.jar:${DEPS}/args4j-2.0.23.jar:${DEPS}/commons-math3-3.0.jar:${DEPS}/ssj-2.5.jar"
  mkdir -p mage_hlavbseq
  bwa mem -t $T -P -L 10000 -a "$REF" "$R1" "$R2" > "mage_hlavbseq/${ACC}.sam" 2>"mage_hlavbseq/${ACC}.bwa.log"
  java -cp "$CP" org.csml.tigar2.Test "$REF" "mage_hlavbseq/${ACC}.sam" "mage_hlavbseq/${ACC}_result.txt" \
    --alpha_zero 0.01 --is_paired > "mage_hlavbseq/${ACC}.typing.log" 2>&1
  local rc=$?
  rm -f "mage_hlavbseq/${ACC}.sam"
  return $rc
}

run_hlapers() {
  local O="mage_hlapers/${ACC}"
  [ -s "$O/genotypes.tsv" ] && return 0
  mkdir -p "$O"
  $MAMBA run -n hlapers bash ${REPO_ROOT}/tools/HLApers/script/run_genotypingkallisto.sh \
    ${REPO_ROOT}/data/input/raw/hlapers_index.idx "$R1" "$R2" "$O" $T > "mage_hlapers/${ACC}.log" 2>&1
}

run_hlaforest() {
  [ -f "mage_hlaforest/${ACC}/haplotypes.txt" ] && return 0
  mkdir -p "mage_hlaforest/${ACC}"
  $MAMBA run -n hlaforest bash ${REPO_ROOT}/tools/hlaforest/scripts/CallHaplotypesPE.sh \
    "mage_hlaforest/${ACC}/" "$R1" "$R2" > "mage_hlaforest/${ACC}.log" 2>&1
}

run_phlat() {
  [ -f "mage_phlat/${ACC}_HLA.sum" ] && return 0
  local DIST=${REPO_ROOT}/tools/phlat/phlat-release
  mkdir -p mage_phlat
  $MAMBA run -n phlat python2.7 "$DIST/dist/PHLAT.py" -1 "$R1" -2 "$R2" \
    -index phlat_index_build/index4phlat_current -b2url "$BOWTIE2" \
    -tag "$ACC" -p $T -e "$DIST" -o mage_phlat -pe 1 > "mage_phlat/${ACC}.log" 2>&1
}

run_hisatgeno() {
  local O="mage_hisatgeno/${ACC}"
  [ -n "$(find "$O" -iname '*.report' 2>/dev/null)" ] && return 0
  mkdir -p "$O"
  $MAMBA run -n hisatgeno ${REPO_ROOT}/tools/hisat-genotype/hisatgenotype -1 "$R1" -2 "$R2" \
    --base genotype_genome -z ${REPO_ROOT}/tools/hisat-genotype/indicies --out-dir "$O" -p $T \
    --locus-list A,B,C,DRB1,DQB1 > "mage_hisatgeno/${ACC}.log" 2>&1
}

run_hlahd() {
  [ -f "mage_hlahd/${ACC}/result/${ACC}_final.result.txt" ] && return 0
  local HD=${REPO_ROOT}/tools/hlahd.1.7.1
  mkdir -p mage_hlahd
  PATH=$HD/bin:$PATH $MAMBA run -n hlahd bash $HD/bin/hlahd.sh -t $T -f $HD/freq_data "$R1" "$R2" \
    $HD/HLA_gene.split.txt $HD/dictionary "$ACC" mage_hlahd > "mage_hlahd/${ACC}.log" 2>&1
}

run_rna2hla() {
  local D="mage_rna2hla/${ACC}"
  [ -s "$D/$ACC/${ACC}.HLAgenotype4digits.txt" ] && return 0
  mkdir -p "$D"
  ln -sf "$(pwd)/$R1" "$D/${ACC}.1.fastq"
  ln -sf "$(pwd)/$R2" "$D/${ACC}.2.fastq"
  (cd ${REPO_ROOT}/tools/RNA2HLA && $MAMBA run -n RNA2HLA_env python2 RNA2HLA.py \
    -f "${REPO_ROOT}/data/input/raw/$D" -r "$ACC" -p $T -3 0 -g 6 > "${REPO_ROOT}/data/input/raw/$D/run.log" 2>&1)
}

run_arcashla() {
  local O="mage_arcashla/${ACC}"
  [ -n "$(find "$O/genotype" -iname '*.json' 2>/dev/null)" ] && return 0
  local ARCAS=${REPO_ROOT}/tools/arcasHLA/arcasHLA
  mkdir -p "$O"
  # STAR holds the ~30 GB genome index in memory: one alignment at a time, and only with room to spare
  (
    flock 9
    wait_mem 45
    STAR --runThreadN $T --genomeDir ${REPO_ROOT}/data/input/raw/star_index --readFilesIn "$R1" "$R2" \
      --outSAMtype BAM SortedByCoordinate --outFileNamePrefix "$O/" > "$O/star.log" 2>&1
  ) 9> mage_star.lock
  samtools index "$O/Aligned.sortedByCoord.out.bam" 2>> "$O/star.log"
  "$ARCAS" extract "$O/Aligned.sortedByCoord.out.bam" -o "$O/extracted" -t $T >> "mage_arcashla/${ACC}.log" 2>&1
  "$ARCAS" genotype "$O/extracted/"*.1.f*q.gz "$O/extracted/"*.2.f*q.gz -o "$O/genotype" -t $T \
    >> "mage_arcashla/${ACC}.log" 2>&1
  local rc=$?
  rm -f "$O/Aligned.sortedByCoord.out.bam" "$O/Aligned.sortedByCoord.out.bam.bai"
  return $rc
}

timed_run() {
  local tool="$1" tl rc
  tl=$(mktemp)
  log "$tool start"
  /usr/bin/time -v -o "$tl" bash -c "run_${tool}"
  rc=$?
  if grep -q "Elapsed (wall clock)" "$tl" 2>/dev/null; then
    local wall user sys cpu rss
    wall=$(grep "Elapsed (wall clock)" "$tl" | awk -F': ' '{print $2}' | awk -F: '{if (NF==3) print $1*3600+$2*60+$3; else print $1*60+$2}')
    user=$(grep "User time" "$tl" | awk -F': ' '{print $2}')
    sys=$(grep "System time" "$tl" | awk -F': ' '{print $2}')
    cpu=$(grep "Percent of CPU" "$tl" | awk -F': ' '{print $2}' | tr -d '%')
    rss=$(grep "Maximum resident set size" "$tl" | awk -F': ' '{print $2}')
    echo "${tool},${ACC},${wall},${user},${sys},${cpu},${rss},${rc}" >> "$RESOURCE_CSV"
  fi
  rm -f "$tl"
  log "$tool done (exit $rc)"
}

export -f log wait_mem run_t1k run_seq2hla run_optitype run_hlaminer run_hlavbseq run_hlapers run_hlaforest \
  run_phlat run_hisatgeno run_hlahd run_rna2hla run_arcashla
export ACC MAMBA BOWTIE2 T R1 R2 REPO_ROOT

if [ ! -s "$R1" ] || [ ! -s "$R2" ]; then
  log "download"
  prefetch --max-size 50G -O "$SRA" "$ACC" > "$FQ/${ACC}.prefetch.log" 2>&1
  fasterq-dump --split-3 -e 4 -O "$FQ" "$SRA/${ACC}/${ACC}.sra" > "$FQ/${ACC}.dump.log" 2>&1
  rm -rf "${SRA:?}/${ACC}"
fi
if [ ! -s "$R1" ] || [ ! -s "$R2" ]; then
  log "DOWNLOAD FAILED"
  exit 1
fi

for tool in t1k seq2hla optitype hlaminer hlavbseq hlapers hlaforest phlat hisatgeno hlahd rna2hla arcashla; do
  wait_mem 20
  timed_run "$tool"
done
rm -f "$R1" "$R2"
log "ALL TOOLS DONE"
