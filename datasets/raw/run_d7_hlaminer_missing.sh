#!/bin/bash
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
set -uo pipefail
cd ${REPO_ROOT}/datasets/raw
REF=${REPO_ROOT}/tools/HLAminer/HLAminer-1.4/database/HLA-I_II_CDS.fasta
HLAMINER=${REPO_ROOT}/tools/HLAminer/HLAminer-1.4/bin/HLAminer.pl
PDB=${REPO_ROOT}/tools/HLAminer/HLAminer-1.4/database/hla_nom_p.txt

run_one() {
  local SAMPLE="$1"
  local OUT="d7_hlaminer_missing/${SAMPLE}"
  mkdir -p "$OUT"
  echo "=== $(date) HLAminer bwa aln (single-end): $SAMPLE ==="
  bwa aln -e 0 -o 0 -t 4 "$REF" "d7_t1k_fastq/${SAMPLE}.fastq" > "$OUT/aln.sai" 2>"$OUT/bwa_aln.log"
  bwa samse "$REF" "$OUT/aln.sai" "d7_t1k_fastq/${SAMPLE}.fastq" > "$OUT/aln.sam" 2>"$OUT/bwa_samse.log"
  echo "=== $(date) HLAminer predicting: $SAMPLE ==="
  (cd "$OUT" && perl "$HLAMINER" -a aln.sam -h "$REF" -p "$PDB" -s 500 > hlaminer_run.log 2>&1)
  echo "=== $(date) done $SAMPLE (exit $?) ==="
}
export -f run_one
export REF HLAMINER PDB

for s in SRR7881406 SRR7881414 SRR7881423; do echo "$s"; done | parallel -j 3 run_one {}
echo "=== $(date) ALL D7 HLAMINER MISSING DONE ==="
