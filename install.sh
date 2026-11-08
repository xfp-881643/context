#!/usr/bin/env bash
# Install .context/ and AGENTS.md into a project.
#
#   curl -fsSL https://raw.githubusercontent.com/xfp-881643/context/master/install.sh | bash
#   bash install.sh [options] [target-dir]
#
# Copies template/.context and template/AGENTS.md into the target and does
# nothing when the target already has a .context/ directory.
set -euo pipefail

REPO="xfp-881643/context"
REF="master"
TARGET="."
SOURCE_DIR=""

die() { printf 'error: %s\n' "$*" >&2; exit 1; }
log() { printf '%s\n' "$*" >&2; }

usage() {
  cat <<USAGE
Usage: install.sh [options] [target-dir]

Copy template/.context and template/AGENTS.md into target-dir (default: .).
Does nothing when target-dir/.context already exists.

Options:
  -s, --source <dir>  Use a local checkout instead of downloading (must contain template/).
      --repo <owner/name>  GitHub repository (default: $REPO).
      --ref <ref>          Branch or tag (default: $REF).
  -h, --help               Show this help.

Environment:
  CONTEXT_TARBALL_URL  Full tarball URL override, e.g. a mirror or file:// path.
USAGE
}

while [ $# -gt 0 ]; do
  case "$1" in
    -s|--source)  [ $# -ge 2 ] || die "--source needs a value"; SOURCE_DIR="$2"; shift 2 ;;
    --source=*)   SOURCE_DIR="${1#*=}"; shift ;;
    --repo)       [ $# -ge 2 ] || die "--repo needs a value"; REPO="$2"; shift 2 ;;
    --repo=*)     REPO="${1#*=}"; shift ;;
    --ref)        [ $# -ge 2 ] || die "--ref needs a value"; REF="$2"; shift 2 ;;
    --ref=*)      REF="${1#*=}"; shift ;;
    -h|--help)    usage; exit 0 ;;
    --)           shift; break ;;
    -*)           die "unknown option: $1" ;;
    *)            TARGET="$1"; shift ;;
  esac
done

mkdir -p "$TARGET"
TARGET="$(cd "$TARGET" && pwd)"
CONTEXT_DIR="$TARGET/.context"
AGENTS_FILE="$TARGET/AGENTS.md"

if [ -e "$CONTEXT_DIR" ]; then
  log "skip: $CONTEXT_DIR already exists"
  exit 0
fi

STAGING=""
WORK_DIR=""
cleanup() {
  local status=$?
  if [ -n "$STAGING" ]; then rm -rf -- "$STAGING"; fi
  if [ -n "$WORK_DIR" ]; then rm -rf -- "$WORK_DIR"; fi
  exit "$status"
}
trap cleanup EXIT

# Local checkout: either --source or the directory this script lives in.
if [ -z "$SOURCE_DIR" ]; then
  self="${BASH_SOURCE[0]:-}"
  if [ -n "$self" ] && [ -f "$self" ]; then
    candidate="$(cd "$(dirname "$self")" && pwd)"
    if [ -d "$candidate/template/.context" ]; then SOURCE_DIR="$candidate"; fi
  fi
fi

if [ -n "$SOURCE_DIR" ]; then
  [ -d "$SOURCE_DIR/template/.context" ] || die "$SOURCE_DIR/template/.context not found"
  PAYLOAD_DIR="$SOURCE_DIR/template"
else
  command -v curl >/dev/null 2>&1 || die "curl not found"
  command -v tar >/dev/null 2>&1 || die "tar not found"

  URL="${CONTEXT_TARBALL_URL:-https://github.com/$REPO/archive/$REF.tar.gz}"
  WORK_DIR="$(mktemp -d)"
  log "downloading $URL"
  curl -fsSL "$URL" -o "$WORK_DIR/repo.tar.gz" || die "download failed: $URL"
  tar -xzf "$WORK_DIR/repo.tar.gz" -C "$WORK_DIR" || die "extract failed"

  PAYLOAD_DIR=""
  shopt -s nullglob
  for dir in "$WORK_DIR"/*/template; do
    if [ -f "$dir/.context/RULES.md" ]; then PAYLOAD_DIR="$dir"; break; fi
  done
  shopt -u nullglob
  [ -n "$PAYLOAD_DIR" ] || die "template/.context not found in archive of $REPO@$REF"
fi

[ -f "$PAYLOAD_DIR/.context/RULES.md" ] || die "payload is missing .context/RULES.md"
[ -f "$PAYLOAD_DIR/AGENTS.md" ] || die "payload is missing AGENTS.md"

STAGING="$(mktemp -d "$TARGET/.context-install.XXXXXX")"
cp -R "$PAYLOAD_DIR/.context" "$STAGING/.context"
mv "$STAGING/.context" "$CONTEXT_DIR"
log "created $CONTEXT_DIR"

if [ -e "$AGENTS_FILE" ]; then
  log "keep: $AGENTS_FILE already exists"
else
  cp "$PAYLOAD_DIR/AGENTS.md" "$AGENTS_FILE"
  log "created $AGENTS_FILE"
fi

log "done"
