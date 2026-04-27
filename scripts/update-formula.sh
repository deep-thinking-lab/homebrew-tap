#!/usr/bin/env bash
# update-formula.sh — Automate Homebrew formula updates for new releases
#
# Usage:
#   ./scripts/update-formula.sh v0.1.0
#
# This downloads all release binaries from GitHub, computes SHA256 hashes,
# and updates Formula/ninmu.rb with the new version and checksums.
#
# Requires: curl, shasum, and write access to the repo.

set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <tag>"
  echo "Example: $0 v0.1.0"
  exit 1
fi

TAG="$1"
REPO="deep-thinking-llc/claw-code"
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
FORMULA="$SCRIPT_DIR/Formula/ninmu.rb"
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

declare -A ARTIFACTS
ARTIFACTS["ARM64_SHA256"]="ninmu-macos-arm64"
ARTIFACTS["X64_SHA256"]="ninmu-macos-x64"
ARTIFACTS["LINUX_ARM64_SHA256"]="ninmu-linux-arm64"
ARTIFACTS["LINUX_X64_SHA256"]="ninmu-linux-x64"

echo "Downloading release assets for ${TAG}..."
for placeholder in "${!ARTIFACTS[@]}"; do
  filename="${ARTIFACTS[$placeholder]}"
  url="https://github.com/${REPO}/releases/download/${TAG}/${filename}"
  echo "  Fetching ${filename}..."
  curl -sfL "$url" -o "$TMPDIR/$filename" || {
    echo "  Warning: could not download ${filename} (not built yet?)"
    ARTIFACTS[$placeholder]=""
    continue
  }
  hash="$(shasum -a 256 "$TMPDIR/$filename" | awk '{print $1}')"
  ARTIFACTS[$placeholder]="$hash"
  echo "  SHA256: ${hash}"
done

echo ""
echo "Updating formula..."
sed -i '' "s/version \"[^\"]*\"/version \"${TAG#v}\"/" "$FORMULA"
sed -i '' "s|releases/download/v[^\"]*|releases/download/${TAG}|" "$FORMULA"

for placeholder in "${!ARTIFACTS[@]}"; do
  hash="${ARTIFACTS[$placeholder]}"
  if [ -n "$hash" ]; then
    sed -i '' "s/sha256 \"${placeholder}\"/sha256 \"${hash}\"/" "$FORMULA"
    sed -i '' "s/sha256 \"[a-f0-9]\{64\}\"/sha256 \"${hash}\"/" "$FORMULA"
  fi
done

echo "Done! Formula updated to ${TAG}"
echo "Review changes:"
git -C "$SCRIPT_DIR" diff Formula/ninmu.rb
echo ""
echo "To commit:"
echo "  cd ${SCRIPT_DIR} && git add Formula/ninmu.rb && git commit -m \"chore: update formula to ${TAG}\" && git push"
