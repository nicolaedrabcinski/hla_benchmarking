#!/bin/bash
set -e
cd /home/nicolaedrabcinski/hla_benchmarking/repo/datasets/raw
REF=/home/nicolaedrabcinski/hla_benchmarking/tools/HLAminer/HLAminer-1.4/database/HLA-I_II_CDS.fasta
HLAMINER=/home/nicolaedrabcinski/hla_benchmarking/tools/HLAminer/HLAminer-1.4/bin/HLAminer.pl
for SAMPLE in mother father daughter; do
  echo "=== $(date) HLAminer bwa aln: $SAMPLE ==="
  OUT=d8_hlaminer/${SAMPLE}
  mkdir -p $OUT
  bwa aln -e 0 -o 0 -t 16 $REF d8_rnaseq/${SAMPLE}.final.1.fastq > $OUT/aln.1.sai
  bwa aln -e 0 -o 0 -t 16 $REF d8_rnaseq/${SAMPLE}.final.2.fastq > $OUT/aln.2.sai
  bwa sampe -o 1000 $REF $OUT/aln.1.sai $OUT/aln.2.sai d8_rnaseq/${SAMPLE}.final.1.fastq d8_rnaseq/${SAMPLE}.final.2.fastq > $OUT/aln.sam
  echo "=== $(date) HLAminer predicting: $SAMPLE ==="
  cd $OUT
  perl $HLAMINER -a aln.sam -h $REF -p /home/nicolaedrabcinski/hla_benchmarking/tools/HLAminer/HLAminer-1.4/database/hla_nom_p.txt -s 500
  cd /home/nicolaedrabcinski/hla_benchmarking/repo/datasets/raw
  echo "=== $(date) finished HLAminer: $SAMPLE ==="
done
echo "=== $(date) ALL D8 HLAMINER DONE ==="
