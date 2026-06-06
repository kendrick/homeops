#!/bin/bash
# sync-to-vault.sh: rsync sanitized homeops content into the Obsidian iCloud
# vault mirror so it's browseable from phone. Idempotent. Run on demand or
# auto-fired by the Stop hook in post-session-discipline-check.sh.
#
# Vault paths come from scripts/lib/vault-config.sh (which reads .working-memoryrc
# with defaults). Mirror manifest is inline below — keep aligned with
# sync-from-vault.sh.

set -eu

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
source "$REPO_ROOT/scripts/lib/vault-config.sh"

if [ "$VAULT_CONFIGURED" != "true" ]; then
  _vault_unconfigured_msg
  exit 0
fi

if [ ! -d "$VAULT_ROOT" ]; then
  echo "✗ Vault root configured but not present on disk: $VAULT_ROOT" >&2
  echo "  Check HOMEOPS_VAULT_ROOT in .env." >&2
  exit 0
fi

mkdir -p "$VAULT_MIRROR_FULL/docs/phases" "$VAULT_MIRROR_FULL/working-memory"

# Mirror manifest. Keep aligned with sync-from-vault.sh.
# `--update` prevents clobbering vault-side edits that are newer than the
# repo version (e.g., Obsidian edits during a Claude session). Without it,
# the Stop-hook auto-push would silently overwrite in-progress edits.
copy() {
  local src="$REPO_ROOT/$1"
  local dst="$VAULT_MIRROR_FULL/$2"
  if [ -f "$src" ]; then
    rsync -a --update "$src" "$dst"
    return 0
  fi
  return 1
}

PUSHED=0

copy "docs/prd.md"                              "docs/prd.md"                              && PUSHED=$((PUSHED + 1))
copy "docs/decisions.md"                        "docs/decisions.md"                        && PUSHED=$((PUSHED + 1))
copy "docs/inventory.md"                        "docs/inventory.md"                        && PUSHED=$((PUSHED + 1))
copy "docs/phases/crawl.md"                     "docs/phases/crawl.md"                     && PUSHED=$((PUSHED + 1))
copy "docs/phases/walk.md"                      "docs/phases/walk.md"                      && PUSHED=$((PUSHED + 1))
copy "docs/phases/run.md"                       "docs/phases/run.md"                       && PUSHED=$((PUSHED + 1))
copy "_working-memory/projectOverview.md"       "working-memory/projectOverview.md"        && PUSHED=$((PUSHED + 1))
copy "_working-memory/openQuestions.md"         "working-memory/openQuestions.md"          && PUSHED=$((PUSHED + 1))
copy "_working-memory/antipatterns.md"          "working-memory/antipatterns.md"           && PUSHED=$((PUSHED + 1))

# Update sync marker. Mtime is the reference point for vault-side edit detection
# in homeops-session-start.sh.
touch "$VAULT_MIRROR_FULL/.last-sync"

echo "✓ Pushed $PUSHED file(s) to vault mirror."
echo "  $VAULT_MIRROR_FULL"
echo "  iCloud will sync to phone within a minute or two."
