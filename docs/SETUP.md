# github-contributions — Setup

> Your GitHub contribution graph.

## Install (one click)

1. Install [Übersicht](https://tracesof.net/uebersicht/) and run it once.
2. Double-click `install.command` (or run `./install.sh` in Terminal).
   It copies `github-contributions.widget` into your Übersicht widgets folder, installs any
   helpers, and walks you through any configuration.

The installer is safe to re-run; it just refreshes the install in place.
To install by hand instead, unzip `github-contributions.widget.zip` into
`~/Library/Application Support/Übersicht/widgets/`.

## Configuration

`install.sh` asks for your **GitHub username** and writes it into the installed
widget. To include private contributions, it can also store a **personal access
token** (classic, `read:user` scope is enough).

You can re-run `install.sh` any time to change either value.

## Fonts

For the intended look, install **Instrument Serif**, **Geist**, and
**Geist Mono**. System fonts are used as a fallback otherwise.
