#!/usr/bin/env bash
set -euo pipefail

DATA_DIR="${EMPIRICAL_DATA_DIR:-data/22-empirical}"
SIMULATED_DATA_DIR="${SIMULATED_DATA_DIR:-data/simulated}"
REQUIRED_FILES=(
  "empirical_alignment_metrics.csv"
  "HIVvif.nex"
  "HIVvif.masked_nex"
  "lysin.nex"
)
REQUIRED_SIMULATED_FILES=(
  "simulated_codon_blocks.fna"
  "simulated_codon_blocks_labeled.fna"
  "simulated_tree.nwk"
  "simulated_truth.json"
)

if [[ ! -d "$DATA_DIR" ]]; then
  echo "ERROR: missing empirical data directory: $DATA_DIR" >&2
  exit 1
fi

if [[ ! -d "$SIMULATED_DATA_DIR" ]]; then
  echo "ERROR: missing simulated data directory: $SIMULATED_DATA_DIR" >&2
  exit 1
fi

missing=()
for file in "${REQUIRED_FILES[@]}"; do
  if [[ ! -s "$DATA_DIR/$file" ]]; then
    missing+=("$DATA_DIR/$file")
  fi
done
for file in "${REQUIRED_SIMULATED_FILES[@]}"; do
  if [[ ! -s "$SIMULATED_DATA_DIR/$file" ]]; then
    missing+=("$SIMULATED_DATA_DIR/$file")
  fi
done

if (( ${#missing[@]} > 0 )); then
  echo "ERROR: missing required data files:" >&2
  printf '  %s\n' "${missing[@]}" >&2
  exit 1
fi

echo "Empirical data available in $DATA_DIR:"
find "$DATA_DIR" -maxdepth 1 -type f | sort
echo
echo "Simulated data available in $SIMULATED_DATA_DIR:"
find "$SIMULATED_DATA_DIR" -maxdepth 1 -type f | sort
