#!/bin/bash
# run-audit.sh: kick off the quarterly homeops discipline audit.
# Intended to be invoked manually OR offered by the SessionStart hook when
# .last-audit is missing or older than the staleness threshold.
#
# Steps it runs (each delegates to a dedicated script when possible):
#   1. PII sweep across tracked content (scripts/audit-pii.sh)
#   2. Discipline drift heuristics (scripts/discipline-check.sh)
#   3. Re-read of the working-memory files (printed paths for human review)
#   4. Touch _working-memory/.last-audit so the staleness clock resets
#
# This script does NOT fix what it finds. It surfaces. The human (or a
# subsequent agent session) does the actual reconciliation.

set -eu
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$REPO_ROOT"

echo "=========================================="
echo "homeops discipline audit"
echo "started: $(date)"
echo "=========================================="
echo

echo "## 1. PII sweep"
if bash scripts/audit-pii.sh; then
  echo "  result: clean"
else
  echo "  result: candidates found above — review and scrub before next push"
fi
echo

echo "## 2. Discipline drift"
bash scripts/discipline-check.sh
PENDING="$REPO_ROOT/_working-memory/.pending-actions"
if [ -s "$PENDING" ]; then
  echo "  result: drift detected"
  cat "$PENDING" | sed 's/^/  /'
else
  echo "  result: no drift"
fi
echo

echo "## 3. Working-memory files to review"
echo "  Open each in your editor; check for staleness, broken assumptions, etc."
for f in conventions.md antipatterns.md openQuestions.md networkContracts.md projectOverview.md; do
  path="$REPO_ROOT/_working-memory/$f"
  if [ -f "$path" ]; then
    mtime=$(stat -f %Sm -t %Y-%m-%d "$path" 2>/dev/null || stat -c %y "$path" 2>/dev/null | cut -d' ' -f1)
    echo "  - $f (last touched: $mtime)"
  fi
done
echo

echo "## 4. Reset staleness clock"
date +%Y-%m-%d > "$REPO_ROOT/_working-memory/.last-audit"
echo "  touched _working-memory/.last-audit ($(cat "$REPO_ROOT/_working-memory/.last-audit"))"
echo

echo "=========================================="
echo "audit done."
echo
echo "Next: if any drift / PII / stale conventions surfaced above, open"
echo "a session and walk through the items. The audit clock has been reset."
echo "=========================================="
