#!/bin/bash
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
set -uo pipefail
cd ${REPO_ROOT}/datasets/raw
REF=${REPO_ROOT}/tools/HLAminer/HLAminer-1.4/database/HLA-I_II_CDS.fasta
HLAMINER=${REPO_ROOT}/tools/HLAminer/HLAminer-1.4/bin/HLAminer.pl
PDB=${REPO_ROOT}/tools/HLAminer/HLAminer-1.4/database/hla_nom_p.txt
OUT=d1_spotcheck_hlaminer
mkdir -p "$OUT"
run_one() {
  local S="$1"
  local O="$OUT/${S}"
  mkdir -p "$O"
  echo "=== $(date) HLAminer bwa aln (paired): $S ==="
  bwa aln -e 0 -o 0 -t 4 "$REF" "d1_spotcheck_rnaseq/${S}_1.fastq" > "$O/aln1.sai" 2>"$O/bwa_aln1.log"
  bwa aln -e 0 -o 0 -t 4 "$REF" "d1_spotcheck_rnaseq/${S}_2.fastq" > "$O/aln2.sai" 2>"$O/bwa_aln2.log"
  bwa sampe -o 1000 "$REF" "$O/aln1.sai" "$O/aln2.sai" "d1_spotcheck_rnaseq/${S}_1.fastq" "d1_spotcheck_rnaseq/${S}_2.fastq" > "$O/aln.sam" 2>"$O/bwa_sampe.log"
  echo "=== $(date) HLAminer predicting: $S ==="
  (cd "$O" && perl "$HLAMINER" -a aln.sam -h "$REF" -p "$PDB" -s 500 > hlaminer_run.log 2>&1)
  echo "=== $(date) done $S (exit $?) ==="
}
export -f run_one
export REF HLAMINER PDB OUT
cat /tmp/d1_spotcheck_samples.txt | parallel -j 6 run_one {}
echo "=== $(date) ALL SPOTCHECK HLAMINER DONE ==="
