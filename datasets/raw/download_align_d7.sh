#!/bin/bash
cd /home/nicolaedrabcinski/hla_benchmarking/repo/datasets/raw
SRA_DIR=d7_sra
FASTQ_DIR=d7_rnaseq
BAM_DIR=d7_bams
mkdir -p $SRA_DIR $FASTQ_DIR $BAM_DIR

while read -r ACC; do
  [ -z "$ACC" ] && continue
  BAM=$BAM_DIR/${ACC}_Aligned.sortedByCoord.out.bam
  if [ -s "$BAM" ]; then
    echo "=== $(date) skip (BAM exists): $ACC ==="
    continue
  fi

  echo "=== $(date) prefetch: $ACC ==="
  prefetch --max-size 50G -O $SRA_DIR $ACC
  if [ ! -f "$SRA_DIR/$ACC/$ACC.sra" ]; then
    echo "=== $(date) FAILED (prefetch): $ACC ==="
    continue
  fi

  echo "=== $(date) fasterq-dump: $ACC ==="
  fasterq-dump --split-3 -e 32 -O $FASTQ_DIR $SRA_DIR/$ACC/$ACC.sra
  rm -rf $SRA_DIR/$ACC

  R1=$FASTQ_DIR/${ACC}_1.fastq
  R2=$FASTQ_DIR/${ACC}_2.fastq
  SE=$FASTQ_DIR/${ACC}.fastq
  UNSORTED_PREFIX=$BAM_DIR/${ACC}_

  echo "=== $(date) STAR align (unsorted): $ACC ==="
  if [ -s "$R1" ] && [ -s "$R2" ]; then
    STAR --runThreadN 32 --genomeDir star_index/ \
         --readFilesIn $R1 $R2 \
         --outSAMtype BAM Unsorted --quantMode GeneCounts \
         --outFileNamePrefix $UNSORTED_PREFIX
  elif [ -s "$SE" ]; then
    STAR --runThreadN 32 --genomeDir star_index/ \
         --readFilesIn $SE \
         --outSAMtype BAM Unsorted --quantMode GeneCounts \
         --outFileNamePrefix $UNSORTED_PREFIX
  else
    echo "=== $(date) FAILED (no fastq output): $ACC ==="
    continue
  fi
  rm -f "$R1" "$R2" "$SE"

  UNSORTED_BAM=${UNSORTED_PREFIX}Aligned.out.bam
  if [ ! -s "$UNSORTED_BAM" ]; then
    echo "=== $(date) FAILED (STAR): $ACC ==="
    continue
  fi

  echo "=== $(date) samtools sort: $ACC ==="
  samtools sort -@ 16 -m 1500M -T $BAM_DIR/${ACC}_sorttmp -o $BAM $UNSORTED_BAM
  rm -f "$UNSORTED_BAM"

  if [ -s "$BAM" ]; then
    echo "=== $(date) done: $ACC ==="
  else
    echo "=== $(date) FAILED (samtools sort): $ACC ==="
  fi
done < /home/nicolaedrabcinski/hla_benchmarking/repo/accession/d7_list.txt
echo "=== $(date) ALL D7 DOWNLOAD+ALIGN DONE ==="
