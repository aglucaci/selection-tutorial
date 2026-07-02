#!/usr/bin/env bash
set -euo pipefail

EMPIRICAL_DATA_DIR="${EMPIRICAL_DATA_DIR:-data/21-empirical}"
ALIGNMENT="$EMPIRICAL_DATA_DIR/lysin.nex"
RESULTS_DIR="results/session3_site_level"

mkdir -p "$RESULTS_DIR"

if ! command -v hyphy >/dev/null 2>&1; then
  echo "ERROR: hyphy is not on PATH. Activate the conda environment first." >&2
  exit 1
fi

if [[ ! -s "$ALIGNMENT" ]]; then
  echo "ERROR: missing $ALIGNMENT. Run scripts/01_download_tutorial_data.sh to verify bundled data." >&2
  exit 1
fi

echo "Running FEL..."
hyphy fel \
  --alignment "$ALIGNMENT" \
  --branches All \
  --srv Yes \
  --output "$RESULTS_DIR/lysin_fel.json"

echo "Running MEME..."
hyphy meme \
  --alignment "$ALIGNMENT" \
  --branches All \
  --output "$RESULTS_DIR/lysin_meme.json"

echo "Running SLAC..."
hyphy slac \
  --alignment "$ALIGNMENT" \
  --branches All \
  --output "$RESULTS_DIR/lysin_slac.json"
