#!/bin/bash
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
set -e
cd ${REPO_ROOT}/data/input/raw

GENOME_DIR=star_index/
OUT_DIR=d8_bams/
FASTQ_DIR=d8_rnaseq/

for SAMPLE in mother father daughter; do
    echo "=== $(date) starting STAR alignment: $SAMPLE ==="
    STAR --runThreadN 16 \
         --genomeDir ${GENOME_DIR} \
         --readFilesIn ${FASTQ_DIR}${SAMPLE}.final.1.fastq ${FASTQ_DIR}${SAMPLE}.final.2.fastq \
         --outSAMtype BAM SortedByCoordinate \
         --quantMode GeneCounts \
         --outFileNamePrefix ${OUT_DIR}${SAMPLE}_
    echo "=== $(date) finished STAR alignment: $SAMPLE ==="
done

echo "=== $(date) ALL D8 ALIGNMENTS DONE ==="
