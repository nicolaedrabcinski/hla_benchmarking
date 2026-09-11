#!/bin/bash
cd /home/nicolaedrabcinski/hla_benchmarking/repo/datasets/raw

MM=/home/nicolaedrabcinski/miniforge3/bin/mamba
BAM_DIR=d7_bams
FQ_DIR=d7_fastq_tmp
mkdir -p $FQ_DIR d7_seq2hla d7_hlaforest d7_hlapers d7_hisatgeno d7_hlahd

THREADS=2

while read -r ACC; do
  [ -z "$ACC" ] && continue
  BAM=$BAM_DIR/${ACC}_Aligned.sortedByCoord.out.bam
  if [ ! -s "$BAM" ]; then
    echo "=== $(date) SKIP (no BAM): $ACC ==="
    continue
  fi

  R1=$FQ_DIR/${ACC}_1.fastq
  R2=$FQ_DIR/${ACC}_2.fastq

  need_fastq=0
  [ ! -s "$FQ_DIR/../d7_seq2hla/${ACC}-ClassI-class.HLAgenotype4digits" ] && need_fastq=1
  [ ! -s "d7_hlaforest/${ACC}/haplotypes.txt" ] && need_fastq=1
  [ ! -s "d7_hlapers/${ACC}/genotypes.tsv" ] && need_fastq=1
  [ ! -d "d7_hisatgeno/${ACC}" ] && need_fastq=1
  [ ! -s "d7_hlahd/${ACC}/result/${ACC}_final.result.txt" ] && need_fastq=1

  if [ "$need_fastq" = "1" ] && [ ! -s "$R1" ]; then
    echo "=== $(date) extract fastq: $ACC ==="
    samtools collate -@ $THREADS -O $BAM $FQ_DIR/${ACC}_collate_tmp \
      | samtools fastq -@ $THREADS -1 $R1 -2 $R2 -0 /dev/null -s /dev/null -n -
  fi

  # 1) seq2HLA
  if [ ! -s "d7_seq2hla/${ACC}-ClassI-class.HLAgenotype4digits" ]; then
    echo "=== $(date) seq2HLA: $ACC ==="
    $MM run -n seq2hla seq2HLA -1 $R1 -2 $R2 -r d7_seq2hla/${ACC} -p $THREADS
  fi

  # 2) HLAforest
  if [ ! -s "d7_hlaforest/${ACC}/haplotypes.txt" ]; then
    echo "=== $(date) HLAforest: $ACC ==="
    mkdir -p d7_hlaforest/${ACC}
    $MM run -n hlaforest bash /home/nicolaedrabcinski/hla_benchmarking/tools/hlaforest/scripts/CallHaplotypesPE.sh \
      d7_hlaforest/${ACC}/ $R1 $R2
  fi

  # 3) HLApers
  if [ ! -s "d7_hlapers/${ACC}/genotypes.tsv" ]; then
    echo "=== $(date) HLApers: $ACC ==="
    $MM run -n hlapers /home/nicolaedrabcinski/hla_benchmarking/tools/HLApers/hlapers genotype \
      -i hlapers_index.idx -1 $R1 -2 $R2 -p $THREADS -o d7_hlapers/${ACC} --kallisto
  fi

  # 4) HISAT-genotype
  if [ ! -d "d7_hisatgeno/${ACC}" ] || [ -z "$(ls -A d7_hisatgeno/${ACC} 2>/dev/null)" ]; then
    echo "=== $(date) HISAT-genotype: $ACC ==="
    mkdir -p d7_hisatgeno/${ACC}
    $MM run -n hisatgeno bash -c "
      export PATH=/home/nicolaedrabcinski/hla_benchmarking/tools/hisat-genotype:/home/nicolaedrabcinski/hla_benchmarking/tools/hisat-genotype/hisat2:\$PATH
      export PYTHONPATH=/home/nicolaedrabcinski/hla_benchmarking/tools/hisat-genotype/hisatgenotype_modules:\$PYTHONPATH
      hisatgenotype -x genotype_genome --base hla -1 $R1 -2 $R2 --out-dir d7_hisatgeno/${ACC} -p $THREADS
    "
  fi

  # 5) HLA-HD
  if [ ! -s "d7_hlahd/${ACC}/result/${ACC}_final.result.txt" ]; then
    echo "=== $(date) HLA-HD: $ACC ==="
    mkdir -p d7_hlahd/${ACC}
    $MM run -n hlahd bash -c "
      export PATH=/home/nicolaedrabcinski/hla_benchmarking/tools/hlahd.1.7.1/bin:\$PATH
      cd /home/nicolaedrabcinski/hla_benchmarking/tools/hlahd.1.7.1
      bash bin/hlahd.sh -t $THREADS -m 100 -f freq_data/ \
        /home/nicolaedrabcinski/hla_benchmarking/repo/datasets/raw/$R1 \
        /home/nicolaedrabcinski/hla_benchmarking/repo/datasets/raw/$R2 \
        HLA_gene.split.txt dictionary/ ${ACC} \
        /home/nicolaedrabcinski/hla_benchmarking/repo/datasets/raw/d7_hlahd/
    "
  fi

  rm -f $R1 $R2
  echo "=== $(date) ALL-TOOLS DONE: $ACC ==="
done < /home/nicolaedrabcinski/hla_benchmarking/repo/accession/d7_list.txt
echo "=== $(date) D7 REMAINING TOOLS FULLY DONE ==="
