#!/usr/bin/env bash
set -euo pipefail

if [[ -n "${COLAB_RELEASE_TAG:-}" ]]; then
  echo "Detected Google Colab runtime."
else
  echo "This script is intended for Google Colab, but it can also run on Ubuntu-like systems."
fi

APT_GET="apt-get"
if ! command -v "$APT_GET" >/dev/null 2>&1; then
  echo "ERROR: apt-get is required for the Colab setup path." >&2
  exit 1
fi

if command -v sudo >/dev/null 2>&1; then
  APT_PREFIX=(sudo)
else
  APT_PREFIX=()
fi

echo "Installing HyPhy and command-line helpers with apt..."
"${APT_PREFIX[@]}" "$APT_GET" update
"${APT_PREFIX[@]}" "$APT_GET" install -y hyphy unzip curl

echo "Installing Python packages with pip..."
python -m pip install -q --upgrade pip
python -m pip install -q pandas matplotlib seaborn biopython pyvolve pyyaml

echo
echo "Versions:"
python --version
hyphy --version || true
echo
echo "Colab setup complete."

