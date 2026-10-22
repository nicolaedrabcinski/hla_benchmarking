#!/bin/bash
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
set -uo pipefail
cd ${REPO_ROOT}/data/input/raw
REF=${REPO_ROOT}/tools/HLAminer/HLAminer-1.4/database/HLA-I_II_CDS.fasta
HLAMINER=${REPO_ROOT}/tools/HLAminer/HLAminer-1.4/bin/HLAminer.pl
PDB=${REPO_ROOT}/tools/HLAminer/HLAminer-1.4/database/hla_nom_p.txt
FQ=d8_synthetic_rnaseq
OUT=d8_synth_hlaminer
mkdir -p "$OUT"
for S in mother father daughter; do
  O="$OUT/${S}"
  mkdir -p "$O"
  echo "=== $(date) HLAminer bwa aln (SYNTHETIC): $S ==="
  bwa aln -e 0 -o 0 -t 16 "$REF" "$FQ/${S}.synth_R1.fastq" > "$O/aln1.sai" 2>"$O/bwa_aln1.log"
  bwa aln -e 0 -o 0 -t 16 "$REF" "$FQ/${S}.synth_R2.fastq" > "$O/aln2.sai" 2>"$O/bwa_aln2.log"
  bwa sampe -o 1000 "$REF" "$O/aln1.sai" "$O/aln2.sai" "$FQ/${S}.synth_R1.fastq" "$FQ/${S}.synth_R2.fastq" > "$O/aln.sam" 2>"$O/bwa_sampe.log"
  echo "=== $(date) HLAminer predicting (SYNTHETIC): $S ==="
  (cd "$O" && perl "$HLAMINER" -a aln.sam -h "$REF" -p "$PDB" -s 500 > hlaminer_run.log 2>&1)
  rm -f "$O/aln.sam"
  echo "=== $(date) finished HLAminer (SYNTHETIC): $S ==="
done
echo "=== $(date) ALL D8-SYNTH HLAMINER DONE ==="
