#!/usr/bin/env bash
#
# build.sh — install dependencies locally and render the IETF draft(s).
#
# Renders every draft-*.md into .xml (via kramdown-rfc) and then .txt + .html
# (via xml2rfc), mirroring what the martinthomson/i-d-template CI does.
#
# All dependencies are isolated inside the repo and require no sudo:
#   .gems/     project-local Ruby gems (kramdown-rfc)
#   .venv/     Python virtualenv (xml2rfc)
#   .refcache/ kramdown-rfc's bibliography cache
# These directories are already in .gitignore.
#
# Usage:
#   ./build.sh                 install deps if needed, then build all drafts
#   ./build.sh draft-x.md      build only the given draft
#   ./build.sh --no-install    build without checking/installing deps
#   ./build.sh --clean         remove installed deps and generated artifacts
#
# Overrides (env): RUBY=/path/to/ruby  KRAMDOWN_RFC_VERSION=1.7.39  XML2RFC_VERSION=3.x
#
set -euo pipefail

cd "$(dirname "$0")"
ROOT="$PWD"
GEM_DIR="$ROOT/.gems"
VENV_DIR="$ROOT/.venv"

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarn:\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

# ---------------------------------------------------------------------------
# argument parsing
# ---------------------------------------------------------------------------
DO_INSTALL=1
TARGETS=()
for arg in "$@"; do
  case "$arg" in
    --no-install) DO_INSTALL=0 ;;
    --clean)
      log "Removing .gems/ .venv/ .refcache/ and generated draft-*.{xml,txt,html}"
      rm -rf "$GEM_DIR" "$VENV_DIR" "$ROOT/.refcache"
      rm -f draft-*.xml draft-*.txt draft-*.html
      exit 0 ;;
    -h|--help) sed -n '2,28p' "$0"; exit 0 ;;
    -*) die "unknown option: $arg" ;;
    *) TARGETS+=("$arg") ;;
  esac
done

# ---------------------------------------------------------------------------
# locate a modern Ruby (kramdown-rfc needs >= 3; macOS system ruby 2.6 is too old)
# ---------------------------------------------------------------------------
ruby_major() { "$1" -e 'print RUBY_VERSION.split(".").first' 2>/dev/null || echo 0; }

find_ruby() {
  local cand
  for cand in "${RUBY:-}" "$(command -v ruby || true)" \
              /opt/homebrew/opt/ruby/bin/ruby /usr/local/opt/ruby/bin/ruby; do
    [ -n "$cand" ] && [ -x "$cand" ] || continue
    [ "$(ruby_major "$cand")" -ge 3 ] 2>/dev/null && { echo "$cand"; return 0; }
  done
  return 1
}

if ! RUBY_BIN="$(find_ruby)"; then
  if command -v brew >/dev/null 2>&1; then
    [ "$DO_INSTALL" -eq 1 ] || die "no Ruby >= 3 found and --no-install given"
    log "Installing Ruby via Homebrew (no system Ruby >= 3 found)"
    brew install ruby
    RUBY_BIN="$(find_ruby)" || die "Ruby install did not yield a usable ruby >= 3"
  else
    die "need Ruby >= 3 (found only $(ruby --version 2>/dev/null)); install via Homebrew or set RUBY=..."
  fi
fi
RUBY_BIN_DIR="$(dirname "$RUBY_BIN")"
GEM_BIN="$RUBY_BIN_DIR/gem"
log "Using Ruby $("$RUBY_BIN" -e 'print RUBY_VERSION') ($RUBY_BIN)"

# kramdown-rfc and xml2rfc run with these set; PATH gets the local gem + ruby bins.
export GEM_HOME="$GEM_DIR" GEM_PATH="$GEM_DIR"
export PATH="$GEM_DIR/bin:$RUBY_BIN_DIR:$PATH"

# ---------------------------------------------------------------------------
# install dependencies (idempotent)
# ---------------------------------------------------------------------------
if [ "$DO_INSTALL" -eq 1 ]; then
  if [ ! -x "$GEM_DIR/bin/kramdown-rfc" ]; then
    log "Installing kramdown-rfc into .gems/"
    "$GEM_BIN" install kramdown-rfc ${KRAMDOWN_RFC_VERSION:+--version "$KRAMDOWN_RFC_VERSION"} \
      --no-document --install-dir "$GEM_DIR"
  else
    log "kramdown-rfc already installed (.gems/)"
  fi

  if [ ! -x "$VENV_DIR/bin/xml2rfc" ]; then
    log "Creating Python venv and installing xml2rfc into .venv/"
    python3 -m venv "$VENV_DIR"
    "$VENV_DIR/bin/pip" install --quiet --upgrade pip
    "$VENV_DIR/bin/pip" install --quiet "xml2rfc${XML2RFC_VERSION:+==$XML2RFC_VERSION}"
  else
    log "xml2rfc already installed (.venv/)"
  fi
fi

KRAMDOWN_RFC="$GEM_DIR/bin/kramdown-rfc"
XML2RFC="$VENV_DIR/bin/xml2rfc"
[ -x "$KRAMDOWN_RFC" ] || die "kramdown-rfc not found; run without --no-install"
[ -x "$XML2RFC" ]      || die "xml2rfc not found; run without --no-install"

# ---------------------------------------------------------------------------
# choose what to build
# ---------------------------------------------------------------------------
if [ "${#TARGETS[@]}" -eq 0 ]; then
  for f in draft-*.md; do
    [ -e "$f" ] || continue
    [ "$f" = "draft-todo-yourname-protocol.md" ] && continue
    TARGETS+=("$f")
  done
fi
[ "${#TARGETS[@]}" -gt 0 ] || die "no draft-*.md files to build"

# ---------------------------------------------------------------------------
# build
# ---------------------------------------------------------------------------
status=0
for md in "${TARGETS[@]}"; do
  [ -f "$md" ] || { warn "skipping missing file: $md"; status=1; continue; }
  base="${md%.md}"
  log "Building $md"
  if ! "$KRAMDOWN_RFC" "$md" > "$base.xml"; then
    warn "kramdown-rfc failed for $md"; rm -f "$base.xml"; status=1; continue
  fi
  if ! "$XML2RFC" "$base.xml" --text --html; then
    warn "xml2rfc failed for $base.xml"; status=1; continue
  fi
  log "Wrote $base.xml, $base.txt, $base.html"
done

[ "$status" -eq 0 ] && log "Done." || warn "Completed with errors."
exit "$status"
