#!/usr/bin/env bash
set -euo pipefail

RESULTS_DIR="results/session2_branch_lineage"
EMPIRICAL_DATA_DIR="${EMPIRICAL_DATA_DIR:-data/21-empirical}"
ABSREL_ALIGNMENT="$EMPIRICAL_DATA_DIR/HIVvif.nex"

mkdir -p "$RESULTS_DIR"

if ! command -v hyphy >/dev/null 2>&1; then
  echo "ERROR: hyphy is not on PATH. Activate the conda environment first." >&2
  exit 1
fi

if [[ ! -s "$ABSREL_ALIGNMENT" ]]; then
  echo "ERROR: missing $ABSREL_ALIGNMENT. Run scripts/01_download_tutorial_data.sh to verify bundled data." >&2
  exit 1
fi

echo "Running aBSREL..."
hyphy absrel \
  --alignment "$ABSREL_ALIGNMENT" \
  --branches All \
  --output "$RESULTS_DIR/hivvif_absrel.json"
