# vault-config.sh: sourced helper that resolves Obsidian vault paths from .env.
#
# Consumers:
#   scripts/sync-to-vault.sh
#   scripts/sync-from-vault.sh
#   scripts/homeops-session-start.sh
#
# Reads (from .env at repo root):
#   HOMEOPS_VAULT_ROOT             — top-level dir Obsidian/iCloud syncs
#   HOMEOPS_VAULT_MIRROR_SUBPATH   — repo mirror location under VAULT_ROOT
#   HOMEOPS_VAULT_RAW_SUBPATH      — raw-thinking dir under VAULT_ROOT (PII-OK)
#
# Sets:
#   VAULT_ROOT, VAULT_MIRROR_SUBPATH, VAULT_RAW_SUBPATH (literal values from .env, or empty)
#   VAULT_MIRROR_FULL, VAULT_RAW_FULL (composed paths; empty if not configured)
#   VAULT_CONFIGURED=true|false (true iff all three required keys are set)
#
# No defaults are applied. Consumers must check VAULT_CONFIGURED before using
# the paths. See .env.example for the override file template.

# REPO_ROOT must be set by the caller before sourcing this file.
_HOMEOPS_ENV="${REPO_ROOT:-.}/.env"

_read_env_key() {
  local k="$1"
  if [ -f "$_HOMEOPS_ENV" ]; then
    grep -E "^${k}=" "$_HOMEOPS_ENV" 2>/dev/null | head -1 | cut -d= -f2- | sed -e 's/^"//;s/"$//;s/^'"'"'//;s/'"'"'$//'
  fi
  return 0
}

VAULT_ROOT=$(_read_env_key HOMEOPS_VAULT_ROOT)
VAULT_MIRROR_SUBPATH=$(_read_env_key HOMEOPS_VAULT_MIRROR_SUBPATH)
VAULT_RAW_SUBPATH=$(_read_env_key HOMEOPS_VAULT_RAW_SUBPATH)

VAULT_MIRROR_FULL=""
VAULT_RAW_FULL=""
VAULT_CONFIGURED="false"

if [ -n "$VAULT_ROOT" ] && [ -n "$VAULT_MIRROR_SUBPATH" ] && [ -n "$VAULT_RAW_SUBPATH" ]; then
  VAULT_MIRROR_FULL="$VAULT_ROOT/$VAULT_MIRROR_SUBPATH"
  VAULT_RAW_FULL="$VAULT_ROOT/$VAULT_RAW_SUBPATH"
  VAULT_CONFIGURED="true"
fi

# Helper for consumers: print a configure-me message to stderr.
_vault_unconfigured_msg() {
  cat >&2 <<EOF
ℹ️  Vault mirror is not configured. To enable Obsidian vault sync:
  1. cp .env.example .env
  2. Edit .env and set HOMEOPS_VAULT_ROOT, HOMEOPS_VAULT_MIRROR_SUBPATH, HOMEOPS_VAULT_RAW_SUBPATH
  3. Re-run this command.
EOF
}
