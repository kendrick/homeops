#!/bin/bash
# audit-pii.sh: sweep the working tree for personally-identifying tokens.
# Exit 1 if any candidate match remains after keeper-filtering; 0 otherwise.
# Used by scripts/git-hooks/pre-push and by the quarterly discipline audit.
#
# The actual PII tokens (real names, locations, etc.) MUST NOT live in
# this script's source — that would defeat the purpose of a public repo.
# Instead, tokens are read from .audit-pii-patterns (local-only, gitignored).
# Safe-context "keeper" filters live in .audit-pii-keepers (committed,
# public-safe — they describe SHAPES of false-positives, not real names).
#
# Bootstrap (after clone):
#   cp .audit-pii-patterns.example .audit-pii-patterns
#   $EDITOR .audit-pii-patterns   # add tokens you don't want leaking publicly
# The script will refuse to run until .audit-pii-patterns exists.

set -eu
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$REPO_ROOT"

PATTERNS_FILE="$REPO_ROOT/.audit-pii-patterns"
KEEPERS_FILE="$REPO_ROOT/.audit-pii-keepers"

if [ ! -f "$PATTERNS_FILE" ]; then
  echo "❌ audit-pii: $PATTERNS_FILE missing."
  echo "   This file is gitignored / local-only. Bootstrap with:"
  echo "     cp .audit-pii-patterns.example .audit-pii-patterns"
  echo "     \$EDITOR .audit-pii-patterns   # add your real tokens"
  exit 1
fi

# Compose patterns (one per line in the file) into a single grep -E alternation.
# Skip blank lines and comments.
PATTERNS=$(grep -vE '^[[:space:]]*(#|$)' "$PATTERNS_FILE" | paste -sd '|' -)

if [ -z "$PATTERNS" ]; then
  echo "✓ audit-pii: no patterns configured in $PATTERNS_FILE (nothing to check)"
  exit 0
fi

KEEPERS=""
if [ -f "$KEEPERS_FILE" ]; then
  KEEPERS=$(grep -vE '^[[:space:]]*(#|$)' "$KEEPERS_FILE" | paste -sd '|' -)
fi

# Scan only tracked files (git ls-files). Push only sends tracked content,
# so untracked / gitignored files (like .audit-pii-patterns itself) are
# correctly excluded. -z + xargs -0 handles paths with spaces.
matches=$(
  git ls-files -z \
  | xargs -0 grep -nEi \
      --exclude='*.png' --exclude='*.jpg' --exclude='*.jpeg' --exclude='*.heic' \
      "$PATTERNS" 2>/dev/null \
  | (if [ -n "$KEEPERS" ]; then grep -vE "$KEEPERS"; else cat; fi) \
  || true
)

if [ -n "$matches" ]; then
  echo "⚠️  PII candidates found:"
  echo "$matches"
  echo ""
  echo "If a match is a legitimate keeper (false positive), add a regex"
  echo "for its context to $KEEPERS_FILE (that file is committed and"
  echo "public-safe — describe the SHAPE of the safe context, not real names)."
  exit 1
fi

# EXIF GPS check on staged images
if command -v exiftool >/dev/null 2>&1; then
  staged_imgs=$(git diff --cached --name-only --diff-filter=A 2>/dev/null | grep -iE '\.(jpe?g|png|heic|tiff?)$' || true)
  if [ -n "$staged_imgs" ]; then
    while IFS= read -r img; do
      [ -z "$img" ] && continue
      if exiftool -GPS:all "$img" 2>/dev/null | grep -q .; then
        echo "⚠️  EXIF GPS data found in staged image: $img"
        echo "   Strip with: exiftool -GPS:all= -overwrite_original '$img'"
        exit 1
      fi
    done <<< "$staged_imgs"
  fi
fi

exit 0
