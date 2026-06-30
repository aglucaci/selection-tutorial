#!/usr/bin/env bash
set -euo pipefail

EMPIRICAL_DATA_DIR="${EMPIRICAL_DATA_DIR:-data/22-empirical}"
ALIGNMENT="$EMPIRICAL_DATA_DIR/HIVvif.nex"
RESULTS_DIR="results/session1_gene_wide"

mkdir -p "$RESULTS_DIR"

if ! command -v hyphy >/dev/null 2>&1; then
  echo "ERROR: hyphy is not on PATH. Activate the conda environment first." >&2
  exit 1
fi

if [[ ! -s "$ALIGNMENT" ]]; then
  echo "ERROR: missing $ALIGNMENT. Run scripts/01_download_tutorial_data.sh to verify bundled data." >&2
  exit 1
fi

echo "Running standard BUSTED..."
hyphy busted \
  --alignment "$ALIGNMENT" \
  --branches All \
  --output "$RESULTS_DIR/hivvif_busted_standard.json"

echo "Running BUSTED with synonymous-rate variation..."
hyphy busted \
  --alignment "$ALIGNMENT" \
  --branches All \
  --srv Yes \
  --syn-rates 3 \
  --output "$RESULTS_DIR/hivvif_busted_srv.json"

echo "Running BUSTED with multiple-hit model..."
hyphy busted \
  --alignment "$ALIGNMENT" \
  --branches All \
  --multiple-hits Double+Triple \
  --output "$RESULTS_DIR/hivvif_busted_multihit.json"
