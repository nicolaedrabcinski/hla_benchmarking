#!/bin/bash
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
cd ${REPO_ROOT}/data/input/raw
set -x

# arcasHLA's STAR alignment step holds the ~30GB genome index in RAM; run it
# alone first (this is a shared machine) before piling on the other tools.
bash run_d8synth_arcashla.sh > d8synth_arcashla.log 2>&1

# Independent tools (no shared dependency) launched in parallel.
bash run_d8synth_hisatgeno.sh  > d8synth_hisatgeno.log  2>&1 &
bash run_d8synth_hlaforest.sh  > d8synth_hlaforest.log  2>&1 &
bash run_d8synth_hlahd.sh      > d8synth_hlahd.log      2>&1 &
bash run_d8synth_hlaminer.sh   > d8synth_hlaminer.log   2>&1 &
bash run_d8synth_hlapers.sh    > d8synth_hlapers.log    2>&1 &
bash run_d8synth_optitype.sh   > d8synth_optitype.log   2>&1 &
bash run_d8synth_seq2hla.sh    > d8synth_seq2hla.log    2>&1 &
bash run_d8synth_t1k.sh        > d8synth_t1k.log        2>&1 &
bash run_d8synth_rna2hla.sh    > d8synth_rna2hla.log    2>&1 &

wait
echo "=== $(date) ALL D8-SYNTHETIC TOOL RUNS FINISHED ==="
