#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="environment.yml"
ENV_NAME="eebg2026-hyphy"

if command -v mamba >/dev/null 2>&1; then
  SOLVER="mamba"
elif command -v conda >/dev/null 2>&1; then
  SOLVER="conda"
else
  echo "ERROR: conda or mamba is required." >&2
  exit 1
fi

if "$SOLVER" env list | awk '{print $1}' | grep -qx "$ENV_NAME"; then
  echo "Updating existing environment: $ENV_NAME"
  "$SOLVER" env update -n "$ENV_NAME" -f "$ENV_FILE"
else
  echo "Creating environment: $ENV_NAME"
  "$SOLVER" env create -f "$ENV_FILE"
fi

echo
echo "Activate with:"
echo "  conda activate $ENV_NAME"

