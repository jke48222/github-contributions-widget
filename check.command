#!/usr/bin/env bash
# Double-clickable diagnostics: runs check.sh and keeps the window open.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bash "$DIR/check.sh"
echo
read -r -p "Press Return to close this window. " _
