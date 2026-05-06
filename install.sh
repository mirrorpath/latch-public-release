#!/bin/bash
# latch installer via Homebrew (private tap, public binaries).
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/mirrorpath/latch-public-release/main/install.sh | bash
#
# Or with a token already set:
#   LATCH_INSTALL_TOKEN=<pat> bash install.sh
#
# The PAT only needs Contents: Read on mirrorpath/homebrew-latch (the tap).
# The binary download itself is public and needs no auth.

set -euo pipefail

TAP="mirrorpath/latch"
TAP_URL="https://github.com/mirrorpath/homebrew-latch.git"

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

prompt_token() {
  if [ -n "${LATCH_INSTALL_TOKEN:-}" ]; then
    return
  fi
  if [ -n "${HOMEBREW_GITHUB_API_TOKEN:-}" ]; then
    LATCH_INSTALL_TOKEN="${HOMEBREW_GITHUB_API_TOKEN}"
    return
  fi

  if [ ! -t 0 ]; then
    cat >&2 <<EOF
Error: stdin is not a TTY (script was piped) and no token was provided.

Re-run with a token in env:
  LATCH_INSTALL_TOKEN=<pat> bash <(curl -fsSL https://raw.githubusercontent.com/mirrorpath/latch-public-release/main/install.sh)

Mint the PAT at https://github.com/settings/personal-access-tokens
  Resource owner: mirrorpath
  Repository access: only mirrorpath/homebrew-latch
  Permissions: Contents = Read-only
EOF
    exit 1
  fi

  printf "Tap PAT (Contents: Read on mirrorpath/homebrew-latch only): " >&2
  IFS= read -rs LATCH_INSTALL_TOKEN
  echo >&2
}

main() {
  require_brew
  prompt_token

  export HOMEBREW_GITHUB_API_TOKEN="${LATCH_INSTALL_TOKEN}"

  if brew tap | grep -qx "${TAP}"; then
    echo "Tap already installed: ${TAP} — refreshing to latest formula."
    brew update --quiet "${TAP}" || brew update --quiet
  else
    brew tap "${TAP}" "${TAP_URL}"
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
  echo "To upgrade later, set HOMEBREW_GITHUB_API_TOKEN before 'brew upgrade latch',"
  echo "or re-run this script."
}

main "$@"
