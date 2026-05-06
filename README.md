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

## Verify a downloaded binary manually

```bash
# Download archive + checksums + signature for your arch
curl -fsSL -O https://github.com/mirrorpath/latch-public-release/releases/download/<TAG>/latch-<TAG>-<TARGET>.tar.gz
curl -fsSL -O https://github.com/mirrorpath/latch-public-release/releases/download/<TAG>/checksums.txt
curl -fsSL -O https://github.com/mirrorpath/latch-public-release/releases/download/<TAG>/checksums.txt.minisig

# Verify signature (requires the latch minisign pubkey — bundled in the tap)
minisign -Vm checksums.txt -p latch-minisign.pub -x checksums.txt.minisig

# Verify archive integrity
sha256sum --check --ignore-missing checksums.txt
```

## Source

Latch source is private at https://github.com/mirrorpath/latch. The source is not approved for distribution at this stage.
