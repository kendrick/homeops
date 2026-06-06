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

# Audit staleness.
# Threshold defaults to 90 days but can be overridden via .env
# (key: AUDIT_STALENESS_DAYS).
STALENESS_DAYS="${WORKING_MEMORY_AUDIT_STALENESS_DAYS:-90}"
if [ -f "$REPO_ROOT/.env" ]; then
  cfg_val=$(grep -E '^AUDIT_STALENESS_DAYS=' "$REPO_ROOT/.env" 2>/dev/null | head -1 | cut -d= -f2- | tr -d ' "'"'"'')
  [ -n "$cfg_val" ] && STALENESS_DAYS="$cfg_val"
fi

AUDIT_FILE="$REPO_ROOT/_working-memory/.last-audit"
FALLBACK_FILE="$REPO_ROOT/_working-memory/conventions.md"

# If .last-audit exists, age it. Otherwise fall back to conventions.md mtime
# (proxy for "when did this project's discipline get set up"). This way the
# clock starts ticking from install, not from the first manual audit.
reference_file=""
if [ -f "$AUDIT_FILE" ]; then
  reference_file="$AUDIT_FILE"
elif [ -f "$FALLBACK_FILE" ]; then
  reference_file="$FALLBACK_FILE"
fi

if [ -n "$reference_file" ]; then
  last_ts=$(stat -f %m "$reference_file" 2>/dev/null || stat -c %Y "$reference_file" 2>/dev/null || echo 0)
  now_ts=$(date +%s)
  days=$(( (now_ts - last_ts) / 86400 ))
  if [ "$days" -gt "$STALENESS_DAYS" ]; then
    if [ "$reference_file" = "$AUDIT_FILE" ]; then
      PARTS+=("⚠️ Discipline audit overdue (${days} days since last). Run \`bash scripts/run-audit.sh\` or ask me to.")
    else
      PARTS+=("⚠️ No discipline audit on record; conventions.md is ${days} days old. Run \`bash scripts/run-audit.sh\` or ask me to.")
    fi
  fi
fi

# Vault mirror delta detection.
# Compare each .md file in the vault mirror against its corresponding repo file.
# If the vault copy is newer, the maintainer edited it in Obsidian since the
# last import. Surface so they can decide whether to import via sync-from-vault.sh.
# Per-file comparison (instead of comparing against .last-sync) makes detection
# robust to within-session edits — the Stop hook's frequent firing doesn't mask
# them.
# Silently skip if vault isn't configured (.env not set up).
source "$REPO_ROOT/scripts/lib/vault-config.sh"

if [ "$VAULT_CONFIGURED" = "true" ] && [ -d "$VAULT_MIRROR_FULL" ]; then
  vault_newer=0
  while IFS= read -r vault_file; do
    # Map vault path → repo path. Only difference: vault has `working-memory/`,
    # repo has `_working-memory/`. Everything under `docs/` is identical.
    rel="${vault_file#$VAULT_MIRROR_FULL/}"
    case "$rel" in
      working-memory/*) repo_file="$REPO_ROOT/_working-memory/${rel#working-memory/}" ;;
      *)                repo_file="$REPO_ROOT/$rel" ;;
    esac
    if [ -f "$repo_file" ]; then
      vault_ts=$(stat -f %m "$vault_file" 2>/dev/null || stat -c %Y "$vault_file" 2>/dev/null || echo 0)
      repo_ts=$(stat -f %m "$repo_file" 2>/dev/null || stat -c %Y "$repo_file" 2>/dev/null || echo 0)
      [ "${vault_ts:-0}" -gt "${repo_ts:-0}" ] && vault_newer=$((vault_newer + 1))
    fi
  done < <(find "$VAULT_MIRROR_FULL" -type f -name '*.md' 2>/dev/null)

  if [ "$vault_newer" -gt 0 ]; then
    PARTS+=("🔄 ${vault_newer} vault file(s) newer than the repo. Run \`bash scripts/sync-from-vault.sh\` to import.")
  fi
fi

if [ "${#PARTS[@]}" -gt 0 ]; then
  msg="${PARTS[*]}"
  escaped=$(printf '%s' "$msg" | sed 's/\\/\\\\/g; s/"/\\"/g')
  echo "{\"systemMessage\":\"$escaped\"}"
fi

exit 0
