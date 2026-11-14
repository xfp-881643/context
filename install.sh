#!/usr/bin/env bash
# Install global .agents rules into ~/.agents.
#
#   curl -fsSL https://raw.githubusercontent.com/xfp-881643/context/master/install.sh | bash
#   bash install.sh [options] [target-dir]
#
# Copies home/.agents/ contents into target-dir (default: ~/.agents),
# preserving existing files such as skills/.
set -euo pipefail

REPO="xfp-881643/context"
REF="master"
TARGET="${HOME}/.agents"
SOURCE_DIR=""

die() { printf 'error: %s\n' "$*" >&2; exit 1; }
log() { printf '%s\n' "$*" >&2; }

usage() {
  cat <<USAGE
Usage: install.sh [options] [target-dir]

Copy home/.agents/ into target-dir (default: ~/.agents).
Existing unrelated files (such as skills/) are preserved.

Options:
  -s, --source <dir>  Use a local checkout instead of downloading (must contain home/.agents/).
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
    if [ -d "$candidate/home/.agents" ]; then SOURCE_DIR="$candidate"; fi
  fi
fi

if [ -n "$SOURCE_DIR" ]; then
  [ -d "$SOURCE_DIR/home/.agents" ] || die "$SOURCE_DIR/home/.agents not found"
  PAYLOAD_DIR="$SOURCE_DIR/home/.agents"
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
  for dir in "$WORK_DIR"/*/home/.agents; do
    if [ -f "$dir/rules/context.md" ]; then PAYLOAD_DIR="$dir"; break; fi
  done
  shopt -u nullglob
  [ -n "$PAYLOAD_DIR" ] || die "home/.agents not found in archive of $REPO@$REF"
fi

[ -f "$PAYLOAD_DIR/rules/context.md" ] || die "payload is missing rules/context.md"

STAGING="$(mktemp -d)"
cp -R "$PAYLOAD_DIR" "$STAGING/.agents"

mkdir -p "$TARGET"
TARGET="$(cd "$TARGET" && pwd)"
cp -Rf "$STAGING/.agents/." "$TARGET/"
log "installed into $TARGET"
log "done"
