#!/usr/bin/env bash
set -euo pipefail

RESULTS_DIR="results/session3_branch_lineage"
ABSREL_ALIGNMENT="data/public/tutorial_data/hiv1_transmission.fna"
RELAX_ALIGNMENT="data/public/tutorial_data/hiv1_transmission_labeled.fna"

mkdir -p "$RESULTS_DIR"

if ! command -v hyphy >/dev/null 2>&1; then
  echo "ERROR: hyphy is not on PATH. Activate the conda environment first." >&2
  exit 1
fi

if [[ ! -s "$ABSREL_ALIGNMENT" || ! -s "$RELAX_ALIGNMENT" ]]; then
  echo "ERROR: missing HIV tutorial alignments. Run scripts/01_download_tutorial_data.sh first." >&2
  exit 1
fi

echo "Running aBSREL..."
hyphy absrel \
  --alignment "$ABSREL_ALIGNMENT" \
  --branches All \
  --output "$RESULTS_DIR/hiv1_transmission_absrel.json"

echo "Running RELAX..."
hyphy relax \
  --alignment "$RELAX_ALIGNMENT" \
  --test test \
  --reference reference \
  --output "$RESULTS_DIR/hiv1_transmission_relax.json"

