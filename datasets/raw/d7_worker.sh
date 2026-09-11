#!/bin/bash
ACC="$1"
cd /home/nicolaedrabcinski/hla_benchmarking/repo/datasets/raw

MM=/home/nicolaedrabcinski/miniforge3/bin/mamba
BAM_DIR=d7_bams
FQ_DIR=d7_fastq_tmp
THREADS=2

BAM=$BAM_DIR/${ACC}_Aligned.sortedByCoord.out.bam
if [ ! -s "$BAM" ]; then
  echo "=== $(date) [$ACC] SKIP (no BAM) ==="
  exit 0
fi

SE=$FQ_DIR/${ACC}.fastq

need_hlapers=1
[ -s "d7_hlapers/${ACC}/genotypes.tsv" ] && need_hlapers=0
need_hisat=1
ls d7_hisatgeno/${ACC}/*.report >/dev/null 2>&1 && need_hisat=0

if { [ "$need_hlapers" = "1" ] || [ "$need_hisat" = "1" ]; } && [ ! -s "$SE" ]; then
  echo "=== $(date) [$ACC] extract single-end fastq ==="
  samtools fastq -@ $THREADS "$BAM" > "$SE"
fi

if [ "$need_hlapers" = "1" ]; then
  echo "=== $(date) [$ACC] HLApers (single-end) ==="
  mkdir -p d7_hlapers/${ACC}
  $MM run -n hlapers kallisto quant -i hlapers_index.idx -t $THREADS \
    --single -l 200 -s 20 -o d7_hlapers/${ACC} "$SE"
  $MM run -n hlapers Rscript /home/nicolaedrabcinski/hla_benchmarking/tools/HLApers/script/genotype_kallisto.R d7_hlapers/${ACC}
fi

if [ "$need_hisat" = "1" ]; then
  echo "=== $(date) [$ACC] HISAT-genotype (single-end) ==="
  rm -rf d7_hisatgeno/${ACC}
  mkdir -p d7_hisatgeno/${ACC}
  $MM run -n hisatgeno bash -c "
    export PATH=/home/nicolaedrabcinski/hla_benchmarking/tools/hisat-genotype:/home/nicolaedrabcinski/hla_benchmarking/tools/hisat-genotype/hisat2:\$PATH
    export PYTHONPATH=/home/nicolaedrabcinski/hla_benchmarking/tools/hisat-genotype/hisatgenotype_modules:\$PYTHONPATH
    hisatgenotype -x genotype_genome --base hla -U $SE --out-dir d7_hisatgeno/${ACC} -p $THREADS
  "
fi

rm -f "$SE"
echo "=== $(date) [$ACC] ALL-TOOLS DONE ==="
