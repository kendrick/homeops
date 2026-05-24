#!/bin/bash
# homeops-session-start.sh: SessionStart hook (homeops-specific).
# Surfaces pending actions, pending ADR drafts, and audit staleness.
# Runs after the kit's working-memory-session-start.sh.

set -eu
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

[ ! -d "$REPO_ROOT/_working-memory" ] && exit 0

PARTS=()

# Pending actions (from discipline-check)
PENDING="$REPO_ROOT/_working-memory/.pending-actions"
if [ -s "$PENDING" ]; then
  content=$(tr '\n' ' ' < "$PENDING" | head -c 400)
  PARTS+=("📝 Pending: $content")
fi

# Pending ADR drafts (from LLM-assisted Stop hook, when enabled)
PENDING_ADR_DIR="$REPO_ROOT/_working-memory/.pending-adrs"
if [ -d "$PENDING_ADR_DIR" ]; then
  count=$(find "$PENDING_ADR_DIR" -name '*.md' -type f 2>/dev/null | wc -l | tr -d ' ')
  if [ "${count:-0}" -gt 0 ]; then
    PARTS+=("📝 $count ADR draft(s) staged in .pending-adrs/.")
  fi
fi

# Audit staleness
AUDIT_FILE="$REPO_ROOT/_working-memory/.last-audit"
if [ -f "$AUDIT_FILE" ]; then
  last_ts=$(stat -f %m "$AUDIT_FILE" 2>/dev/null || stat -c %Y "$AUDIT_FILE" 2>/dev/null || echo 0)
  now_ts=$(date +%s)
  days=$(( (now_ts - last_ts) / 86400 ))
  if [ "$days" -gt 90 ]; then
    PARTS+=("⚠️ Discipline audit overdue (${days} days since last).")
  fi
elif [ -f "$REPO_ROOT/_working-memory/conventions.md" ]; then
  PARTS+=("ℹ️ No discipline audit recorded yet — quarterly schedule recommended.")
fi

if [ "${#PARTS[@]}" -gt 0 ]; then
  msg="${PARTS[*]}"
  escaped=$(printf '%s' "$msg" | sed 's/\\/\\\\/g; s/"/\\"/g')
  echo "{\"systemMessage\":\"$escaped\"}"
fi

exit 0
