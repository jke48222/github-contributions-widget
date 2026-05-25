#!/usr/bin/env bash
# Diagnostics ("doctor") for this Übersicht widget. Read-only: it checks setup
# and prints pass/fail per item so you can see exactly why a widget is blank.
#
# Usage:  ./check.sh
set -uo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CFG="$HOME/.config/widgetsuite"
WIDGETS="$HOME/Library/Application Support/Übersicht/widgets"

pass() { printf '  \033[32m✓\033[0m %s\n' "$*"; }
warn() { printf '  \033[33m!\033[0m %s\n' "$*"; }
fail() { printf '  \033[31m✗\033[0m %s\n' "$*"; }

NAME="$(basename "$(/bin/ls -d "$DIR"/*.widget 2>/dev/null | head -1)")"
echo "Checking ${NAME:-widget}"

# --- Common checks -----------------------------------------------------------
if [ -d "$WIDGETS" ]; then pass "Übersicht widgets folder found"
else fail "Übersicht widgets folder missing ($WIDGETS) — install Übersicht"; fi

if [ -n "${NAME:-}" ] && [ -d "$WIDGETS/$NAME" ]; then pass "$NAME is installed"
else warn "$NAME not copied into Übersicht yet — run ./install.sh"; fi

if command -v /usr/bin/python3 >/dev/null 2>&1; then pass "python3 available"
else warn "python3 not found (helper scripts need it)"; fi

# Probe macOS Automation permission for controlling the Music app.
check_music_automation() {
  if ! osascript -e 'application "Music" is running' >/dev/null 2>&1; then
    warn "could not query Music state"; return
  fi
  if [ "$(osascript -e 'application "Music" is running' 2>/dev/null)" = "true" ]; then
    if osascript -e 'tell application "Music" to player state' >/tmp/ws-doc.out 2>/tmp/ws-doc.err; then
      pass "Automation permission for Music is granted"
    else
      fail "Übersicht is blocked from controlling Music — enable it in"
      fail "  System Settings → Privacy & Security → Automation → Übersicht"
    fi
  else
    warn "Music isn't running — open it (and play something) to verify fully"
  fi
}

# --- Widget-specific checks --------------------------------------------------
case "$NAME" in
  daily-ai-prompt.widget)
    [ -x "$CFG/ai-daily-pull-fetch.py" ] || [ -f "$CFG/ai-daily-pull-fetch.py" ] \
      && pass "fetch helper installed" || warn "fetch helper missing — run ./install.sh"
    prov="$(cat "$CFG/ai-provider.txt" 2>/dev/null || echo '')"
    [ -n "$prov" ] && pass "active provider: $prov" || warn "no provider selected (using bundled prompts)"
    found=""
    for k in anthropic.key openai.key gemini.key; do
      [ -s "$CFG/$k" ] && found="$found $k"
    done
    [ -n "$found" ] && pass "API key present:$found" || warn "no API key — widget uses the bundled prompt library"
    if [ -f "$CFG/ai-daily-pull-fetch.py" ] && [ -n "$found" ]; then
      out="$(/usr/bin/python3 "$CFG/ai-daily-pull-fetch.py" 2>/dev/null)"
      case "$out" in
        *'"prompt":'*) pass "helper returned a prompt" ;;
        *) fail "helper ran but returned no prompt — check the key is valid" ;;
      esac
    fi
    ;;
  now-playing.widget)
    check_music_automation
    [ -f "$CFG/musickit-fetch.py" ] && pass "MusicKit helper installed (optional)" \
      || warn "MusicKit helper not installed (optional — used for Apple Music art)"
    ;;
  recent-album-covers.widget)
    check_music_automation
    [ -f "$CFG/spotify.json" ] && pass "Spotify configured" || warn "Spotify not configured (optional)"
    [ -f "$CFG/musickit-fetch.py" ] && pass "MusicKit helper installed (optional)" \
      || warn "MusicKit helper not installed (optional)"
    ;;
  github-contributions.widget)
    u="$(sed -n 's/^const USERS = \["\(.*\)"\];/\1/p' "$WIDGETS/$NAME/index.jsx" 2>/dev/null | head -1)"
    [ -n "$u" ] && pass "GitHub username set: $u" || warn "set your username via ./install.sh"
    ;;
esac

echo "Done."
