#!/bin/bash
# latch installer via Homebrew (public tap, public binaries — no auth needed).
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/mirrorpath/latch-public-release/main/install.sh | bash

set -euo pipefail

TAP="mirrorpath/latch"

require_brew() {
  if ! command -v brew >/dev/null 2>&1; then
    cat >&2 <<EOF
Error: Homebrew is not installed.

Install brew first:
  /bin/bash -c "\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

Then re-run this script.
EOF
    exit 1
  fi
}

main() {
  require_brew

  if brew tap | grep -qx "${TAP}"; then
    echo "Tap already installed: ${TAP} — refreshing to latest formula."
    brew update --quiet "${TAP}" || brew update --quiet
  else
    brew tap "${TAP}"
  fi

  # Use `reinstall` instead of `install` so a stale or pinned local install
  # (e.g. installed before a release reset) gets replaced with whatever the
  # refreshed tap currently points at, even if SemVer would call it a
  # "downgrade" (which `brew upgrade` refuses).
  if brew list latch >/dev/null 2>&1; then
    brew reinstall latch
  else
    brew install latch
  fi

  echo
  echo "Installed: $(brew --prefix)/bin/latch"
  echo
  echo "To upgrade later:  brew update && brew upgrade latch"
  echo "Or re-run this script."
}

main "$@"
