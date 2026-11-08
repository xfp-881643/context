#!/usr/bin/env bash
# Bootstrap .context/ + AGENTS.md into a project, delivered through `bunx skills`.
#
# The skill package (this repository) is installed with the `skills` CLI, then its
# payload (.context/ and AGENTS.md) is materialised at the project root. The skill
# install is removed afterwards unless --keep-skill is given.
#
# Usage: scripts/init-context.sh [options] [target-dir]
set -euo pipefail

SKILL_NAME="context-init"
AGENT="claude-code"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE="${CONTEXT_SKILL_SOURCE:-$(dirname "$SCRIPT_DIR")}"
TARGET="."
KEEP_SKILL=0

die() { printf 'error: %s\n' "$*" >&2; exit 1; }
log() { printf '%s\n' "$*" >&2; }

usage() {
  cat <<EOF
Usage: $(basename "$0") [options] [target-dir]

Install the $SKILL_NAME skill with \`bunx skills\` and copy its payload
(.context/ + AGENTS.md) into target-dir (default: .).
Does nothing when target-dir/.context already exists.

Options:
  -s, --source <spec>  skills source (owner/repo, URL, or path).
                       Default: this repository, or \$CONTEXT_SKILL_SOURCE.
      --keep-skill     Keep the installed skill under $AGENT/skills.
  -h, --help           Show this help.
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    -s|--source)      [ $# -ge 2 ] || die "--source needs a value"; SOURCE="$2"; shift 2 ;;
    --source=*)       SOURCE="${1#*=}"; shift ;;
    --keep-skill)     KEEP_SKILL=1; shift ;;
    -h|--help)        usage; exit 0 ;;
    --)               shift; break ;;
    -*)               die "unknown option: $1" ;;
    *)                TARGET="$1"; shift ;;
  esac
done

command -v bunx >/dev/null 2>&1 || die "bunx not found; install Bun first (https://bun.sh)"

mkdir -p "$TARGET"
TARGET="$(cd "$TARGET" && pwd)"
CONTEXT_DIR="$TARGET/.context"
AGENTS_FILE="$TARGET/AGENTS.md"

if [ -e "$CONTEXT_DIR" ]; then
  log "skip: $CONTEXT_DIR already exists"
  exit 0
fi

STAGING=""
cleanup() { [ -n "$STAGING" ] && rm -rf "$STAGING"; }
trap cleanup EXIT

HAD_LOCK=0
[ -e "$TARGET/skills-lock.json" ] && HAD_LOCK=1

log "installing skill '$SKILL_NAME' from '$SOURCE'"
( cd "$TARGET" && bunx skills add "$SOURCE" --skill "$SKILL_NAME" --agent "$AGENT" --copy -y ) \
  || die "bunx skills add failed"

SKILL_DIR=""
for candidate in "$TARGET/.agents/skills/$SKILL_NAME" "$TARGET/.claude/skills/$SKILL_NAME"; do
  if [ -d "$candidate/.context" ]; then SKILL_DIR="$candidate"; break; fi
done
[ -n "$SKILL_DIR" ] || die "installed payload not found (looked for .context under .agents/skills and .claude/skills)"

[ -f "$SKILL_DIR/.context/RULES.md" ] || die "payload is missing .context/RULES.md"

STAGING="$(mktemp -d "$TARGET/.context-init.XXXXXX")"
cp -R "$SKILL_DIR/.context" "$STAGING/.context"
mv "$STAGING/.context" "$CONTEXT_DIR"
log "created $CONTEXT_DIR"

if [ -e "$AGENTS_FILE" ]; then
  log "keep: $AGENTS_FILE already exists"
else
  cp "$SKILL_DIR/AGENTS.md" "$AGENTS_FILE"
  log "created $AGENTS_FILE"
fi

if [ "$KEEP_SKILL" -eq 0 ]; then
  ( cd "$TARGET" && bunx skills remove "$SKILL_NAME" --agent "$AGENT" -y >/dev/null )
  rmdir "$TARGET/.claude/skills" "$TARGET/.claude" "$TARGET/.agents/skills" "$TARGET/.agents" 2>/dev/null || true
  if [ "$HAD_LOCK" -eq 0 ] && [ -f "$TARGET/skills-lock.json" ] \
     && grep -qE '"skills"[[:space:]]*:[[:space:]]*\{\}' "$TARGET/skills-lock.json"; then
    rm -f "$TARGET/skills-lock.json"
  fi
fi

log "done"
