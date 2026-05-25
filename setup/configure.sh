#!/usr/bin/env bash
# Interactive setup for GitHub Contributions. Invoked by install.sh.
# Sets the GitHub username (and optional token for private contributions) by
# patching the installed widget's index.jsx. Idempotent: re-running just
# rewrites the two config lines.
set -euo pipefail
W="${WIDGET_INSTALL_DIR:-}"
if [ -z "$W" ] || [ ! -f "$W/index.jsx" ]; then
  echo "    Could not find the installed widget. Edit USERS/TOKEN at the top of"
  echo "    index.jsx to set your GitHub username."
  exit 0
fi

current="$(sed -n 's/^const USERS = \["\(.*\)"\];/\1/p' "$W/index.jsx" | head -1)"
printf "Your GitHub username (Ex: jke48222): "; read -r u
u="${u:-$current}"
if [ -n "$u" ]; then
  sed -i '' "s|^const USERS = \[.*\];|const USERS = [\"$u\"];|" "$W/index.jsx"
  echo "    Set USERS to [\"$u\"]."
fi

printf "Add a GitHub token to include private contributions? [y/N] "; read -r t
case "$t" in
  y|Y)
    printf "Token (input hidden): "; read -rs tok; echo
    if [ -n "$tok" ]; then
      sed -i '' "s|^const TOKEN = .*;|const TOKEN = \"$tok\";|" "$W/index.jsx"
      echo "    Token set."
    fi ;;
esac
