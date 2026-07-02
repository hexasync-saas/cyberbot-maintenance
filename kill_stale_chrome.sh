#!/usr/bin/env bash
set -euo pipefail

MAX_AGE_MINUTES=120
MAX_CPU_PERCENT=1.0
DRY_RUN="${DRY_RUN:-false}"

echo "=== Kill stale Chrome started at $(date) ==="

ps -eo pid,etimes,pcpu,comm,args --no-headers \
| awk -v max_age="$((MAX_AGE_MINUTES * 60))" -v max_cpu="$MAX_CPU_PERCENT" '
  $4 ~ /^(chrome|chromium|google-chrome|chrome_crashpad_handler)$/ {
    pid=$1
    age=$2
    cpu=$3
    if (age > max_age && cpu < max_cpu) {
      print pid
    }
  }
' \
| while read -r pid; do
    [ -z "$pid" ] && continue

    if [ "$DRY_RUN" = "true" ]; then
      echo "Would kill stale Chrome PID: $pid"
    else
      echo "Killing stale Chrome PID: $pid"
      kill -TERM "$pid" || true
    fi
  done

echo "=== Kill stale Chrome finished at $(date) ==="
