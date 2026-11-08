#!/usr/bin/env bash
# Bootstrap .context/ + AGENTS.md into a project, delivered through `bunx skills`.
#
# The skill package (this repository) is installed with the `skills` CLI, then its
# `template/` payload is materialised at the project root. The temporary skill
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

Install the $SKILL_NAME skill with \`bunx skills\` and copy its template payload
(template/.context + template/AGENTS.md) into target-dir (default: .).
Does nothing when target-dir/.context already exists.

Options:
  -s, --source <spec>  skills source (owner/repo, URL, or path).
                       Default: this repository, or \$CONTEXT_SKILL_SOURCE.
  -a, --agent <name>   Agent directory to install to (default: claude-code).
                       Never use '*' here: it installs ~79 agent dirs.
      --keep-skill     Keep the installed skill under \$AGENT/skills.
  -h, --help           Show this help.
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    -s|--source)      [ $# -ge 2 ] || die "--source needs a value"; SOURCE="$2"; shift 2 ;;
    --source=*)       SOURCE="${1#*=}"; shift ;;
    -a|--agent)       [ $# -ge 2 ] || die "--agent needs a value"; AGENT="$2"; shift 2 ;;
    --agent=*)        AGENT="${1#*=}"; shift ;;
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
NEW_DIRS=""
LOCK_PREEXISTED=0
if [ -e "$TARGET/skills-lock.json" ]; then LOCK_PREEXISTED=1; fi

prune_empty_ancestors() {
  local parent
  parent="$(dirname "$1")"
  while [ "$parent" != "$TARGET" ] && [ "${parent#"$TARGET"/}" != "$parent" ]; do
    rmdir "$parent" 2>/dev/null || break
    parent="$(dirname "$parent")"
  done
}

cleanup() {
  local status=$?
  [ -n "$STAGING" ] && rm -rf -- "$STAGING"
  if [ "$KEEP_SKILL" -eq 0 ]; then
    # `bunx skills remove` reports success while leaving the universal copy
    # (`<agent>/skills/<skill>`, `skills/<skill>`) and skills-lock.json behind,
    # so remove exactly the directories this run created.
    if [ -n "$NEW_DIRS" ]; then
      while IFS= read -r dir; do
        [ -n "$dir" ] || continue
        rm -rf -- "$dir"
        prune_empty_ancestors "$dir"
      done <<< "$NEW_DIRS"
    fi
    if [ "$LOCK_PREEXISTED" -eq 0 ] && [ -f "$TARGET/skills-lock.json" ]; then
      rm -f "$TARGET/skills-lock.json"
    fi
  fi
  exit "$status"
}
trap cleanup EXIT

# Directories that already existed; only newly created ones are removed later.
DA_SNAPSHOT="$(find "$TARGET" -type d -name "$SKILL_NAME" 2>/dev/null | sort || true)"

log "installing skill '$SKILL_NAME' from '$SOURCE'"
( cd "$TARGET" && bunx skills add "$SOURCE" --skill "$SKILL_NAME" --agent "$AGENT" --copy -y ) \
  || die "bunx skills add failed"

AFTER_SNAPSHOT="$(find "$TARGET" -type d -name "$SKILL_NAME" 2>/dev/null | sort || true)"
NEW_DIRS="$(comm -13 <(printf '%s\n' "$DA_SNAPSHOT") <(printf '%s\n' "$AFTER_SNAPSHOT"))"

SKILL_DIR=""
shopt -s nullglob dotglob
for candidate in "$TARGET"/*/skills/"$SKILL_NAME"; do
  if [ -d "$candidate/template/.context" ]; then SKILL_DIR="$candidate"; break; fi
done
shopt -u nullglob dotglob
[ -n "$SKILL_DIR" ] || die "installed payload not found (searched <agent>/skills/$SKILL_NAME/template)"

PAYLOAD_DIR="$SKILL_DIR/template"
[ -f "$PAYLOAD_DIR/.context/RULES.md" ] || die "payload is missing template/.context/RULES.md"
[ -f "$PAYLOAD_DIR/AGENTS.md" ] || die "payload is missing template/AGENTS.md"

STAGING="$(mktemp -d "$TARGET/.context-init.XXXXXX")"
cp -R "$PAYLOAD_DIR/.context" "$STAGING/.context"
mv "$STAGING/.context" "$CONTEXT_DIR"
log "created $CONTEXT_DIR"

if [ -e "$AGENTS_FILE" ]; then
  log "keep: $AGENTS_FILE already exists"
else
  cp "$PAYLOAD_DIR/AGENTS.md" "$AGENTS_FILE"
  log "created $AGENTS_FILE"
fi

if [ "$KEEP_SKILL" -eq 0 ] && [ "$LOCK_PREEXISTED" -eq 1 ] && [ -f "$TARGET/skills-lock.json" ]; then
  log "note: $TARGET/skills-lock.json still lists '$SKILL_NAME'; remove it manually if unwanted"
fi

log "done"
