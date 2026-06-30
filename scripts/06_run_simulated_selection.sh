#!/usr/bin/env bash
set -euo pipefail

ALIGNMENT="data/simulated/simulated_codon_blocks.fna"
TREE="data/simulated/simulated_tree.nwk"
RESULTS_DIR="results/session4_simulated"

mkdir -p "$RESULTS_DIR"

if ! command -v hyphy >/dev/null 2>&1; then
  echo "ERROR: hyphy is not on PATH. Activate the conda environment first." >&2
  exit 1
fi

if [[ ! -s "$ALIGNMENT" || ! -s "$TREE" ]]; then
  echo "ERROR: missing bundled simulated data in data/simulated." >&2
  exit 1
fi

echo "Running BUSTED on simulated data..."
hyphy busted \
  --alignment "$ALIGNMENT" \
  --tree "$TREE" \
  --branches All \
  --output "$RESULTS_DIR/simulated_busted.json"

echo "Running FEL on simulated data..."
hyphy fel \
  --alignment "$ALIGNMENT" \
  --tree "$TREE" \
  --branches All \
  --output "$RESULTS_DIR/simulated_fel.json"

echo "Running MEME on simulated data..."
hyphy meme \
  --alignment "$ALIGNMENT" \
  --tree "$TREE" \
  --branches All \
  --output "$RESULTS_DIR/simulated_meme.json"

echo "Running aBSREL on simulated data..."
hyphy absrel \
  --alignment "$ALIGNMENT" \
  --tree "$TREE" \
  --branches All \
  --output "$RESULTS_DIR/simulated_absrel.json"
