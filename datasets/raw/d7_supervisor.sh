#!/bin/bash
cd /home/nicolaedrabcinski/hla_benchmarking/repo/datasets/raw
QUEUE=/tmp/claude-1003/-home-nicolaedrabcinski-hla-benchmarking/8fcb41b2-c02a-483f-8c0b-91eb720ffa51/scratchpad/d7_fresh_remaining.txt
MAXPAR=6

while true; do
  running=$(pgrep -f "bash d7_worker.sh" | wc -l)
  if [ "$running" -lt "$MAXPAR" ] && [ -s "$QUEUE" ]; then
    ACC=$(head -1 "$QUEUE")
    tail -n +2 "$QUEUE" > "${QUEUE}.tmp" && mv "${QUEUE}.tmp" "$QUEUE"
    echo "=== $(date) supervisor launching: $ACC (running=$running) ==="
    nohup bash d7_worker.sh "$ACC" >> d7_parallel.log 2>&1 &
    disown
    sleep 5
  elif [ ! -s "$QUEUE" ] && [ "$running" -eq 0 ]; then
    echo "=== $(date) supervisor: queue empty and no workers running, exiting ==="
    break
  else
    sleep 30
  fi
done
