#!/bin/bash
# sync-from-vault.sh: rsync homeops mirror content from the Obsidian iCloud
# vault back into the repo working tree. Use when you've edited a mirrored
# file in Obsidian (Mac or phone via iCloud) and want it reflected in git.
#
# After running this, `git status` will show modified files. Review with
# `git diff` and commit normally.
#
# Vault paths come from scripts/lib/vault-config.sh. Manifest matches
# sync-to-vault.sh.

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

if [ ! -d "$VAULT_MIRROR_FULL" ]; then
  echo "✗ Vault mirror not initialized at $VAULT_MIRROR_FULL. Run sync-to-vault.sh first." >&2
  exit 1
fi

# Mirror manifest. Keep aligned with sync-to-vault.sh.
copy() {
  local src="$VAULT_MIRROR_FULL/$1"
  local dst="$REPO_ROOT/$2"
  if [ -f "$src" ]; then
    rsync -a "$src" "$dst"
    return 0
  fi
  return 1
}

PULLED=0

copy "docs/prd.md"                              "docs/prd.md"                              && PULLED=$((PULLED + 1))
copy "docs/decisions.md"                        "docs/decisions.md"                        && PULLED=$((PULLED + 1))
copy "docs/inventory.md"                        "docs/inventory.md"                        && PULLED=$((PULLED + 1))
copy "docs/phases/crawl.md"                     "docs/phases/crawl.md"                     && PULLED=$((PULLED + 1))
copy "docs/phases/walk.md"                      "docs/phases/walk.md"                      && PULLED=$((PULLED + 1))
copy "docs/phases/run.md"                       "docs/phases/run.md"                       && PULLED=$((PULLED + 1))
copy "working-memory/projectOverview.md"        "_working-memory/projectOverview.md"       && PULLED=$((PULLED + 1))
copy "working-memory/openQuestions.md"          "_working-memory/openQuestions.md"         && PULLED=$((PULLED + 1))
copy "working-memory/antipatterns.md"           "_working-memory/antipatterns.md"          && PULLED=$((PULLED + 1))

# Reset sync marker so the session-start delta check resets.
touch "$VAULT_MIRROR_FULL/.last-sync"

echo "✓ Pulled $PULLED file(s) from vault into repo working tree."
echo ""
echo "Next:"
echo "  git status        # see what changed"
echo "  git diff          # review the edits"
echo "  # then stage + propose commit per the usual workflow"
