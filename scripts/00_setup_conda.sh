#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="environment.yml"
ENV_NAME="eebg2026-hyphy"

platform_name() {
  local kernel
  kernel="$(uname -s 2>/dev/null || printf unknown)"
  case "$kernel" in
    Darwin)
      printf "macOS"
      ;;
    Linux)
      if grep -qi microsoft /proc/version 2>/dev/null; then
        printf "Windows WSL Ubuntu/Linux"
      else
        printf "Linux"
      fi
      ;;
    MINGW*|MSYS*|CYGWIN*)
      printf "Windows shell"
      ;;
    *)
      printf "%s" "$kernel"
      ;;
  esac
}

print_conda_install_help() {
  local platform
  platform="$(platform_name)"
  cat >&2 <<EOF
ERROR: conda or mamba is required, but neither command was found.

Detected platform: $platform

Recommended setup:
  1. Install Miniforge: https://conda-forge.org/download/
  2. Close and reopen the terminal.
  3. Confirm Conda works:
       conda --version
  4. Re-run:
       bash scripts/00_setup_conda.sh

Platform notes:
  macOS:
    Download the macOS Miniforge installer for your chip type (Apple Silicon arm64 or Intel x86_64).

  Linux:
    Download the Linux Miniforge installer, run it with bash, then restart your shell.

  Windows:
    Use Windows Subsystem for Linux (WSL) with Ubuntu for this workshop. Open the Ubuntu
    terminal, install Miniforge inside Ubuntu, then run this script from the repository.

If 'conda activate' later fails, run:
  conda init
then close and reopen the terminal.
EOF
}

if [[ ! -s "$ENV_FILE" ]]; then
  echo "ERROR: missing $ENV_FILE. Run this script from the repository root." >&2
  exit 1
fi

if command -v mamba >/dev/null 2>&1; then
  SOLVER="mamba"
elif command -v conda >/dev/null 2>&1; then
  SOLVER="conda"
else
  print_conda_install_help
  exit 1
fi

echo "Detected platform: $(platform_name)"
echo "Using solver: $SOLVER"

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
echo
echo "Verify with:"
echo "  hyphy --version"

if "$SOLVER" run -n "$ENV_NAME" hyphy --version >/dev/null 2>&1; then
  echo
  echo "HyPhy verification succeeded inside $ENV_NAME."
else
  echo
  echo "WARNING: Environment setup finished, but HyPhy could not be verified with '$SOLVER run'." >&2
  echo "After activating the environment, run: hyphy --version" >&2
fi
