#!/usr/bin/env bash
set -euo pipefail

echo "=== Cleanup disk started at $(date) ==="

echo "=== BEFORE ==="
df -h
journalctl --disk-usage || true
du -sh /tmp /var/cache/apt 2>/dev/null || true

echo "=== 1. Clear tmp ==="
find /tmp -mindepth 1 -mtime +1 -exec rm -rf {} + || true

echo "=== 2. Clean snap ==="
if command -v snap >/dev/null 2>&1; then
  snap set system refresh.retain=2 || true

  snap list --all | awk '/disabled/{print $1, $3}' | \
  while read -r snapname revision; do
    [ -z "$snapname" ] && continue
    echo "Removing disabled snap: $snapname revision $revision"
    snap remove "$snapname" --revision="$revision" || true
  done
else
  echo "snap command not found, skip clean snap"
fi

echo "=== 3. Clean logs ==="
journalctl --vacuum-time=3d || true

echo "=== 4. Clean apt cache ==="
apt clean || true

echo "=== AFTER ==="
df -h
journalctl --disk-usage || true
du -sh /tmp /var/cache/apt 2>/dev/null || true

echo "=== Cleanup disk finished at $(date) ==="
