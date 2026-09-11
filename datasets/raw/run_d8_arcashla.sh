#!/bin/bash
set -e
cd /home/nicolaedrabcinski/hla_benchmarking/repo/datasets/raw

ARCASHLA=/home/nicolaedrabcinski/hla_benchmarking/tools/arcasHLA/arcasHLA
OUT_DIR=d8_arcashla/
mkdir -p ${OUT_DIR}

for SAMPLE in mother father daughter; do
    BAM=d8_bams/${SAMPLE}_Aligned.sortedByCoord.out.bam

    echo "=== $(date) indexing BAM: $SAMPLE ==="
    samtools index -@ 16 ${BAM}

    echo "=== $(date) arcasHLA extract: $SAMPLE ==="
    ${ARCASHLA} extract ${BAM} -o ${OUT_DIR} -t 16 --log ${OUT_DIR}${SAMPLE}.extract.log

    R1=$(find ${OUT_DIR} -name "${SAMPLE}_Aligned.sortedByCoord.out.extracted.1.fq.gz")
    R2=$(find ${OUT_DIR} -name "${SAMPLE}_Aligned.sortedByCoord.out.extracted.2.fq.gz")
    echo "extracted fastqs: $R1 $R2"

    echo "=== $(date) arcasHLA genotype: $SAMPLE ==="
    ${ARCASHLA} genotype ${R1} ${R2} -o ${OUT_DIR} -t 16 --log ${OUT_DIR}${SAMPLE}.genotype.log

    echo "=== $(date) finished arcasHLA: $SAMPLE ==="
done

echo "=== $(date) ALL D8 ARCASHLA DONE ==="
