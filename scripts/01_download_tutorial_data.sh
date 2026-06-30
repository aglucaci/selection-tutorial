#!/usr/bin/env bash
set -euo pipefail

DATA_DIR="data/public/tutorial_data"
TMP_DIR="$(mktemp -d)"
ZIP_URL="https://www.hyphy.org/resources/tutorials/hyphy-cmd-tutorial.zip"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

mkdir -p "$DATA_DIR"

if [[ -s "$DATA_DIR/ksr2.fna" && -s "$DATA_DIR/lysin.fna" ]]; then
  echo "Tutorial data already present in $DATA_DIR"
  exit 0
fi

echo "Downloading HyPhy tutorial data..."
if command -v curl >/dev/null 2>&1; then
  curl -L "$ZIP_URL" -o "$TMP_DIR/hyphy-cmd-tutorial.zip"
elif command -v wget >/dev/null 2>&1; then
  wget -O "$TMP_DIR/hyphy-cmd-tutorial.zip" "$ZIP_URL"
else
  echo "ERROR: curl or wget is required to download tutorial data." >&2
  exit 1
fi

unzip -q "$TMP_DIR/hyphy-cmd-tutorial.zip" -d "$TMP_DIR/unzipped"

find "$TMP_DIR/unzipped" -type f \( -name '*.fna' -o -name '*.nex' -o -name '*.nwk' -o -name '*.tree' -o -name '*.fas' \) -exec cp {} "$DATA_DIR/" \;

echo "Downloaded files:"
find "$DATA_DIR" -maxdepth 1 -type f | sort

