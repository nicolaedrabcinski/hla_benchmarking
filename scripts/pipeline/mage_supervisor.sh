#!/bin/bash
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
# Feeds data/input/accessions/d1_mage_list.txt to mage_worker.sh, MAXPAR runs at a time,
# starting a new run only when the shared machine has memory and disk to spare.
# MAXPAR is re-read from mage_maxpar.txt on every pass, so it can be changed while running.
cd ${REPO_ROOT}/data/input/raw
QUEUE=mage_queue.txt
[ -f "$QUEUE" ] || cp ${REPO_ROOT}/data/input/accessions/d1_mage_list.txt "$QUEUE"

while true; do
  MAXPAR=$(cat mage_maxpar.txt 2>/dev/null || echo 1)
  running=$(pgrep -f "bash ${REPO_ROOT}/scripts/pipeline/mage_worker.sh" | wc -l)
  mem=$(awk '/MemAvailable/ {print int($2/1048576)}' /proc/meminfo)
  disk=$(df -BG --output=avail . | tail -1 | tr -dc 0-9)
  if [ "$running" -lt "$MAXPAR" ] && [ -s "$QUEUE" ] && [ "$mem" -ge 30 ] && [ "$disk" -ge 200 ]; then
    ACC=$(head -1 "$QUEUE")
    tail -n +2 "$QUEUE" > "${QUEUE}.tmp" && mv "${QUEUE}.tmp" "$QUEUE"
    echo "=== $(date) launch $ACC (running=$running, mem=${mem}G, disk=${disk}G) ==="
    nohup bash ${REPO_ROOT}/scripts/pipeline/mage_worker.sh "$ACC" > "mage_${ACC}.log" 2>&1 &
    sleep 120
  elif [ ! -s "$QUEUE" ] && [ "$running" -eq 0 ]; then
    echo "=== $(date) queue empty, all runs finished ==="
    break
  else
    sleep 60
  fi
done
