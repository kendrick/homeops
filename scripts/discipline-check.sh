#!/bin/bash
# discipline-check.sh: heuristic checks for documentation/state drift.
# Writes findings to _working-memory/.pending-actions; empty file removed.

set -eu
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
PENDING="$REPO_ROOT/_working-memory/.pending-actions"

[ ! -d "$REPO_ROOT/_working-memory" ] && exit 0

mkdir -p "$REPO_ROOT/_working-memory"
TMP="$PENDING.tmp"
> "$TMP"

# Drift 1: decisions.md changed in last 5 commits but decisionLog.md didn't
if git -C "$REPO_ROOT" log -5 --name-only --pretty=format: 2>/dev/null \
     | grep -q "docs/decisions.md"; then
  if ! git -C "$REPO_ROOT" log -5 --name-only --pretty=format: 2>/dev/null \
       | grep -q "_working-memory/decisionLog.md"; then
    echo "📝 decisions.md changed recently but decisionLog.md wasn't regenerated. Run scripts/regen-decision-log.sh." >> "$TMP"
  fi
fi

# Drift 2: recent commits look like infra changes but inventory.md wasn't touched
if git -C "$REPO_ROOT" log -5 --pretty=format:%s 2>/dev/null \
     | grep -iE '(install|deploy|configure).*(switch|sensor|coordinator|router|VM|LXC|lock|forgejo|tailscale|proxmox)' >/dev/null; then
  if ! git -C "$REPO_ROOT" log -5 --name-only --pretty=format: 2>/dev/null \
       | grep -q "docs/inventory.md"; then
    echo "📋 Recent commits look like infra changes but inventory.md wasn't updated." >> "$TMP"
  fi
fi

# Drift 3: pending ADR drafts staged but not resolved
PENDING_ADR_DIR="$REPO_ROOT/_working-memory/.pending-adrs"
if [ -d "$PENDING_ADR_DIR" ]; then
  count=$(find "$PENDING_ADR_DIR" -name '*.md' -type f 2>/dev/null | wc -l | tr -d ' ')
  if [ "${count:-0}" -gt 0 ]; then
    echo "📝 $count pending ADR draft(s) in _working-memory/.pending-adrs/ — review and merge or delete." >> "$TMP"
  fi
fi

if [ -s "$TMP" ]; then
  mv "$TMP" "$PENDING"
else
  rm -f "$PENDING" "$TMP"
fi

exit 0
