#!/bin/bash
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
# Feeds hlaminer_rerun_runs.tsv (dataset, sample id, runs) to hlaminer_rerun_worker.sh; the number of
# parallel samples is re-read from hlaminer_rerun_maxpar.txt on every pass.
cd ${REPO_ROOT}/data/input/raw
QUEUE=hlaminer_rerun_queue.tsv
[ -f "$QUEUE" ] || cp hlaminer_rerun_runs.tsv "$QUEUE"
mkdir -p rerun_hlaminer/logs

while true; do
  MAXPAR=$(cat hlaminer_rerun_maxpar.txt 2>/dev/null || echo 1)
  # count samples, not processes: subshells inside a worker show the same command line
  running=$(pgrep -af "^bash ${REPO_ROOT}/scripts/pipeline/hlaminer_rerun_worker.sh" | awk '{print $5}' | sort -u | wc -l)
  disk=$(df -BG --output=avail . | tail -1 | tr -dc 0-9)
  if [ "$running" -lt "$MAXPAR" ] && [ -s "$QUEUE" ] && [ "$disk" -ge 300 ]; then
    IFS=$'\t' read -r DS ID RUNS < "$QUEUE"
    tail -n +2 "$QUEUE" > "${QUEUE}.tmp" && mv "${QUEUE}.tmp" "$QUEUE"
    echo "=== $(date) launch D${DS} ${ID} (running=$running, disk=${disk}G) ==="
    nohup bash ${REPO_ROOT}/scripts/pipeline/hlaminer_rerun_worker.sh "$DS" "$ID" "$RUNS" \
      > "rerun_hlaminer/logs/d${DS}_${ID}.log" 2>&1 &
    sleep 20
  elif [ ! -s "$QUEUE" ] && [ "$running" -eq 0 ]; then
    echo "=== $(date) queue empty, all samples finished ==="
    break
  else
    sleep 60
  fi
done
