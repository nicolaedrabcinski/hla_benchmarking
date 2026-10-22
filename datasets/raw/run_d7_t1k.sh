#!/bin/bash
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
set -uo pipefail
cd ${REPO_ROOT}/datasets/raw
T1K="mamba run -n t1k run-t1k"

run_one() {
  local SRR="$1"
  if [ -f "d7_t1k/${SRR}_genotype.tsv" ]; then
    echo "=== $(date) skip $SRR (already done) ==="
    return 0
  fi
  echo "=== $(date) start $SRR ==="
  $T1K -u "d7_t1k_fastq/${SRR}.fastq" \
       -f t1k_ref/hlaidx_rna_seq.fa \
       --preset hla -t 16 \
       -o "$SRR" --od d7_t1k/ > "d7_t1k/${SRR}.log" 2>&1
  echo "=== $(date) done $SRR (exit $?) ==="
}
export -f run_one
export T1K

cat ${REPO_ROOT}/accession/d7_list.txt | parallel -j 4 run_one {}
echo "=== $(date) ALL D7 T1K DONE ==="
