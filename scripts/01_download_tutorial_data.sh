#!/usr/bin/env bash
set -euo pipefail

DATA_DIR="${EMPIRICAL_DATA_DIR:-data/22-empirical}"
REQUIRED_FILES=(
  "HIVvif.nex"
  "HIVvif.masked_nex"
  "lysin.nex"
)

if [[ ! -d "$DATA_DIR" ]]; then
  echo "ERROR: missing empirical data directory: $DATA_DIR" >&2
  exit 1
fi

missing=()
for file in "${REQUIRED_FILES[@]}"; do
  if [[ ! -s "$DATA_DIR/$file" ]]; then
    missing+=("$DATA_DIR/$file")
  fi
done

if (( ${#missing[@]} > 0 )); then
  echo "ERROR: missing required empirical data files:" >&2
  printf '  %s\n' "${missing[@]}" >&2
  exit 1
fi

echo "Empirical data available in $DATA_DIR:"
find "$DATA_DIR" -maxdepth 1 -type f | sort
