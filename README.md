# latch-public-release

Public binary release host for [`latch`](https://github.com/mirrorpath/latch). The latch source is private and is not distributed via this repository or any other public channel.

This repo exists so users can `brew install latch` (or `curl | bash`) without needing PAT-gated access to the binaries themselves. The Homebrew tap that consumes these releases is at `mirrorpath/homebrew-latch` (still private — gates discovery and upgrades).

## Install

### One-liner

```bash
curl -fsSL https://raw.githubusercontent.com/mirrorpath/latch-public-release/main/install.sh | bash
```

The script prompts for a tap PAT (one-time), taps `mirrorpath/latch`, and runs `brew install latch`.

### Manual

```bash
# Mint a fine-grained PAT at https://github.com/settings/personal-access-tokens
#   Resource owner: mirrorpath
#   Repository access: only mirrorpath/homebrew-latch
#   Permissions: Contents = Read-only
export HOMEBREW_GITHUB_API_TOKEN=<PAT>

brew tap mirrorpath/latch https://github.com/mirrorpath/homebrew-latch.git
brew install latch
```

The tap clone needs the PAT (tap repo is private). The binary download pulls from this public release repo and needs no auth.

## Trust posture

The formula bundles the project's minisign public key. At install time, `def install` runs:

```
minisign -Vm checksums.txt -p latch-minisign.pub -x checksums.txt.minisig
```

Install aborts on verification failure. The trust anchor is the bundled pubkey — anyone can download the binary, but only the holder of the matching private key can sign a release the formula will accept.

## Manual install (no brew required)

For users who can't or don't want to use Homebrew:

```bash
# Pick the version and your target triple.
TAG="v0.1.0-preview.1"
TARGET="aarch64-apple-darwin"   # or x86_64-apple-darwin / aarch64-unknown-linux-gnu / x86_64-unknown-linux-gnu

# Download the archive + signed manifest.
curl -fsSL -O "https://github.com/mirrorpath/latch-public-release/releases/download/${TAG}/latch-${TAG}-${TARGET}.tar.gz"
curl -fsSL -O "https://github.com/mirrorpath/latch-public-release/releases/download/${TAG}/checksums.txt"
curl -fsSL -O "https://github.com/mirrorpath/latch-public-release/releases/download/${TAG}/checksums.txt.minisig"

# Get the trust public key (bundled in the private tap; you'll need read access there
# OR ask whoever shared latch with you to send you the key out of band).
# If you have brew tap access:
#   curl -fsSL -O "https://raw.githubusercontent.com/mirrorpath/homebrew-latch/main/Formula/latch-minisign.pub"

# Verify signature on the manifest.
minisign -Vm checksums.txt -p latch-minisign.pub -x checksums.txt.minisig

# Verify archive integrity matches the manifest.
sha256sum --check --ignore-missing checksums.txt

# Extract and install.
tar -xzf "latch-${TAG}-${TARGET}.tar.gz"
mkdir -p "${HOME}/.local/bin"
install -m 0755 "latch-${TAG}-${TARGET}/latch" "${HOME}/.local/bin/latch"

# Make sure ${HOME}/.local/bin is on PATH.
latch --version
```

This covers the platforms Homebrew doesn't reach (e.g., minimal Linux containers, distros without brew). The trust posture is identical to the brew install path — same minisign signature, same trust anchor.

## Source

Latch source is private at https://github.com/mirrorpath/latch. The source is not approved for distribution at this stage.
