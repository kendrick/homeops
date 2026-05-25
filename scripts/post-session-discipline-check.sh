#!/bin/bash
# post-session-discipline-check.sh: Stop hook entry point.
# Runs discipline-check, auto-regenerates decisionLog if needed, surfaces
# pending actions via the Claude Code hook protocol (JSON systemMessage).

set -eu
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

# Bail silently outside working-memory projects
[ ! -d "$REPO_ROOT/_working-memory" ] && exit 0

bash "$REPO_ROOT/scripts/discipline-check.sh" 2>/dev/null || true

# If decisions.md changed in last 5 commits, auto-regenerate decisionLog
# (idempotent — safe to run even if log is already current)
if git -C "$REPO_ROOT" log -5 --name-only --pretty=format: 2>/dev/null \
     | grep -q "docs/decisions.md"; then
  bash "$REPO_ROOT/scripts/regen-decision-log.sh" >/dev/null 2>&1 || true
fi

# Refresh the Obsidian vault mirror so the phone stays current.
# Always-on (idempotent + fast); rsync only copies changed files. Silent if
# the vault doesn't exist (e.g., on a machine without Obsidian).
bash "$REPO_ROOT/scripts/sync-to-vault.sh" >/dev/null 2>&1 || true

# Emit pending actions as systemMessage if any
PENDING="$REPO_ROOT/_working-memory/.pending-actions"
if [ -s "$PENDING" ]; then
  # Collapse to single line, escape for JSON
  content=$(tr '\n' ' ' < "$PENDING" | head -c 500)
  escaped=$(printf '%s' "$content" | sed 's/\\/\\\\/g; s/"/\\"/g')
  echo "{\"systemMessage\":\"⚠️ homeops pending: ${escaped}\"}"
fi

exit 0
