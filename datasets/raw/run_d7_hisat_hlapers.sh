#!/bin/bash
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
cd ${REPO_ROOT}/datasets/raw

MM=mamba
BAM_DIR=d7_bams
FQ_DIR=d7_fastq_tmp
mkdir -p $FQ_DIR d7_hlapers d7_hisatgeno

THREADS=8

while read -r ACC; do
  [ -z "$ACC" ] && continue
  BAM=$BAM_DIR/${ACC}_Aligned.sortedByCoord.out.bam
  if [ ! -s "$BAM" ]; then
    echo "=== $(date) SKIP (no BAM): $ACC ==="
    continue
  fi

  SE=$FQ_DIR/${ACC}.fastq

  need_hlapers=1
  [ -s "d7_hlapers/${ACC}/genotypes.tsv" ] && need_hlapers=0
  need_hisat=1
  [ -d "d7_hisatgeno/${ACC}" ] && [ -n "$(ls -A d7_hisatgeno/${ACC} 2>/dev/null)" ] && need_hisat=0

  if { [ "$need_hlapers" = "1" ] || [ "$need_hisat" = "1" ]; } && [ ! -s "$SE" ]; then
    echo "=== $(date) extract single-end fastq: $ACC ==="
    samtools fastq -@ $THREADS "$BAM" > "$SE"
  fi

  if [ "$need_hlapers" = "1" ]; then
    echo "=== $(date) HLApers (single-end): $ACC ==="
    mkdir -p d7_hlapers/${ACC}
    $MM run -n hlapers kallisto quant -i hlapers_index.idx -t $THREADS \
      --single -l 200 -s 20 -o d7_hlapers/${ACC} "$SE"
    $MM run -n hlapers Rscript ${REPO_ROOT}/tools/HLApers/script/genotype_kallisto.R d7_hlapers/${ACC}
  fi

  if [ "$need_hisat" = "1" ]; then
    echo "=== $(date) HISAT-genotype (single-end): $ACC ==="
    mkdir -p d7_hisatgeno/${ACC}
    $MM run -n hisatgeno bash -c "
      export PATH=${REPO_ROOT}/tools/hisat-genotype:${REPO_ROOT}/tools/hisat-genotype/hisat2:\$PATH
      export PYTHONPATH=${REPO_ROOT}/tools/hisat-genotype/hisatgenotype_modules:\$PYTHONPATH
      hisatgenotype -x genotype_genome --base hla -U $SE --out-dir d7_hisatgeno/${ACC} -p $THREADS
    "
  fi

  rm -f "$SE"
  echo "=== $(date) ALL-TOOLS DONE: $ACC ==="
done < ${REPO_ROOT}/accession/d7_list.txt
echo "=== $(date) D7 HISAT+HLAPERS FULLY DONE ==="
